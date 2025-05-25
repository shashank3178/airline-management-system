-- Create database
CREATE DATABASE skyways_airline_management;
USE skyways_airline_management;

-- Country table
CREATE TABLE countries (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_code CHAR(2) NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    UNIQUE KEY (country_code)
);

-- Cities table
CREATE TABLE cities (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    is_major BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

-- Airports table
CREATE TABLE airports (
    airport_id INT AUTO_INCREMENT PRIMARY KEY,
    airport_code CHAR(3) NOT NULL,
    airport_name VARCHAR(100) NOT NULL,
    city_id INT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50),
    UNIQUE KEY (airport_code),
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

-- Airlines table
CREATE TABLE airlines (
    airline_id INT AUTO_INCREMENT PRIMARY KEY,
    airline_code CHAR(2) NOT NULL,
    airline_name VARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    logo_url VARCHAR(255),
    founding_year INT,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE KEY (airline_code),
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

-- Aircraft types table
CREATE TABLE aircraft_types (
    aircraft_type_id INT AUTO_INCREMENT PRIMARY KEY,
    manufacturer VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    capacity INT NOT NULL,
    range_km INT NOT NULL,
    UNIQUE KEY (manufacturer, model)
);

-- Aircraft table
CREATE TABLE aircraft (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    registration_number VARCHAR(10) NOT NULL,
    aircraft_type_id INT NOT NULL,
    airline_id INT NOT NULL,
    manufacturing_date DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    status ENUM('operational', 'maintenance', 'maintenance_overdue', 'retired') DEFAULT 'operational',
    UNIQUE KEY (registration_number),
    FOREIGN KEY (aircraft_type_id) REFERENCES aircraft_types(aircraft_type_id),
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id)
);

-- Crew positions table
CREATE TABLE crew_positions (
    position_id INT AUTO_INCREMENT PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL,
    position_type ENUM('pilot', 'cabin_crew', 'ground_staff') NOT NULL,
    UNIQUE KEY (position_name)
);

-- Crew table
CREATE TABLE crew (
    crew_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position_id INT NOT NULL,
    airline_id INT NOT NULL,
    experience_years INT,
    hire_date DATE NOT NULL,
    certifications TEXT,
    status ENUM('on_duty', 'off_duty', 'training', 'leave', 'terminated') DEFAULT 'off_duty',
    UNIQUE KEY (employee_id),
    FOREIGN KEY (position_id) REFERENCES crew_positions(position_id),
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id)
);

-- Routes table
CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    origin_airport_id INT NOT NULL,
    destination_airport_id INT NOT NULL,
    distance_km INT NOT NULL,
    estimated_duration TIME NOT NULL,
    UNIQUE KEY (origin_airport_id, destination_airport_id),
    FOREIGN KEY (origin_airport_id) REFERENCES airports(airport_id),
    FOREIGN KEY (destination_airport_id) REFERENCES airports(airport_id)
);

-- Flights table
CREATE TABLE flights (
    flight_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL,
    airline_id INT NOT NULL,
    route_id INT NOT NULL,
    aircraft_id INT NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    status ENUM('scheduled', 'boarding', 'departed', 'in_air', 'landed', 'arrived', 'delayed', 'cancelled') DEFAULT 'scheduled',
    actual_departure_time DATETIME,
    actual_arrival_time DATETIME,
    gate_departure VARCHAR(10),
    gate_arrival VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (flight_number, departure_time),
    FOREIGN KEY (airline_id) REFERENCES airlines(airline_id),
    FOREIGN KEY (route_id) REFERENCES routes(route_id),
    FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id)
);

-- Flight crew assignments table
CREATE TABLE flight_crew_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    crew_id INT NOT NULL,
    role VARCHAR(50) NOT NULL,
    UNIQUE KEY (flight_id, crew_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (crew_id) REFERENCES crew(crew_id)
);

-- Passengers table
CREATE TABLE passengers (
    passenger_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    passport_number VARCHAR(20),
    nationality_country_id INT,
    date_of_birth DATE,
    email VARCHAR(100),
    phone VARCHAR(20),
    frequent_flyer_number VARCHAR(20),
    FOREIGN KEY (nationality_country_id) REFERENCES countries(country_id)
);

