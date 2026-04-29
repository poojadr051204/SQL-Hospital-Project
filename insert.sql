-- Sample data for Hospital Management System
-- Run after schema.sql

USE hospital_management;

START TRANSACTION;

-- ----------------------------
-- Patients
-- ----------------------------
INSERT INTO patients
  (patient_id, first_name, last_name, dob, gender, phone, email, address)
VALUES
  (1, 'Priya', 'Sharma', '1990-03-14', 'F', '555-0101', 'priya.sharma@example.com', 'Baker Street 12'),
  (2, 'Rahul', 'Verma',  '1983-11-02', 'M', '555-0102', 'rahul.verma@example.com', 'Park Avenue 5'),
  (3, 'Ananya', 'Singh',  '2000-06-20', 'F', '555-0103', 'ananya.singh@example.com', 'Lake View 9'),
  (4, 'Sameer', 'Khan',   '1975-09-05', 'M', '555-0104', 'sameer.khan@example.com', 'Hill Road 21'),
  (5, 'Neha', 'Gupta',    '1998-01-30', 'F', '555-0105', 'neha.gupta@example.com', 'Sunset Blvd 7'),
  (6, 'Arjun', 'Mehta',   '2010-12-10', 'M', '555-0106', 'arjun.mehta@example.com', 'Maple Street 3');

-- ----------------------------
-- Doctors
-- ----------------------------
INSERT INTO doctors
  (doctor_id, first_name, last_name, specialty, phone, email, license_number)
VALUES
  (1, 'Alice',  'Smith',  'Cardiology',      '555-0201', 'alice.smith@hospital.com', 'LIC-CA-1001'),
  (2, 'Bob',    'Johnson','Dermatology',     '555-0202', 'bob.johnson@hospital.com', 'LIC-DE-1002'),
  (3, 'Carol',  'Lee',    'Pediatrics',      '555-0203', 'carol.lee@hospital.com', 'LIC-PE-1003'),
  (4, 'David',  'Patel',  'Orthopedics',     '555-0204', 'david.patel@hospital.com', 'LIC-OR-1004');

-- ----------------------------
-- Medicines
-- ----------------------------
INSERT INTO medicines
  (medicine_id, name, strength, form, side_effects)
VALUES
  (1, 'Amoxicillin',  '500mg', 'Capsule', 'May cause nausea or mild stomach upset.'),
  (2, 'Ibuprofen',     '200mg', 'Tablet',  'Can irritate the stomach; take with food if needed.'),
  (3, 'Cetirizine',    '10mg',  'Tablet',  'May cause drowsiness in some patients.'),
  (4, 'Paracetamol',   '500mg', 'Tablet',  'Avoid exceeding the recommended daily dose.'),
  (5, 'Clotrimazole',  '1%',     'Cream',    'Rare irritation at the application site.'),
  (6, 'Omeprazole',    '20mg',  'Capsule',  'May cause headache in some people.'),
  (7, 'Atorvastatin',  '10mg',  'Tablet',   'May cause muscle aches (rare).');

-- ----------------------------
-- Appointments
-- (Use explicit IDs so later INSERTs can reference them reliably.)
-- ----------------------------
INSERT INTO appointments
  (appointment_id, patient_id, doctor_id, appointment_datetime, status, reason, notes)
VALUES
  (1,  1, 1, DATE_ADD(NOW(), INTERVAL -14 DAY), 'COMPLETED', 'Chest pain check', NULL),
  (2,  2, 1, DATE_ADD(NOW(), INTERVAL -10 DAY), 'COMPLETED', 'Hypertension follow-up', NULL),
  (3,  3, 2, DATE_ADD(NOW(), INTERVAL -8 DAY),  'COMPLETED', 'Skin rash', NULL),
  (4,  4, 4, DATE_ADD(NOW(), INTERVAL -6 DAY),  'COMPLETED', 'Knee pain', NULL),
  (5,  5, 3, DATE_ADD(NOW(), INTERVAL -5 DAY),  'COMPLETED', 'Fever and cough', NULL),
  (6,  6, 3, DATE_ADD(NOW(), INTERVAL -4 DAY),  'COMPLETED', 'Allergy symptoms', NULL),
  (7,  1, 2, DATE_ADD(NOW(), INTERVAL -2 DAY),  'COMPLETED', 'Itching', NULL),
  (8,  2, 1, DATE_ADD(NOW(), INTERVAL -1 DAY),  'SCHEDULED', 'Blood pressure monitoring', NULL),
  (9,  3, 4, DATE_ADD(NOW(), INTERVAL  1 DAY),  'SCHEDULED', 'Back pain', NULL),
  (10, 4, 1, DATE_ADD(NOW(), INTERVAL  2 DAY),  'SCHEDULED', 'Cholesterol management', NULL),
  (11, 5, 3, DATE_ADD(NOW(), INTERVAL  3 DAY),  'SCHEDULED', 'Vaccination consult', NULL),
  (12, 6, 2, DATE_ADD(NOW(), INTERVAL  4 DAY),  'SCHEDULED', 'Fungal infection', NULL);

-- ----------------------------
-- Prescriptions (only for completed appointments)
-- ----------------------------
INSERT INTO prescriptions
  (prescription_id, appointment_id, prescribed_at, diagnosis)
VALUES
  (1, 1,  DATE_ADD(NOW(), INTERVAL -13 DAY), 'Cardiac evaluation follow-up'),
  (2, 2,  DATE_ADD(NOW(), INTERVAL -9 DAY),  'Hypertension control'),
  (3, 3,  DATE_ADD(NOW(), INTERVAL -7 DAY),  'Dermatitis'),
  (4, 4,  DATE_ADD(NOW(), INTERVAL -5 DAY),  'Knee inflammation'),
  (5, 5,  DATE_ADD(NOW(), INTERVAL -4 DAY),  'Respiratory infection'),
  (6, 6,  DATE_ADD(NOW(), INTERVAL -3 DAY),  'Allergic rhinitis'),
  (7, 7,  DATE_ADD(NOW(), INTERVAL -1 DAY),  'Allergic skin reaction');

-- ----------------------------
-- Prescription Items
-- ----------------------------
INSERT INTO prescription_items
  (prescription_item_id, prescription_id, medicine_id, dosage_instructions, quantity)
VALUES
  (1, 1, 7, 'Take 1 tablet daily after dinner', 30),
  (2, 1, 6, 'Take 1 capsule daily before breakfast', 30),

  (3, 2, 7, 'Take 1 tablet daily after dinner', 30),

  (4, 3, 5, 'Apply thin layer twice daily for 14 days', 1),
  (5, 3, 3, 'Take 1 tablet at night for 10 days', 10),

  (6, 4, 2, 'Take 1 tablet after meals twice daily for 5 days', 10),

  (7, 5, 4, 'Take 1 tablet every 6-8 hours as needed', 20),
  (8, 5, 1, 'Take 1 capsule three times daily for 7 days', 21),

  (9, 6, 3, 'Take 1 tablet at night for 10 days', 10),
  (10, 6, 4, 'Take 1 tablet as needed for fever', 12),

  (11, 7, 3, 'Take 1 tablet at night for 10 days', 10),
  (12, 7, 5, 'Apply cream twice daily for 10 days', 1);

COMMIT;

