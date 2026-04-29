-- Useful SQL queries for the Hospital Management System
-- Run after schema.sql and insert.sql

USE hospital_management;

-- -------------------------------------------------------
-- 1) Booking an appointment (safe workflow example)
-- -------------------------------------------------------
-- This shows how to check if a doctor is already booked
-- for a given datetime before inserting.
--
-- Change these values as needed:
SET @patient_id := 1;
SET @doctor_id := 1;
SET @appt_dt := DATE_ADD(NOW(), INTERVAL 7 DAY);

START TRANSACTION;
  -- Check for conflicts
  SELECT appointment_id, status
  FROM appointments
  WHERE doctor_id = @doctor_id
    AND appointment_datetime = @appt_dt;

  -- If the SELECT returns 0 rows, insert the appointment
  INSERT INTO appointments (patient_id, doctor_id, appointment_datetime, status, reason)
  VALUES (@patient_id, @doctor_id, @appt_dt, 'SCHEDULED', 'General check-up');
COMMIT;

-- -------------------------------------------------------
-- 2) Doctor schedule for a specific day
-- -------------------------------------------------------
SET @schedule_date := CURDATE();
SELECT
  a.appointment_datetime,
  a.status,
  p.patient_id,
  CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
  a.reason
FROM appointments a
JOIN patients p ON p.patient_id = a.patient_id
WHERE a.doctor_id = 1
  AND DATE(a.appointment_datetime) = @schedule_date
ORDER BY a.appointment_datetime;

-- -------------------------------------------------------
-- 3) View patient history (appointments + prescribed medicines)
-- -------------------------------------------------------
SET @patient_history_id := 1;
SELECT
  p.patient_id,
  CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
  a.appointment_id,
  a.appointment_datetime,
  d.specialty,
  a.reason,
  a.status,
  GROUP_CONCAT(
    DISTINCT CONCAT(m.name, ' (', IFNULL(m.strength, 'N/A'), ')')
    ORDER BY m.name
    SEPARATOR ', '
  ) AS medicines
FROM appointments a
JOIN patients p ON p.patient_id = a.patient_id
JOIN doctors d ON d.doctor_id = a.doctor_id
LEFT JOIN prescriptions pr ON pr.appointment_id = a.appointment_id
LEFT JOIN prescription_items pi ON pi.prescription_id = pr.prescription_id
LEFT JOIN medicines m ON m.medicine_id = pi.medicine_id
WHERE p.patient_id = @patient_history_id
GROUP BY
  p.patient_id,
  p.first_name,
  p.last_name,
  a.appointment_id,
  a.appointment_datetime,
  d.specialty,
  a.reason,
  a.status
ORDER BY a.appointment_datetime DESC;

-- -------------------------------------------------------
-- 4) Total appointments per doctor (includes all statuses)
-- -------------------------------------------------------
SELECT
  d.doctor_id,
  CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
  d.specialty,
  COUNT(*) AS total_appointments
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialty
ORDER BY total_appointments DESC;

-- -------------------------------------------------------
-- 5) Total DISTINCT patients per doctor
-- -------------------------------------------------------
SELECT
  d.doctor_id,
  CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
  COUNT(DISTINCT a.patient_id) AS total_distinct_patients
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name
ORDER BY total_distinct_patients DESC;

-- -------------------------------------------------------
-- 6) Most visited doctor (by number of appointments)
-- -------------------------------------------------------
SELECT
  d.doctor_id,
  CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
  COUNT(*) AS total_appointments
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name
ORDER BY total_appointments DESC
LIMIT 1;

-- -------------------------------------------------------
-- 7) Appointments count by status
-- -------------------------------------------------------
SELECT
  a.status,
  COUNT(*) AS count_of_appointments
FROM appointments a
GROUP BY a.status
ORDER BY count_of_appointments DESC;

-- -------------------------------------------------------
-- 8) Doctors with the most COMPLETED appointments
-- -------------------------------------------------------
SELECT
  d.doctor_id,
  CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
  COUNT(*) AS completed_appointments
FROM appointments a
JOIN doctors d ON d.doctor_id = a.doctor_id
WHERE a.status = 'COMPLETED'
GROUP BY d.doctor_id, d.first_name, d.last_name
ORDER BY completed_appointments DESC;

-- -------------------------------------------------------
-- 9) Top appointment reasons (by frequency)
-- -------------------------------------------------------
SELECT
  a.reason,
  COUNT(*) AS occurrences
FROM appointments a
GROUP BY a.reason
ORDER BY occurrences DESC
LIMIT 5;

-- -------------------------------------------------------
-- 10) Most prescribed medicine (by total quantity)
-- -------------------------------------------------------
SELECT
  m.medicine_id,
  m.name,
  m.strength,
  SUM(pi.quantity) AS total_quantity_prescribed,
  COUNT(*) AS number_of_prescription_items
FROM prescription_items pi
JOIN medicines m ON m.medicine_id = pi.medicine_id
GROUP BY m.medicine_id, m.name, m.strength
ORDER BY total_quantity_prescribed DESC
LIMIT 5;

-- -------------------------------------------------------
-- 11) Medicines prescribed to a patient (distinct)
-- -------------------------------------------------------
SET @patient_meds_id := 1;
SELECT
  p.patient_id,
  CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
  GROUP_CONCAT(DISTINCT m.name ORDER BY m.name SEPARATOR ', ') AS medicines_taken
FROM appointments a
JOIN patients p ON p.patient_id = a.patient_id
JOIN prescriptions pr ON pr.appointment_id = a.appointment_id
JOIN prescription_items pi ON pi.prescription_id = pr.prescription_id
JOIN medicines m ON m.medicine_id = pi.medicine_id
WHERE p.patient_id = @patient_meds_id
GROUP BY p.patient_id, p.first_name, p.last_name;

-- -------------------------------------------------------
-- 12) Patients who have never booked an appointment
-- -------------------------------------------------------
SELECT
  p.patient_id,
  CONCAT(p.first_name, ' ', p.last_name) AS patient_name
FROM patients p
LEFT JOIN appointments a ON a.patient_id = p.patient_id
WHERE a.appointment_id IS NULL
ORDER BY p.last_name, p.first_name;

-- -------------------------------------------------------
-- 13) Monthly appointment volume (last 6 months)
-- -------------------------------------------------------
SELECT
  DATE_FORMAT(a.appointment_datetime, '%Y-%m') AS year_month,
  COUNT(*) AS total_appointments
FROM appointments a
WHERE a.appointment_datetime >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY DATE_FORMAT(a.appointment_datetime, '%Y-%m')
ORDER BY year_month;

-- -------------------------------------------------------
-- 14) Next 7 days: all upcoming appointments with doctor + patient
-- -------------------------------------------------------
SELECT
  a.appointment_datetime,
  a.status,
  CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
  CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
  d.specialty,
  a.reason
FROM appointments a
JOIN patients p ON p.patient_id = a.patient_id
JOIN doctors d ON d.doctor_id = a.doctor_id
WHERE a.status = 'SCHEDULED'
  AND a.appointment_datetime >= NOW()
  AND a.appointment_datetime < DATE_ADD(NOW(), INTERVAL 7 DAY)
ORDER BY a.appointment_datetime ASC;