-- Booking statuses table
CREATE TABLE booking_statuses (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    description TEXT,
    UNIQUE KEY (status_name)
);

-- Bookings table
CREATE TABLE bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_reference VARCHAR(10) NOT NULL,
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    seat_number VARCHAR(5),
    class ENUM('economy', 'premium_economy', 'business', 'first') DEFAULT 'economy',
    status_id INT NOT NULL,
    checked_in BOOLEAN DEFAULT FALSE,
    special_requests TEXT,
    UNIQUE KEY (booking_reference),
    UNIQUE KEY (flight_id, seat_number),
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id),
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (status_id) REFERENCES booking_statuses(status_id)
);

-- Flight delays table
CREATE TABLE flight_delays (
    delay_id INT AUTO_INCREMENT PRIMARY KEY,
    flight_id INT NOT NULL,
    delay_minutes INT NOT NULL,
    reason TEXT,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
);

-- Aircraft maintenance table
CREATE TABLE aircraft_maintenance (
    maintenance_id INT AUTO_INCREMENT PRIMARY KEY,
    aircraft_id INT NOT NULL,
    maintenance_type VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    description TEXT,
    status ENUM('scheduled', 'in_progress', 'completed', 'delayed') DEFAULT 'scheduled',
    cost DECIMAL(10, 2),
    FOREIGN KEY (aircraft_id) REFERENCES aircraft(aircraft_id)
);

-- Insert countries data
INSERT INTO countries (country_code, country_name) VALUES
('IN', 'India'),
('US', 'United States'),
('GB', 'United Kingdom'),
('AE', 'United Arab Emirates'),
('SG', 'Singapore'),
('DE', 'Germany'),
('FR', 'France'),
('AU', 'Australia'),
('JP', 'Japan'),
('CA', 'Canada'),
('CN', 'China'),
('RU', 'Russia'),
('IT', 'Italy'),
('ES', 'Spain'),
('TH', 'Thailand');

-- Insert major Indian cities
INSERT INTO cities (city_name, country_id, is_major) VALUES
('Mumbai', 1, TRUE),
('Delhi', 1, TRUE),
('Bangalore', 1, TRUE),
('Hyderabad', 1, TRUE),
('Chennai', 1, TRUE),
('Kolkata', 1, TRUE),
('Ahmedabad', 1, TRUE),
('Pune', 1, TRUE),
('Jaipur', 1, TRUE),
('Lucknow', 1, TRUE),
('Kochi', 1, TRUE),
('Goa', 1, TRUE),
('Chandigarh', 1, TRUE),
('Guwahati', 1, TRUE),
('Srinagar', 1, TRUE),
('Varanasi', 1, TRUE),
('Thiruvananthapuram', 1, TRUE),
('Bhubaneswar', 1, TRUE),
('Indore', 1, TRUE),
('Nagpur', 1, TRUE);

-- Insert major global cities
INSERT INTO cities (city_name, country_id, is_major) VALUES
('New York', 2, TRUE),
('Los Angeles', 2, TRUE),
('Chicago', 2, TRUE),
('San Francisco', 2, TRUE),
('London', 3, TRUE),
('Dubai', 4, TRUE),
('Singapore', 5, TRUE),
('Berlin', 6, TRUE),
('Paris', 7, TRUE),
('Sydney', 8, TRUE),
('Tokyo', 9, TRUE),
('Toronto', 10, TRUE),
('Beijing', 11, TRUE),
('Shanghai', 11, TRUE),
('Moscow', 12, TRUE),
('Rome', 13, TRUE),
('Madrid', 14, TRUE),
('Bangkok', 15, TRUE);

