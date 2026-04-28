# ============================================================
# Airline Reservation System - Flask Backend
# Run: python app.py
# ============================================================

from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
import mysql.connector
from mysql.connector import Error
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import random
import string
import os

app = Flask(__name__)
# Secret key for session management - change this in production
app.secret_key = 'airline_secret_key_2024'

# ============================================================
# DATABASE CONFIGURATION
# Update host/user/password as per your MySQL setup
# ============================================================
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',          # Your MySQL username
    'password': 'JDdsNv@6',      # Your MySQL password
    'database': 'airline_reservation',
    'autocommit': False
}

def get_db_connection():
    """Create and return a MySQL database connection."""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Database connection error: {e}")
        return None



# ============================================================
# HOME ROUTE
# ============================================================
@app.route('/')
def home():
    """Render the home/landing page."""
    conn = get_db_connection()
    flights = []
    if conn:
        cursor = conn.cursor(dictionary=True)
        # Fetch upcoming scheduled flights for the homepage
        cursor.execute("""
            SELECT f.flight_number, a.airline_name, f.origin, f.destination,
                   f.departure_time, f.arrival_time, f.price, f.flight_class, f.available_seats, f.flight_id
            FROM Flight f
            JOIN Airline a ON f.airline_id = a.airline_id
            WHERE f.available_seats > 0
            ORDER BY f.departure_time
            LIMIT 6
        """)
        flights = cursor.fetchall()
        cursor.close()
        conn.close()
    return render_template('home.html', flights=flights)

