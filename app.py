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
    'database': 'Airline_Reservation',
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
@app.route("/testdb")
def testdb():
    cursor.execute("SELECT COUNT(*) FROM Flight")
    count = cursor.fetchone()
    return f"Flights in database: {count}"
def generate_seat_number():
    """Generate a random seat number like 12A, 5C, etc."""
    row = random.randint(1, 30)
    col = random.choice(['A', 'B', 'C', 'D', 'E', 'F'])
    return f"{row}{col}"

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
            SELECT flight_number, airline_name, origin, destination,
                   departure_time, price, flight_class, available_seats
            FROM Flight
            WHERE status = 'Scheduled' AND available_seats > 0
            ORDER BY departure_time
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
                SELECT * FROM Flight
                WHERE available_seats > 0
                AND status = 'Scheduled'
            """
            params = []

            if origin:
                query += " AND LOWER(origin) LIKE %s"
                params.append(f"%{origin.lower()}%")
            if destination:
                query += " AND LOWER(destination) LIKE %s"
                params.append(f"%{destination.lower()}%")
            if date:
                query += " AND DATE(departure_time) = %s"
                params.append(date)
            if flight_class:
                query += " AND flight_class = %s"
                params.append(flight_class)

            query += " ORDER BY departure_time"
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
    cursor.execute("SELECT * FROM Flight WHERE flight_id = %s", (flight_id,))
    flight = cursor.fetchone()
    cursor.close()

    if not flight:
        conn.close()
        flash('Flight not found.', 'error')
        return redirect(url_for('search'))

    if request.method == 'POST':
        passenger_name = request.form.get('passenger_name', '').strip()
        passport_no    = request.form.get('passport_no', '').strip()

        if not passenger_name:
            flash('Passenger name is required.', 'error')
            conn.close()
            return render_template('booking.html', flight=flight)

        if flight['available_seats'] <= 0:
            flash('Sorry, no seats available on this flight.', 'error')
            conn.close()
            return redirect(url_for('search'))

        seat_number = generate_seat_number()

        try:
            cursor = conn.cursor()
            # Insert ticket record
            cursor.execute("""
                INSERT INTO Ticket (user_id, flight_id, seat_number, passenger_name, passport_no, total_price)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (session['user_id'], flight_id, seat_number, passenger_name, passport_no, flight['price']))

            ticket_id = cursor.lastrowid

            # Reduce available seats by 1
            cursor.execute("""
                UPDATE Flight SET available_seats = available_seats - 1
                WHERE flight_id = %s
            """, (flight_id,))

            conn.commit()
            flash('Booking confirmed!', 'success')
            cursor.close()
            conn.close()
            # Redirect to confirmation page
            return redirect(url_for('confirmation', ticket_id=ticket_id))

        except Error as e:
            conn.rollback()
            flash(f'Booking failed: {e}', 'error')
            cursor.close()

    conn.close()
    return render_template('booking.html', flight=flight)

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
        SELECT t.*, f.flight_number, f.airline_name, f.origin, f.destination,
               f.departure_time, f.arrival_time, f.flight_class,
               u.full_name, u.email
        FROM Ticket t
        JOIN Flight f ON t.flight_id = f.flight_id
        JOIN User u ON t.user_id = u.user_id
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
            SELECT t.*, f.flight_number, f.airline_name, f.origin, f.destination,
                   f.departure_time, f.flight_class
            FROM Ticket t
            JOIN Flight f ON t.flight_id = f.flight_id
            WHERE t.user_id = %s
            ORDER BY t.booking_date DESC
        """, (session['user_id'],))
        tickets = cursor.fetchall()
        cursor.close()
        conn.close()

    return render_template('my_bookings.html', tickets=tickets)

# ============================================================
# FOOD ORDERING ROUTES
# ============================================================

# Available meal options with prices
MEAL_OPTIONS = {
    'Vegetarian': [
        {'name': 'Paneer Butter Masala with Rice',  'price': 350.00},
        {'name': 'Veg Biryani with Raita',           'price': 320.00},
        {'name': 'Dal Tadka with Roti',              'price': 280.00},
    ],
    'Non-Vegetarian': [
        {'name': 'Chicken Curry with Rice',          'price': 420.00},
        {'name': 'Grilled Fish with Veggies',        'price': 480.00},
        {'name': 'Mutton Biryani',                   'price': 500.00},
    ],
    'Vegan': [
        {'name': 'Mixed Vegetable Stir Fry',         'price': 300.00},
        {'name': 'Quinoa Salad Bowl',                'price': 340.00},
    ],
    'Gluten-Free': [
        {'name': 'Grilled Chicken Salad',            'price': 390.00},
        {'name': 'Rice & Lentil Bowl',               'price': 310.00},
    ]
}

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

    # Fetch existing food orders for this ticket
    cursor.execute("SELECT * FROM Food_Ordering WHERE ticket_id = %s", (ticket_id,))
    existing_orders = cursor.fetchall()

    if request.method == 'POST':
        meal_type = request.form.get('meal_type', '')
        meal_name = request.form.get('meal_name', '')
        quantity  = int(request.form.get('quantity', 1))

        # Find price from our menu
        price = 0
        for meal in MEAL_OPTIONS.get(meal_type, []):
            if meal['name'] == meal_name:
                price = meal['price']
                break

        if not meal_type or not meal_name or price == 0:
            flash('Please select a valid meal.', 'error')
        else:
            try:
                cursor.execute("""
                    INSERT INTO Food_Ordering (ticket_id, user_id, meal_type, meal_name, quantity, price)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (ticket_id, session['user_id'], meal_type, meal_name, quantity, price * quantity))
                conn.commit()
                flash('Meal ordered successfully!', 'success')
                # Refresh orders
                cursor.execute("SELECT * FROM Food_Ordering WHERE ticket_id = %s", (ticket_id,))
                existing_orders = cursor.fetchall()
            except Error as e:
                conn.rollback()
                flash(f'Order failed: {e}', 'error')

    cursor.close()
    conn.close()
    return render_template('food.html', ticket=ticket, meal_options=MEAL_OPTIONS,
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
                SELECT c.*, f.flight_number, f.origin, f.destination, f.departure_time
                FROM Crew c JOIN Flight f ON c.flight_id = f.flight_id
                WHERE c.flight_id = %s
                ORDER BY c.role
            """, (flight_id,))
        else:
            cursor.execute("""
                SELECT c.*, f.flight_number, f.origin, f.destination, f.departure_time
                FROM Crew c JOIN Flight f ON c.flight_id = f.flight_id
                ORDER BY f.flight_number, c.role
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
        # Verify ticket ownership
        cursor.execute("SELECT * FROM Ticket WHERE ticket_id = %s AND user_id = %s",
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
    meals = MEAL_OPTIONS.get(meal_type, [])
    return jsonify(meals)

# ============================================================
# MAIN ENTRY POINT
# ============================================================
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
