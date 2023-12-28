CREATE DATABASE  IF NOT EXISTS `health_ease` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `health_ease`;
-- MySQL dump 10.13  Distrib 8.0.34, for macos13 (arm64)
--
-- Host: localhost    Database: health_ease
-- ------------------------------------------------------
-- Server version	8.0.34

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `appointment`
--

DROP TABLE IF EXISTS `appointment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment` (
  `appointment_id` int NOT NULL AUTO_INCREMENT,
  `appointment_date_time` datetime NOT NULL,
  `appointment_type` enum('office visit','routine checkup','specialist consultation') NOT NULL,
  `bill_type` enum('office visit','preventative','specialty') DEFAULT NULL,
  `patient_id` int DEFAULT NULL,
  `npi` char(10) DEFAULT NULL,
  PRIMARY KEY (`appointment_id`),
  KEY `patient_id` (`patient_id`),
  KEY `npi` (`npi`),
  CONSTRAINT `appointment_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient_profile` (`patient_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `appointment_ibfk_2` FOREIGN KEY (`npi`) REFERENCES `doctor` (`npi`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment`
--

LOCK TABLES `appointment` WRITE;
/*!40000 ALTER TABLE `appointment` DISABLE KEYS */;
INSERT INTO `appointment` VALUES (1,'2023-01-10 09:00:00','routine checkup','preventative',1,'1231234567'),(2,'2023-06-05 11:00:00','specialist consultation','specialty',1,'7237890123'),(3,'2023-08-28 14:30:00','office visit','office visit',1,'7237890123'),(4,'2023-11-29 10:30:00','office visit','office visit',2,'3233456789'),(5,'2023-10-20 11:30:00','office visit','office visit',5,'4234567890'),(6,'2023-12-20 10:00:00','office visit','office visit',5,'4234567890'),(7,'2023-09-20 09:30:00','routine checkup','preventative',5,'1231234567');
/*!40000 ALTER TABLE `appointment` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bill_type_update` BEFORE INSERT ON `appointment` FOR EACH ROW BEGIN
	IF NEW.appointment_type = 'office visit' THEN 
		SET NEW.bill_type = 'office visit';
	ELSEIF NEW.appointment_type = 'routine checkup' THEN 
		SET NEW.bill_type = 'preventative';
	ELSEIF NEW.appointment_type = 'specialist consultation' THEN 
		SET NEW.bill_type = 'specialty';
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `patient_has_doctor_update` AFTER INSERT ON `appointment` FOR EACH ROW BEGIN
	DECLARE count_records INT;

	-- check to see if patient/doctor record exists
    SELECT COUNT(*) INTO count_records
    FROM patient_has_doctor
    WHERE patient_id = NEW.patient_id AND npi = NEW.npi;
    
    IF count_records = 0 THEN
        INSERT INTO patient_has_doctor (patient_id, npi)
        VALUES (NEW.patient_id, NEW.npi);
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `bill`
--

DROP TABLE IF EXISTS `bill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bill` (
  `bill_id` int NOT NULL AUTO_INCREMENT,
  `bill_description` longtext NOT NULL,
  `date_issued` date NOT NULL,
  `due_date` date NOT NULL,
  `total_amount` decimal(8,2) NOT NULL,
  `bill_type` enum('office visit','preventative','specialty') DEFAULT NULL,
  `balance_remaining` decimal(8,2) DEFAULT NULL,
  `office_name` varchar(64) DEFAULT NULL,
  `patient_id` int DEFAULT NULL,
  PRIMARY KEY (`bill_id`),
  KEY `office_name` (`office_name`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `bill_ibfk_1` FOREIGN KEY (`office_name`) REFERENCES `medical_office` (`office_name`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `bill_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patient_profile` (`patient_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bill`
--

LOCK TABLES `bill` WRITE;
/*!40000 ALTER TABLE `bill` DISABLE KEYS */;
INSERT INTO `bill` VALUES (1,'Routine checkup','2023-01-10','2023-01-25',0.00,'preventative',0.00,'Healthy Clinic',1),(2,'Specialist consultation charge','2023-06-05','2023-06-20',40.00,'specialty',40.00,'Healthy Clinic',1),(3,'Follow-up charge','2023-08-28','2023-09-12',40.00,'office visit',40.00,'Healthy Clinic',1),(4,'Office visit charge, non-routine','2023-11-29','2023-12-14',40.00,'office visit',40.00,'Care Center',2),(5,'Office visit charge, non-routine','2023-10-21','2023-12-20',40.00,'office visit',40.00,'Wellbeing Medical',5),(6,'Routine checkup','2023-09-20','2023-10-10',0.00,'preventative',0.00,'Healthy Clinic',5);
/*!40000 ALTER TABLE `bill` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor`
--

DROP TABLE IF EXISTS `doctor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor` (
  `npi` char(10) NOT NULL,
  `full_name` varchar(64) NOT NULL,
  `photo` blob,
  `doctor_gender` enum('male','female','other') NOT NULL,
  `provider_type` enum('MD','DO','NP','PA') NOT NULL,
  `specialty` varchar(64) NOT NULL,
  `office_name` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`npi`),
  KEY `office_name` (`office_name`),
  CONSTRAINT `doctor_ibfk_1` FOREIGN KEY (`office_name`) REFERENCES `medical_office` (`office_name`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor`
--

LOCK TABLES `doctor` WRITE;
/*!40000 ALTER TABLE `doctor` DISABLE KEYS */;
INSERT INTO `doctor` VALUES ('1231234567','Olivia Stevenson',NULL,'female','MD','Internal Medicine','Healthy Clinic'),('2232345678','Sophia Ricardo',NULL,'female','DO','Family Medicine','Care Center'),('3233456789','Emma Williams',NULL,'female','MD','Pediatrics','Care Center'),('4234567890','Liam Miller',NULL,'male','MD','Cardiology','Wellbeing Medical'),('5235678901','Jordan Taylor',NULL,'other','DO','Orthopedics','Care Center'),('6236789012','Ethan Brown',NULL,'male','NP','Family Medicine','Wellbeing Medical'),('7237890123','Avery Clark',NULL,'other','PA','Dermatology','Healthy Clinic');
/*!40000 ALTER TABLE `doctor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor_prescribes`
--

DROP TABLE IF EXISTS `doctor_prescribes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor_prescribes` (
  `patient_id` int NOT NULL,
  `npi` char(10) NOT NULL,
  `rx_id` int NOT NULL,
  `dosage_instructions` longtext NOT NULL,
  `start_date` date NOT NULL,
  `finish_date` date NOT NULL,
  `patient_refill_count` int NOT NULL,
  PRIMARY KEY (`patient_id`,`npi`,`rx_id`),
  KEY `npi` (`npi`),
  KEY `rx_id` (`rx_id`),
  CONSTRAINT `doctor_prescribes_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient_profile` (`patient_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `doctor_prescribes_ibfk_2` FOREIGN KEY (`npi`) REFERENCES `doctor` (`npi`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `doctor_prescribes_ibfk_3` FOREIGN KEY (`rx_id`) REFERENCES `prescription_med` (`rx_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_prescribes`
--

LOCK TABLES `doctor_prescribes` WRITE;
/*!40000 ALTER TABLE `doctor_prescribes` DISABLE KEYS */;
INSERT INTO `doctor_prescribes` VALUES (1,'7237890123',5,'Take 1 pill (20mg) each morning with a fatty meal.','2023-08-28','2024-02-28',4),(2,'3233456789',6,'Take twice a day for 10 days. Be sure to complete the full course of antibiotics.','2023-11-29','2023-12-13',0),(2,'3233456789',7,'Take 1 pill a day untill fever breaks.','2023-11-29','2023-12-06',2),(5,'4234567890',4,'Take 1 pill in the morning every day.','2023-11-29','2024-04-06',3);
/*!40000 ALTER TABLE `doctor_prescribes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `insurance_policy`
--

DROP TABLE IF EXISTS `insurance_policy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `insurance_policy` (
  `policy_no` varchar(64) NOT NULL,
  `insurance_provider_name` varchar(64) NOT NULL,
  `account_holder` varchar(64) NOT NULL,
  PRIMARY KEY (`policy_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `insurance_policy`
--

LOCK TABLES `insurance_policy` WRITE;
/*!40000 ALTER TABLE `insurance_policy` DISABLE KEYS */;
INSERT INTO `insurance_policy` VALUES ('POL123456789','Blue Cross Blue Shield','John Doe'),('POL345678901','Harvard Pilgram','Alex Johnson'),('POL387524321','Harvard Pilgram','Diane Dow'),('POL987654321','Tufts Health Plan','Jane Smith Sr.');
/*!40000 ALTER TABLE `insurance_policy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medical_office`
--

DROP TABLE IF EXISTS `medical_office`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medical_office` (
  `office_name` varchar(64) NOT NULL,
  `street_no` int NOT NULL,
  `street_name` varchar(64) NOT NULL,
  `town` varchar(64) NOT NULL,
  `zipcode` char(5) NOT NULL,
  `phone_no` char(11) NOT NULL,
  PRIMARY KEY (`office_name`),
  UNIQUE KEY `street_no` (`street_no`,`street_name`,`town`,`zipcode`),
  UNIQUE KEY `phone_no` (`phone_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medical_office`
--

LOCK TABLES `medical_office` WRITE;
/*!40000 ALTER TABLE `medical_office` DISABLE KEYS */;
INSERT INTO `medical_office` VALUES ('Care Center',456,'Maple Avenue','Boston','02215','16177789454'),('Healthy Clinic',123,'Main Street','Boston','02215','16177895634'),('Wellbeing Medical',789,'Oak Street','Boston','02215','16173324770');
/*!40000 ALTER TABLE `medical_office` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_has_doctor`
--

DROP TABLE IF EXISTS `patient_has_doctor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_has_doctor` (
  `patient_id` int NOT NULL,
  `npi` char(10) NOT NULL,
  PRIMARY KEY (`patient_id`,`npi`),
  KEY `npi` (`npi`),
  CONSTRAINT `patient_has_doctor_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient_profile` (`patient_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `patient_has_doctor_ibfk_2` FOREIGN KEY (`npi`) REFERENCES `doctor` (`npi`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_has_doctor`
--

LOCK TABLES `patient_has_doctor` WRITE;
/*!40000 ALTER TABLE `patient_has_doctor` DISABLE KEYS */;
INSERT INTO `patient_has_doctor` VALUES (1,'1231234567'),(5,'1231234567'),(2,'3233456789'),(5,'4234567890'),(1,'7237890123');
/*!40000 ALTER TABLE `patient_has_doctor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_profile`
--

DROP TABLE IF EXISTS `patient_profile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_profile` (
  `patient_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(64) NOT NULL,
  `last_name` varchar(64) NOT NULL,
  `date_of_birth` date NOT NULL,
  `gender` enum('male','female','other','prefer not to say') DEFAULT NULL,
  `email` varchar(64) NOT NULL,
  `phone_no` char(11) DEFAULT NULL,
  `credit_card_no` char(16) DEFAULT NULL,
  `emergency_contact_name` varchar(64) DEFAULT NULL,
  `emergency_contact_no` char(11) DEFAULT NULL,
  `policy_no` char(12) DEFAULT NULL,
  `user_password` varchar(20) DEFAULT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`patient_id`),
  UNIQUE KEY `email` (`email`),
  KEY `policy_no` (`policy_no`),
  CONSTRAINT `patient_profile_ibfk_1` FOREIGN KEY (`policy_no`) REFERENCES `insurance_policy` (`policy_no`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_profile`
--

LOCK TABLES `patient_profile` WRITE;
/*!40000 ALTER TABLE `patient_profile` DISABLE KEYS */;
INSERT INTO `patient_profile` VALUES (1,'John','Doe','1990-05-15','male','john.doe@email.com','12345678901','1234567890123456','Jane Doe','16175432101','POL123456789','password123$',0),(2,'Jane','Smith','2001-08-22','female','jane.smith@email.com','98765432109','9876543210987654','John Smith','16175678902','POL987654321','howdy123$',0),(3,'Alex','Johnson','1995-03-10','other','alex.johnson@email.com','23456789012','3456789012345678','Amy Johnson','16171234503','POL345678901','test987!',0),(4,'Portal','Admin','1980-01-15','male','portaladmin@healthease.com','6178887676',NULL,NULL,NULL,NULL,'strongpass!',1),(5,'Donna','Dow','1965-04-10','female','donna@gmail.com','16178876576','1234567654382398','Diane Dow','16175554343','POL387524321','123456',0);
/*!40000 ALTER TABLE `patient_profile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prescription_med`
--

DROP TABLE IF EXISTS `prescription_med`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prescription_med` (
  `rx_id` int NOT NULL AUTO_INCREMENT,
  `rx_name` varchar(64) NOT NULL,
  `refill_count` int NOT NULL,
  PRIMARY KEY (`rx_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescription_med`
--

LOCK TABLES `prescription_med` WRITE;
/*!40000 ALTER TABLE `prescription_med` DISABLE KEYS */;
INSERT INTO `prescription_med` VALUES (1,'Lisinopril',2),(2,'Levothyroxine',3),(3,'Metformin',2),(4,'Atorvastatin',1),(5,'Isotretinoin',4),(6,'Amoxicillin',0),(7,'Acetaminophen',2);
/*!40000 ALTER TABLE `prescription_med` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review`
--

DROP TABLE IF EXISTS `review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `review` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `star_rating` int DEFAULT NULL,
  `comments` longtext,
  `review_date` date NOT NULL,
  `patient_id` int DEFAULT NULL,
  `npi` char(10) DEFAULT NULL,
  PRIMARY KEY (`review_id`),
  KEY `patient_id` (`patient_id`),
  KEY `npi` (`npi`),
  CONSTRAINT `review_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patient_profile` (`patient_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `review_ibfk_2` FOREIGN KEY (`npi`) REFERENCES `doctor` (`npi`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review`
--

LOCK TABLES `review` WRITE;
/*!40000 ALTER TABLE `review` DISABLE KEYS */;
INSERT INTO `review` VALUES (1,4,'Dr. Clark was very informative and helpful during my appointment.','2023-08-31',1,'7237890123'),(2,3,'The wait time at Dr. Williams\'s office was a bit long, but the doctor was knowledgeable.','2023-03-10',2,'3233456789'),(3,5,'I appreciate Dr. Stevenson\'s thorough explanations and friendly demeanor. Highly recommend!','2023-04-05',1,'1231234567'),(4,3,'Dr. Miller is great, but he has me on too many pills!','2023-04-05',5,'4234567890'),(5,4,'Big fan of Dr. Stevenson','2023-09-21',5,'1231234567');
/*!40000 ALTER TABLE `review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'health_ease'
--

--
-- Dumping routines for database 'health_ease'
--
/*!50003 DROP FUNCTION IF EXISTS `doc_avg_star_rating` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `doc_avg_star_rating`(full_name_p VARCHAR(64)) RETURNS decimal(5,4)
    DETERMINISTIC
BEGIN
		DECLARE ret_value DECIMAL(5,4) DEFAULT 0;
        
		SELECT AVG(doc_star_ratings.avg_star_rating) INTO ret_value FROM 
		( SELECT full_name, AVG(review.star_rating) AS avg_star_rating
			FROM doctor
			LEFT JOIN review USING(npi)
			WHERE full_name = full_name_p
			GROUP BY full_name ) as doc_star_ratings ;

	RETURN(ret_value);
	END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `add_insurance_policy` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_insurance_policy`(IN patient_id_p INT,
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_account` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_account`(OUT patient_id_p INT, IN first_name_p VARCHAR(64), last_name_p VARCHAR(64),
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
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_doctor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_doctor`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `create_review` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_review`(IN patient_id_p INT,
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_appointment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_appointment`(IN patient_id_p INT,
									IN apt_id_p INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM appointment WHERE appointment_id = apt_id_p) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Appointment not found.", MYSQL_ERRNO = 1644;
	ELSE DELETE FROM appointment 
		WHERE appointment_id = apt_id_p;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_doctor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_doctor`(IN npi_p CHAR(10))
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_patient` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_patient`(IN patient_id_p INT, p_id_p INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `delete_review` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_review`(IN patient_id_p INT,
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `find_doctor` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `find_doctor`(IN specialty_p VARCHAR(64), IN doctor_name_p VARCHAR(64))
BEGIN
    SELECT doctor.*, AVG(r.star_rating) as avg_rating
    FROM doctor
    LEFT JOIN review r USING(npi)
    WHERE (specialty = specialty_p OR specialty_p IS NULL)
      AND (full_name LIKE CONCAT('%', doctor_name_p, '%') OR doctor_name_p IS NULL)
	GROUP BY npi, full_name, photo, doctor_gender, provider_type, specialty, office_name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `get_patient_reviews` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_patient_reviews`(IN patient_id_p INT)
BEGIN
    SELECT review_id, star_rating, comments, review_date, npi
    FROM review
    WHERE patient_id = patient_id_p;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `pay_bill` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `pay_bill`(IN patient_id_p INT,
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `refill_rx` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `refill_rx`(IN patient_id_p INT,
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `reschedule_appointment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `reschedule_appointment`(IN apt_id_p INT,
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `schedule_appointment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `schedule_appointment`(IN apt_date_time_p DATETIME,
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_account` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_account`(IN patient_id_p INT, IN gender_p ENUM('male', 'female', 'other', 'prefer not to say'), phone_no_p CHAR(11),
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_patient_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_patient_password`(IN patient_id_p INT, p_id_p INT, user_password_p VARCHAR(20))
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `update_patient_username` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_patient_username`(IN patient_id_p INT, p_id_p INT, email_p VARCHAR(64))
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_all_doctors` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_all_doctors`()
BEGIN
	SELECT * FROM doctor;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_all_patients` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_all_patients`(IN patient_id_p INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_appointments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_appointments`(IN patient_id_p INT)
BEGIN
    SELECT appointment_id, appointment_date_time, appointment_type, bill_type, d.full_name, npi
    FROM appointment
    JOIN doctor d USING(npi)
        WHERE patient_id = patient_id_p;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_bills` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_bills`(IN patient_id_p INT)
BEGIN
    SELECT *
    FROM bill AS b
    WHERE b.patient_id = patient_id_p;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_profile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_profile`(IN patient_id_p INT)
BEGIN
    SELECT patient_id, first_name, last_name, date_of_birth, gender, 
		   email, phone_no, credit_card_no, emergency_contact_name, 
           emergency_contact_no, policy_no 
        FROM patient_profile
        WHERE patient_id = patient_id_p;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_reviews` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_reviews`(IN full_name_p VARCHAR(64))
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `view_rx` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `view_rx`(IN patient_id_p INT)
BEGIN
	SELECT pm.rx_id, pm.rx_name, dp.patient_refill_count, dp.dosage_instructions, dp.start_date, dp.finish_date
    FROM prescription_med AS pm
    JOIN doctor_prescribes AS dp
    ON pm.rx_id = dp.rx_id
    WHERE dp.patient_id = patient_id_p;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-12-08 15:57:16
