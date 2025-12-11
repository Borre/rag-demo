from flask import Flask, render_template, request, jsonify
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime
import openai
import json
from dotenv import load_dotenv
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

load_dotenv()

app = Flask(__name__)

# Database configuration
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'postgres')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'postgres')

# DeepSeek API configuration
DEEPSEEK_API_KEY = os.getenv('DEEPSEEK_API_KEY')
DEEPSEEK_BASE_URL = os.getenv('DEEPSEEK_BASE_URL', 'https://api.deepseek.com')

# Initialize OpenAI client for DeepSeek
client = None
if DEEPSEEK_API_KEY:
    try:
        client = openai.OpenAI(
            api_key=DEEPSEEK_API_KEY,
            base_url=DEEPSEEK_BASE_URL
        )
    except Exception as e:
        print(f"Failed to initialize DeepSeek client: {e}")
else:
    print("Warning: DEEPSEEK_API_KEY not configured")

def get_db_connection():
    """Create database connection"""
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        client_encoding='utf8',
        options='-c client_encoding=utf8'
    )
    return conn

def find_similar_cases(current_findings, limit=5):
    """Find similar cases based on findings summary"""
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    # Get all existing studies
    cursor.execute("""
        SELECT study_id, findings_summary, report_text,
               modality, body_part, indication, priority_flag,
               exam_datetime, current_status
        FROM imaging_studies
        WHERE findings_summary IS NOT NULL AND findings_summary != ''
        ORDER BY exam_datetime DESC
    """)

    all_studies = cursor.fetchall()
    cursor.close()
    conn.close()

    if not all_studies:
        return []

    # Create TF-IDF vectors for similarity matching
    documents = [study['findings_summary'] for study in all_studies]
    documents.append(current_findings)  # Add current study as last document

    vectorizer = TfidfVectorizer(stop_words='english', ngram_range=(1, 2))
    tfidf_matrix = vectorizer.fit_transform(documents)

    # Calculate similarity between current study and all others
    current_vector = tfidf_matrix[-1]  # Last document is current study
    similarities = cosine_similarity(current_vector, tfidf_matrix[:-1]).flatten()

    # Get top similar cases
    top_indices = np.argsort(similarities)[::-1][:limit]
    similar_cases = []

    for idx in top_indices:
        if similarities[idx] > 0.1:  # Threshold for similarity
            study = all_studies[idx]
            study['similarity_score'] = float(similarities[idx])
            similar_cases.append(study)

    return similar_cases

def get_triage_recommendation(current_study, similar_cases):
    """Get AI triage recommendation from DeepSeek"""

    # Check if client is available
    if not client:
        return {
            "triage_level": "MEDIUM",
            "triage_score": 0.5,
            "explanation": "DeepSeek API client not initialized. Please check API configuration."
        }

    # Prepare context for AI
    context = f"""
CURRENT STUDY:
- Study ID: {current_study['study_id']}
- Modality: {current_study['modality']}
- Body Part: {current_study['body_part']}
- Indication: {current_study['indication']}
- Findings: {current_study['findings_summary']}
- Current Status: {current_study['current_status']}
- Exam Time: {current_study['exam_datetime']}

SIMILAR PAST CASES:
"""

    for i, case in enumerate(similar_cases, 1):
        context += f"""
Case {i}:
- Study ID: {case['study_id']}
- Modality: {case['modality']}
- Body Part: {case['body_part']}
- Indication: {case['indication']}
- Findings: {case['findings_summary']}
- Previous Priority: {case['priority_flag'] or 'Not set'}
- Similarity Score: {case['similarity_score']:.2f}
"""

    prompt = f"""{context}

You are an AI assistant helping a radiology operations team to PRIORITIZE imaging studies, not to make final diagnoses.

Your task:
- Read the current study information and a list of similar past cases.
- Propose a triage level: HIGH, MEDIUM, or LOW.
- Justify the triage level in operational terms (risk, symptoms, time-sensitivity).
- Do NOT overstep into giving definitive diagnoses; focus on urgency of review.
- Output in JSON with keys: triage_level, triage_score, explanation.

Response format:
{{
  "triage_level": "HIGH|MEDIUM|LOW",
  "triage_score": 0.0-1.0,
  "explanation": "Operational justification focusing on urgency and workflow considerations"
}}"""

    try:
        response = client.chat.completions.create(
            model="deepseek-chat",
            messages=[
                {"role": "system", "content": "You are a radiology operations AI assistant focused on study prioritization."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
            max_tokens=500
        )

        result = response.choices[0].message.content.strip()

        # Try to parse as JSON, if fails return default
        try:
            return json.loads(result)
        except:
            return {
                "triage_level": "MEDIUM",
                "triage_score": 0.5,
                "explanation": "Unable to parse AI response. Defaulting to medium priority."
            }

    except Exception as e:
        print(f"Error calling DeepSeek API: {e}")
        return {
            "triage_level": "MEDIUM",
            "triage_score": 0.5,
            "explanation": f"API Error: {str(e)}. Defaulting to medium priority."
        }

@app.route('/')
def index():
    """Main page with studies list"""
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    # Get all studies
    cursor.execute("""
        SELECT study_id, patient_id, modality, body_part, indication,
               findings_summary, exam_datetime, site, current_status, priority_flag
        FROM imaging_studies
        ORDER BY exam_datetime DESC
    """)

    studies = cursor.fetchall()
    cursor.close()
    conn.close()

    return render_template('index.html', studies=studies)

@app.route('/study/<study_id>')
def study_detail(study_id):
    """Study detail page"""
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    # Get current study
    cursor.execute("""
        SELECT * FROM imaging_studies
        WHERE study_id = %s
    """, (study_id,))

    current_study = cursor.fetchone()

    if not current_study:
        cursor.close()
        conn.close()
        return "Study not found", 404

    # Check if already triaged
    cursor.execute("""
        SELECT * FROM study_triage_ai
        WHERE study_id = %s
        ORDER BY created_at DESC
        LIMIT 1
    """, (study_id,))

    existing_triage = cursor.fetchone()

    cursor.close()
    conn.close()

    # Find similar cases
    similar_cases = find_similar_cases(current_study['findings_summary'] or '')

    return render_template('study_detail.html',
                         study=current_study,
                         similar_cases=similar_cases,
                         existing_triage=existing_triage)

@app.route('/triage/<study_id>', methods=['POST'])
def triage_study(study_id):
    """Perform AI triage on study"""
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    # Get current study
    cursor.execute("""
        SELECT * FROM imaging_studies
        WHERE study_id = %s
    """, (study_id,))

    current_study = cursor.fetchone()

    if not current_study:
        cursor.close()
        conn.close()
        return jsonify({"error": "Study not found"}), 404

    # Find similar cases
    similar_cases = find_similar_cases(current_study['findings_summary'] or '')

    # Get AI triage recommendation
    triage_result = get_triage_recommendation(current_study, similar_cases)

    # Save triage result to database
    cursor.execute("""
        INSERT INTO study_triage_ai
        (study_id, triage_level, triage_score, ai_explanation, created_at)
        VALUES (%s, %s, %s, %s, %s)
    """, (
        study_id,
        triage_result['triage_level'],
        triage_result['triage_score'],
        triage_result['explanation'],
        datetime.now()
    ))

    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({
        "success": True,
        "triage": triage_result,
        "similar_cases_count": len(similar_cases)
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)