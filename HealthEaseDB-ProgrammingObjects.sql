-- programming objects: procedures, functions, triggers, etc.
-- CRUD operations

USE health_ease;

/* --------------------------------------------
CREATE ACCOUNT 
input; first_name, last_name, date_of_birth, email, password
-------------------------------------------- */
DROP PROCEDURE IF EXISTS create_account;
DELIMITER //
CREATE PROCEDURE create_account(OUT patient_id_p INT, IN first_name_p VARCHAR(64), last_name_p VARCHAR(64),
                            	date_of_birth_p DATE, email_p VARCHAR(64), user_password_p VARCHAR(12))
BEGIN

	DECLARE curr_date_time DATETIME;
	DECLARE age_check INT;
	DECLARE email_valid BOOLEAN;
    
	SET curr_date_time = NOW();
    
	-- Calculate the age difference in years
	SET age_check = YEAR(curr_date_time) - YEAR(date_of_birth_p) - (DATE_FORMAT(curr_date_time, '%m%d') < DATE_FORMAT(date_of_birth_p, '%m%d'));
    
	-- Check for valid email
	SET email_valid = LOCATE('@', email_p) > 0 
                  AND LOCATE('@', email_p) != 1 -- Email should not start with '@'
                  AND CHAR_LENGTH(SUBSTRING_INDEX(email_p, '@', -1)) > 1; -- Domain name after '@' should be more than one character

	-- Validate that the person is 18 or older and email is valid
	IF age_check < 18 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User must be 18 years or older.', MYSQL_ERRNO = 1644;
	ELSEIF NOT email_valid THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email format.', MYSQL_ERRNO = 1644;
	ELSEIF CHAR_LENGTH(user_password_p) < 6 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password must be at least 6 characters', MYSQL_ERRNO = 1644;
	ELSEIF CHAR_LENGTH(user_password_p) > 12 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password must be at less than 12 characters', MYSQL_ERRNO = 1644;
	ELSEIF EXISTS ( 
		(SELECT 1 FROM patient_profile
		WHERE (email = email_p))) THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Email is already in use. Please Try again.", MYSQL_ERRNO = 1644;
	ELSE
    	INSERT INTO patient_profile (first_name, last_name, date_of_birth, email, user_password)
    	VALUES (first_name_p, last_name_p, date_of_birth_p, email_p, user_password_p);
   	 
    	-- Get the last inserted patient_id
    	SET patient_id_p = LAST_INSERT_ID();
	END IF;
    
END //
DELIMITER ;


CALL create_account('Billy', 'Joel', '1985-10-22', 'bj1022@gmail.com', '123Password!'); -- valid
CALL create_account('Joel', 'Joel', '2020-06-01', 'jj0601@gmail.com', 'Not18!'); -- invalid

/* --------------------------------------------
UPDATE ACCOUNT 
input; gender, phone_no, credit_card_no, emergency_contact_name, emergency_contact_no
-------------------------------------------- */ 

DROP PROCEDURE IF EXISTS update_account;
DELIMITER //
CREATE PROCEDURE update_account(IN patient_id_p INT, IN gender_p ENUM('male', 'female', 'other', 'prefer not to say'), phone_no_p CHAR(11),
   							 credit_card_no_p CHAR(16), emergency_contact_name_p VARCHAR(64), emergency_contact_no_p CHAR(11)
)
BEGIN
	-- Validate phone number and credit card number lengths
	IF CHAR_LENGTH(phone_no_p) != 11 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Phone number must be 11 characters long.', MYSQL_ERRNO = 1644;
	ELSEIF CHAR_LENGTH(credit_card_no_p) != 16 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Credit card number must be 16 characters long.', MYSQL_ERRNO = 1644;
	ELSE
    	-- Update the patient profile
    	UPDATE patient_profile
    	SET gender = gender_p,
        	phone_no = phone_no_p,
        	credit_card_no = credit_card_no_p,
        	emergency_contact_name = emergency_contact_name_p,
        	emergency_contact_no = emergency_contact_no_p
    	WHERE patient_id = patient_id_p;
	END IF;
END //
DELIMITER ;

CALL update_account(4, 'female', '12489181995', '1234567890123456', 'brandon spink', '12345678901');


/* --------------------------------------------
VIEW RX
input; patient_id
-------------------------------------------- */
DROP PROCEDURE view_rx;
DELIMITER //
CREATE PROCEDURE view_rx(IN patient_id_p INT)
BEGIN
	SELECT pm.rx_id, pm.rx_name, dp.patient_refill_count, dp.dosage_instructions, dp.start_date, dp.finish_date
    FROM prescription_med AS pm
    JOIN doctor_prescribes AS dp
    ON pm.rx_id = dp.rx_id
    WHERE dp.patient_id = patient_id_p;
END //
DELIMITER ;


-- test:
CALL view_rx(1);
CALL view_rx(2);

