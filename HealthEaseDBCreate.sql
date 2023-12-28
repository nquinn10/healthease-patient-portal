-- Final Project: 

DROP DATABASE health_ease;
-- create database
CREATE DATABASE IF NOT EXISTS health_ease;

-- set default db
USE health_ease;

DROP TABLE IF EXISTS insurance_policy;
CREATE TABLE insurance_policy
(  policy_no VARCHAR(64) PRIMARY KEY, 
   insurance_provider_name VARCHAR(64) NOT NULL,
   account_holder VARCHAR(64) NOT NULL
);

-- create patient table
DROP TABLE IF EXISTS patient_profile;
CREATE TABLE patient_profile
(  patient_id INT AUTO_INCREMENT PRIMARY KEY, 
   first_name VARCHAR(64) NOT NULL,
   last_name VARCHAR(64) NOT NULL,
   date_of_birth DATE NOT NULL, 
   gender ENUM ('male', 'female', 'other', 'prefer not to say'),
   email VARCHAR(64) UNIQUE NOT NULL, 
   phone_no CHAR(11), 
   credit_card_no CHAR(16),
   emergency_contact_name VARCHAR(64),
   emergency_contact_no CHAR(11),
   policy_no CHAR(12),
   user_password VARCHAR(20),
   is_admin BOOLEAN NOT NULL DEFAULT 0,
   -- 1:1 relationship "insurance_card insures patient"
   FOREIGN KEY (policy_no) REFERENCES insurance_policy(policy_no)
			ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS medical_office;
CREATE TABLE medical_office 
(  office_name VARCHAR(64) PRIMARY KEY,
   street_no INT NOT NULL, 
   street_name VARCHAR(64) NOT NULL,
   town VARCHAR(64) NOT NULL,
   zipcode CHAR(5) NOT NULL,
   UNIQUE (street_no, street_name, town, zipcode),
   phone_no CHAR(11) NOT NULL UNIQUE
);

-- create doctor table
DROP TABLE IF EXISTS doctor;
CREATE TABLE doctor
(  npi CHAR(10) PRIMARY KEY, 
   full_name VARCHAR(64) NOT NULL,
   photo BLOB,
   doctor_gender ENUM ('male', 'female', 'other') NOT NULL,
   provider_type ENUM ('MD', 'DO', 'NP', 'PA') NOT NULL,
   specialty VARCHAR(64) NOT NULL,
   -- FK to represent 1:* relationship "doctor practices at office"
   office_name VARCHAR(64),
   FOREIGN KEY (office_name) REFERENCES medical_office(office_name)
		ON UPDATE CASCADE ON DELETE SET NULL
);

-- create new table for "patient has doctor" *:* relationship
-- take PK of both and the combo of boths PKs becomes PK for relationship table (include any relationship attributes,
-- include FKs
DROP TABLE IF EXISTS patient_has_doctor;
CREATE TABLE patient_has_doctor
(  patient_id INT,
   npi CHAR(10), 
   PRIMARY KEY (patient_id, npi),
   FOREIGN KEY (patient_id) REFERENCES patient_profile(patient_id)
			ON UPDATE CASCADE ON DELETE CASCADE,
   FOREIGN KEY (npi) REFERENCES doctor(npi)
			ON UPDATE CASCADE ON DELETE CASCADE
);

-- create table prescription medicine
DROP TABLE IF EXISTS prescription_med;
CREATE TABLE prescription_med
(  rx_id INT AUTO_INCREMENT PRIMARY KEY,
   rx_name VARCHAR(64) NOT NULL, 
   refill_count INT NOT NULL
);

-- create table for complex relationship "doctor prescribes prescription medication to a patient"
DROP TABLE IF EXISTS doctor_prescribes;
CREATE TABLE doctor_prescribes
(  patient_id INT,
   npi CHAR(10), 
   rx_id INT, 
   dosage_instructions LONGTEXT NOT NULL,
   start_date DATE NOT NULL, 
   finish_date DATE NOT NULL, -- duration can be derived 
   patient_refill_count INT NOT NULL,
   PRIMARY KEY (patient_id, npi, rx_id),
   FOREIGN KEY (patient_id) REFERENCES patient_profile(patient_id)
			ON UPDATE CASCADE ON DELETE CASCADE,
   FOREIGN KEY (npi) REFERENCES doctor(npi)
			ON UPDATE CASCADE ON DELETE CASCADE,
   FOREIGN KEY (rx_id) REFERENCES prescription_med(rx_id)
			ON UPDATE CASCADE ON DELETE CASCADE
);

-- create table for review
DROP TABLE IF EXISTS review;
CREATE TABLE review
(  review_id INT AUTO_INCREMENT PRIMARY KEY,
   star_rating INT,
   comments LONGTEXT,
   review_date DATE NOT NULL,
   patient_id INT,
   npi CHAR(10),
   FOREIGN KEY (patient_id) REFERENCES patient_profile(patient_id)
			ON UPDATE CASCADE ON DELETE SET NULL, -- FK to represent 1:* relationship "patient leaves review"
   FOREIGN KEY (npi) REFERENCES doctor(npi)
			ON UPDATE CASCADE ON DELETE CASCADE -- FK to represent 1:* relationship "doctor receives review"
);

DROP TABLE IF EXISTS appointment;
CREATE TABLE appointment
(  appointment_id INT AUTO_INCREMENT PRIMARY KEY, 
   appointment_date_time DATETIME NOT NULL,
   appointment_type ENUM ('office visit', 'routine checkup', 'specialist consultation') NOT NULL, 
   bill_type ENUM ('office visit', 'preventative', 'specialty'),
   patient_id INT,
   npi CHAR(10),
   FOREIGN KEY (patient_id) REFERENCES patient_profile(patient_id)
			ON UPDATE CASCADE ON DELETE CASCADE, -- FK to represent 1:* relationship "patient schedules appointment"
   FOREIGN KEY (npi) REFERENCES doctor(npi)
			ON UPDATE CASCADE ON DELETE CASCADE -- FK to represent 1:* relationship "appointment scheduled with doctor"
);

DROP TABLE IF EXISTS bill;
CREATE TABLE bill
(  bill_id INT AUTO_INCREMENT PRIMARY KEY,
   bill_description LONGTEXT NOT NULL,
   date_issued DATE NOT NULL, 
   due_date DATE NOT NULL, 
   total_amount DECIMAL(8,2) NOT NULL,
   bill_type ENUM ('office visit', 'preventative', 'specialty'),
   balance_remaining DECIMAL(8,2),
   -- FK for 1:* relationship "medical office issues bill)
   office_name VARCHAR(64),
   FOREIGN KEY (office_name) REFERENCES medical_office(office_name)
		ON UPDATE CASCADE ON DELETE SET NULL,
   patient_id INT, 
   -- FK for 1:* relationship "patient pays bill"
   FOREIGN KEY (patient_id) REFERENCES patient_profile(patient_id)
		ON UPDATE CASCADE ON DELETE CASCADE
);