# ============================================================
# USER AUTHENTICATION ROUTES
# ============================================================
@app.route('/register', methods=['GET', 'POST'])
def register():
    """Handle user registration."""
    if 'user_id' in session:
        return redirect(url_for('home'))

    if request.method == 'POST':
        full_name = request.form.get('full_name', '').strip()
        email     = request.form.get('email', '').strip()
        password  = request.form.get('password', '')
        phone     = request.form.get('phone', '').strip()
        dob       = request.form.get('dob', '')
        gender    = request.form.get('gender', 'Other')

        # Basic validation
        if not full_name or not email or not password:
            flash('Name, email and password are required.', 'error')
            return render_template('register.html')

        # Hash the password before storing
        hashed_pw = generate_password_hash(password)

        conn = get_db_connection()
        if not conn:
            flash('Database connection failed. Please try again.', 'error')
            return render_template('register.html')

        try:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO User (full_name, email, password_hash, phone, dob, gender)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (full_name, email, hashed_pw, phone, dob or None, gender))
            conn.commit()
            flash('Registration successful! Please log in.', 'success')
            return redirect(url_for('login'))
        except Error as e:
            conn.rollback()
            if 'Duplicate entry' in str(e):
                flash('Email already registered. Please log in.', 'error')
            else:
                flash(f'Registration failed: {e}', 'error')
        finally:
            cursor.close()
            conn.close()

    return render_template('register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    """Handle user login with session creation."""
    if 'user_id' in session:
        return redirect(url_for('home'))

    if request.method == 'POST':
        email    = request.form.get('email', '').strip()
        password = request.form.get('password', '')

        conn = get_db_connection()
        if not conn:
            flash('Database connection failed.', 'error')
            return render_template('login.html')

        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM User WHERE email = %s", (email,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user and check_password_hash(user['password_hash'], password):
            # Store user info in session
            session['user_id']   = user['user_id']
            session['full_name'] = user['full_name']
            session['email']     = user['email']
            flash(f"Welcome back, {user['full_name']}!", 'success')
            return redirect(url_for('home'))
        else:
            flash('Invalid email or password.', 'error')

    return render_template('login.html')


@app.route('/logout')
def logout():
    """Clear session and log out user."""
    session.clear()
    flash('You have been logged out.', 'info')
    return redirect(url_for('home'))

# ============================================================
# FLIGHT SEARCH ROUTE
# ============================================================
@app.route('/search', methods=['GET', 'POST'])
def search():
    """Search flights based on user criteria."""
    flights = []
    search_params = {}

    if request.method == 'POST':
        origin      = request.form.get('origin', '').strip()
        destination = request.form.get('destination', '').strip()
        date        = request.form.get('date', '')
        flight_class= request.form.get('flight_class', '')

        search_params = {
            'origin': origin,
            'destination': destination,
            'date': date,
            'flight_class': flight_class
        }

        conn = get_db_connection()
        if conn:
            cursor = conn.cursor(dictionary=True)
            # Dynamic query with optional filters
            query = """
                SELECT f.*, a.airline_name 
                FROM Flight f
                JOIN Airline a ON f.airline_id = a.airline_id
                WHERE f.available_seats > 0
            """
            params = []

            if origin:
                query += " AND LOWER(f.origin) LIKE %s"
                params.append(f"%{origin.lower()}%")
            if destination:
                query += " AND LOWER(f.destination) LIKE %s"
                params.append(f"%{destination.lower()}%")
            if date:
                query += " AND DATE(f.departure_time) = %s"
                params.append(date)
            if flight_class:
                query += " AND f.flight_class = %s"
                params.append(flight_class)

            query += " ORDER BY f.departure_time"
            cursor.execute(query, params)
            flights = cursor.fetchall()
            cursor.close()
            conn.close()

            if not flights:
                flash('No flights found matching your criteria.', 'info')

    return render_template('search.html', flights=flights, search_params=search_params)

# ============================================================
# TICKET BOOKING ROUTES
# ============================================================
@app.route('/booking/<int:flight_id>', methods=['GET', 'POST'])
def booking(flight_id):
    """Show booking form and handle ticket creation."""
    if 'user_id' not in session:
        flash('Please log in to book a flight.', 'warning')
        return redirect(url_for('login'))

    conn = get_db_connection()
    if not conn:
        flash('Database error. Please try again.', 'error')
        return redirect(url_for('search'))

    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT f.*, a.airline_name 
        FROM Flight f
        JOIN Airline a ON f.airline_id = a.airline_id 
        WHERE f.flight_id = %s
    """, (flight_id,))
    flight = cursor.fetchone()
    cursor.close()

    if not flight:
        conn.close()
        flash('Flight not found.', 'error')
        return redirect(url_for('search'))

    # Get booked seats
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT seat_number FROM Ticket WHERE flight_id = %s AND ticket_status != 'Cancelled'", (flight_id,))
    booked_seats = {row['seat_number'] for row in cursor.fetchall()}
    
    # Get cabin crew for this flight to act as potential caretakers
    cursor.execute("""
        SELECT e.employee_id, e.full_name, e.role 
        FROM Employee e
        JOIN Flight_Crew fc ON e.employee_id = fc.employee_id
        WHERE fc.flight_id = %s AND e.role IN ('Cabin Crew', 'Flight Attendant')
    """, (flight_id,))
    cabin_crew = cursor.fetchall()
    cursor.close()

    # Generate all possible seats (150 seats = 25 rows * 6 columns)
    all_seats = [f"{row}{col}" for row in range(1, 26) for col in ['A', 'B', 'C', 'D', 'E', 'F']]
    available_seats_list = [seat for seat in all_seats if seat not in booked_seats]

    if request.method == 'POST':
        passenger_name = request.form.get('passenger_name', '').strip()
        passport_no    = request.form.get('passport_no', '').strip()
        seat_number    = request.form.get('seat_number', '').strip()

        if not passenger_name:
            flash('Passenger name is required.', 'error')
            conn.close()
            return redirect(url_for('booking', flight_id=flight_id))

        if not seat_number:
            flash('Please select a seat.', 'error')
            conn.close()
            return redirect(url_for('booking', flight_id=flight_id))

        if flight['available_seats'] <= 0:
            flash('Sorry, no seats available on this flight.', 'error')
            conn.close()
            return redirect(url_for('search'))

        try:
            cursor = conn.cursor()
            
            # --- CONCURRENCY CONTROL & ACID ---
            cursor.execute("SELECT available_seats, price FROM Flight WHERE flight_id = %s FOR UPDATE", (flight_id,))
            flight_lock = cursor.fetchone()
            
            if not flight_lock or flight_lock[0] <= 0: 
                conn.rollback()
                flash('Sorry, no seats available on this flight.', 'error')
                return redirect(url_for('search'))

            # Check if the requested seat is still available
            cursor.execute("SELECT 1 FROM Ticket WHERE flight_id = %s AND seat_number = %s AND ticket_status != 'Cancelled' FOR UPDATE", (flight_id, seat_number))
            if cursor.fetchone():
                conn.rollback()
                flash(f'Seat {seat_number} was just booked by someone else. Please choose another seat.', 'error')
                return redirect(url_for('booking', flight_id=flight_id))

            # Insert or update Passenger record
            cursor.execute("""
                INSERT INTO Passenger (passport_no, passenger_name)
                VALUES (%s, %s)
                ON DUPLICATE KEY UPDATE passenger_name = %s
            """, (passport_no, passenger_name, passenger_name))

            # Insert ticket record
            caretaker_id = request.form.get('caretaker_id')
            cursor.execute("""
                INSERT INTO Ticket (user_id, flight_id, seat_number, passport_no, total_price, ticket_status, caretaker_id)
                VALUES (%s, %s, %s, %s, %s, 'Confirmed', %s)
            """, (session['user_id'], flight_id, seat_number, passport_no, flight_lock[1], caretaker_id or None)) 

            ticket_id = cursor.lastrowid    
            conn.commit()
            flash('Booking confirmed!', 'success')
            cursor.close()
            conn.close()
            return redirect(url_for('confirmation', ticket_id=ticket_id))

        except Error as e:
            conn.rollback()
            flash(f'Booking failed: {e}', 'error')
            cursor.close()

    conn.close()
    return render_template('booking.html', flight=flight, available_seats=available_seats_list, cabin_crew=cabin_crew)

# ============================================================
# BOOKING CONFIRMATION ROUTE
# ============================================================
@app.route('/confirmation/<int:ticket_id>')
def confirmation(ticket_id):
    """Show booking confirmation details."""
    if 'user_id' not in session:
        return redirect(url_for('login'))

    conn = get_db_connection()
    if not conn:
        flash('Database error.', 'error')
        return redirect(url_for('home'))

    cursor = conn.cursor(dictionary=True)
    # Join Ticket with Flight and User for full details
    cursor.execute("""
        SELECT t.*, f.flight_number, a.airline_name, f.origin, f.destination,
               f.departure_time, f.arrival_time, f.flight_class,
               u.full_name, u.email, p.passenger_name, e.full_name as caretaker_name
        FROM Ticket t
        JOIN Flight f ON t.flight_id = f.flight_id
        JOIN Airline a ON f.airline_id = a.airline_id
        JOIN User u ON t.user_id = u.user_id
        LEFT JOIN Passenger p ON t.passport_no = p.passport_no
        LEFT JOIN Employee e ON t.caretaker_id = e.employee_id
        WHERE t.ticket_id = %s AND t.user_id = %s
    """, (ticket_id, session['user_id']))
    ticket = cursor.fetchone()
    cursor.close()
    conn.close()

    if not ticket:
        flash('Ticket not found.', 'error')
        return redirect(url_for('home'))

    return render_template('confirmation.html', ticket=ticket)

# ============================================================
# MY BOOKINGS ROUTE
# ============================================================
@app.route('/my_bookings')
def my_bookings():
    """Show all tickets booked by the logged-in user."""
    if 'user_id' not in session:
        return redirect(url_for('login'))

    conn = get_db_connection()
    tickets = []
    if conn:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
            SELECT t.*, f.flight_number, a.airline_name, f.origin, f.destination,
                   f.departure_time, f.flight_class, p.passenger_name, e.full_name as caretaker_name
            FROM Ticket t
            JOIN Flight f ON t.flight_id = f.flight_id
            JOIN Airline a ON f.airline_id = a.airline_id
            LEFT JOIN Passenger p ON t.passport_no = p.passport_no
            LEFT JOIN Employee e ON t.caretaker_id = e.employee_id
            WHERE t.user_id = %s
            ORDER BY t.booking_date DESC
        """, (session['user_id'],))
        tickets = cursor.fetchall()

        # Fetch meals for these tickets
        for ticket in tickets:
            cursor.execute("""
                SELECT fo.quantity, m.meal_name, m.meal_type
                FROM Food_Ordering fo
                JOIN Meal m ON fo.meal_id = m.meal_id
                WHERE fo.ticket_id = %s
            """, (ticket['ticket_id'],))
            ticket['meals'] = cursor.fetchall()

        cursor.close()
        conn.close()

    return render_template('my_bookings.html', tickets=tickets)