/* --------------------------------------------
FIND DOCTOR
input; patient_id
-------------------------------------------- */

-- idea: put in specialty you want and it outputs all doctors of that specialty, then patient selects one from list
-- similar to genre in DB, we would only allow patients to see doctors from the limited specialties in our DB
-- they have to select a specialty from the list\

DROP PROCEDURE IF EXISTS find_doctor;
DELIMITER //
CREATE PROCEDURE find_doctor(IN specialty_p VARCHAR(64), IN doctor_name_p VARCHAR(64))
BEGIN
    SELECT doctor.*, AVG(r.star_rating) as avg_rating
    FROM doctor
    LEFT JOIN review r USING(npi)
    WHERE (specialty = specialty_p OR specialty_p IS NULL)
      AND (full_name LIKE CONCAT('%', doctor_name_p, '%') OR doctor_name_p IS NULL)
	GROUP BY npi, full_name, photo, doctor_gender, provider_type, specialty, office_name;
END //
DELIMITER ;

/* -----------
FIND DOCTOR
testing testing
----------- */
CALL find_doctor('OBGYN', NULL); -- handle in Python when result set is empty
CALL find_doctor(NULL, 'Avery Clark'); -- name exists
CALL find_doctor(NULL, 'Emma'); -- pull up doctors with name emma
CALL find_doctor('Family Medicine', NULL);  -- specialty only
CALL find_doctor('Family Medicine', 'Sophia Ricardo');  -- specialty and name - 1 results
CALL find_doctor('Family Medicine', 'Sophia');  -- specialty and partial name - 1 result 
CALL find_doctor('Family Medicine', 'John');  -- specialty and partial inccorect name - no results 
CALL find_doctor('Family Medicine', 'Sophia rick'); -- specialty and inccorect last name - no results 


/* --------------------------------------------
VIEW REVIEWS on doctors; 
input; full name 
-------------------------------------------- */

DROP PROCEDURE IF EXISTS view_reviews;
DELIMITER //
CREATE PROCEDURE view_reviews(IN full_name_p VARCHAR(64))
BEGIN
    SELECT 
        r.review_id,
        r.npi,
        d.full_name,
        r.star_rating, 
        r.comments, 
        r.review_date
    FROM review AS r
    JOIN doctor AS d 
        ON r.npi = d.npi
    WHERE (d.full_name LIKE CONCAT('%', full_name_p, '%'));
END //
DELIMITER ;

/* -----------
VIEW REVIEWS; 
testing testing
----------- */
CALL view_reviews('Olivia Stevenson'); -- correct
CALL view_reviews('Olivia'); -- correct
CALL view_reviews('Olivia'); -- correct
CALL view_reviews('Ricardo'); -- correct, no reviews
CALL view_reviews('clark'); -- correct
CALL view_reviews('averyyyy'); -- incorrect, returns no results *user can't misspell!*
CALL view_reviews('Avery'); -- correct
CALL view_reviews(NULL); -- returns all reviews in DB

/* --------------------------------------------
DOCTOR AVG STAR RATING; 
input; full name 
-------------------------------------------- */

DELIMITER //
CREATE FUNCTION doc_avg_star_rating(full_name_p VARCHAR(64))
	RETURNS DECIMAL(5,4) DETERMINISTIC CONTAINS SQL

	BEGIN
		DECLARE ret_value DECIMAL(5,4) DEFAULT 0;
        
		SELECT AVG(doc_star_ratings.avg_star_rating) INTO ret_value FROM 
		( SELECT full_name, AVG(review.star_rating) AS avg_star_rating
			FROM doctor
			LEFT JOIN review USING(npi)
			WHERE full_name = full_name_p
			GROUP BY full_name ) as doc_star_ratings ;

	RETURN(ret_value);
	END //
 
DELIMITER ;

SELECT doc_avg_star_rating("Avery Clark");

/* --------------------------------------------
VIEW BILLS; 
input; patient_id
-------------------------------------------- */

DELIMITER //
CREATE PROCEDURE view_bills(IN patient_id_p INT)
BEGIN
    SELECT *
    FROM bill AS b
    WHERE b.patient_id = patient_id_p;
END //
DELIMITER ;

/* -----------
VIEW BILLS; 
testing testing
----------- */
CALL view_bills(1); -- correct
CALL view_bills(2); -- correct
CALL view_bills(8); -- correct, no results

/* --------------------------------------------
CRAETE REVIEWS; 
input; patint_id, npi, star_rating, comments, review_date
** check error handling if no NPI or patient ID **
** limit to 5 stars **
-------------------------------------------- */
DROP PROCEDURE IF EXISTS create_review;
DELIMITER //

CREATE PROCEDURE create_review(IN patient_id_p INT,
                                 IN full_name_p VARCHAR(64),
                                 IN star_rating_p INT,
                                 IN comments_p LONGTEXT,
                                 IN review_date_p DATE)
