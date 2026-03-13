CREATE DATABASE IF NOT EXISTS eventspark;
USE eventspark;

-- Customer Table
CREATE TABLE IF NOT EXISTS customer (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fullname VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Event Manager Table
CREATE TABLE IF NOT EXISTS event_manager (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fullname VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(50) NOT NULL,
    company VARCHAR(255),
    experience VARCHAR(100),
    specialization VARCHAR(255),
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Events Table
CREATE TABLE IF NOT EXISTS events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    manager_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_date DATETIME NOT NULL,
    location VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (manager_id) REFERENCES event_manager(id) ON DELETE CASCADE
);

-- Bookings Table
CREATE TABLE IF NOT EXISTS bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    event_id INT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'confirmed',
    FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);

-- ==========================================
-- Example Insert Data for Testing
-- ==========================================

-- Insert Example Customers
INSERT INTO customer (fullname, email, phone, password) VALUES
('John Doe', 'john@example.com', '1234567890', 'password123'),
('Jane Smith', 'jane@example.com', '0987654321', 'password123');

-- Insert Example Event Managers
INSERT INTO event_manager (fullname, email, phone, company, experience, specialization, password) VALUES
('Alice Johnson', 'alice@events.com', '1112223333', 'Elite Events', '5 years', 'Weddings', 'manager123'),
('Bob Williams', 'bob@events.com', '4445556666', 'Corporate Pro', '10 years', 'Corporate Seminars', 'manager123');

-- Insert Example Events
INSERT INTO events (manager_id, title, description, event_date, location, price) VALUES
(1, 'Grand Wedding Expo', 'Annual wedding planning event showcasing best wedding vendors.', '2026-06-15 10:00:00', 'City Hall', 50.00),
(2, 'Tech Innovators Conference', 'Gathering of tech enthusiasts sharing newly emerged tech trends.', '2026-08-20 09:00:00', 'Convention Center', 150.00);

-- Insert Example Bookings
INSERT INTO bookings (customer_id, event_id, status) VALUES
(1, 1, 'confirmed'),
(2, 2, 'confirmed'),
(1, 2, 'pending');