# ============================================================
# FOOD ORDERING ROUTES
# ============================================================

@app.route('/food/<int:ticket_id>', methods=['GET', 'POST'])
def food(ticket_id):
    """Handle food ordering for a booked ticket."""
    if 'user_id' not in session:
        return redirect(url_for('login'))

    conn = get_db_connection()
    if not conn:
        flash('Database error.', 'error')
        return redirect(url_for('my_bookings'))

    cursor = conn.cursor(dictionary=True)
    # Verify ticket belongs to this user
    cursor.execute("""
        SELECT t.*, f.flight_number, f.origin, f.destination, f.departure_time
        FROM Ticket t JOIN Flight f ON t.flight_id = f.flight_id
        WHERE t.ticket_id = %s AND t.user_id = %s
    """, (ticket_id, session['user_id']))
    ticket = cursor.fetchone()

    if not ticket:
        cursor.close()
        conn.close()
        flash('Ticket not found.', 'error')
        return redirect(url_for('my_bookings'))

    # Fetch meal types to populate dropdown
    cursor.execute("SELECT DISTINCT meal_type FROM Meal")
    meal_options = {row['meal_type']: [] for row in cursor.fetchall()}

    # Fetch existing food orders for this ticket
    cursor.execute("""
        SELECT fo.*, m.meal_name, m.meal_type, m.price
        FROM Food_Ordering fo
        JOIN Meal m ON fo.meal_id = m.meal_id
        WHERE fo.ticket_id = %s
    """, (ticket_id,))
    existing_orders = cursor.fetchall()

    if request.method == 'POST':
        meal_type = request.form.get('meal_type', '')
        meal_id = request.form.get('meal_name', '')
        quantity  = int(request.form.get('quantity', 1))

        if not meal_type or not meal_id:
            flash('Please select a valid meal.', 'error')
        else:
            try:
                cursor.execute("SELECT meal_id FROM Meal WHERE meal_id = %s", (meal_id,))
                meal = cursor.fetchone()
                
                if meal:
                    cursor.execute("""
                        INSERT INTO Food_Ordering (ticket_id, user_id, meal_id, quantity)
                        VALUES (%s, %s, %s, %s)
                    """, (ticket_id, session['user_id'], meal_id, quantity))
                    conn.commit()
                    flash('Meal ordered successfully!', 'success')
                    # Refresh orders
                    cursor.execute("""
                        SELECT fo.*, m.meal_name, m.meal_type, m.price
                        FROM Food_Ordering fo
                        JOIN Meal m ON fo.meal_id = m.meal_id
                        WHERE fo.ticket_id = %s
                    """, (ticket_id,))
                    existing_orders = cursor.fetchall()
                else:
                    flash('Selected meal is invalid.', 'error')
            except Error as e:
                conn.rollback()
                flash(f'Order failed: {e}', 'error')

    cursor.close()
    conn.close()
    return render_template('food.html', ticket=ticket, meal_options=meal_options,
                           existing_orders=existing_orders)

