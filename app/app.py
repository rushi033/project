from flask import Flask, request
import sqlite3

app = Flask(__name__)

@app.route("/login", methods=["POST"])
def login():
    user = request.form["username"]
    pwd = request.form["password"]
    
    # Vulnerable to SQL Injection
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM users WHERE username='{user}' AND password='{pwd}'")
    result = cursor.fetchone()
    return "Welcome" if result else "Invalid"

@app.route("/eval")
def eval_route():
    code = request.args.get("code")
    return str(eval(code))  # Vulnerable to code injection

if __name__ == "__main__":
    app.run(debug=True)
