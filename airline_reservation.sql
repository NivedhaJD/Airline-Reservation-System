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

INSERT INTO Flight(flight_number,airline_name,origin,destination,price,available_seats) VALUES
('AI101','Air India','Mumbai','Delhi',4500,50),
('6E201','IndiGo','Chennai','Bangalore',2200,70),
('SG301','SpiceJet','Kolkata','Hyderabad',3800,40);

INSERT INTO Crew(flight_id,full_name,role,employee_id,experience) VALUES
(1,'Capt. Rajesh Kumar','Pilot','EMP001',18),
(1,'Ananya Sharma','Co-Pilot','EMP002',8),
(2,'Arjun Pillai','Pilot','EMP003',12);

INSERT INTO Ticket(user_id,flight_id,seat_number,passenger_name,passport_no,total_price) VALUES
(1,1,'12A','Rahul Sharma','P123456',4500),
(2,2,'14C','Ananya Iyer','P654321',2200),
(3,3,'10B','David Joseph','P998877',3800);

INSERT INTO Food_Ordering(ticket_id,user_id,meal_type,meal_name,quantity,price) VALUES
(1,1,'Vegetarian','Paneer Meal',1,350),
(2,2,'Non-Vegetarian','Chicken Biryani',1,420),
(3,3,'Vegetarian','Veg Sandwich',2,200);

-- =========================
-- 5 JOIN QUERIES
-- =========================

SELECT 
U.full_name,
F.flight_number,
F.origin,
F.destination,
T.seat_number
FROM Ticket T
JOIN User U ON T.user_id = U.user_id
JOIN Flight F ON T.flight_id = F.flight_id;

SELECT 
F.flight_number,
C.full_name,
C.role
FROM Crew C
JOIN Flight F ON C.flight_id = F.flight_id;

SELECT 
U.full_name,
FO.meal_name,
FO.quantity
FROM Food_Ordering FO
JOIN User U ON FO.user_id = U.user_id;

-- =========================
-- 6 SUBQUERIES (MINIMUM 3)
-- =========================

-- Subquery 1: Most expensive flight
SELECT flight_number, price
FROM Flight
WHERE price = (SELECT MAX(price) FROM Flight);

-- Subquery 2: Users who have booked tickets
SELECT full_name, email
FROM User
WHERE user_id IN (SELECT user_id FROM Ticket);

-- Subquery 3: Flights with below average seat availability
SELECT flight_number, available_seats
FROM Flight
WHERE available_seats < (SELECT AVG(available_seats) FROM Flight);

-- Subquery 4: Flights booked by Rahul Sharma
SELECT flight_number
FROM Flight
WHERE flight_id IN (
SELECT flight_id
FROM Ticket
WHERE user_id = (
SELECT user_id
FROM User
WHERE full_name = 'Rahul Sharma'
));

-- =========================
-- 7 SET OPERATIONS
-- =========================

SELECT origin FROM Flight
UNION
SELECT destination FROM Flight;

SELECT origin FROM Flight
UNION ALL
SELECT destination FROM Flight;

SELECT origin
FROM Flight
WHERE origin IN (SELECT destination FROM Flight);

-- =========================
-- 8 AGGREGATE FUNCTIONS
-- =========================

SELECT COUNT(*) AS Total_Users FROM User;

SELECT AVG(price) AS Average_Flight_Price FROM Flight;

SELECT MAX(total_price) AS Highest_Ticket,
       MIN(total_price) AS Lowest_Ticket
FROM Ticket;

-- =========================
-- 9 VIEWS
-- =========================

CREATE VIEW Passenger_Booking_View AS
SELECT 
U.full_name,
F.flight_number,
T.seat_number
FROM Ticket T
JOIN User U ON T.user_id = U.user_id
JOIN Flight F ON T.flight_id = F.flight_id;

CREATE VIEW Flight_Crew_View AS
SELECT 
F.flight_number,
C.full_name,
C.role
FROM Crew C
JOIN Flight F ON C.flight_id = F.flight_id;

CREATE VIEW Food_Order_View AS
SELECT 
U.full_name,
FO.meal_name,
FO.quantity
FROM Food_Ordering FO
JOIN User U ON FO.user_id = U.user_id;

-- =========================
-- 10 TEST QUERIES
-- =========================

SELECT * FROM User;
SELECT * FROM Flight;
SELECT * FROM Crew;
SELECT * FROM Ticket;
SELECT * FROM Food_Ordering;

SELECT * FROM Passenger_Booking_View;
SELECT * FROM Flight_Crew_View;
SELECT * FROM Food_Order_View;

SELECT 'DATABASE SETUP COMPLETED SUCCESSFULLY' AS STATUS;
