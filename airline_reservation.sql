-- ============================================================
-- Airline Reservation System - Full Database Setup Script
-- Run this in MySQL Workbench before starting the Flask app
-- ============================================================

-- Create and select the database
DROP DATABASE IF EXISTS Airline_Reservation;
CREATE DATABASE Airline_Reservation;
USE Airline_Reservation;

-- ============================================================
-- TABLE: User
-- Stores registered user accounts
-- ============================================================
CREATE TABLE User (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,        -- Stored as hashed string
    phone         VARCHAR(20),
    dob           DATE,
    gender        ENUM('Male','Female','Other'),
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE: Flight
-- Stores all available flight information
-- ============================================================
CREATE TABLE Flight (
    flight_id        INT AUTO_INCREMENT PRIMARY KEY,
    flight_number    VARCHAR(10) NOT NULL UNIQUE,
    airline_name     VARCHAR(100) NOT NULL,
    origin           VARCHAR(100) NOT NULL,
    destination      VARCHAR(100) NOT NULL,
    departure_time   DATETIME NOT NULL,
    arrival_time     DATETIME NOT NULL,
    total_seats      INT NOT NULL DEFAULT 150,
    available_seats  INT NOT NULL DEFAULT 150,
    price            DECIMAL(10,2) NOT NULL,
    flight_class     ENUM('Economy','Business','First') DEFAULT 'Economy',
    status           ENUM('Scheduled','Delayed','Cancelled','Completed') DEFAULT 'Scheduled'
);

-- ============================================================
-- TABLE: Crew
-- Stores crew members and their flight assignments
-- ============================================================
CREATE TABLE Crew (
    crew_id     INT AUTO_INCREMENT PRIMARY KEY,
    flight_id   INT NOT NULL,
    full_name   VARCHAR(100) NOT NULL,
    role        ENUM('Pilot','Co-Pilot','Flight Attendant','Engineer') NOT NULL,
    employee_id VARCHAR(20) NOT NULL UNIQUE,
    experience  INT DEFAULT 0,                -- Years of experience
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: Ticket
-- Records every booking made by users
-- ============================================================
CREATE TABLE Ticket (
    ticket_id      INT AUTO_INCREMENT PRIMARY KEY,
    user_id        INT NOT NULL,
    flight_id      INT NOT NULL,
    seat_number    VARCHAR(10),
    booking_date   DATETIME DEFAULT CURRENT_TIMESTAMP,
    passenger_name VARCHAR(100) NOT NULL,
    passport_no    VARCHAR(30),
    ticket_status  ENUM('Confirmed','Cancelled','Pending') DEFAULT 'Confirmed',
    total_price    DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    FOREIGN KEY (flight_id) REFERENCES Flight(flight_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE: Food_Ordering
-- Allows passengers to pre-order food for their flight
-- ============================================================
CREATE TABLE Food_Ordering (
    order_id     INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id    INT NOT NULL,
    user_id      INT NOT NULL,
    meal_type    ENUM('Vegetarian','Non-Vegetarian','Vegan','Gluten-Free') NOT NULL,
    meal_name    VARCHAR(100) NOT NULL,
    quantity     INT DEFAULT 1,
    price        DECIMAL(6,2) NOT NULL,
    order_status ENUM('Ordered','Confirmed','Cancelled') DEFAULT 'Ordered',
    order_time   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES Ticket(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE
);

-- ============================================================
-- SAMPLE DATA: Flights
-- ============================================================
INSERT INTO Flight (flight_number, airline_name, origin, destination, departure_time, arrival_time, total_seats, available_seats, price, flight_class, status) VALUES
('AI101',  'Air India',        'Mumbai',   'Delhi',     '2026-04-10 06:00:00', '2026-04-10 08:00:00', 180, 45,  4500.00,  'Economy',  'Scheduled'),
('AI102',  'Air India',        'Delhi',    'Mumbai',    '2026-04-10 10:00:00', '2026-04-10 12:00:00', 180, 100, 4500.00,  'Economy',  'Scheduled'),
('6E201',  'IndiGo',           'Chennai',  'Bangalore', '2026-04-11 07:30:00', '2026-04-11 08:30:00', 180, 80,  2200.00,  'Economy',  'Scheduled'),
('6E202',  'IndiGo',           'Bangalore','Chennai',   '2026-04-11 14:00:00', '2026-04-11 15:00:00', 180, 60,  2200.00,  'Economy',  'Scheduled'),
('SG301',  'SpiceJet',         'Kolkata',  'Hyderabad', '2026-04-12 09:00:00', '2026-04-12 11:30:00', 150, 90,  3800.00,  'Economy',  'Scheduled'),
('UK401',  'Vistara',          'Mumbai',   'London',    '2026-04-13 23:00:00', '2026-04-14 05:00:00', 250, 30,  55000.00, 'Business', 'Scheduled'),
('AI501',  'Air India',        'Delhi',    'New York',  '2026-04-14 02:00:00', '2026-04-14 14:00:00', 300, 20,  72000.00, 'First',    'Scheduled'),
('IX601',  'Air Asia',         'Pune',     'Goa',       '2026-04-15 08:00:00', '2026-04-15 09:00:00', 160, 120, 1800.00,  'Economy',  'Scheduled'),
('G8701',  'Go First',         'Ahmedabad','Jaipur',    '2026-04-15 11:00:00', '2026-04-15 12:30:00', 150, 75,  2500.00,  'Economy',  'Scheduled'),
('SG801',  'SpiceJet',         'Hyderabad','Mumbai',    '2026-04-16 16:00:00', '2026-04-16 18:00:00', 150, 50,  3200.00,  'Economy',  'Scheduled');

-- ============================================================
-- SAMPLE DATA: Crew
-- ============================================================
INSERT INTO Crew (flight_id, full_name, role, employee_id, experience) VALUES
(1, 'Capt. Rajesh Kumar',     'Pilot',           'EMP001', 18),
(1, 'Capt. Ananya Sharma',    'Co-Pilot',        'EMP002', 8),
(1, 'Priya Mehta',            'Flight Attendant','EMP003', 5),
(1, 'Suresh Nair',            'Flight Attendant','EMP004', 3),
(2, 'Capt. Vikram Singh',     'Pilot',           'EMP005', 20),
(2, 'Capt. Divya Rao',        'Co-Pilot',        'EMP006', 6),
(2, 'Neha Gupta',             'Flight Attendant','EMP007', 4),
(3, 'Capt. Arjun Pillai',     'Pilot',           'EMP008', 15),
(3, 'Capt. Meera Krishnan',   'Co-Pilot',        'EMP009', 7),
(3, 'Lakshmi Venkat',         'Flight Attendant','EMP010', 2),
(4, 'Capt. Ravi Shankar',     'Pilot',           'EMP011', 22),
(4, 'Capt. Pooja Iyer',       'Co-Pilot',        'EMP012', 9),
(5, 'Capt. Sunil Verma',      'Pilot',           'EMP013', 17),
(5, 'Capt. Kavitha Reddy',    'Co-Pilot',        'EMP014', 5),
(5, 'Mohammed Ali',           'Flight Attendant','EMP015', 6),
(6, 'Capt. James D Souza',    'Pilot',           'EMP016', 25),
(6, 'Capt. Sarah Mathew',     'Co-Pilot',        'EMP017', 12),
(6, 'Rohan Bose',             'Flight Attendant','EMP018', 8),
(6, 'Tanya Malhotra',         'Flight Attendant','EMP019', 4),
(7, 'Capt. Arun Khanna',      'Pilot',           'EMP020', 30),
(7, 'Capt. Nisha Bajaj',      'Co-Pilot',        'EMP021', 14),
(7, 'Deepak Joshi',           'Engineer',        'EMP022', 10),
(8, 'Capt. Vinod Kapoor',     'Pilot',           'EMP023', 12),
(8, 'Capt. Anjali Das',       'Co-Pilot',        'EMP024', 5),
(9, 'Capt. Ramesh Pandey',    'Pilot',           'EMP025', 16),
(9, 'Capt. Sunita Choudhary', 'Co-Pilot',        'EMP026', 7),
(10,'Capt. Kiran Nambiar',    'Pilot',           'EMP027', 19),
(10,'Capt. Rekha Patel',      'Co-Pilot',        'EMP028', 8),
(10,'Amitabh Roy',            'Flight Attendant','EMP029', 3);

-- ============================================================
-- End of Setup Script
-- ============================================================
SELECT 'Database setup complete!' AS Message;
