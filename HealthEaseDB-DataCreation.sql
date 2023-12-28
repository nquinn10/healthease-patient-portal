-- insert data into database
USE health_ease;

INSERT INTO insurance_policy (policy_no, insurance_provider_name, account_holder)
VALUES
('POL123456789', 'Blue Cross Blue Shield', 'John Doe'),
('POL987654321', 'Tufts Health Plan', 'Jane Smith Sr.'),
('POL345678901', 'Harvard Pilgram', 'Alex Johnson'),
('POL387524321', 'Harvard Pilgram', 'Diane Dow');

INSERT INTO patient_profile (first_name, last_name, date_of_birth, gender, email, phone_no, credit_card_no, emergency_contact_name, emergency_contact_no, policy_no, user_password, is_admin)
VALUES
('John', 'Doe', '1990-05-15', 'male', 'john.doe@email.com', '12345678901', '1234567890123456', 'Jane Doe', '16175432101', 'POL123456789', 'password123$', 0),
('Jane', 'Smith', '2001-08-22', 'female', 'jane.smith@email.com', '98765432109', '9876543210987654', 'John Smith', '16175678902', 'POL987654321', 'howdy123$', 0),
('Alex', 'Johnson', '1995-03-10', 'other', 'alex.johnson@email.com', '23456789012', '3456789012345678', 'Amy Johnson', '16171234503', 'POL345678901', 'test987!', 0);



INSERT INTO medical_office (office_name, street_no, street_name, town, zipcode, phone_no)
VALUES
('Healthy Clinic', 123, 'Main Street', 'Boston', '02215', '16177895634'),
('Care Center', 456, 'Maple Avenue', 'Boston', '02215', '16177789454'),
('Wellbeing Medical', 789, 'Oak Street', 'Boston', '02215', '16173324770');

INSERT INTO doctor (npi, full_name, photo, doctor_gender, provider_type, specialty, office_name)
VALUES
('1231234567', 'Olivia Stevenson', NULL, 'female', 'MD', 'Internal Medicine', 'Healthy Clinic'),
('2232345678', 'Sophia Ricardo', NULL, 'female', 'DO', 'Family Medicine', 'Care Center'),
('3233456789', 'Emma Williams', NULL, 'female', 'MD', 'Pediatrics', 'Care Center'),
('4234567890', 'Liam Miller', NULL, 'male', 'MD', 'Cardiology', 'Wellbeing Medical'),
('5235678901', 'Jordan Taylor', NULL, 'other', 'DO', 'Orthopedics', 'Care Center'),
('6236789012', 'Ethan Brown', NULL, 'male', 'NP', 'Family Medicine', 'Wellbeing Medical'),
('7237890123', 'Avery Clark', NULL, 'other', 'PA', 'Dermatology', 'Healthy Clinic');

INSERT INTO patient_has_doctor (patient_id, npi)
VALUES
(1, '7237890123'),
(1, '1231234567'), 
(2, '3233456789'),
(5, '4234567890'),
(5, '1231234567');


INSERT INTO prescription_med (rx_name, refill_count)
VALUES
('Lisinopril', 2), -- high blood pressure
('Levothyroxine', 3), -- thyroid
('Metformin', 2), -- diabetes
('Atorvastatin', 1), -- cholesterol
('Isotretinoin', 4), -- accutane 
('Amoxicillin', 0), -- antibiotics
('Acetaminophen', 2); -- pain meds

INSERT INTO doctor_prescribes (patient_id, npi, rx_id, dosage_instructions, start_date, finish_date, patient_refill_count)
VALUES
(1, '7237890123', 5, 'Take 1 pill (20mg) each morning with a fatty meal.', '2023-08-28', '2024-02-28', 4),
(2, '3233456789', 6, 'Take twice a day for 10 days. Be sure to complete the full course of antibiotics.', '2023-11-29', '2023-12-13', 0),
(2, '3233456789', 7, 'Take 1 pill a day untill fever breaks.', '2023-11-29', '2023-12-06', 2),
(5, '4234567890', 4, 'Take 1 pill in the morning every day.', '2023-11-29', '2024-4-06', 3);

