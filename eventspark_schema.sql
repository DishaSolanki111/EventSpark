-- ============================================
-- EventSpark - MySQL Database Schema
-- ============================================

CREATE DATABASE IF NOT EXISTS eventspark;
USE eventspark;

-- ============================================
-- TABLE: customers
-- ============================================
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    fname       VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    phone       VARCHAR(15)  NOT NULL,
    pass        VARCHAR(255) NOT NULL,       -- store hashed password
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: managers (Event Managers)
-- ============================================
CREATE TABLE IF NOT EXISTS managers (
    manager_id      INT AUTO_INCREMENT PRIMARY KEY,
    fname           VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    mob             VARCHAR(15)  NOT NULL,
    company         VARCHAR(150),
    experience      INT DEFAULT 0,
    specialization  ENUM('weddings','corporate','concerts','social','sports') NOT NULL,
    pass            VARCHAR(255) NOT NULL,   -- store hashed password
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: events
-- ============================================
CREATE TABLE IF NOT EXISTS events (
    event_id        INT AUTO_INCREMENT PRIMARY KEY,
    manager_id      INT NOT NULL,
    title           VARCHAR(200) NOT NULL,
    description     TEXT,
    category        ENUM('weddings','corporate','concerts','social','sports') NOT NULL,
    venue           VARCHAR(255) NOT NULL,
    event_date      DATE NOT NULL,
    event_time      TIME NOT NULL,
    total_seats     INT NOT NULL DEFAULT 100,
    available_seats INT NOT NULL DEFAULT 100,
    price           DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    image_url       VARCHAR(500),
    status          ENUM('upcoming','ongoing','completed','cancelled') DEFAULT 'upcoming',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES managers(manager_id) ON DELETE CASCADE
);

-- ============================================
-- TABLE: bookings
-- ============================================
CREATE TABLE IF NOT EXISTS bookings (
    booking_id      INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    event_id        INT NOT NULL,
    seats_booked    INT NOT NULL DEFAULT 1,
    total_amount    DECIMAL(10,2) NOT NULL,
    booking_status  ENUM('confirmed','cancelled','pending') DEFAULT 'confirmed',
    booked_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id)    REFERENCES events(event_id)       ON DELETE CASCADE,
    UNIQUE KEY unique_booking (customer_id, event_id)           -- prevent duplicate bookings
);

-- ============================================
-- INDEXES for performance
-- ============================================
CREATE INDEX idx_events_date     ON events(event_date);
CREATE INDEX idx_events_category ON events(category);
CREATE INDEX idx_events_status   ON events(status);
CREATE INDEX idx_bookings_customer ON bookings(customer_id);
CREATE INDEX idx_bookings_event    ON bookings(event_id);

-- ============================================
-- TRIGGER: auto-decrement available_seats on booking
-- ============================================
DELIMITER $$

CREATE TRIGGER after_booking_insert
AFTER INSERT ON bookings
FOR EACH ROW
BEGIN
    UPDATE events
    SET available_seats = available_seats - NEW.seats_booked
    WHERE event_id = NEW.event_id;
END$$

CREATE TRIGGER after_booking_cancel
AFTER UPDATE ON bookings
FOR EACH ROW
BEGIN
    IF NEW.booking_status = 'cancelled' AND OLD.booking_status != 'cancelled' THEN
        UPDATE events
        SET available_seats = available_seats + OLD.seats_booked
        WHERE event_id = OLD.event_id;
    END IF;
END$$

DELIMITER ;

-- ============================================
-- SAMPLE DATA
-- ============================================

-- Passwords below are bcrypt hashes of "password123"
INSERT INTO customers (fname, email, phone, pass) VALUES
('Alice Johnson',   'alice@example.com',   '9876543210', '$2b$10$KIX.qH8lAZfFq7UQvBj9ROeXaRhLwzBqGUl1qPv0F1K/ZJdsPKaOO'),
('Bob Smith',       'bob@example.com',     '9123456780', '$2b$10$KIX.qH8lAZfFq7UQvBj9ROeXaRhLwzBqGUl1qPv0F1K/ZJdsPKaOO'),
('Priya Patel',     'priya@example.com',   '9988776655', '$2b$10$KIX.qH8lAZfFq7UQvBj9ROeXaRhLwzBqGUl1qPv0F1K/ZJdsPKaOO');

INSERT INTO managers (fname, email, mob, company, experience, specialization, pass) VALUES
('Raj Mehta',       'raj@eventspark.com',  '9000011111', 'Mehta Events Pvt Ltd', 8, 'weddings',  '$2b$10$KIX.qH8lAZfFq7UQvBj9ROeXaRhLwzBqGUl1qPv0F1K/ZJdsPKaOO'),
('Sara Khan',       'sara@eventspark.com', '9000022222', 'Khan Corporate Mgmt',  5, 'corporate', '$2b$10$KIX.qH8lAZfFq7UQvBj9ROeXaRhLwzBqGUl1qPv0F1K/ZJdsPKaOO'),
('Dev Sharma',      'dev@eventspark.com',  '9000033333', 'Sharma Concerts LLC',  3, 'concerts',  '$2b$10$KIX.qH8lAZfFq7UQvBj9ROeXaRhLwzBqGUl1qPv0F1K/ZJdsPKaOO');

INSERT INTO events (manager_id, title, description, category, venue, event_date, event_time, total_seats, available_seats, price, status) VALUES
(1, 'Royal Garden Wedding Expo',    'Explore the finest wedding themes, decorators, and planners.',  'weddings',  'The Grand Ballroom, Mumbai',       '2026-04-15', '10:00:00', 300, 285, 499.00,  'upcoming'),
(2, 'TechCorp Annual Summit 2026',  'A premier corporate gathering for tech leaders and innovators.', 'corporate', 'ITC Maratha Convention Centre',    '2026-05-10', '09:00:00', 500, 412, 1999.00, 'upcoming'),
(3, 'Sunburn Music Festival',       'India\'s biggest EDM festival with top DJs.',                   'concerts',  'Candolim Beach, Goa',              '2026-06-20', '18:00:00', 2000,1850, 1499.00,'upcoming'),
(1, 'Social Fiesta - Ahmedabad',    'A fun-filled social gathering with food, music & networking.',  'social',    'ISKCON Lawns, Ahmedabad',          '2026-04-28', '17:00:00', 200, 178, 299.00,  'upcoming'),
(2, 'IPL Corporate Box Experience', 'Watch live IPL in a premium corporate box with F&B included.',  'sports',    'Narendra Modi Stadium, Ahmedabad', '2026-05-05', '19:30:00', 50,  38,  3999.00, 'upcoming');

INSERT INTO bookings (customer_id, event_id, seats_booked, total_amount, booking_status) VALUES
(1, 1, 2, 998.00,  'confirmed'),
(2, 2, 1, 1999.00, 'confirmed'),
(3, 3, 3, 4497.00, 'confirmed'),
(1, 5, 1, 3999.00, 'confirmed');