-- Insert airports data
INSERT INTO airports (airport_code, airport_name, city_id, latitude, longitude, timezone) VALUES
-- Indian Airports
('BOM', 'Chhatrapati Shivaji Maharaj International Airport', 1, 19.0896, 72.8656, 'Asia/Kolkata'),
('DEL', 'Indira Gandhi International Airport', 2, 28.5562, 77.1000, 'Asia/Kolkata'),
('BLR', 'Kempegowda International Airport', 3, 13.1986, 77.7066, 'Asia/Kolkata'),
('HYD', 'Rajiv Gandhi International Airport', 4, 17.2403, 78.4294, 'Asia/Kolkata'),
('MAA', 'Chennai International Airport', 5, 12.9941, 80.1709, 'Asia/Kolkata'),
('CCU', 'Netaji Subhas Chandra Bose International Airport', 6, 22.6547, 88.4467, 'Asia/Kolkata'),
('AMD', 'Sardar Vallabhbhai Patel International Airport', 7, 23.0772, 72.6347, 'Asia/Kolkata'),
('PNQ', 'Pune International Airport', 8, 18.5793, 73.9089, 'Asia/Kolkata'),
('JAI', 'Jaipur International Airport', 9, 26.8242, 75.8122, 'Asia/Kolkata'),
('LKO', 'Chaudhary Charan Singh International Airport', 10, 26.7606, 80.8893, 'Asia/Kolkata'),
('COK', 'Cochin International Airport', 11, 10.1520, 76.3920, 'Asia/Kolkata'),
('GOI', 'Goa International Airport', 12, 15.3808, 73.8314, 'Asia/Kolkata'),
('IXC', 'Chandigarh International Airport', 13, 30.6735, 76.7885, 'Asia/Kolkata'),
('GAU', 'Lokpriya Gopinath Bordoloi International Airport', 14, 26.1058, 91.5869, 'Asia/Kolkata'),
('SXR', 'Sheikh ul-Alam International Airport', 15, 33.9872, 74.7738, 'Asia/Kolkata'),
('VNS', 'Lal Bahadur Shastri International Airport', 16, 25.4523, 82.8593, 'Asia/Kolkata'),
('TRV', 'Trivandrum International Airport', 17, 8.4825, 76.9198, 'Asia/Kolkata'),
('BBI', 'Biju Patnaik International Airport', 18, 20.2444, 85.8174, 'Asia/Kolkata'),
('IDR', 'Devi Ahilya Bai Holkar Airport', 19, 22.7220, 75.8007, 'Asia/Kolkata'),
('NAG', 'Dr. Babasaheb Ambedkar International Airport', 20, 21.0920, 79.0471, 'Asia/Kolkata'),

-- International Airports
('JFK', 'John F. Kennedy International Airport', 21, 40.6413, -73.7781, 'America/New_York'),
('LAX', 'Los Angeles International Airport', 22, 33.9416, -118.4085, 'America/Los_Angeles'),
('ORD', 'O\'Hare International Airport', 23, 41.9742, -87.9073, 'America/Chicago'),
('SFO', 'San Francisco International Airport', 24, 37.6213, -122.3790, 'America/Los_Angeles'),
('LHR', 'Heathrow Airport', 25, 51.4700, -0.4543, 'Europe/London'),
('DXB', 'Dubai International Airport', 26, 25.2528, 55.3644, 'Asia/Dubai'),
('SIN', 'Singapore Changi Airport', 27, 1.3644, 103.9915, 'Asia/Singapore'),
('TXL', 'Berlin Tegel Airport', 28, 52.5548, 13.2925, 'Europe/Berlin'),
('CDG', 'Charles de Gaulle Airport', 29, 49.0097, 2.5479, 'Europe/Paris'),
('SYD', 'Sydney Airport', 30, -33.9399, 151.1753, 'Australia/Sydney'),
('HND', 'Tokyo Haneda Airport', 31, 35.5494, 139.7798, 'Asia/Tokyo'),
('YYZ', 'Toronto Pearson International Airport', 32, 43.6777, -79.6248, 'America/Toronto'),
('PEK', 'Beijing Capital International Airport', 33, 40.0725, 116.5974, 'Asia/Shanghai'),
('PVG', 'Shanghai Pudong International Airport', 34, 31.1443, 121.8083, 'Asia/Shanghai'),
('SVO', 'Sheremetyevo International Airport', 35, 55.9726, 37.4146, 'Europe/Moscow'),
('FCO', 'Leonardo da Vinci International Airport', 36, 41.8003, 12.2389, 'Europe/Rome'),
('MAD', 'Adolfo Suárez Madrid–Barajas Airport', 37, 40.4983, -3.5676, 'Europe/Madrid'),
('BKK', 'Suvarnabhumi Airport', 38, 13.6900, 100.7501, 'Asia/Bangkok');