# ============================================================
# CREW INFORMATION ROUTE
# ============================================================
@app.route('/crew')
def crew():
    """Display crew information for all or a specific flight."""
    flight_id = request.args.get('flight_id', '')
    conn = get_db_connection()
    crew_members = []
    flights = []

    if conn:
        cursor = conn.cursor(dictionary=True)
        # Get all flights for the filter dropdown
        cursor.execute("SELECT flight_id, flight_number, origin, destination FROM Flight ORDER BY flight_number")
        flights = cursor.fetchall()

        if flight_id:
            cursor.execute("""
                SELECT e.*, f.flight_number, f.origin, f.destination, f.departure_time
                FROM Employee e 
                JOIN Flight_Crew fc ON e.employee_id = fc.employee_id
                JOIN Flight f ON fc.flight_id = f.flight_id
                WHERE fc.flight_id = %s
                ORDER BY e.role
            """, (flight_id,))
        else:
            cursor.execute("""
                SELECT e.*, f.flight_number, f.origin, f.destination, f.departure_time
                FROM Employee e 
                JOIN Flight_Crew fc ON e.employee_id = fc.employee_id
                JOIN Flight f ON fc.flight_id = f.flight_id
                ORDER BY f.flight_number, e.role
            """)
        crew_members = cursor.fetchall()
        cursor.close()
        conn.close()

    return render_template('crew.html', crew_members=crew_members,
                           flights=flights, selected_flight=flight_id)

