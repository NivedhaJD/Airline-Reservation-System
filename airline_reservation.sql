-- ============================================================
-- Airline Reservation System - FULL DATABASE SETUP SCRIPT
-- Run this entire script in MySQL Workbench
-- ============================================================

-- ------------------------------------------------------------
-- Create and select the database
-- ------------------------------------------------------------
DROP DATABASE IF EXISTS Airline_Reservation;
CREATE DATABASE Airline_Reservation;
USE Airline_Reservation;

-- ============================================================
-- TABLE: User
-- ============================================================

CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    dob DATE,
    gender ENUM('Male','Female','Other'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE: Flight
-- ============================================================

CREATE TABLE Flight (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL UNIQUE,
    airline_name VARCHAR(100) NOT NULL,
    origin VARCHAR(100) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    total_seats INT NOT NULL DEFAULT 150,
    available_seats INT NOT NULL DEFAULT 150,
    price DECIMAL(10,2) NOT NULL,
    flight_class ENUM('Economy','Business','First') DEFAULT 'Economy',
    status ENUM('Scheduled','Delayed','Cancelled','Completed') DEFAULT 'Scheduled'
);

-- ============================================================
-- TABLE: Crew
-- ============================================================

CREATE TABLE Crew (
    crew_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('Pilot','Co-Pilot','Flight Attendant','Engineer') NOT NULL,
    employee_id VARCHAR(20) NOT NULL UNIQUE,
    experience INT DEFAULT 0,
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: Ticket
-- ============================================================

CREATE TABLE Ticket (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    flight_id INT NOT NULL,
    seat_number VARCHAR(10),
    booking_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    passenger_name VARCHAR(100) NOT NULL,
    passport_no VARCHAR(30),
    ticket_status ENUM('Confirmed','Cancelled','Pending') DEFAULT 'Confirmed',
    total_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: Food_Ordering
-- ============================================================

CREATE TABLE Food_Ordering (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    user_id INT NOT NULL,
    meal_type ENUM('Vegetarian','Non-Vegetarian','Vegan','Gluten-Free') NOT NULL,
    meal_name VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 1,
    price DECIMAL(6,2) NOT NULL,
    order_status ENUM('Ordered','Confirmed','Cancelled') DEFAULT 'Ordered',
    order_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES Ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- ============================================================
-- SAMPLE USERS
-- ============================================================

INSERT INTO User (full_name,email,password_hash,phone,dob,gender) VALUES
('Rahul Sharma','rahul@gmail.com','hash123','9876543210','1998-04-12','Male'),
('Ananya Iyer','ananya@gmail.com','hash123','9123456780','2000-06-22','Female'),
('David Joseph','david@gmail.com','hash123','9988776655','1995-01-15','Male'),
('Priya Nair','priya@gmail.com','hash123','9765432109','1999-09-05','Female'),
('Arjun Mehta','arjun@gmail.com','hash123','9871234567','1997-11-19','Male'),
('Meera Kapoor','meera@gmail.com','hash123','9001122334','2001-02-08','Female'),
('Rohit Verma','rohit@gmail.com','hash123','9887766554','1996-03-30','Male'),
('Sneha Patel','sneha@gmail.com','hash123','9012345678','2002-05-17','Female'),
('Vikram Singh','vikram@gmail.com','hash123','9898989898','1994-07-11','Male'),
('Aisha Khan','aisha@gmail.com','hash123','9776655443','2000-12-01','Female');

-- ============================================================
-- SAMPLE FLIGHTS
-- ============================================================

INSERT INTO Flight (flight_number,airline_name,origin,destination,departure_time,arrival_time,total_seats,available_seats,price,flight_class,status) VALUES
('AI101','Air India','Mumbai','Delhi','2026-04-10 06:00:00','2026-04-10 08:00:00',180,45,4500,'Economy','Scheduled'),
('AI102','Air India','Delhi','Mumbai','2026-04-10 10:00:00','2026-04-10 12:00:00',180,100,4500,'Economy','Scheduled'),
('6E201','IndiGo','Chennai','Bangalore','2026-04-11 07:30:00','2026-04-11 08:30:00',180,80,2200,'Economy','Scheduled'),
('6E202','IndiGo','Bangalore','Chennai','2026-04-11 14:00:00','2026-04-11 15:00:00',180,60,2200,'Economy','Scheduled'),
('SG301','SpiceJet','Kolkata','Hyderabad','2026-04-12 09:00:00','2026-04-12 11:30:00',150,90,3800,'Economy','Scheduled'),
('UK401','Vistara','Mumbai','London','2026-04-13 23:00:00','2026-04-14 05:00:00',250,30,55000,'Business','Scheduled'),
('AI501','Air India','Delhi','New York','2026-04-14 02:00:00','2026-04-14 14:00:00',300,20,72000,'First','Scheduled'),
('IX601','Air Asia','Pune','Goa','2026-04-15 08:00:00','2026-04-15 09:00:00',160,120,1800,'Economy','Scheduled'),
('G8701','Go First','Ahmedabad','Jaipur','2026-04-15 11:00:00','2026-04-15 12:30:00',150,75,2500,'Economy','Scheduled'),
('SG801','SpiceJet','Hyderabad','Mumbai','2026-04-16 16:00:00','2026-04-16 18:00:00',150,50,3200,'Economy','Scheduled');

-- ============================================================
-- SAMPLE CREW
-- ============================================================

INSERT INTO Crew (flight_id,full_name,role,employee_id,experience) VALUES
(1,'Capt. Rajesh Kumar','Pilot','EMP001',18),
(1,'Capt. Ananya Sharma','Co-Pilot','EMP002',8),
(1,'Priya Mehta','Flight Attendant','EMP003',5),
(2,'Capt. Vikram Singh','Pilot','EMP004',20),
(2,'Capt. Divya Rao','Co-Pilot','EMP005',6),
(3,'Capt. Arjun Pillai','Pilot','EMP006',15),
(3,'Lakshmi Venkat','Flight Attendant','EMP007',2),
(4,'Capt. Ravi Shankar','Pilot','EMP008',22),
(5,'Capt. Sunil Verma','Pilot','EMP009',17),
(6,'Capt. James D Souza','Pilot','EMP010',25);

-- ============================================================
-- SAMPLE TICKETS
-- ============================================================

INSERT INTO Ticket (user_id,flight_id,seat_number,passenger_name,passport_no,total_price) VALUES
(1,1,'12A','Rahul Sharma','P1234567',4500),
(2,3,'14C','Ananya Iyer','P4567891',2200),
(3,5,'8B','David Joseph','P9876543',3800),
(4,2,'10D','Priya Nair','P6543217',4500),
(5,4,'16F','Arjun Mehta','P7778881',2200),
(6,6,'2A','Meera Kapoor','P4443332',55000),
(7,7,'1B','Rohit Verma','P5556663',72000),
(8,8,'18C','Sneha Patel','P3332221',1800),
(9,9,'15E','Vikram Singh','P1112223',2500),
(10,10,'20A','Aisha Khan','P8887776',3200);

-- ============================================================
-- SAMPLE FOOD ORDERS
-- ============================================================

INSERT INTO Food_Ordering (ticket_id,user_id,meal_type,meal_name,quantity,price) VALUES
(1,1,'Vegetarian','Paneer Meal',1,350),
(2,2,'Non-Vegetarian','Chicken Biryani',1,420),
(3,3,'Vegetarian','Veg Sandwich',2,200),
(4,4,'Vegan','Vegan Salad',1,300),
(5,5,'Non-Vegetarian','Grilled Chicken',1,450),
(6,6,'Vegetarian','Pasta Meal',1,380),
(7,7,'Non-Vegetarian','Fish Curry',1,420),
(8,8,'Vegetarian','Veg Noodles',2,240),
(9,9,'Gluten-Free','Gluten Free Salad',1,320),
(10,10,'Vegetarian','Veg Wrap',1,260);

-- ============================================================
-- FINAL VERIFICATION
-- ============================================================

SELECT * FROM User;
SELECT * FROM Flight;
SELECT * FROM Crew;
SELECT * FROM Ticket;
SELECT * FROM Food_Ordering;
SELECT 
U.full_name,
F.flight_number,
F.origin,
F.destination,
T.seat_number,
T.total_price
FROM Ticket T
JOIN User U ON T.user_id = U.user_id
JOIN Flight F ON T.flight_id = F.flight_id;

-- Crew assigned to flights

SELECT 
F.flight_number,
C.full_name,
C.role,
C.experience
FROM Crew C
JOIN Flight F ON C.flight_id = F.flight_id;

-- Food orders with passenger and flight

SELECT 
U.full_name,
F.flight_number,
FO.meal_name,
FO.quantity,
FO.price
FROM Food_Ordering FO
JOIN User U ON FO.user_id = U.user_id
JOIN Ticket T ON FO.ticket_id = T.ticket_id
JOIN Flight F ON T.flight_id = F.flight_id;

-- ============================================================
-- SUBQUERIES
-- ============================================================

-- Most expensive flight

SELECT flight_number, price
FROM Flight
WHERE price = (SELECT MAX(price) FROM Flight);

-- Users who booked tickets

SELECT full_name,email
FROM User
WHERE user_id IN (SELECT user_id FROM Ticket);

-- Flights with below average seat availability

SELECT flight_number,available_seats
FROM Flight
WHERE available_seats < (SELECT AVG(available_seats) FROM Flight);

-- ============================================================
-- AGGREGATION
-- ============================================================

SELECT 
F.flight_number,
COUNT(T.ticket_id) AS total_passengers
FROM Flight F
LEFT JOIN Ticket T ON F.flight_id = T.flight_id
GROUP BY F.flight_number;

-- ============================================================
-- FINAL MESSAGE
-- ============================================================

SELECT 'DATABASE SETUP COMPLETED SUCCESSFULLY' AS STATUS;
SELECT 'Database setup complete!' AS Message;
