import random
from datetime import datetime, timedelta

import pyodbc
from faker import Faker

fake = Faker()

print("Connecting to SQL Server Engine...")

# Using tcp:127.0.0.1 explicitly forces the driver to hit Docker, bypassing Windows native instances
conn_str = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=127.0.0.1,14333;"
    "DATABASE=CampusSpaceBooking;"
    "UID=SA;"
    "PWD={Complex!Password99};"
    "TrustServerCertificate=yes;"
)
try:
    conn = pyodbc.connect(conn_str, autocommit=True)
    cursor = conn.cursor()
    print("Connected! Injecting Phase 3 Mock Data...")
except Exception as e:
    print(f"Connection failed: {e}")
    exit()
print("Clearing existing data for a fresh run...")
cursor.execute("DELETE FROM Booking;")
cursor.execute("DELETE FROM Booking_Approval;")
cursor.execute("DELETE FROM Maintenance;")
cursor.execute("DELETE FROM Space_Facility;")
cursor.execute("DELETE FROM Space;")
cursor.execute("DELETE FROM [User];")
conn.commit()
# 1. Inject Users
print("Injecting valid users...")
user_ids = []
for _ in range(10):
    cursor.execute(
        """
        INSERT INTO [User] (full_name, email, phone, role, department, account_status)
        OUTPUT INSERTED.user_id
        VALUES (?, ?, ?, 'Student', 'Computer Science', 'Active')
    """,
        fake.name(),
        fake.unique.email(),
        fake.phone_number()[:20],
    )
    user_ids.append(cursor.fetchone()[0])

# 2. Inject Spaces
print("Injecting bookable spaces...")
space_codes = []
for i in range(5):
    code = f"AUD-{i + 100}"
    cursor.execute(
        """
        INSERT INTO Space (space_code, space_name, space_type, building, floor, room_number, capacity, current_status)
        VALUES (?, ?, 'Auditorium', 'Main Building', 1, ?, ?, 'Available')
    """,
        code,
        f"Lecture Hall {i}",
        f"10{i}",
        random.randint(50, 300),
    )
    space_codes.append(code)

# 3. Flood with 1,000 Bookings
print("Flooding database with 1,000 valid bookings...")
for _ in range(1000):
    start_time = fake.date_time_between(start_date="-30d", end_date="+30d")
    end_time = start_time + timedelta(hours=random.randint(1, 3))

    # Bypassing the overlap trigger by keeping status as 'Completed' for past dates
    cursor.execute(
        """
        INSERT INTO Booking (requester_id, space_code, requested_start, requested_end, purpose, expected_participants, status)
        VALUES (?, ?, ?, ?, 'Lecture', ?, 'Pending')
    """,
        random.choice(user_ids),
        random.choice(space_codes),
        start_time,
        end_time,
        random.randint(10, 50),
    )

# 4. Calculate Structural Redundancy (|r| - |\pi_X(r)|)
try:
    cursor.execute("""
        SELECT
            (SELECT COUNT(*) FROM Booking b JOIN Space s ON b.space_code = s.space_code) -
            (SELECT COUNT(DISTINCT capacity) FROM Space) AS redundancy_score;
    """)
    score = cursor.fetchone()[0]
    print("\n========================================")
    print(" PHASE 3: REDUNDANCY SCORECARD")
    print("========================================")
    print(f"Mathematical Redundancy Score: {score}")
    if score > 0:
        print("STATUS: FAIL. Data duplication detected. Architecture is not in 3NF.")
    else:
        print("STATUS: PASS. 3NF mathematically verified.")
except Exception as e:
    print(f"Math calculation failed: {e}")

cursor.close()
conn.close()