# ============================================================
# CANCEL TICKET ROUTE
# ============================================================
@app.route('/cancel_ticket/<int:ticket_id>', methods=['POST'])
def cancel_ticket(ticket_id):
    """Cancel a ticket and restore the available seat count."""
    if 'user_id' not in session:
        return redirect(url_for('login'))

    conn = get_db_connection()
    if not conn:
        flash('Database error.', 'error')
        return redirect(url_for('my_bookings'))

    try:
        cursor = conn.cursor(dictionary=True)
        # Verify ticket ownership and lock
        cursor.execute("SELECT * FROM Ticket WHERE ticket_id = %s AND user_id = %s FOR UPDATE",
                       (ticket_id, session['user_id']))
        ticket = cursor.fetchone()

        if not ticket or ticket['ticket_status'] == 'Cancelled':
            flash('Cannot cancel this ticket.', 'error')
        else:
            # Cancel the ticket
            cursor.execute("UPDATE Ticket SET ticket_status = 'Cancelled' WHERE ticket_id = %s", (ticket_id,))
            # Restore the seat
            cursor.execute("UPDATE Flight SET available_seats = available_seats + 1 WHERE flight_id = %s",
                           (ticket['flight_id'],))
            conn.commit()
            flash('Ticket cancelled successfully.', 'success')

        cursor.close()
    except Error as e:
        conn.rollback()
        flash(f'Cancellation failed: {e}', 'error')
    finally:
        conn.close()

    return redirect(url_for('my_bookings'))

# ============================================================
# API ENDPOINT: Get meals by type (used by JS)
# ============================================================
@app.route('/api/meals/<meal_type>')
def get_meals(meal_type):
    """Return JSON list of meals for a given meal type."""
    conn = get_db_connection()
    meals = []
    if conn:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT meal_id, meal_name, price FROM Meal WHERE meal_type = %s", (meal_type,))
        for row in cursor.fetchall():
            meals.append({
                'meal_id': row['meal_id'],
                'name': row['meal_name'],
                'price': float(row['price'])
            })
        cursor.close()
        conn.close()
    return jsonify(meals)

# ============================================================
# MAIN ENTRY POINT
# ============================================================
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)