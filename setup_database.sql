-- Create tables for the Radiology Triage System
-- Run this in your external PostgreSQL database

-- Table for storing AI triage results
CREATE TABLE IF NOT EXISTS study_triage_ai (
    id BIGSERIAL PRIMARY KEY,
    study_id VARCHAR(64),
    triage_level VARCHAR(16),
    triage_score DECIMAL(5,2),
    ai_explanation VARCHAR(2000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for imaging studies
CREATE TABLE IF NOT EXISTS imaging_studies (
    study_id           VARCHAR(64)   PRIMARY KEY,
    patient_id         VARCHAR(64),
    modality           VARCHAR(16),      -- CT, MRI, XR, US, etc.
    body_part          VARCHAR(64),      -- Chest, Abdomen, Brain, etc.
    indication         VARCHAR(256),     -- "suspicion of PE", "chronic cough", etc.
    report_text        VARCHAR(4000),    -- informe o resumen textual
    findings_summary   VARCHAR(1000),    -- versión corta para RAG
    exam_datetime      TIMESTAMP,
    site               VARCHAR(64),      -- hospital / clínica
    sla_seconds        INT,              -- objetivo interno de atención
    current_status     VARCHAR(32),      -- NEW, REPORTED, IN_REVIEW
    priority_flag      VARCHAR(16)       -- NULL, HIGH, MEDIUM, LOW (a llenar por la IA)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_studies_status ON imaging_studies(current_status);
CREATE INDEX IF NOT EXISTS idx_studies_modality ON imaging_studies(modality);
CREATE INDEX IF NOT EXISTS idx_studies_datetime ON imaging_studies(exam_datetime);
CREATE INDEX IF NOT EXISTS idx_triage_study_id ON study_triage_ai(study_id);