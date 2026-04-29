-- Hospital Management System (MySQL)
-- Run this file first to create the schema.
-- Assumes MySQL 8.x with InnoDB.

DROP DATABASE IF EXISTS hospital_management;
CREATE DATABASE hospital_management;
USE hospital_management;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS prescription_items;
DROP TABLE IF EXISTS prescriptions;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS medicines;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS patients;
SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------
-- Patients
-- ----------------------------
CREATE TABLE patients (
  patient_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  dob DATE NOT NULL,
  gender ENUM('M', 'F', 'O') NOT NULL DEFAULT 'O',
  phone VARCHAR(20),
  email VARCHAR(100),
  address VARCHAR(255),
  PRIMARY KEY (patient_id),
  UNIQUE KEY uq_patients_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Doctors
-- ----------------------------
CREATE TABLE doctors (
  doctor_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  specialty VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  license_number VARCHAR(50),
  PRIMARY KEY (doctor_id),
  UNIQUE KEY uq_doctors_email (email),
  UNIQUE KEY uq_doctors_license (license_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Appointments
-- ----------------------------
CREATE TABLE appointments (
  appointment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  patient_id INT UNSIGNED NOT NULL,
  doctor_id INT UNSIGNED NOT NULL,
  appointment_datetime DATETIME NOT NULL,
  status ENUM('SCHEDULED', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
  reason VARCHAR(255) NOT NULL,
  notes TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (appointment_id),

  -- Prevent double booking a doctor at the same datetime.
  UNIQUE KEY uq_doctor_datetime (doctor_id, appointment_datetime),

  KEY idx_appointments_patient_datetime (patient_id, appointment_datetime),
  KEY idx_appointments_doctor_datetime (doctor_id, appointment_datetime),

  CONSTRAINT fk_appointments_patient
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_appointments_doctor
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Medicines
-- ----------------------------
CREATE TABLE medicines (
  medicine_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  strength VARCHAR(60),
  form VARCHAR(60),
  side_effects TEXT,
  PRIMARY KEY (medicine_id),
  UNIQUE KEY uq_medicines_name_strength_form (name, strength, form)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Prescriptions (one per appointment)
-- ----------------------------
CREATE TABLE prescriptions (
  prescription_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  appointment_id INT UNSIGNED NOT NULL,
  prescribed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  diagnosis VARCHAR(255) NOT NULL,
  PRIMARY KEY (prescription_id),
  UNIQUE KEY uq_prescriptions_appointment (appointment_id),

  CONSTRAINT fk_prescriptions_appointment
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Prescription Items (many medicines per prescription)
-- ----------------------------
CREATE TABLE prescription_items (
  prescription_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  prescription_id INT UNSIGNED NOT NULL,
  medicine_id INT UNSIGNED NOT NULL,
  dosage_instructions VARCHAR(255) NOT NULL,
  quantity INT UNSIGNED NOT NULL,
  PRIMARY KEY (prescription_item_id),

  -- Avoid inserting the same medicine twice for one prescription.
  UNIQUE KEY uq_prescription_medicine (prescription_id, medicine_id),

  KEY idx_prescription_items_medicine (medicine_id),
  CONSTRAINT fk_prescription_items_prescription
    FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_prescription_items_medicine
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- Helpful indexes (optional)
-- ----------------------------
-- appointment_datetime is already indexed via composite indexes above.