BEGIN
    DECLARE doctor_npi_var CHAR(10);

    -- multi-join to verify doctor, patient, and their relationship
    SELECT d.npi INTO doctor_npi_var
    FROM patient_profile pp
    JOIN patient_has_doctor phd 
        ON pp.patient_id = phd.patient_id
    JOIN doctor d 
        ON phd.npi = d.npi AND d.full_name = full_name_p
    WHERE pp.patient_id = patient_id_p;

    -- check if a valid NPI
    IF doctor_npi_var IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have not had an appointment with this doctor or doctor does not exist.';
    END IF;
    
    -- Validate star rating
    IF star_rating_p < 1 OR star_rating_p > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Star rating must be from 1 to 5.';
    END IF;

    -- Insert review
    INSERT INTO review (patient_id, npi, star_rating, comments, review_date)
    VALUES (patient_id_p, doctor_npi_var, star_rating_p, comments_p, review_date_p);
END //

DELIMITER ;

CALL create_review(1, 'Avery Clark', 2, 'laksjfd;laskjdf;l aksjf', '2023-12-05');

/* -----------
CREATE REVIEWS; 
testing testing
----------- */

CALL create_review(1, 'Avery Clark', 5, 'Nice.', '2023-11-30'); -- correct, patient id doesn't exist
CALL create_review(2, 'Emma Williams', 5, 'Nice. THANK YOU! ', '2023-12-30'); -- correct, doctor npi doesn't exist
CALL create_review(1, 'Olivia Stevenson', 5, 'RUDDE!.', '2023-11-30'); -- correct
CALL create_review(2, '3233456789', 32, 'Nice.', '2023-11-30'); -- correct, invalid star rating

/* --------------------------------------------
DELETE REVIEWS; 
input; patient_id, review_id
    * only the user who posted review can delete
-------------------------------------------- */
-- for deletion, show all reviews with review id and ask patient to enter in ID 
DROP PROCEDURE IF EXISTS delete_review;
DELIMITER //
CREATE PROCEDURE delete_review(IN patient_id_p INT,
                               IN review_id_p INT
)
BEGIN
    DECLARE review_count_var INT;
    
    -- check if reviews by user
    SELECT COUNT(*) INTO review_count_var
        FROM review
        WHERE review_id = review_id_p AND patient_id = patient_id_p;
        
    -- allow delete if review exists
    IF review_count_var > 0 THEN
        DELETE FROM review
            WHERE review_id = review_id_p;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Review does not exist.';
    END IF;
END//
DELIMITER ;

/* -----------
DELETE REVIEWS; 
testing testing
----------- */
CALL delete_review(1, 7); -- correct
CALL delete_review(1, 8); -- correct
CALL delete_review(2, 9); -- correct
CALL delete_review(3, 99); -- correct, unable to delete non-existent review_id

/* --------------------------------------------
GET PATIENT REVIEWS; 
input; patient_id
-------------------------------------------- */

DROP PROCEDURE IF EXISTS get_patient_reviews;
DELIMITER //
CREATE PROCEDURE get_patient_reviews(IN patient_id_p INT)
BEGIN
    SELECT review_id, star_rating, comments, review_date, npi
    FROM review
    WHERE patient_id = patient_id_p;
END //
DELIMITER ;

/* -----------
GET PATIENT REVIEWS; 
testing testing
----------- */
CALL get_patient_reviews(1);


/* --------------------------------------------
PAY BILL; 
input; patient_id, bill_id, payment
** updated bill to have balance_remaining
-------------------------------------------- */
-- similar to delete review, display all bills and have them type in bill id 
Drop procedure if exists pay_bill;
DELIMITER //
CREATE PROCEDURE pay_bill(IN patient_id_p INT,
                          IN bill_id_p INT,
                          IN payment_amount_p DECIMAL(8, 2)
)
BEGIN
	DECLARE balance_remaining_var DECIMAL(8, 2);
	DECLARE patient_id_var INT;
	-- current balance
	SELECT balance_remaining, patient_id INTO balance_remaining_var, patient_id_var
    	FROM bill
    	WHERE bill_id = bill_id_p;
    IF balance_remaining_var IS NULL OR patient_id_var IS NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bill ID not found.';
	-- error when bill's patient_id doesn't match patient
	ELSE
   	 IF patient_id_var != patient_id_p THEN
   		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bill does not match the patient.';
	ELSE
    	-- error for overpaying
    	IF payment_amount_p > balance_remaining_var THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment amount higher than balance remaining.';
    ELSE
   	 -- error for payment amount less than 0
    	IF payment_amount_p <= 0 THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment amount cannot be less than 0.';
	ELSE
    	-- accept pay & update balance
    	UPDATE bill
    	SET balance_remaining = balance_remaining_var - payment_amount_p
    	WHERE bill_id = bill_id_p;
    	END IF;
    END IF;
	END IF;
	END IF;