-- Insert Indian airlines
INSERT INTO airlines (airline_code, airline_name, country_id, founding_year, is_active) VALUES
('AI', 'Air India', 1, 1932, TRUE),
('IX', 'Air India Express', 1, 2005, TRUE),
('UK', 'Vistara', 1, 2013, TRUE),
('6E', 'IndiGo', 1, 2006, TRUE),
('SG', 'SpiceJet', 1, 2005, TRUE),
('G8', 'GoAir', 1, 2005, TRUE),
('I5', 'AirAsia India', 1, 2014, TRUE),
('9I', 'Alliance Air', 1, 1996, TRUE),
('2T', 'TruJet', 1, 2015, TRUE),
('S5', 'Star Air', 1, 2018, TRUE);

-- Insert major global airlines
INSERT INTO airlines (airline_code, airline_name, country_id, founding_year, is_active) VALUES
('AA', 'American Airlines', 2, 1926, TRUE),
('UA', 'United Airlines', 2, 1926, TRUE),
('DL', 'Delta Air Lines', 2, 1925, TRUE),
('WN', 'Southwest Airlines', 2, 1967, TRUE),
('BA', 'British Airways', 3, 1974, TRUE),
('EK', 'Emirates', 4, 1985, TRUE),
('SQ', 'Singapore Airlines', 5, 1947, TRUE),
('LH', 'Lufthansa', 6, 1953, TRUE),
('AF', 'Air France', 7, 1933, TRUE),
('QF', 'Qantas', 8, 1920, TRUE),
('JL', 'Japan Airlines', 9, 1951, TRUE),
('AC', 'Air Canada', 10, 1937, TRUE),
('CA', 'Air China', 11, 1988, TRUE),
('MU', 'China Eastern Airlines', 11, 1988, TRUE),
('SU', 'Aeroflot', 12, 1923, TRUE),
('AZ', 'Alitalia', 13, 1946, TRUE),
('IB', 'Iberia', 14, 1927, TRUE),
('TG', 'Thai Airways', 15, 1960, TRUE);

-- Insert aircraft types
INSERT INTO aircraft_types (manufacturer, model, capacity, range_km) VALUES
('Boeing', '737-800', 180, 5765),
('Boeing', '737 MAX 8', 178, 6570),
('Boeing', '787-9 Dreamliner', 290, 14140),
('Boeing', '777-300ER', 386, 13650),
('Boeing', '747-8', 467, 14815),
('Airbus', 'A320-200', 150, 5700),
('Airbus', 'A320neo', 165, 6500),
('Airbus', 'A321', 200, 5950),
('Airbus', 'A330-300', 277, 11750),
('Airbus', 'A350-900', 325, 15000),
('Airbus', 'A380-800', 525, 15200),
('Bombardier', 'CRJ-700', 78, 2655),
('Bombardier', 'Q400', 90, 2040),
('Embraer', 'E190', 114, 4537),
('ATR', 'ATR 72-600', 78, 1528);

-- Insert booking statuses
INSERT INTO booking_statuses (status_name, description) VALUES
('Confirmed', 'Booking has been confirmed'),
('Check-in Pending', 'Booking confirmed but check-in not completed'),
('Checked-in', 'Passenger has checked in'),
('Boarded', 'Passenger has boarded the aircraft'),
('Completed', 'Flight has been completed'),
('Cancelled', 'Booking has been cancelled'),
('No-show', 'Passenger did not show up for the flight'),
('Waitlisted', 'Booking is on waitlist');

-- Insert crew positions
INSERT INTO crew_positions (position_name, position_type) VALUES
('Captain', 'pilot'),
('First Officer', 'pilot'),
('Second Officer', 'pilot'),
('Cabin Manager', 'cabin_crew'),
('Senior Flight Attendant', 'cabin_crew'),
('Flight Attendant', 'cabin_crew'),
('Ground Operations Manager', 'ground_staff'),
('Check-in Agent', 'ground_staff'),
('Baggage Handler', 'ground_staff'),
('Ramp Agent', 'ground_staff');

