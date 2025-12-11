CREATE TABLE study_triage_ai (
    id BIGSERIAL PRIMARY KEY,
    study_id VARCHAR(64),
    triage_level VARCHAR(16),
    triage_score DECIMAL(5,2),
    ai_explanation VARCHAR(2000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE imaging_studies (
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


INSERT INTO imaging_studies (
  study_id, patient_id, modality, body_part, indication, report_text,
  findings_summary, exam_datetime, site, sla_seconds, current_status, priority_flag
) VALUES
-- 21–70
('STUDY021','P021','XR','Chest','Fever, cough, COVID rule-out',
 'Patchy opacities in lower lobes.',
 'Lower lobe patchy opacities', '2025-02-10 11:40:00','Hospital Norte',3600,'NEW',NULL),

('STUDY022','P022','CT','Chest','Follow-up for PE',
 'No new filling defects; previous PE improving.',
 'Improving pulmonary embolism', '2025-02-10 11:45:00','Hospital Norte',7200,'NEW',NULL),

('STUDY023','P023','MRI','Brain','Syncope episode',
 'No acute stroke; mild periventricular changes.',
 'No acute findings; chronic changes', '2025-02-10 11:50:00','Clínica Los Andes',3600,'NEW',NULL),

('STUDY024','P024','CT','Abdomen','Vomiting, RUQ pain',
 'Gallbladder distention with multiple stones.',
 'Cholelithiasis; possible cholecystitis', '2025-02-10 12:00:00','Hospital Sur',1800,'NEW',NULL),

('STUDY025','P025','XR','Chest','Shortness of breath in elderly patient',
 'Mild cardiomegaly; vascular congestion.',
 'Cardiomegaly + congestion', '2025-02-10 12:05:00','Hospital Norte',1800,'NEW',NULL),

('STUDY026','P026','MRI','Knee','Chronic knee pain',
 'Meniscal degeneration; no acute tear.',
 'Degenerative meniscal changes', '2025-02-10 12:10:00','Clínica Central',7200,'NEW',NULL),

('STUDY027','P027','CT','Chest','Post-COVID persistent dyspnea',
 'Peripheral GGO distribution.',
 'Post-COVID ground-glass opacities', '2025-02-10 12:12:00','Hospital Norte',7200,'NEW',NULL),

('STUDY028','P028','MRI','Spine','Cervical radiculopathy',
 'C5-C6 foraminal stenosis.',
 'C5-C6 stenosis with nerve impingement', '2025-02-10 12:20:00','Clínica Central',7200,'NEW',NULL),

('STUDY029','P029','CT','Brain','Trauma after bicycle accident',
 'Small left frontal contusion.',
 'Frontal contusion; mild traumatic injury', '2025-02-10 12:30:00','Hospital Trauma',1200,'NEW',NULL),

('STUDY030','P030','XR','Chest','Chest pain',
 'Clear lungs; no acute findings.',
 'Normal chest radiograph', '2025-02-10 12:40:00','Hospital Norte',14400,'NEW',NULL),

('STUDY031','P031','CT','Abdomen','Suspected kidney stone',
 '3 mm calculus in right ureter.',
 'Small ureteral calculus', '2025-02-10 12:45:00','Hospital Sur',3600,'NEW',NULL),

('STUDY032','P032','MRI','Brain','Memory impairment',
 'Mild hippocampal atrophy.',
 'Hippocampal volume loss', '2025-02-10 12:50:00','Clínica Los Andes',7200,'NEW',NULL),

('STUDY033','P033','XR','Chest','Dyspnea with leg swelling',
 'Pulmonary vascular congestion.',
 'Heart failure-related congestion', '2025-02-10 12:55:00','Hospital Norte',1800,'NEW',NULL),

('STUDY034','P034','CT','Chest','Hemoptysis',
 'Cavitating lesion in upper lobe.',
 'Suspicious cavitary lesion', '2025-02-10 13:00:00','Clínica Los Andes',1800,'NEW',NULL),

('STUDY035','P035','CT','Chest','Pre-op evaluation',
 'No acute findings.',
 'Normal CT chest (pre-op)', '2025-02-10 13:10:00','Hospital Norte',7200,'NEW',NULL),

('STUDY036','P036','MRI','Abdomen','Chronic liver disease',
 'Nodular liver contour; portal hypertension.',
 'Cirrhosis pattern', '2025-02-10 13:20:00','Clínica Central',7200,'NEW',NULL),

('STUDY037','P037','CT','Abdomen','Pelvic pain',
 'Ovarian cyst 4 cm.',
 'Simple ovarian cyst', '2025-02-10 13:25:00','Hospital Sur',7200,'NEW',NULL),

('STUDY038','P038','XR','Chest','Fever in child',
 'Right middle lobe opacity.',
 'Possible pediatric pneumonia', '2025-02-10 13:30:00','Hospital Norte',3600,'NEW',NULL),

('STUDY039','P039','CT','Chest','Chronic smoker, screening',
 '1.5 cm spiculated nodule.',
 'Suspicious pulmonary nodule', '2025-02-10 13:40:00','Clínica Los Andes',3600,'NEW',NULL),

('STUDY040','P040','MRI','Brain','Migraine evaluation',
 'No acute abnormality.',
 'Normal MRI brain', '2025-02-10 13:45:00','Clínica Los Andes',7200,'NEW',NULL),

('STUDY041','P041','CT','Spine','Back trauma lifting object',
 'Mild L2-L3 disc bulge.',
 'L2-L3 disc bulge', '2025-02-10 13:50:00','Hospital Trauma',7200,'NEW',NULL),

('STUDY042','P042','CT','Chest','Acute hypoxia',
 'Diffuse bilateral opacities + air bronchograms.',
 'Severe pneumonia pattern', '2025-02-10 14:00:00','Hospital Norte',1200,'NEW',NULL),

('STUDY043','P043','MRI','Spine','Chronic neck pain',
 'C3-C4 disc osteophyte complex.',
 'Degenerative cervical changes', '2025-02-10 14:05:00','Clínica Central',7200,'NEW',NULL),

('STUDY044','P044','CT','Abdomen','LLQ abdominal pain',
 'Colonic wall thickening.',
 'Possible diverticulitis', '2025-02-10 14:10:00','Hospital Sur',1800,'NEW',NULL),

('STUDY045','P045','XR','Chest','Wheezing, dyspnea',
 'Bronchial wall thickening.',
 'Bronchitis pattern', '2025-02-10 14:15:00','Hospital Norte',3600,'NEW',NULL),

('STUDY046','P046','MRI','Brain','Seizure episode',
 'Left temporal hyperintensity.',
 'Possible epileptogenic focus', '2025-02-10 14:20:00','Clínica Los Andes',1800,'NEW',NULL),

('STUDY047','P047','CT','Chest','Post-transplant check',
 'No acute rejection signs.',
 'Stable post-transplant CT', '2025-02-10 14:30:00','Hospital Norte',7200,'NEW',NULL),

('STUDY048','P048','CT','Abdomen','Acute abdominal pain',
 'Free air under diaphragm.',
 'Suspected perforation', '2025-02-10 14:35:00','Hospital Sur',900,'NEW',NULL),

('STUDY049','P049','MRI','Knee','Evaluation after trauma',
 'Complete ACL tear.',
 'ACL complete tear', '2025-02-10 14:40:00','Clínica Central',1800,'NEW',NULL),

('STUDY050','P050','CT','Chest','PE follow-up second scan',
 'Reduced clot burden compared to prior.',
 'Improving PE', '2025-02-10 14:50:00','Hospital Norte',7200,'NEW',NULL),

('STUDY051','P051','XR','Chest','Smoker screening',
 'Hyperlucent right upper lobe area.',
 'Possible emphysema focus', '2025-02-10 14:55:00','Hospital Norte',7200,'NEW',NULL),

('STUDY052','P052','MRI','Brain','Evaluate demyelination',
 'Few periventricular lesions.',
 'Possible demyelinating disease', '2025-02-10 15:00:00','Clínica Los Andes',3600,'NEW',NULL),

('STUDY053','P053','CT','Chest','Fever + tachycardia',
 'Dense consolidation in RLL.',
 'RLL pneumonia', '2025-02-10 15:05:00','Hospital Norte',1800,'NEW',NULL),

('STUDY054','P054','CT','Abdomen','Epigastric pain',
 'Mild pancreatitis changes.',
 'Pancreatitis signs', '2025-02-10 15:10:00','Hospital Sur',1800,'NEW',NULL),

('STUDY055','P055','MRI','Spine','Thoracic back pain',
 'T7-T8 small disc protrusion.',
 'Thoracic disc protrusion', '2025-02-10 15:20:00','Clínica Central',7200,'NEW',NULL),

('STUDY056','P056','XR','Chest','Productive cough',
 'Left perihilar opacity.',
 'Perihilar infiltrate', '2025-02-10 15:25:00','Hospital Norte',3600,'NEW',NULL),

('STUDY057','P057','CT','Brain','Stroke code',
 'Hyperdense MCA sign.',
 'Possible large-vessel occlusion', '2025-02-10 15:30:00','Hospital Trauma',600,'NEW',NULL),

('STUDY058','P058','MRI','Abdomen','Evaluate adrenal lesion',
 'Benign-appearing adenoma.',
 'Adrenal adenoma', '2025-02-10 15:35:00','Clínica Central',7200,'NEW',NULL),

('STUDY059','P059','CT','Chest','Acute pleuritic chest pain',
 'Small left pleural effusion.',
 'Pleural effusion; mild', '2025-02-10 15:40:00','Hospital Norte',7200,'NEW',NULL),

('STUDY060','P060','MRI','Brain','Recurrent migraines',
 'Mild sinus mucosal thickening.',
 'No significant findings', '2025-02-10 15:45:00','Clínica Los Andes',7200,'NEW',NULL),

('STUDY061','P061','CT','Abdomen','Lower abdominal pain',
 'Dilated bowel loops; air-fluid levels.',
 'Small bowel obstruction', '2025-02-10 15:50:00','Hospital Sur',1200,'NEW',NULL),

('STUDY062','P062','XR','Chest','Choking episode',
 'No foreign body seen.',
 'Normal pediatric chest XR', '2025-02-10 15:55:00','Hospital Norte',7200,'NEW',NULL),

('STUDY063','P063','CT','Chest','Weight loss + chronic cough',
 'Mass-like opacity 3 cm.',
 'Suspicious lung mass', '2025-02-10 16:00:00','Clínica Los Andes',1800,'NEW',NULL),

('STUDY064','P064','MRI','Spine','Chronic lower back pain',
 'Facet joint degeneration.',
 'Facet arthropathy', '2025-02-10 16:05:00','Clínica Central',7200,'NEW',NULL),

('STUDY065','P065','CT','Brain','New onset headache',
 'Normal CT brain.',
 'No acute intracranial findings', '2025-02-10 16:10:00','Hospital Norte',7200,'NEW',NULL),

('STUDY066','P066','CT','Chest','Trauma, high impact',
 'Large right pneumothorax.',
 'Pneumothorax; large', '2025-02-10 16:15:00','Hospital Trauma',600,'NEW',NULL),

('STUDY067','P067','MRI','Abdomen','Evaluate renal cyst',
 'Bosniak II cyst.',
 'Benign renal cyst', '2025-02-10 16:20:00','Clínica Central',7200,'NEW',NULL),

('STUDY068','P068','XR','Chest','Asthma exacerbation',
 'Hyperinflation; peribronchial thickening.',
 'Asthma-related changes', '2025-02-10 16:25:00','Hospital Norte',3600,'NEW',NULL),

('STUDY069','P069','CT','Abdomen','Post-operative complication',
 'Fluid collection near surgical bed.',
 'Possible abscess', '2025-02-10 16:30:00','Hospital Sur',1800,'NEW',NULL),

('STUDY070','P070','MRI','Brain','Facial paralysis evaluation',
 'No acute infarct detected.',
 'No acute findings', '2025-02-10 16:35:00','Clínica Los Andes',7200,'NEW',NULL),

 ('STUDY001', 'P001', 'CT', 'Chest', 'Acute shortness of breath; rule out PE',
  'Preliminary findings suggest possible filling defects in right pulmonary artery.',
  'Possible pulmonary embolism; further review required', '2025-02-10 08:23:00', 'Hospital Norte', 1800, 'NEW', NULL),

 ('STUDY002', 'P002', 'XR', 'Chest', 'Chronic cough, fever',
  'Mild bilateral infiltrates. No pleural effusion noted.',
  'Bilateral infiltrates consistent with infection', '2025-02-10 08:41:00', 'Hospital Norte', 3600, 'NEW', NULL),

 ('STUDY003', 'P003', 'CT', 'Brain', 'Acute headache, rule out bleed',
  'No midline shift; small hyperdensity in left temporal lobe.',
  'Possible micro-hemorrhage', '2025-02-10 08:55:00', 'Clínica Los Andes', 1200, 'NEW', NULL),

 ('STUDY004', 'P004', 'MRI', 'Spine', 'Lumbar pain radiating to left leg',
  'Disc protrusion at L4-L5 contacting nerve root.',
  'L4-L5 protrusion contacting nerve root', '2025-02-10 09:10:00', 'Clínica Central', 7200, 'NEW', NULL),

 ('STUDY005', 'P005', 'CT', 'Abdomen', 'Right lower quadrant pain; rule out appendicitis',
  'Mildly enlarged appendix with periappendiceal fat stranding.',
  'Findings suspicious for appendicitis', '2025-02-10 09:15:00', 'Hospital Sur', 1800, 'NEW', NULL),

 ('STUDY006', 'P006', 'XR', 'Chest', 'Persistent dyspnea, smoker',
  'Hyperinflated lungs. Flattened diaphragm.',
  'COPD-like changes', '2025-02-10 09:30:00', 'Hospital Norte', 7200, 'NEW', NULL),

 ('STUDY007', 'P007', 'CT', 'Chest', 'Trauma after fall',
  'Multiple right rib fractures; mild pneumothorax.',
  'Rib fractures + small pneumothorax', '2025-02-10 09:32:00', 'Hospital Trauma', 900, 'NEW', NULL),

 ('STUDY008', 'P008', 'MRI', 'Brain', 'Dizziness and visual disturbances',
  'Small white matter hyperintensities; no acute infarct.',
  'Nonspecific white matter changes', '2025-02-10 09:40:00', 'Clínica Los Andes', 3600, 'NEW', NULL),

 ('STUDY009', 'P009', 'CT', 'Chest', 'Chest pain and elevated D-dimer',
  'Segmental filling defect in left lower lobe artery.',
  'Likely pulmonary embolism', '2025-02-10 09:50:00', 'Hospital Norte', 1200, 'NEW', NULL),

 ('STUDY010', 'P010', 'CT', 'Abdomen', 'Generalized abdominal pain, nausea',
  'Mild hepatomegaly and fatty infiltration; no acute findings.',
  'Hepatic steatosis', '2025-02-10 10:00:00', 'Hospital Sur', 7200, 'NEW', NULL),

 ('STUDY011', 'P011', 'XR', 'Chest', 'Suspected pneumonia',
  'Right lower lobe consolidation.',
  'Right lower lobe consolidation', '2025-02-10 10:05:00', 'Hospital Norte', 3600, 'NEW', NULL),

 ('STUDY012', 'P012', 'MRI', 'Knee', 'Pain after sports injury',
  'Partial tear of ACL with joint effusion.',
  'Partial ACL tear', '2025-02-10 10:20:00', 'Clínica Central', 7200, 'NEW', NULL),

 ('STUDY013', 'P013', 'CT', 'Chest', 'Acute hypoxia',
  'Diffuse ground-glass opacities.',
  'Ground-glass opacities – consider infection/inflammation', '2025-02-10 10:30:00', 'Hospital Norte', 1800, 'NEW', NULL),

 ('STUDY014', 'P014', 'MRI', 'Brain', 'Progressive memory issues',
  'Mild cortical atrophy.',
  'Cortical atrophy pattern', '2025-02-10 10:45:00', 'Clínica Los Andes', 7200, 'NEW', NULL),

 ('STUDY015', 'P015', 'CT', 'Spine', 'Severe back pain after accident',
  'L1 compression fracture with 20% height loss.',
  'Compression fracture L1', '2025-02-10 11:00:00', 'Hospital Trauma', 900, 'NEW', NULL),

 ('STUDY016', 'P016', 'CT', 'Abdomen', 'Post-op fever; rule out abscess',
  'Small fluid collection near surgical site.',
  'Possible post-op abscess', '2025-02-10 11:10:00', 'Hospital Sur', 1800, 'NEW', NULL),

 ('STUDY017', 'P017', 'XR', 'Chest', 'Routine checkup',
  'Normal study.',
  'Normal chest X-ray', '2025-02-10 11:15:00', 'Hospital Norte', 14400, 'NEW', NULL),

 ('STUDY018', 'P018', 'CT', 'Chest', 'Cough + weight loss',
  'Irregular 2 cm nodule in upper lobe.',
  'Suspicious solitary pulmonary nodule', '2025-02-10 11:20:00', 'Clínica Los Andes', 3600, 'NEW', NULL),

 ('STUDY019', 'P019', 'MRI', 'Abdomen', 'Evaluate liver lesion',
  'Well-circumscribed lesion consistent with hemangioma.',
  'Likely hemangioma', '2025-02-10 11:30:00', 'Clínica Central', 7200, 'NEW', NULL),

 ('STUDY020', 'P020', 'CT', 'Chest', 'Tachycardia, pleuritic pain',
  'Subsegmental filling defect in right lower segment.',
  'Possible small PE', '2025-02-10 11:35:00', 'Hospital Norte', 1500, 'NEW', NULL);