END //
DELIMITER ;

/* -----------
PAY BILL; 
testing testing
----------- */
CALL pay_bill(1, 5, 50.00); -- error
CALL pay_bill(1, 6, 20.00); -- correct, rem bal should be 20 
CALL pay_bill(2, 8, 40.00); -- correct, rem bal should be 0 

/* --------------------------------------------
VIEW PROFILE
input; patient_id
-------------------------------------------- */
DROP PROCEDURE IF EXISTS view_profile;
DELIMITER //
CREATE PROCEDURE view_profile(IN patient_id_p INT)
BEGIN
    SELECT patient_id, first_name, last_name, date_of_birth, gender, 
		   email, phone_no, credit_card_no, emergency_contact_name, 
           emergency_contact_no, policy_no 
        FROM patient_profile
        WHERE patient_id = patient_id_p;
END //
DELIMITER ;

/* -----------
VIEW PROFILE; 
testing testing
----------- */

CALL view_profile(1); -- correct
CALL view_profile(3); -- correct

/* --------------------------------------------
REFILL PRESCRIPTION
input; patient_id, rx_id
-------------------------------------------- */
-- similar to delete review, display all prescriptions with refill and have them type in rx_id

DROP PROCEDURE IF EXISTS refill_rx;
DELIMITER //
CREATE PROCEDURE refill_rx(IN patient_id_p INT,
                           IN rx_id_p INT
)
BEGIN
    DECLARE current_refill_count_var INT;
    
    -- current refill count
    SELECT dp.patient_refill_count INTO current_refill_count_var
        FROM doctor_prescribes AS dp
        WHERE dp.rx_id = rx_id_p AND dp.patient_id = patient_id_p;
            
    -- check if prescription exists, and has refills remaining
    IF current_refill_count_var IS NOT NULL AND current_refill_count_var > 0 THEN
        UPDATE doctor_prescribes
        SET patient_refill_count = current_refill_count_var - 1
        WHERE rx_id = rx_id_p;
    ELSE
        -- no refills remain, or prescription doesn't exist
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No refills remaining, or prescription no found.';
    END IF;
END //
DELIMITER ;

/* -----------
REFILL RX; 
testing testing
----------- */
CALL refill_rx(5, 5); -- correct, no patient exists
CALL refill_rx(5, 235); -- correct, presc doesn't exist
CALL refill_rx(1, 5); -- correct, refill john's accutane (decrement shows up in prescription med table)

/* --------------------------------------------
ADD INSURANCE POLICY
input; policy_no, insurance_provider_name, account_holder
-------------------------------------------- */
-- Check whether insurance tuple exists 
-- Update patient profile policy number - either overwrite null or overwrite old policy number
DROP PROCEDURE IF EXISTS add_insurance_policy;
DELIMITER //
CREATE PROCEDURE add_insurance_policy(IN patient_id_p INT,
									  IN policy_no_p VARCHAR(64),
                                      IN insurance_provider_name_p VARCHAR(64),
                                      IN account_holder_p VARCHAR(64)
)
BEGIN
	IF CHAR_LENGTH(policy_no_p) < 6 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Policy number must be at least 6 characters', MYSQL_ERRNO = 1644;
	ELSEIF CHAR_LENGTH(policy_no_p) > 12 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Policy number must be less than 12 characters', MYSQL_ERRNO = 1644;
	END IF;
    
    IF EXISTS ( 
		(SELECT 1 FROM insurance_policy
		WHERE (policy_no = policy_no_p))) THEN 
		UPDATE patient_profile SET policy_no = policy_no_p 
		WHERE patient_id = patient_id_p;
	ELSE
		INSERT INTO insurance_policy (policy_no, insurance_provider_name, account_holder)
		VALUES (policy_no_p, insurance_provider_name_p, account_holder_p);
		UPDATE patient_profile SET policy_no = policy_no_p 
		WHERE patient_id = patient_id_p;
	END IF;
END //
DELIMITER ;

/* -----------
ADD INSURANCE POLICY; 
testing testing
----------- */
CALL add_insurance_policy('POL000000000', 'testing insurance', 'bob mcbob'); -- correct
CALL add_insurance_policy('POL0000000', 'TEST', 'Sandy Cheeks'); 


/* --------------------------------------------
MAKE AN APPOINTMENT 
input; apt_date_time, appointment_type, patient_id, npi
-------------------------------------------- */
-- add trigger to add to patient has doctor table

DROP PROCEDURE IF EXISTS schedule_appointment;
DELIMITER //
CREATE PROCEDURE schedule_appointment(IN apt_date_time_p DATETIME,
                                      IN appointment_type_p ENUM ('office visit', 'routine checkup', 'specialist consultation'),
                                      IN patient_id_p INT,
                                      IN npi_p CHAR(10))