-- Sample aircraft records (one for each airline)
INSERT INTO aircraft (registration_number, aircraft_type_id, airline_id, manufacturing_date, last_maintenance_date, next_maintenance_date, status) VALUES
('VT-AIA', 4, 1, '2017-05-15', '2025-04-28', '2025-06-28', 'operational'),
('VT-IXA', 6, 2, '2015-11-10', '2025-04-15', '2025-06-15', 'operational'),
('VT-UKA', 6, 3, '2018-03-20', '2025-05-01', '2025-07-01', 'operational'),
('VT-IEA', 7, 4, '2019-04-05', '2025-04-20', '2025-06-20', 'operational'),
('VT-SGA', 1, 5, '2016-02-12', '2025-05-05', '2025-07-05', 'operational'),
('VT-WAA', 6, 6, '2017-07-10', '2025-04-10', '2025-06-10', 'operational'),
('VT-ATF', 6, 7, '2018-06-15', '2025-05-03', '2025-07-03', 'operational'),
('VT-ABD', 13, 8, '2014-10-18', '2025-04-25', '2025-06-25', 'operational'),
('VT-TJA', 14, 9, '2019-01-30', '2025-05-07', '2025-07-07', 'operational'),
('VT-SRM', 15, 10, '2019-11-05', '2025-04-18', '2025-06-18', 'operational'),
('N12345', 1, 11, '2016-08-10', '2025-05-12', '2025-07-12', 'operational'),
('N67890', 6, 12, '2017-09-18', '2025-05-02', '2025-07-02', 'operational'),
('N54321', 3, 13, '2018-11-25', '2025-05-12', '2025-05-19', 'maintenance'),
('N98765', 8, 14, '2016-03-05', '2025-03-15', '2025-05-15', 'maintenance_overdue');

-- Creating a sample route (Mumbai to Delhi)
INSERT INTO routes (origin_airport_id, destination_airport_id, distance_km, estimated_duration) VALUES
(1, 2, 1142, '02:15:00'); -- Mumbai to Delhi

-- Insert a sample flight for this route
INSERT INTO flights (flight_number, airline_id, route_id, aircraft_id, departure_time, arrival_time, status, gate_departure, gate_arrival) VALUES
('AI101', 1, 1, 1, '2025-05-18 08:30:00', '2025-05-18 10:45:00', 'scheduled', 'T2-A1', 'T3-B2');

-- Insert a sample crew member
INSERT INTO crew (employee_id, first_name, last_name, position_id, airline_id, experience_years, hire_date, certifications, status) VALUES
('AI-P-001', 'Rajesh', 'Sharma', 1, 1, 15, '2010-06-15', 'ATP, B777, B787', 'off_duty');

-- Create a flight crew assignment
INSERT INTO flight_crew_assignments (flight_id, crew_id, role) VALUES
(1, 1, 'Captain');

-- Insert a sample passenger
INSERT INTO passengers (first_name, last_name, passport_number, nationality_country_id, date_of_birth, email, phone) VALUES
('Priya', 'Patel', 'A1234567', 1, '1985-09-25', 'priya.patel@example.com', '+91 98765 43210');

-- Create a booking for the passenger
INSERT INTO bookings (booking_reference, passenger_id, flight_id, booking_date, seat_number, class, status_id, checked_in) VALUES
('ABCDEF', 1, 1, '2025-05-01 14:22:15', '12A', 'business', 1, FALSE);

-- Create common routes between major cities
INSERT INTO routes (origin_airport_id, destination_airport_id, distance_km, estimated_duration) VALUES
-- Domestic Indian routes
(1, 3, 845, '01:45:00'),  -- Mumbai to Bangalore
(1, 4, 631, '01:20:00'),  -- Mumbai to Hyderabad
(1, 5, 1031, '02:00:00'), -- Mumbai to Chennai
(2, 3, 1740, '02:30:00'), -- Delhi to Bangalore
(2, 4, 1253, '02:10:00'), -- Delhi to Hyderabad
(2, 5, 1760, '02:35:00'), -- Delhi to Chennai
(2, 6, 1305, '02:15:00'), -- Delhi to Kolkata
(3, 5, 284, '00:45:00'),  -- Bangalore to Chennai
-- International routes
(2, 25, 6704, '08:30:00'), -- Delhi to London
(2, 26, 2184, '03:15:00'), -- Delhi to Dubai
(1, 26, 1936, '03:00:00'), -- Mumbai to Dubai
(2, 33, 3769, '05:45:00'), -- Delhi to Beijing
(1, 21, 12051, '15:30:00'), -- Mumbai to New York
(3, 27, 3180, '04:30:00'); -- Bangalore to Singapore
