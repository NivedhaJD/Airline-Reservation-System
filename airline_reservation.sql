-- ============================================================
-- AIRLINE RESERVATION SYSTEM - COMPLETE DATABASE SCRIPT
-- ============================================================

-- =========================
-- 1 DATABASE CREATION
-- =========================

DROP DATABASE IF EXISTS Airline_Reservation;
CREATE DATABASE Airline_Reservation;
USE Airline_Reservation;

-- =========================
-- 2 TABLE CREATION
-- =========================

CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    dob DATE,
    gender ENUM('Male','Female','Other'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Flight (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) UNIQUE,
    airline_name VARCHAR(100),
    origin VARCHAR(100),
    destination VARCHAR(100),
    departure_time DATETIME,
    arrival_time DATETIME,
    total_seats INT DEFAULT 150,
    available_seats INT DEFAULT 150,
    price DECIMAL(10,2),
    flight_class ENUM('Economy','Business','First')
);

CREATE TABLE Crew (
    crew_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT,
    full_name VARCHAR(100),
    role VARCHAR(50),
    employee_id VARCHAR(20) UNIQUE,
    experience INT,
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id)
);

CREATE TABLE Ticket (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    flight_id INT,
    seat_number VARCHAR(10),
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    passenger_name VARCHAR(100),
    passport_no VARCHAR(30),
    total_price DECIMAL(10,2),
    ticket_status VARCHAR(20) DEFAULT 'Confirmed',
    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id)
);