INSERT INTO review (star_rating, comments, review_date, patient_id, npi) 
VALUES
(4, "Dr. Clark was very informative and helpful during my appointment.", '2023-08-31', 1, '7237890123'),
(3, "The wait time at Dr. Williams's office was a bit long, but the doctor was knowledgeable.", '2023-03-10', 2, '3233456789'),
(5, "I appreciate Dr. Stevenson's thorough explanations and friendly demeanor. Highly recommend!", '2023-04-05', 1, '1231234567'),
(3, "Dr. Miller is great, but he has me on too many pills!", '2023-04-05', 5, '4234567890'),
(4, "Big fan of Dr. Stevenson", '2023-09-21', 5, '1231234567');

INSERT INTO review (star_rating, comments, review_date, patient_id, npi) 
VALUES
(4, "Big fan of Dr. Stevenson", '2023-09-21', 5, '1231234567');

INSERT INTO appointment (appointment_date_time, appointment_type, bill_type, patient_id, npi) VALUES
('2023-01-10 09:00:00', 'routine checkup', 'preventative', 1, '1231234567'),
('2023-06-05 11:00:00', 'specialist consultation', 'specialty', 1, '7237890123'),
('2023-08-28 14:30:00', 'office visit', 'office visit', 1, '7237890123'),
('2023-11-29 10:30:00', 'office visit', 'office visit', 2, '3233456789'),
('2023-10-20 11:30:00', 'office visit', 'office visit', 5, '4234567890'),
('2023-12-20 10:00:00', 'office visit', 'office visit', 5, '4234567890'),
('2023-09-20 09:30:00', 'routine checkup', 'preventative', 5, '1231234567');

INSERT INTO appointment (appointment_date_time, appointment_type, bill_type, patient_id, npi) VALUES
('2023-09-20 09:30:00', 'routine checkup', 'preventative', 5, '1231234567');


INSERT INTO bill (bill_description, date_issued, due_date, total_amount, bill_type, office_name, patient_id, balance_remaining)
VALUES
('Routine checkup', '2023-01-10', '2023-01-25', 00.00, 'preventative', 'Healthy Clinic', 1, 00.00),
('Specialist consultation charge', '2023-06-05', '2023-06-20', 40.00, 'specialty', 'Healthy Clinic', 1, 40.00),
('Follow-up charge', '2023-08-28', '2023-09-12', 40.00, 'office visit', 'Healthy Clinic', 1, 40.00),
('Office visit charge, non-routine', '2023-11-29', '2023-12-14', 40.00, 'office visit', 'Care Center', 2, 40.00),
('Office visit charge, non-routine', '2023-10-21', '2023-12-20', 40.00, 'office visit', 'Wellbeing Medical', 5, 40.00);

INSERT INTO bill (bill_description, date_issued, due_date, total_amount, bill_type, office_name, patient_id, balance_remaining)
VALUES
('Routine checkup', '2023-09-20', '2023-10-10', 00.00, 'preventative', 'Healthy Clinic', 5, 00.00);


-- ADMIN DATA 
INSERT INTO patient_profile (first_name, last_name, date_of_birth, gender, email, phone_no, credit_card_no, emergency_contact_name, emergency_contact_no, policy_no, user_password, is_admin)
VALUES
('Portal', 'Admin', '1980-01-15', 'male', 'portaladmin@healthease.com', '6178887676', NULL , NULL, NULL, NULL, 'strongpass!', 1);

-- Additional patient - add after admin
INSERT INTO patient_profile (first_name, last_name, date_of_birth, gender, email, phone_no, credit_card_no, emergency_contact_name, emergency_contact_no, policy_no, user_password, is_admin)
VALUES
('Donna', 'Dow', '1965-04-10', 'female', 'donna@gmail.com', '16178876576', '1234567654382398', 'Diane Dow', '16175554343', 'POL387524321', '123456', 0);
