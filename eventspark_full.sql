-- ================================================================
-- EventSpark - Complete MySQL Database Schema (UPDATED)
-- Categories: concerts, sports, festivals
-- Removed: weddings, corporate, social
-- Import in phpMyAdmin > SQL tab > click GO
-- Password for ALL accounts = test123
-- ================================================================

DROP DATABASE IF EXISTS eventspark;
CREATE DATABASE eventspark CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eventspark;

-- ================================================================
-- TABLE 1: categories
-- ================================================================
CREATE TABLE categories (
    category_id   INT          AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50)  NOT NULL UNIQUE,
    description   VARCHAR(255) NOT NULL,
    icon          VARCHAR(10)  DEFAULT '🎟️'
);

-- ================================================================
-- TABLE 2: customers
-- ================================================================
CREATE TABLE customers (
    customer_id INT          AUTO_INCREMENT PRIMARY KEY,
    fname       VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    phone       VARCHAR(15)  NOT NULL,
    pass        VARCHAR(255) NOT NULL,
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================
-- TABLE 3: managers
-- category_id FK references categories table
-- ================================================================
CREATE TABLE managers (
    manager_id  INT          AUTO_INCREMENT PRIMARY KEY,
    fname       VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    mob         VARCHAR(15)  NOT NULL,
    company     VARCHAR(150),
    experience  INT          DEFAULT 0,
    category_id INT          NOT NULL,
    pass        VARCHAR(255) NOT NULL,
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- ================================================================
-- TABLE 4: events
-- manager_id FK -> managers, category_id FK -> categories
-- ================================================================
CREATE TABLE events (
    event_id        INT           AUTO_INCREMENT PRIMARY KEY,
    manager_id      INT           NOT NULL,
    category_id     INT           NOT NULL,
    title           VARCHAR(200)  NOT NULL,
    description     TEXT,
    venue           VARCHAR(255)  NOT NULL,
    event_date      DATE          NOT NULL,
    event_time      TIME          NOT NULL,
    total_seats     INT           NOT NULL DEFAULT 100,
    available_seats INT           NOT NULL DEFAULT 100,
    price           DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status          ENUM('upcoming','ongoing','completed','cancelled') DEFAULT 'upcoming',
    created_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id)  REFERENCES managers(manager_id)   ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- ================================================================
-- TABLE 5: bookings
-- customer_id FK -> customers, event_id FK -> events
-- ================================================================
CREATE TABLE bookings (
    booking_id     INT           AUTO_INCREMENT PRIMARY KEY,
    customer_id    INT           NOT NULL,
    event_id       INT           NOT NULL,
    seats_booked   INT           NOT NULL DEFAULT 1,
    total_amount   DECIMAL(10,2) NOT NULL,
    booking_status ENUM('confirmed','cancelled','pending') DEFAULT 'confirmed',
    booked_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id)    REFERENCES events(event_id)       ON DELETE CASCADE,
    UNIQUE KEY unique_booking (customer_id, event_id)
);

-- ================================================================
-- INDEXES
-- ================================================================
CREATE INDEX idx_events_date       ON events(event_date);
CREATE INDEX idx_events_category   ON events(category_id);
CREATE INDEX idx_events_status     ON events(status);
CREATE INDEX idx_bookings_customer ON bookings(customer_id);
CREATE INDEX idx_bookings_event    ON bookings(event_id);

-- ================================================================
-- TRIGGERS
-- ================================================================
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

-- ================================================================
-- DATA: categories (3 categories)
-- ================================================================
INSERT INTO categories (category_name, description, icon) VALUES
('concerts',  'Live music, band performances and cultural shows',     '🎵'),
('sports',    'Cricket, football, kabaddi and outdoor sports events', '⚽'),
('festivals', 'Cultural festivals, fairs and celebration events',     '🎪');

-- ================================================================
-- DATA: customers (12 Indian names)
-- Password: test123
-- Hash: $2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay
-- ================================================================
INSERT INTO customers (fname, email, phone, pass) VALUES
('Aarav Shah',   'aarav.shah@gmail.com',   '9824501234', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Priya Patel',  'priya.patel@gmail.com',  '9737812345', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Rohan Mehta',  'rohan.mehta@gmail.com',  '9099623456', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Sneha Joshi',  'sneha.joshi@gmail.com',  '9512034567', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Karan Desai',  'karan.desai@gmail.com',  '9825145678', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Pooja Sharma', 'pooja.sharma@gmail.com', '9687256789', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Vikram Nair',  'vikram.nair@gmail.com',  '9374367890', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Ananya Iyer',  'ananya.iyer@gmail.com',  '9265478901', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Manish Gupta', 'manish.gupta@gmail.com', '9156589012', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Riya Verma',   'riya.verma@gmail.com',   '9047690123', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Arjun Singh',  'arjun.singh@gmail.com',  '9938701234', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Divya Rao',    'divya.rao@gmail.com',    '9829812345', '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay');

-- ================================================================
-- DATA: managers (3 — one per category)
-- category_id: 1=concerts  2=sports  3=festivals
-- Password: test123
-- ================================================================
INSERT INTO managers (fname, email, mob, company, experience, category_id, pass) VALUES
('Deepak Sharma',  'deepak.sharma@eventspark.com',  '9000033333', 'Sharma Sangeet Productions', 5, 1, '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Nikhil Patil',   'nikhil.patil@eventspark.com',   '9000055555', 'Patil Sports Management',    6, 2, '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay'),
('Kavita Joshi',   'kavita.joshi@eventspark.com',   '9000044444', 'Joshi Festivals & Fairs',    7, 3, '$2b$12$f5u3Og60vKmY6IAi5oa3tOApk8RmuefHdAQ4Uh1sJlEEWEowEJ1Ay');

-- ================================================================
-- DATA: events (9 total — 3 per category)
-- Price: Rs 500-799 | Seats: max 300 | Venues: Ahmedabad
-- manager 1=Deepak(concerts) 2=Nikhil(sports) 3=Kavita(festivals)
-- ================================================================

-- CONCERTS (category_id=1) — manager: Deepak Sharma
INSERT INTO events (manager_id, category_id, title, description, venue, event_date, event_time, total_seats, available_seats, price, status) VALUES
(1, 1, 'Garba Beats Live Concert',
 'Live concert blending traditional Gujarati garba with modern EDM beats. Featuring DJ Vishal and folk artist Geeta Ben. Traditional attire encouraged.',
 'Kankaria Lakefront Amphitheatre, Ahmedabad', '2026-05-20', '19:00:00', 300, 300, 699.00, 'upcoming'),

(1, 1, 'Sufi Shaam Evening',
 'Soulful evening of Sufi music and qawwali by renowned artists from Rajasthan and Gujarat. Candle-lit open-air setting with complimentary chai and snacks.',
 'Calico Museum Garden, Ahmedabad', '2026-06-14', '17:30:00', 150, 150, 599.00, 'upcoming'),

(1, 1, 'Indie Unplugged Ahmedabad',
 'Live acoustic performances by 5 independent Indian bands covering folk, blues and indie pop genres. Open jam session for audience musicians after the show.',
 'Alpha One Mall Open Stage, Ahmedabad', '2026-07-05', '18:00:00', 200, 200, 500.00, 'upcoming');

-- SPORTS (category_id=2) — manager: Nikhil Patil
INSERT INTO events (manager_id, category_id, title, description, venue, event_date, event_time, total_seats, available_seats, price, status) VALUES
(2, 2, 'Ahmedabad Premier Cricket League',
 'Inter-colony T10 cricket tournament with 16 teams. Live commentary, digital scoreboard and awards for best batsman and bowler. Entry includes match souvenir kit.',
 'Shahibaug Cricket Ground, Ahmedabad', '2026-05-25', '08:00:00', 200, 200, 599.00, 'upcoming'),

(2, 2, 'Weekend Warriors Kabaddi Cup',
 'Open kabaddi tournament for amateur teams across Ahmedabad. Categories: men, women and mixed. Trophies and cash prizes for top three teams. Per-person spectator entry.',
 'Sardar Patel Stadium, Ahmedabad', '2026-06-22', '07:30:00', 150, 150, 500.00, 'upcoming'),

(2, 2, 'Cyclothon Ahmedabad 2026',
 'City-wide cycling event with three routes: 10 km fun ride, 25 km intermediate and 50 km pro challenge. Medal for all finishers, refreshment stations every 5 km.',
 'Sabarmati Riverfront Start Point, Ahmedabad', '2026-07-19', '06:00:00', 300, 300, 799.00, 'upcoming');

-- FESTIVALS (category_id=3) — manager: Kavita Joshi
INSERT INTO events (manager_id, category_id, title, description, venue, event_date, event_time, total_seats, available_seats, price, status) VALUES
(3, 3, 'Uttarayan Kite Festival Mela',
 'Grand kite festival celebration with a kite flying competition, kite stalls, traditional Gujarati street food and live folk music. Open for all age groups.',
 'Sabarmati Riverfront Ground, Ahmedabad', '2026-05-18', '08:00:00', 300, 300, 500.00, 'upcoming'),

(3, 3, 'Navratri Utsav 2026',
 'Nine nights of traditional Gujarati garba and dandiya celebrations with live orchestra, costume competition and prizes for best dressed participants.',
 'GMDC Exhibition Ground, Ahmedabad', '2026-06-08', '19:00:00', 250, 250, 699.00, 'upcoming'),

(3, 3, 'Diwali Food and Craft Fair',
 'Vibrant Diwali celebration fair featuring handmade craft stalls, fireworks display, rangoli competition, sweets stalls and live entertainment for families.',
 'Riverfront East Garden, Ahmedabad', '2026-07-12', '17:00:00', 280, 280, 599.00, 'upcoming');

-- ================================================================
-- DATA: bookings (27 total — each customer has 2-3 bookings)
-- total_amount = seats_booked x price (all verified)
-- Trigger auto-updates available_seats on each INSERT
-- ================================================================
INSERT INTO bookings (customer_id, event_id, seats_booked, total_amount, booking_status) VALUES
-- Aarav Shah — 3 bookings
(1, 1, 2, 1398.00, 'confirmed'),   -- Garba Beats (2x699)
(1, 4, 1,  599.00, 'confirmed'),   -- Cricket League (1x599)
(1, 7, 2, 1000.00, 'confirmed'),   -- Uttarayan Kite Mela (2x500)
-- Priya Patel — 3 bookings
(2, 2, 1,  599.00, 'confirmed'),   -- Sufi Shaam (1x599)
(2, 5, 2, 1000.00, 'confirmed'),   -- Kabaddi Cup (2x500)
(2, 8, 1,  699.00, 'confirmed'),   -- Navratri Utsav (1x699)
-- Rohan Mehta — 2 bookings
(3, 3, 3, 1500.00, 'confirmed'),   -- Indie Unplugged (3x500)
(3, 6, 2, 1598.00, 'confirmed'),   -- Cyclothon (2x799)
-- Sneha Joshi — 3 bookings
(4, 1, 1,  699.00, 'confirmed'),   -- Garba Beats (1x699)
(4, 7, 2, 1000.00, 'confirmed'),   -- Uttarayan Kite Mela (2x500)
(4, 9, 1,  599.00, 'confirmed'),   -- Diwali Fair (1x599)
-- Karan Desai — 2 bookings
(5, 2, 2, 1198.00, 'confirmed'),   -- Sufi Shaam (2x599)
(5, 8, 2, 1398.00, 'confirmed'),   -- Navratri Utsav (2x699)
-- Pooja Sharma — 2 bookings
(6, 4, 2, 1198.00, 'confirmed'),   -- Cricket League (2x599)
(6, 9, 3, 1797.00, 'confirmed'),   -- Diwali Fair (3x599)
-- Vikram Nair — 3 bookings
(7, 3, 2, 1000.00, 'confirmed'),   -- Indie Unplugged (2x500)
(7, 5, 1,  500.00, 'confirmed'),   -- Kabaddi Cup (1x500)
(7, 7, 2, 1000.00, 'confirmed'),   -- Uttarayan Kite Mela (2x500)
-- Ananya Iyer — 2 bookings
(8, 1, 1,  699.00, 'confirmed'),   -- Garba Beats (1x699)
(8, 8, 1,  699.00, 'confirmed'),   -- Navratri Utsav (1x699)
-- Manish Gupta — 3 bookings
(9, 2, 2, 1198.00, 'confirmed'),   -- Sufi Shaam (2x599)
(9, 4, 1,  599.00, 'confirmed'),   -- Cricket League (1x599)
(9, 9, 2, 1198.00, 'confirmed'),   -- Diwali Fair (2x599)
-- Riya Verma — 2 bookings
(10, 6, 1,  799.00, 'confirmed'),  -- Cyclothon (1x799)
(10, 8, 1,  699.00, 'confirmed'),  -- Navratri Utsav (1x699)
-- Arjun Singh — 2 bookings
(11, 3, 1,  500.00, 'confirmed'),  -- Indie Unplugged (1x500)
(11, 7, 1,  500.00, 'confirmed'),  -- Uttarayan Kite Mela (1x500)
-- Divya Rao — 2 bookings
(12, 5, 2, 1000.00, 'confirmed'),  -- Kabaddi Cup (2x500)
(12, 9, 1,  599.00, 'confirmed');  -- Diwali Fair (1x599)
