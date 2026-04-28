# ✈️ AltitudeX - Next-Gen Airline Reservation System

AltitudeX is a premium, high-tech airline management and reservation platform featuring a futuristic **Neon-Glassmorphism** interface. Designed for a seamless user experience, it combines advanced booking logic with immersive visual effects.

---

## 🌟 Key Features

### 🔹 Modern Booking Experience
- **Futuristic UI**: A high-contrast dark theme with neon blue accents, interactive glassmorphism cards, and digital glitch effects.
- **Dynamic Search**: Filter flights by origin, destination, date, and class with real-time "LIVE" status indicators.
- **Seat Selection**: Interactive seat selection with concurrency control to prevent double-bookings.

### 🔹 Passenger-Centric Tools
- **Elderly Assistance & Caretakers**: Unique feature allowing elderly passengers to request dedicated cabin crew assistance during booking.
- **In-Flight Meal Ordering**: Pre-order meals (Veg, Non-Veg, Vegan) and manage orders directly from the dashboard.
- **My Bookings Dashboard**: A high-density "Single Row" table layout providing a comprehensive overview of tickets, meals, and assistance details.

### 🔹 Technical Highlights
- **Advanced Visuals**: Animated scanlines, holographic light sweeps, and responsive CRT-style overlays.
- **Database Integrity**: Normalized MySQL schema with ACID-compliant transactions and row-level locking.
- **Immersive HUD**: A system status footer showing network security and encryption levels.

---

## 🛠️ Tech Stack

- **Frontend**: HTML5, CSS3 (Vanilla), JavaScript (ES6+)
- **Backend**: Python 3.x, Flask
- **Database**: MySQL (Normalized 3NF Architecture)
- **Typography**: Orbitron (Headings), Inter (Body), DM Sans (UI)

---

## 🚀 Getting Started

### 1. Prerequisites
- Python 3.8+
- MySQL Server

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/NivedhaJD/Airline-Reservation-System.git
cd Airline-Reservation-System

# Install dependencies
pip install -r requirements.txt
```

### 3. Database Setup
1. Import the provided `airline_reservation.sql` file into your MySQL instance.
2. Update the `DB_CONFIG` credentials in `app.py`:
   ```python
   DB_CONFIG = {
       'host': 'localhost',
       'user': 'your_username',
       'password': 'your_password',
       'database': 'airline_reservation'
   }
   ```

### 4. Run the Application
```bash
python app.py
```
Visit `http://127.0.0.1:5000` to experience AltitudeX.

---

## 📂 Project Structure
- `app.py`: Core Flask application logic and API endpoints.
- `static/`: Contains CSS styles (Neon theme) and JS logic.
- `templates/`: Jinja2 templates for the futuristic UI components.
- `airline_reservation.sql`: Complete database schema and sample data.

---
**AltitudeX** — *Flying into the future of aviation.*