CREATE TABLE Food_Ordering (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT,
    user_id INT,
    meal_type VARCHAR(50),
    meal_name VARCHAR(100),
    quantity INT,
    price DECIMAL(6,2),
    FOREIGN KEY (ticket_id) REFERENCES Ticket(ticket_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- =========================
-- 3 CONSTRAINTS
-- =========================

ALTER TABLE Flight
ADD CONSTRAINT chk_price CHECK (price > 0);

ALTER TABLE Flight
ADD CONSTRAINT chk_seats CHECK (available_seats >= 0);

ALTER TABLE Ticket
ADD CONSTRAINT chk_ticket_price CHECK (total_price > 0);

-- =========================
-- 4 SAMPLE DATA
-- =========================

INSERT INTO User(full_name,email,password_hash) VALUES
('Rahul Sharma','rahul@gmail.com','hash123'),
('Ananya Iyer','ananya@gmail.com','hash123'),
('David Joseph','david@gmail.com','hash123'),
('Priya Nair','priya@gmail.com','hash123');

INSERT INTO Flight(flight_number,airline_name,origin,destination,price,available_seats,departure_time,arrival_time,flight_class) VALUES
('AI101','Air India','Mumbai','Delhi',4500,50,'2026-05-10 10:00:00','2026-05-10 12:30:00','Economy'),
('6E201','IndiGo','Chennai','Bangalore',2200,70,'2026-05-12 14:00:00','2026-05-12 15:30:00','Business'),
('SG301','SpiceJet','Kolkata','Hyderabad',3800,40,'2026-05-15 18:00:00','2026-05-15 20:15:00','Economy'),
('UK405','Vistara','Delhi','Mumbai',6000,100,'2026-05-11 08:00:00','2026-05-11 10:15:00','Business'),
('AI802','Air India','Bangalore','Delhi',5500,80,'2026-05-13 16:00:00','2026-05-13 18:45:00','Economy'),
('6E502','IndiGo','Hyderabad','Chennai',1800,60,'2026-05-16 09:30:00','2026-05-16 10:45:00','Economy'),
('QP110','Akasa Air','Mumbai','Bangalore',3200,120,'2026-05-20 07:00:00','2026-05-20 08:45:00','Economy'),
('AIX55','Air India Express','Delhi','Kochi',5200,95,'2026-05-21 11:30:00','2026-05-21 14:45:00','Economy'),
('6E982','IndiGo','Mumbai','Goa',2800,110,'2026-05-22 15:00:00','2026-05-22 16:15:00','Economy'),
('UK224','Vistara','Bangalore','Mumbai',7500,40,'2026-05-23 10:30:00','2026-05-23 12:15:00','First'),
('SG882','SpiceJet','Ahmedabad','Mumbai',2400,85,'2026-05-24 20:00:00','2026-05-24 21:10:00','Economy'),
('AI442','Air India','Kolkata','Delhi',4800,75,'2026-05-25 13:45:00','2026-05-25 16:15:00','Business');

INSERT INTO Crew(flight_id,full_name,role,employee_id,experience) VALUES
(1,'Capt. Rajesh Kumar','Pilot','EMP001',18),
(1,'Ananya Sharma','Co-Pilot','EMP002',8),
(2,'Arjun Pillai','Pilot','EMP003',12),
(4,'Capt. Vikram Singh','Pilot','EMP004',20),
(4,'Neha Desai','Cabin Crew','EMP005',5),
(5,'Capt. Suresh','Pilot','EMP006',15),
(5,'Maya Menon','Cabin Crew','EMP007',7),
(6,'Aditi Rao','Co-Pilot','EMP008',6),
(6,'Rahul Verma','Cabin Crew','EMP009',3),
(2,'Sarah Thomas','Cabin Crew','EMP010',4),
(3,'Capt. Anil Kapoor','Pilot','EMP011',22),
(3,'Kavita Singh','Cabin Crew','EMP012',6),
(1,'Rohan Joshi','Cabin Crew','EMP013',3),
(3,'Pooja Hegde','Co-Pilot','EMP014',5);

INSERT INTO Ticket(user_id,flight_id,seat_number,passenger_name,passport_no,total_price) VALUES
(1,1,'12A','Rahul Sharma','P123456',4500),
(2,2,'14C','Ananya Iyer','P654321',2200),
(3,3,'10B','David Joseph','P998877',3800);

INSERT INTO Food_Ordering(ticket_id,user_id,meal_type,meal_name,quantity,price) VALUES
(1,1,'Vegetarian','Paneer Meal',1,350),
(2,2,'Non-Vegetarian','Chicken Biryani',1,420),
(3,3,'Vegetarian','Veg Sandwich',2,200);
-- =========================================
-- AGGREGATE FUNCTION QUERIES
-- =========================================

-- 1 Total number of users
SELECT COUNT(*) AS Total_Users
FROM `User`;

-- 2 Average flight price
SELECT AVG(price) AS Average_Flight_Price
FROM Flight;

-- 3 Maximum ticket price
SELECT MAX(total_price) AS Highest_Ticket_Price
FROM Ticket;

SELECT * FROM `User`;
SELECT * FROM Flight;
SELECT * FROM Ticket;


-- =========================================
-- SET OPERATIONS (Using UNION)
-- =========================================

-- 1 List all origins and destinations
SELECT origin AS City FROM Flight
UNION
SELECT destination FROM Flight;

-- 2 Passenger names and crew names
SELECT passenger_name AS Name FROM Ticket
UNION
SELECT full_name FROM Crew;

-- 3 Users who booked tickets or ordered food
SELECT user_id FROM Ticket
UNION
SELECT user_id FROM Food_Ordering;

SELECT * FROM Flight;
SELECT * FROM Ticket;
SELECT * FROM Crew;
SELECT * FROM Food_Ordering;


-- =========================================
-- SUBQUERIES
-- =========================================

-- 1 Flights with price above average
SELECT flight_number, price
FROM Flight
WHERE price > (SELECT AVG(price) FROM Flight);

-- 2 Users who booked tickets
SELECT full_name
FROM `User`
WHERE user_id IN (SELECT user_id FROM Ticket);

-- 3 Flights with highest price
SELECT flight_number
FROM Flight
WHERE price = (SELECT MAX(price) FROM Flight);

SELECT * FROM `User`;
SELECT * FROM Flight;
SELECT * FROM Ticket;


-- =========================================
-- JOINS
-- =========================================

-- 1 User with their ticket
SELECT u.full_name, t.passenger_name, t.seat_number
FROM `User` u
JOIN Ticket t ON u.user_id = t.user_id;

-- 2 Ticket with flight details
SELECT t.ticket_id, f.flight_number, f.origin, f.destination
FROM Ticket t
JOIN Flight f ON t.flight_id = f.flight_id;

-- 3 Food orders with user
SELECT u.full_name, fo.meal_name, fo.quantity
FROM Food_Ordering fo
JOIN `User` u ON fo.user_id = u.user_id;

SELECT * FROM `User`;
SELECT * FROM Ticket;
SELECT * FROM Flight;
SELECT * FROM Food_Ordering;


-- =========================================
-- VIEWS
-- =========================================

-- Passenger flight details view
CREATE VIEW passenger_flight_view AS
SELECT u.full_name, t.passenger_name, f.flight_number
FROM `User` u
JOIN Ticket t ON u.user_id = t.user_id
JOIN Flight f ON t.flight_id = f.flight_id;

SELECT * FROM passenger_flight_view;

-- Flight booking summary
CREATE VIEW flight_booking_summary AS
SELECT f.flight_number, COUNT(t.ticket_id) AS total_bookings
FROM Flight f
LEFT JOIN Ticket t ON f.flight_id = t.flight_id
GROUP BY f.flight_number;

SELECT * FROM flight_booking_summary;

-- Food order view
CREATE VIEW food_order_details AS
SELECT u.full_name, fo.meal_name, fo.quantity
FROM Food_Ordering fo
JOIN `User` u ON fo.user_id = u.user_id;

SELECT * FROM food_order_details;


-- =========================================
-- TRIGGERS
-- =========================================

DELIMITER $$

CREATE TRIGGER reduce_seats
AFTER INSERT ON Ticket
FOR EACH ROW
BEGIN
UPDATE Flight
SET available_seats = available_seats - 1
WHERE flight_id = NEW.flight_id;
END$$

DELIMITER ;

SELECT * FROM Flight;


DELIMITER $$

CREATE TRIGGER check_seat_availability
BEFORE INSERT ON Ticket
FOR EACH ROW
BEGIN
IF (SELECT available_seats FROM Flight WHERE flight_id = NEW.flight_id) <= 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'No seats available for this flight';
END IF;
END$$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER set_booking_date
BEFORE INSERT ON Ticket
FOR EACH ROW
BEGIN
SET NEW.booking_date = NOW();
END$$

DELIMITER ;

SELECT * FROM Ticket;


-- =========================================
-- CURSOR PROCEDURES
-- =========================================

DELIMITER $$

CREATE PROCEDURE passenger_flight_cursor()
BEGIN

DECLARE done INT DEFAULT 0;
DECLARE pname VARCHAR(100);
DECLARE fnum VARCHAR(10);

DECLARE cur CURSOR FOR
SELECT passenger_name, flight_number
FROM Ticket t
JOIN Flight f ON t.flight_id = f.flight_id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

OPEN cur;

read_loop: LOOP
FETCH cur INTO pname, fnum;

IF done THEN
LEAVE read_loop;
END IF;

SELECT pname AS Passenger_Name, fnum AS Flight_Number;

END LOOP;

CLOSE cur;

END$$

DELIMITER ;

CALL passenger_flight_cursor();

SELECT * FROM Ticket;


DELIMITER $$

CREATE PROCEDURE total_ticket_revenue()
BEGIN

DECLARE done INT DEFAULT 0;
DECLARE price DECIMAL(10,2);
DECLARE total DECIMAL(10,2) DEFAULT 0;

DECLARE cur CURSOR FOR
SELECT total_price FROM Ticket;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

OPEN cur;

read_loop: LOOP

FETCH cur INTO price;

IF done THEN
LEAVE read_loop;
END IF;

SET total = total + price;

END LOOP;

CLOSE cur;

SELECT total AS Total_Revenue;

END$$

DELIMITER ;

CALL total_ticket_revenue();

SELECT * FROM Ticket;


-- =========================================
-- EXCEPTION HANDLING
-- =========================================

DELIMITER $$

CREATE PROCEDURE add_user(
IN name VARCHAR(100),
IN mail VARCHAR(100),
IN pass VARCHAR(255)
)

BEGIN

DECLARE EXIT HANDLER FOR 1062
BEGIN
SELECT 'Error: Email already exists' AS Message;
END;

INSERT INTO `User`(full_name,email,password_hash)
VALUES(name,mail,pass);

SELECT 'User Added Successfully' AS Message;

END$$

DELIMITER ;

CALL add_user('Rahul Sharma','rahul@gmail.com','abc123');

SELECT * FROM `User`;


DELIMITER $$

CREATE PROCEDURE book_ticket(
IN uid INT,
IN fid INT,
IN seat VARCHAR(10),
IN pname VARCHAR(100),
IN passno VARCHAR(30),
IN price DECIMAL(10,2)
)

BEGIN

DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
SELECT 'Booking failed due to invalid flight or user' AS Message;
END;

INSERT INTO Ticket(user_id,flight_id,seat_number,passenger_name,passport_no,total_price)
VALUES(uid,fid,seat,pname,passno,price);

SELECT 'Ticket booked successfully' AS Message;

END$$

DELIMITER ;

CALL book_ticket(1,1,'A15','Rahul Kumar','P987654',5000);

SELECT * FROM Ticket;
SELECT 'DATABASE SETUP COMPLETED SUCCESSFULLY' AS STATUS;
 
select user_id, total_price from ticket where total_price=(select MAX(total_price) from ticket);
USE airline_reservation;

-- =========================================================
-- 0. SETTINGS
-- =========================================================
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

-- =========================================================
-- 1. DROP FOREIGN KEYS (SAFE)
-- =========================================================

SET @fk := (
SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA='airline_reservation'
AND TABLE_NAME='ticket'
AND CONSTRAINT_NAME='fk_ticket_passenger');

SET @q := IF(@fk>0,
'ALTER TABLE ticket DROP FOREIGN KEY fk_ticket_passenger;',
'SELECT 1;');
PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

SET @fk := (
SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA='airline_reservation'
AND TABLE_NAME='food_ordering'
AND CONSTRAINT_NAME='fk_food_meal');

SET @q := IF(@fk>0,
'ALTER TABLE food_ordering DROP FOREIGN KEY fk_food_meal;',
'SELECT 1;');
PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

SET @fk := (
SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA='airline_reservation'
AND TABLE_NAME='flight'
AND CONSTRAINT_NAME='fk_flight_airline');

SET @q := IF(@fk>0,
'ALTER TABLE flight DROP FOREIGN KEY fk_flight_airline;',
'SELECT 1;');
PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

-- =========================================================
-- 2. DROP TABLES
-- =========================================================
DROP TABLE IF EXISTS Flight_Crew;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Meal;
DROP TABLE IF EXISTS Airline;
DROP TABLE IF EXISTS Passenger;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- 3. PASSENGER (3NF)
-- =========================================================
CREATE TABLE Passenger (
passport_no VARCHAR(20) PRIMARY KEY,
passenger_name VARCHAR(100)
);

SET @col := (
SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='airline_reservation'
AND TABLE_NAME='ticket'
AND COLUMN_NAME='passenger_name');

SET @q := IF(@col>0,
'INSERT INTO Passenger (passport_no, passenger_name)
 SELECT DISTINCT passport_no, passenger_name FROM ticket WHERE passport_no IS NOT NULL;',
'INSERT INTO Passenger (passport_no, passenger_name)
 SELECT DISTINCT passport_no, "UNKNOWN" FROM ticket WHERE passport_no IS NOT NULL;');

PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

SET @q := IF(@col>0,
'ALTER TABLE ticket DROP COLUMN passenger_name;',
'SELECT 1;');
PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

ALTER TABLE ticket
ADD CONSTRAINT fk_ticket_passenger
FOREIGN KEY (passport_no) REFERENCES Passenger(passport_no);
-- =========================================================
-- 4. EMPLOYEE + FLIGHT_CREW (BCNF + 5NF)
-- =========================================================
CREATE TABLE Employee (
employee_id VARCHAR(10) PRIMARY KEY,
full_name VARCHAR(100),
role VARCHAR(50),
experience INT
);

SET @crew := (
SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA='airline_reservation'
AND TABLE_NAME='crew');

SET @q := IF(@crew>0,
'INSERT INTO Employee (employee_id, full_name, role, experience)
 SELECT DISTINCT employee_id, full_name, role, experience FROM crew;',
'SELECT 1;');

PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

CREATE TABLE Flight_Crew (
flight_id INT,
employee_id VARCHAR(10),
PRIMARY KEY (flight_id, employee_id),
FOREIGN KEY (flight_id) REFERENCES flight(flight_id),
FOREIGN KEY (employee_id) REFERENCES Employee(employee_id)
);

SET @q := IF(@crew>0,
'INSERT INTO Flight_Crew (flight_id, employee_id)
 SELECT flight_id, employee_id FROM crew;',
'SELECT 1;');

PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

SET @q := IF(@crew>0,
'DROP TABLE crew;',
'SELECT 1;');

PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

-- =========================================================
-- 5. MEAL + FOOD_ORDERING (3NF + 4NF) FINAL SAFE
-- =========================================================
CREATE TABLE Meal (
meal_id INT AUTO_INCREMENT PRIMARY KEY,
meal_name VARCHAR(100),
meal_type VARCHAR(50),
price DECIMAL(10,2)
);

SET @col := (
SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='airline_reservation'
AND TABLE_NAME='food_ordering'
AND COLUMN_NAME='meal_name');

SET @q := IF(@col>0,
'INSERT INTO Meal (meal_name, meal_type, price)
 SELECT DISTINCT meal_name, meal_type, price FROM food_ordering;',
'SELECT 1;');

PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

SET @col2 := (
SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='food_ordering'
AND COLUMN_NAME='meal_id');

SET @q := IF(@col2=0,
'ALTER TABLE food_ordering ADD COLUMN meal_id INT;',
'SELECT 1;');

PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

SET @q := IF(@col>0,
'UPDATE food_ordering f
 JOIN Meal m
 ON f.meal_name=m.meal_name
 AND f.meal_type=m.meal_type
 AND f.price=m.price
 SET f.meal_id=m.meal_id;',
'SELECT 1;');

PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

SET @q := IF(@col>0,
'ALTER TABLE food_ordering 
 DROP COLUMN meal_name, 
 DROP COLUMN meal_type, 
 DROP COLUMN price;',
'SELECT 1;');

PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

-- 🔥 FIX FK ISSUE
UPDATE food_ordering
SET meal_id = NULL
WHERE meal_id IS NOT NULL
AND meal_id NOT IN (SELECT meal_id FROM Meal);

INSERT INTO Meal (meal_name, meal_type, price)
VALUES ('Default Meal', 'Unknown', 0);

SET @default_id = LAST_INSERT_ID();

UPDATE food_ordering
SET meal_id = @default_id
WHERE meal_id IS NULL;

ALTER TABLE food_ordering
ADD CONSTRAINT fk_food_meal
FOREIGN KEY (meal_id) REFERENCES Meal(meal_id);

-- =========================================================
-- 6. AIRLINE (3NF)
-- =========================================================
CREATE TABLE Airline (
airline_id INT AUTO_INCREMENT PRIMARY KEY,
airline_name VARCHAR(100)
);

INSERT INTO Airline (airline_name)
SELECT DISTINCT airline_name FROM flight;

SET @col := (
SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='flight'
AND COLUMN_NAME='airline_id');

SET @q := IF(@col=0,
'ALTER TABLE flight ADD COLUMN airline_id INT;',
'SELECT 1;');

PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

UPDATE flight f
JOIN Airline a
ON f.airline_name = a.airline_name
SET f.airline_id = a.airline_id;

SET @col := (
SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='flight'
AND COLUMN_NAME='airline_name');

SET @q := IF(@col>0,
'ALTER TABLE flight DROP COLUMN airline_name;',
'SELECT 1;');

PREPARE s FROM @q; EXECUTE s; DEALLOCATE PREPARE s;

ALTER TABLE flight
ADD CONSTRAINT fk_flight_airline
FOREIGN KEY (airline_id) REFERENCES Airline(airline_id);

-- =========================================================
-- DONE
-- =========================================================
SET SQL_SAFE_UPDATES = 1;

SELECT * FROM Passenger;
SELECT * FROM Employee;
SELECT * FROM Flight_Crew;
SELECT * FROM Meal;
SELECT * FROM Airline;
START TRANSACTION;
-- Complete Ticket Booking Process
-- Step 1: Check available seats
SELECT available_seats 
FROM flight 
WHERE flight_id = 1;

-- Step 2: Lock the row to prevent double booking
SELECT * 
FROM flight 
WHERE flight_id = 1 
FOR UPDATE;

-- Step 3: Insert new ticket
INSERT INTO ticket (user_id, flight_id, seat_number, booking_date, passport_no, total_price)
VALUES (1, 1, '16A', NOW(), 'P123456', 4500);

-- Step 4: Reduce available seats
UPDATE flight
SET available_seats = available_seats - 1
WHERE flight_id = 1;

-- Step 5: Confirm booking
COMMIT;

START TRANSACTION;

-- Step 1: Lock ticket row
SELECT * 
FROM ticket 
WHERE ticket_id = 1 
FOR UPDATE;

-- Step 2: Check if new seat is already taken
SELECT * 
FROM ticket 
WHERE flight_id = 1 AND seat_number = '18B';

-- Step 3: Update seat if available
UPDATE ticket
SET seat_number = '18B'
WHERE ticket_id = 1;

-- Step 4: Commit changes
COMMIT;


START TRANSACTION;

-- Step 1: Lock the ticket row
SELECT * 
FROM ticket 
WHERE ticket_id = 2 
FOR UPDATE;

-- Step 2: Delete dependent food orders first
DELETE FROM food_ordering
WHERE ticket_id = 2;

-- Step 3: Delete ticket
DELETE FROM ticket
WHERE ticket_id = 2;

-- Step 4: Increase available seats
UPDATE flight
SET available_seats = available_seats + 1
WHERE flight_id = 2;

-- Step 5: Commit changes
COMMIT;

START TRANSACTION;

-- Lock ticket
SELECT * FROM ticket WHERE ticket_id = 2 FOR UPDATE;

-- Delete child + parent
DELETE FROM food_ordering WHERE ticket_id = 2;
DELETE FROM ticket WHERE ticket_id = 2;

-- Increase seats
UPDATE flight
SET available_seats = available_seats + 1
WHERE flight_id = 2;

-- Simulate failure
ROLLBACK;

START TRANSACTION;

-- Step 1: Lock ticket for ordering
SELECT * 
FROM ticket 
WHERE ticket_id = 1 
FOR UPDATE;

-- Step 2: Insert multiple food items
INSERT INTO food_ordering (ticket_id, user_id, meal_id, quantity)
VALUES (1, 1, 1, 2);

INSERT INTO food_ordering (ticket_id, user_id, meal_id, quantity)
VALUES (1, 1, 1, 1);

-- Step 3: Check order summary
SELECT * 
FROM food_ordering 
WHERE ticket_id = 1;

-- Step 4: Commit order
COMMIT;

START TRANSACTION;

-- Step 1: Lock flight row
SELECT *
FROM flight
WHERE flight_id = 1
FOR UPDATE;

-- Step 2: Update flight price
UPDATE flight
SET price = price + 500
WHERE flight_id = 1;

-- Step 3: Savepoint
SAVEPOINT sp_update;

-- Step 4: Update with VALID ENUM value
UPDATE flight
SET flight_class = 'Business'
WHERE flight_id = 1;

-- Step 5: Rollback only last change
ROLLBACK TO sp_update;

-- Step 6: Final commit
COMMIT;

START TRANSACTION;

SELECT * FROM ticket
WHERE ticket_id = 1
FOR UPDATE;

LOCK TABLES ticket WRITE;

UPDATE ticket SET total_price = 6000 WHERE ticket_id = 1;

UNLOCK TABLES;

COMMIT;

ROLLBACK;

START TRANSACTION;

-- Lock the flight row
SELECT * 
FROM flight 
WHERE flight_id = 1 
FOR UPDATE;

-- Update price
UPDATE flight
SET price = price + 500
WHERE flight_id = 1;

COMMIT;

START TRANSACTION;

-- Try to access same flight
SELECT * 
FROM flight 
WHERE flight_id = 1 
FOR UPDATE;

-- This waits until Transaction A completes

-- Insert booking
INSERT INTO ticket (user_id, flight_id, seat_number, booking_date, passport_no, total_price)
VALUES (1, 1, '20A', NOW(), 'P123456', 5000);

COMMIT;

