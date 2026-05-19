from flask import Flask, render_template, request, redirect
import sqlite3
from datetime import datetime

app = Flask(__name__)
DB_PATH = "attendance.db"

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            employee_id TEXT NOT NULL,
            status TEXT NOT NULL,
            timestamp TEXT NOT NULL
        )
    ''')
    conn.commit()
    conn.close()

@app.route("/", methods=["GET", "POST"])
def index():
    message = None
    if request.method == "POST":
        name = request.form.get("name")
        employee_id = request.form.get("employee_id")
        status = request.form.get("status")
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO attendance (name, employee_id, status, timestamp) VALUES (?, ?, ?, ?)",
            (name, employee_id, status, timestamp)
        )
        conn.commit()
        conn.close()
        message = f"Attendance marked for {name}!"
    return render_template("index.html", message=message)

@app.route("/records")
def records():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM attendance ORDER BY id DESC")
    rows = cursor.fetchall()
    conn.close()
    return render_template("records.html", records=rows)

@app.route("/health")
def health():
    return {"status": "healthy"}, 200

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=5000, debug=False)