from flask import Flask, render_template, request, jsonify
import mysql.connector
from config import DB_CONFIG

app = Flask(__name__)

def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)

@app.route('/')
def index():
    return render_template('index.html')

# Flights endpoints
@app.route('/api/flights', methods=['GET'])
def get_flights():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT f.flight_id, f.flight_number, a1.airport_code AS origin,
               a2.airport_code AS destination, f.departure_time, f.arrival_time,
               ac.registration_number, ac_type.model AS aircraft_model, f.status
        FROM flights f
        JOIN routes r ON f.route_id = r.route_id
        JOIN airports a1 ON r.origin_airport_id = a1.airport_id
        JOIN airports a2 ON r.destination_airport_id = a2.airport_id
        JOIN aircraft ac ON f.aircraft_id = ac.aircraft_id
        JOIN aircraft_types ac_type ON ac.aircraft_type_id = ac_type.aircraft_type_id
    """)
    flights = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(flights)

@app.route('/api/flights', methods=['POST'])
def add_flight():
    data = request.json
    print("Incoming flight data:", data)
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO flights (flight_number, airline_id, route_id, aircraft_id,
                departure_time, arrival_time, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            data['flight_number'],
            data['airline_id'],
            data['route_id'],
            data['aircraft_id'],
            data['departure_time'],
            data['arrival_time'],
            data.get('status', 'scheduled')
        ))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'message': 'Flight added successfully'}), 201
    except Exception as e:
        print("Error inserting flight:", e)
        return jsonify({'error': str(e)}), 500


# Aircraft endpoints
@app.route('/api/aircraft', methods=['GET'])
def get_aircraft():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT a.aircraft_id, a.registration_number, at.model, at.capacity,
               a.manufacturing_date, a.last_maintenance_date, a.next_maintenance_date,
               a.status
        FROM aircraft a
        JOIN aircraft_types at ON a.aircraft_type_id = at.aircraft_type_id
    """)
    aircraft = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(aircraft)

@app.route('/api/aircraft', methods=['POST'])
def add_aircraft():
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO aircraft (registration_number, aircraft_type_id, airline_id, 
        manufacturing_date, last_maintenance_date, next_maintenance_date, status)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (
        data['registration_number'],
        data['aircraft_type_id'],
        data['airline_id'],
        data['manufacturing_date'],
        data['last_maintenance_date'],
        data['next_maintenance_date'],
        data['status']
    ))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'Aircraft added successfully'}), 201

# Crew endpoints
@app.route('/api/crew', methods=['GET'])
def get_crew():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT c.crew_id, c.employee_id, c.first_name, c.last_name,
               cp.position_name, c.experience_years, c.hire_date, c.certifications, c.status
        FROM crew c
        JOIN crew_positions cp ON c.position_id = cp.position_id
    """)
    crew = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(crew)

@app.route('/api/crew', methods=['POST'])
def add_crew():
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO crew (employee_id, first_name, last_name, position_id, airline_id,
        experience_years, hire_date, certifications, status)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, (
        data['employee_id'],
        data['first_name'],
        data['last_name'],
        data['position_id'],
        data['airline_id'],
        data['experience_years'],
        data['hire_date'],
        data['certifications'],
        data['status']
    ))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'Crew member added successfully'}), 201

if __name__ == '__main__':
    app.run(debug=True)
