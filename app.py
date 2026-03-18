 # ============================================================
# Airline Reservation System - Flask Backend
# Run: python app.py
# ============================================================

from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
import sqlite3
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import random
import string
import os

# Secret key for session management
app = Flask(__name__)
app.secret_key = 'airline_secret_key_2024'

# ============================================================
# SQLITE DATABASE CONFIGURATION
# ============================================================

DATABASE = "airline.db"

def get_db_connection():
    """Create and return a SQLite database connection."""
    try:
        conn = sqlite3.connect(DATABASE)
        conn.row_factory = sqlite3.Row
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        return None


@app.route("/testdb")
def testdb():
    conn = get_db_connection()

    if not conn:
        return "Database connection failed"

    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM Flight")

    result = cursor.fetchone()

    cursor.close()
    conn.close()

    return f"Flights in database: {result[0]}"


def generate_seat_number():
    """Generate a random seat number like 12A"""
    row = random.randint(1, 30)
    col = random.choice(['A','B','C','D','E','F'])
    return f"{row}{col}"


# ============================================================
# HOME ROUTE
# ============================================================

@app.route('/')
def home():
    conn = get_db_connection()
    flights = []

    if conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT flight_number, airline_name, origin, destination,
                   departure_time, price, flight_class, available_seats
            FROM Flight
            WHERE available_seats > 0
            ORDER BY departure_time
            LIMIT 6
        """)
        flights = cursor.fetchall()

        cursor.close()
        conn.close()

    return render_template('home.html', flights=flights)


# ============================================================
# USER REGISTRATION
# ============================================================

@app.route('/register', methods=['GET','POST'])
def register():

    if 'user_id' in session:
        return redirect(url_for('home'))

    if request.method == 'POST':

        full_name = request.form.get('full_name')
        email = request.form.get('email')
        password = request.form.get('password')
        phone = request.form.get('phone')
        dob = request.form.get('dob')
        gender = request.form.get('gender')

        if not full_name or not email or not password:
            flash("All required fields must be filled","error")
            return render_template("register.html")

        hashed_pw = generate_password_hash(password)

        conn = get_db_connection()

        try:
            cursor = conn.cursor()

            cursor.execute("""
                INSERT INTO User (full_name,email,password_hash,phone,dob,gender)
                VALUES (?,?,?,?,?,?)
            """,(full_name,email,hashed_pw,phone,dob,gender))

            conn.commit()

            flash("Registration successful!","success")
            return redirect(url_for('login'))

        except Exception as e:
            conn.rollback()
            flash(f"Registration failed {e}","error")

        finally:
            cursor.close()
            conn.close()

    return render_template("register.html")


# ============================================================
# LOGIN
# ============================================================

@app.route('/login',methods=['GET','POST'])
def login():

    if request.method == "POST":

        email = request.form.get("email")
        password = request.form.get("password")

        conn = get_db_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM User WHERE email = ?",(email,))
        user = cursor.fetchone()

        cursor.close()
        conn.close()

        if user and check_password_hash(user["password_hash"],password):

            session["user_id"] = user["user_id"]
            session["full_name"] = user["full_name"]
            session["email"] = user["email"]

            flash("Login successful","success")
            return redirect(url_for("home"))

        else:
            flash("Invalid email or password","error")

    return render_template("login.html")


# ============================================================
# LOGOUT
# ============================================================

@app.route('/logout')
def logout():

    session.clear()
    flash("Logged out","info")

    return redirect(url_for("home"))


# ============================================================
# SEARCH FLIGHTS
# ============================================================

@app.route('/search',methods=['GET','POST'])
def search():

    flights=[]
    search_params={}

    if request.method=="POST":

        origin=request.form.get("origin")
        destination=request.form.get("destination")
        date=request.form.get("date")
        flight_class=request.form.get("flight_class")

        conn=get_db_connection()
        cursor=conn.cursor()

        query="""
        SELECT * FROM Flight
        WHERE available_seats>0
        """

        params=[]

        if origin:
            query+=" AND LOWER(origin) LIKE ?"
            params.append(f"%{origin.lower()}%")

        if destination:
            query+=" AND LOWER(destination) LIKE ?"
            params.append(f"%{destination.lower()}%")

        if date:
            query+=" AND DATE(departure_time)=?"
            params.append(date)

        if flight_class:
            query+=" AND flight_class=?"
            params.append(flight_class)

        query+=" ORDER BY departure_time"

        cursor.execute(query,params)
        flights=cursor.fetchall()

        cursor.close()
        conn.close()

    return render_template("search.html",flights=flights,search_params=search_params)


# ============================================================
# BOOKING
# ============================================================

@app.route('/booking/<int:flight_id>',methods=['GET','POST'])
def booking(flight_id):

    if "user_id" not in session:
        flash("Login required","warning")
        return redirect(url_for("login"))

    conn=get_db_connection()
    cursor=conn.cursor()

    cursor.execute("SELECT * FROM Flight WHERE flight_id=?",(flight_id,))
    flight=cursor.fetchone()

    if request.method=="POST":

        passenger_name=request.form.get("passenger_name")
        passport_no=request.form.get("passport_no")

        seat_number=generate_seat_number()

        cursor.execute("""
        INSERT INTO Ticket (user_id,flight_id,seat_number,passenger_name,passport_no,total_price)
        VALUES (?,?,?,?,?,?)
        """,(session["user_id"],flight_id,seat_number,passenger_name,passport_no,flight["price"]))

        ticket_id=cursor.lastrowid

        cursor.execute("""
        UPDATE Flight
        SET available_seats=available_seats-1
        WHERE flight_id=?
        """,(flight_id,))

        conn.commit()

        cursor.close()
        conn.close()

        return redirect(url_for("confirmation",ticket_id=ticket_id))

    cursor.close()
    conn.close()

    return render_template("booking.html",flight=flight)


# ============================================================
# CONFIRMATION
# ============================================================

@app.route('/confirmation/<int:ticket_id>')
def confirmation(ticket_id):

    conn=get_db_connection()
    cursor=conn.cursor()

    cursor.execute("""
    SELECT t.*,f.flight_number,f.airline_name,f.origin,f.destination,
           f.departure_time,f.arrival_time,f.flight_class
    FROM Ticket t
    JOIN Flight f ON t.flight_id=f.flight_id
    WHERE t.ticket_id=?
    """,(ticket_id,))

    ticket=cursor.fetchone()

    cursor.close()
    conn.close()

    return render_template("confirmation.html",ticket=ticket)


# ============================================================
# MAIN
# ============================================================

if __name__=="__main__":
    app.run(host="0.0.0.0",port=5000)