BEGIN
	
    DECLARE curr_date_time DATETIME;
    DECLARE apt_date_time_var DATETIME;
    DECLARE patient_id_var INT;
    DECLARE npi_var CHAR(10);
    
    SET curr_date_time = NOW();
    
    -- VALIDATE PARAM VALUES
    IF apt_date_time_p < curr_date_time THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Appointment cannot be in the past.";
	ELSEIF TIME(apt_date_time_p) < '08:00:00' OR TIME(apt_date_time_p) > '17:00:00' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Appointment must be between 8AM and 5PM";
	ELSEIF patient_id_p NOT IN
		(SELECT patient_id FROM patient_profile) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Patient ID not found.";
	ELSEIF npi_p NOT IN
		(SELECT npi FROM doctor) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Doctor NPI not found.";
	ELSEIF EXISTS ( 
		(SELECT 1 FROM appointment
		WHERE (appointment_date_time = apt_date_time_p AND patient_id = patient_id_p))) THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Pre-existing appointment found for patient.";
	ELSEIF EXISTS ( 
		(SELECT 1 FROM appointment
		WHERE (appointment_date_time = apt_date_time_p AND npi = npi_p))) THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Appointment time slot no longer available";
	ELSEIF (MINUTE(apt_date_time_p) NOT IN (0, 30)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Invalid appointment time. Please schedule on the hour or half-hour.";
	END IF;

    INSERT INTO appointment (appointment_date_time, appointment_type, bill_type, patient_id, npi)
    VALUES (apt_date_time_p, appointment_type_p, NULL, patient_id_p, npi_p);
END //
DELIMITER ;

/* -----------
MAKE AN APPOINTMENT 
testing testing
----------- */

CALL schedule_appointment('2023-11-30 14:00:00', 'office visit', 3, 5235678901); -- should fail since in the past
CALL schedule_appointment('2023-12-15 14:00:00', 'office visit', 3, 5235678901); -- Friday December 15 2PM - should work
CALL schedule_appointment('2023-12-15 14:00:00', 'office visit', 3, 6236789012); -- should fail since patient already has apt at that time
CALL schedule_appointment('2023-12-15 17:30:00', 'office visit', 3, 5235678901); -- should fail since after 5PM 
CALL schedule_appointment('2023-12-15 14:00:00', 'office visit', 1, 5265678901); -- should fail since docotor NPI does not exist
CALL schedule_appointment('2023-12-15 14:00:00', 'office visit', 1, 5235678901); -- should fail since second CALL above already created apt with doc at the same time
CALL schedule_appointment('2023-12-12 14:00:00', 'office visit', 1, 5235678901); -- should work - schedule apt with 5235678901
CALL schedule_appointment('2023-12-11 15:00:00', 'specialist consultation', 3, 4234567890); -- should work - adding second doctor for patient 3 
CALL schedule_appointment('2023-12-11 15:00:00', 'specialist', 3, 4234567890); -- should fail - invalid appointment type
CALL schedule_appointment('2023-12-11 15:31:00', 'specialist consultation', 3, 4234567890); -- should fail - hour and half hour only scheduling

/* --------------------------------------------
TRIGGER - Update PATIENT_HAS_DOCTOR when patient schedules apt 
-------------------------------------------- */
DROP TRIGGER patient_has_doctor_update;
DELIMITER //
CREATE TRIGGER patient_has_doctor_update
	AFTER INSERT ON appointment
    FOR EACH ROW
BEGIN
	DECLARE count_records INT;

	-- check to see if patient/doctor record exists
    SELECT COUNT(*) INTO count_records
    FROM patient_has_doctor
    WHERE patient_id = NEW.patient_id AND npi = NEW.npi;
    
    IF count_records = 0 THEN
        INSERT INTO patient_has_doctor (patient_id, npi)
        VALUES (NEW.patient_id, NEW.npi);
    END IF;
END //
DELIMITER ;

/* -----------
TRIGGER TESTING
- Call the schedule_appointment procedure - confirm record added to patient has doctor table 
----------- */
CALL schedule_appointment('2023-12-28 12:00:00', 'follow-up', 3, 5235678901); -- Create follow up apt with same doc, trigger should not work 

/* --------------------------------------------
TRIGGER - Update bill_type when patient schedules apt type 
-------------------------------------------- */
DROP TRIGGER bill_type_update;
DELIMITER //
CREATE TRIGGER bill_type_update
	BEFORE INSERT ON appointment
    FOR EACH ROW
BEGIN
	IF NEW.appointment_type = 'office visit' THEN 
		SET NEW.bill_type = 'office visit';
	ELSEIF NEW.appointment_type = 'routine checkup' THEN 
		SET NEW.bill_type = 'preventative';
	ELSEIF NEW.appointment_type = 'specialist consultation' THEN 
		SET NEW.bill_type = 'specialty';
	END IF;
END //
DELIMITER ;

/* -----------
TRIGGER TESTING
- Call the schedule_appointment procedure - confirm bill type has been updated 
----------- */


/* --------------------------------------------
RESCHEDULE AN APPOINTMENT 
input; 
-------------------------------------------- */
-- similar to delete review, display all appointments and enter in apt id
DROP PROCEDURE IF EXISTS reschedule_appointment;
DELIMITER //
CREATE PROCEDURE reschedule_appointment(IN apt_id_p INT,
                                        IN new_apt_date_time_p DATETIME)
BEGIN
    DECLARE curr_date_time DATETIME;
    DECLARE patient_id_var INT;
    DECLARE npi_var CHAR(10);
    
    SELECT patient_id, npi
    INTO patient_id_var, npi_var
    FROM appointment
    WHERE appointment_id = apt_id_p;
    
    SET curr_date_time = NOW();
    
    -- VALIDATE PARAM VALUES
        -- Check if the appointment to be rescheduled exists
    IF NOT EXISTS (SELECT 1 FROM appointment WHERE appointment_id = apt_id_p) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Appointment not found.", MYSQL_ERRNO = 1644;
    ELSEIF new_apt_date_time_p < curr_date_time THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Appointment cannot be in the past.", MYSQL_ERRNO = 1644;
	ELSEIF TIME(new_apt_date_time_p) < '08:00:00' OR TIME(new_apt_date_time_p) > '17:00:00' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Appointment must be between 8AM and 5PM", MYSQL_ERRNO = 1644;
    ELSEIF EXISTS ( 
		(SELECT 1 FROM appointment
		WHERE (appointment_date_time = new_apt_date_time_p AND patient_id = patient_id_var))) THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Pre-existing appointment found for patient.", MYSQL_ERRNO = 1644;
	ELSEIF EXISTS ( 
		(SELECT 1 FROM appointment
		WHERE (appointment_date_time = new_apt_date_time_p AND npi = npi_var))) THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Appointment time slot no longer available", MYSQL_ERRNO = 1644;
	ELSEIF (MINUTE(new_apt_date_time_p) NOT IN (0, 30)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Invalid appointment time. Please schedule on the hour or half-hour.";
	END IF;

    -- Update the appointment with the new date and time
    UPDATE appointment
    SET appointment_date_time = new_apt_date_time_p
    WHERE appointment_id = apt_id_p;
END //
DELIMITER ;

/* -----------
RESCHEDULE AN APPOINTMENT 
testing testing
----------- */
CALL reschedule_appointment(5, '2023-12-12 09:00:00'); -- Reschedule appointment created in make appointment for patient 3
CALL reschedule_appointment(85, '2023-12-12 09:00:00'); -- Apt id doesnt exist - should not work 
CALL reschedule_appointment(5, '2023-11-12 09:00:00'); -- should not work - apt in past
CALL reschedule_appointment(5, '2023-12-12 07:00:00'); -- should not work - apt outside of 8-5
CALL reschedule_appointment(6, '2023-12-12 09:00:00'); -- should not work - doctor already has appointment at this time
CALL reschedule_appointment(7, '2023-12-12 09:00:00'); -- should not work - patient already has appointment at this time
/* --------------------------------------------
CANCEL AN APPOINTMENT 
input; 
-------------------------------------------- */
-- delete appointment, show all appointments and have them enter in apt id 
DELIMITER //
CREATE PROCEDURE delete_appointment(IN patient_id_p INT,
									IN apt_id_p INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM appointment WHERE appointment_id = apt_id_p) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Appointment not found.", MYSQL_ERRNO = 1644;
	ELSE DELETE FROM appointment 
		WHERE appointment_id = apt_id_p;
	END IF;
END //
DELIMITER ;

/* -----------
CANCEL AN APPOINTMENT 
testing testing
----------- */

CALL delete_appointment(3, 5); -- DELETE apt created for patient 3
CALL delete_appointment(3, 5); -- DELETE apt created for patient 3 - not found now - should not work


/* --------------------------------------------
VIEW APPOINTMENTS
input; patient_id
-------------------------------------------- */
DROP PROCEDURE IF EXISTS view_appointments;
DELIMITER //
CREATE PROCEDURE view_appointments(IN patient_id_p INT)
BEGIN
    SELECT appointment_id, appointment_date_time, appointment_type, bill_type, d.full_name, npi
    FROM appointment
    JOIN doctor d USING(npi)
        WHERE patient_id = patient_id_p;
END //
DELIMITER ;

/* -----------
VIEW APPOINTMENTS
testing testing
----------- */

CALL view_appointments(1); -- should be 4 based on current DB values and test case inserts 
CALL view_appointments(2); -- should be 1 based on current DB values and test case inserts 
CALL view_appointments(3); -- should be 1 based on current DB values and test case inserts 
CALL view_appointments(7); -- patient id does not exist - no results 


-- -------------------------------------------------------------------------------------------------------------
/* --------------------------------------------
ADMIN PROCEDURES
-------------------------------------------- */

/* --------------------------------------------
VIEW ALL PATIENTS
-------------------------------------------- */
DROP PROCEDURE IF EXISTS view_all_patients;
DELIMITER //

CREATE PROCEDURE view_all_patients(IN patient_id_p INT)
BEGIN
    DECLARE is_admin_value BOOLEAN;

    SELECT is_admin INTO is_admin_value
    FROM patient_profile
    WHERE patient_id = patient_id_p;

    IF is_admin_value = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admin access only!', MYSQL_ERRNO = 1644;
    ELSE
		SELECT * FROM patient_profile
        WHERE is_admin = 0;
	END IF;
END //
DELIMITER ;

/* -----------
VIEW ALL PATIENTS
testing testing
----------- */

CALL view_all_patients(4); -- admin ID
CALL view_all_patients(4); -- non admin ID - should not work 

/* --------------------------------------------
VIEW ALL DOCTORS
-------------------------------------------- */

DROP PROCEDURE IF EXISTS view_all_doctors;
DELIMITER //
CREATE PROCEDURE view_all_doctors()
BEGIN
	SELECT * FROM doctor;
END //
DELIMITER ;

/* -----------
VIEW ALL DOCTORS
testing testing
----------- */

CALL view_all_doctors();

/* --------------------------------------------
DELETE PATIENT
-------------------------------------------- */
DROP PROCEDURE IF EXISTS delete_patient;
DELIMITER //
CREATE PROCEDURE delete_patient(IN patient_id_p INT, p_id_p INT)
BEGIN
    DECLARE is_admin_value BOOLEAN;

    SELECT is_admin INTO is_admin_value
    FROM patient_profile
    WHERE patient_id = patient_id_p;

    IF is_admin_value = 1 AND p_id_p != patient_id_p THEN
        DELETE FROM patient_profile
        WHERE patient_id = p_id_p;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admin access only, and cannot delete themselves!', MYSQL_ERRNO = 1644;
    END IF;
END //
DELIMITER ;

/* -----------
DELETE PATIENT
testing testing
----------- */

CALL delete_patient(5,4); -- SHOULD NOT WORK - NOT ADMIN
CALL delete_patient(4,5); -- DELETE DONNA
CALL delete_patient(4,1); -- DELETE JOHN
CALL delete_patient(4,4); -- ADMIN CANNOT DELETE THEMSELF

/* --------------------------------------------
UPDATE PATIENT USERNAME 
input; patient_id, p_id, email
-------------------------------------------- */

DROP PROCEDURE IF EXISTS update_patient_username;
DELIMITER //
CREATE PROCEDURE update_patient_username(IN patient_id_p INT, p_id_p INT, email_p VARCHAR(64))
BEGIN
	DECLARE email_valid BOOLEAN;
    DECLARE is_admin_value BOOLEAN;
    
    SELECT is_admin INTO is_admin_value
    FROM patient_profile
    WHERE patient_id = patient_id_p;
    
    IF is_admin_value = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admin access only!', MYSQL_ERRNO = 1644;
	ELSEIF patient_id_p = p_id_p THEN
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admin cannot change admin username', MYSQL_ERRNO = 1644;
	END IF;
    
	-- Check for valid email
	SET email_valid = LOCATE('@', email_p) > 0 AND LOCATE('.', email_p) > LOCATE('@', email_p);
    
    IF NOT email_valid THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid email format.', MYSQL_ERRNO = 1644;
	ELSEIF EXISTS ( 
		(SELECT 1 FROM patient_profile
		WHERE (email = email_p))) THEN 
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Email is already in use. Please try again.", MYSQL_ERRNO = 1644;
	ELSE
    	-- Update the patient profile
    	UPDATE patient_profile
    	SET email = email_p
    	WHERE patient_id = p_id_p;
	END IF;
END //
DELIMITER ;

/* -----------
UPDATE PATIENT USERNAME
testing testing
----------- */


CALL update_patient_username(2, 3, 'test@email.com'); -- should not work - non admin cannot update 
CALL update_patient_username(4, 4, 'test@email.com'); -- should not work - admin cannot update themselves
CALL update_patient_username(4, 5, 'donnad@gmail.com'); -- should work - update donna's email 
CALL update_patient_username(4, 5, 'donna@gmail.com'); -- should work - reset donna's email
CALL update_patient_username(4, 5, 'hank@email.com'); -- should not work - email already in use 
CALL update_patient_username(4, 5, 'donnaemail.com'); -- should not work - invalid email format

/* --------------------------------------------
UPDATE PATIENT PASSWORD 
input; patient_id, p_id, email
-------------------------------------------- */

DROP PROCEDURE IF EXISTS update_patient_password;
DELIMITER //
CREATE PROCEDURE update_patient_password(IN patient_id_p INT, p_id_p INT, user_password_p VARCHAR(20))
BEGIN
    DECLARE is_admin_value BOOLEAN;
    
    SELECT is_admin INTO is_admin_value
    FROM patient_profile
    WHERE patient_id = patient_id_p;
    
    IF is_admin_value = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admin access only!', MYSQL_ERRNO = 1644;
	ELSEIF patient_id_p = p_id_p THEN
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admin cannot change admin password', MYSQL_ERRNO = 1644;
	END IF;
    

	IF CHAR_LENGTH(user_password_p) < 6 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password must be at least 6 characters', MYSQL_ERRNO = 1644;
	ELSEIF CHAR_LENGTH(user_password_p) > 12 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password must be at less than 12 characters', MYSQL_ERRNO = 1644;
	ELSE
    	-- Update the patient profile
    	UPDATE patient_profile
    	SET user_password = user_password_p
    	WHERE patient_id = p_id_p;
	END IF;
END //
DELIMITER ;

/* -----------
UPDATE PATIENT PASSWORD
testing testing
----------- */

CALL update_patient_password(2, 3, '123223'); -- should not work - non admin cannot update 
CALL update_patient_password(4, 4, '123223'); -- should not work - admin cannot update themselves
CALL update_patient_password(4, 5, '123223'); -- should work - update donna's password 
CALL update_patient_password(4, 5, '123456'); -- should work - reset donna's password 
CALL update_patient_password(4, 5, '12346'); -- should not work - not enough characters
CALL update_patient_password(4, 5, '12345678908743'); -- should not work - too many characters

/* --------------------------------------------
ADD DOCTOR
input; npi, full_name, photo, doctor_gender, provider_type, specialty, office_name)

-------------------------------------------- */
DROP PROCEDURE IF EXISTS create_doctor;
DELIMITER //
CREATE PROCEDURE create_doctor(
	IN npi_p VARCHAR(64),
    IN full_name_p VARCHAR(64),
    IN doctor_gender_p ENUM('male', 'female', 'other'),
    IN provider_type_p ENUM('MD', 'DO', 'NP', 'PA'),
    IN specialty_p VARCHAR(64),
    IN office_name_p VARCHAR(64)
)
BEGIN
    -- Check if the provided office_name exists in the medical_office table
    DECLARE office_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO office_exists
    FROM medical_office
    WHERE office_name = office_name_p;

    IF office_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Office does not exist database.', MYSQL_ERRNO = 1644;
	-- Check if the doctor with the provided NPI already exists
    ELSEIF EXISTS (SELECT * FROM doctor WHERE npi = npi_p) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor with the provided NPI already exists.', MYSQL_ERRNO = 1644;
	ELSEIF CHAR_LENGTH(npi_p) != 10 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'NPI must be 10 characters', MYSQL_ERRNO = 1644;
    ELSE
        -- Insert the new doctor record
        INSERT INTO doctor (npi, full_name, photo, doctor_gender, provider_type, specialty, office_name)
        VALUES (npi_p, full_name_p, NULL, doctor_gender_p, provider_type_p, specialty_p, office_name_p);
    END IF;
END //
DELIMITER ;

/* -----------
CREATE DOCTOR
testing testing
----------- */

CALL create_doctor('1231234567', 'James Marsden', 'male', 'DO','Neurology', 'Healthy Clinic'); -- invalid should not work - npi already exists 
CALL create_doctor('122331234567', 'James Marsden', 'male', 'DO','Neurology', 'Healthy Clinic'); -- invalid npi - too long
CALL create_doctor('122331234567', 'James Marsden', 'male', 'DO','Neurology', 'Healthy Clinic'); -- invalid npi - too short
CALL create_doctor('1233214444','James Marsden', 'male', 'DO','Neurology', 'Clinic'); -- invalid should not work - office does not exist
CALL create_doctor('1233214444', 'James Holiday', 'male', 'DO','Neurology', 'Wellbeing Medical'); -- valid should work 

/* --------------------------------------------
DELETE DOCTOR
input; npi
-------------------------------------------- */
DROP PROCEDURE IF EXISTS delete_doctor;
DELIMITER //
CREATE PROCEDURE delete_doctor(IN npi_p CHAR(10))
BEGIN
    -- Check if the doctor with the specified NPI exists
    DECLARE doctor_exists INT DEFAULT 0;

    SELECT COUNT(*) INTO doctor_exists
    FROM doctor
    WHERE npi = npi_p;

    IF doctor_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor with the specified NPI does not exist', MYSQL_ERRNO = 1644;
    ELSE
        -- Delete the doctor record
        DELETE FROM doctor
        WHERE npi = npi_p;
    END IF;
END //
DELIMITER ;

/* -----------
DELETE DOCTOR
testing testing
----------- */
 
CALL delete_doctor('23232'); -- invalid cannot delete doctor that doesnt exist
CALL delete_doctor('1233214444'); -- works


