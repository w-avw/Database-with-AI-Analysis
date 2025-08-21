from flask import Flask, jsonify
import psycopg2
import os

app = Flask(__name__)

def get_db_connection():
    return psycopg2.connect(
        dbname=os.getenv('POSTGRES_DB', 'mydb'),
        user=os.getenv('POSTGRES_USER', 'myuser'),
        password=os.getenv('POSTGRES_PASSWORD', 'mypassword'),
        host=os.getenv('POSTGRES_HOST', 'localhost'),
        port=os.getenv('POSTGRES_PORT', '5433')
    )

@app.route('/api/errors')
def errors():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT DATE_TRUNC('day', date_time) as time,
            COUNT(*) FILTER (WHERE disconnection_cause = '014 - SwMI requested disconnection') as swmi_disconnections,
            COUNT(*) as total_calls
        FROM call_records
        WHERE source_fleet = '100 - NJT OPS'
        GROUP BY DATE_TRUNC('day', date_time)
        ORDER BY time;
    """)
    rows = cur.fetchall()
    cur.close()
    conn.close()
    result = [{
        "time": str(row[0]),
        "swmi_disconnections": row[1],
        "total_calls": row[2]
    } for row in rows]
    return jsonify(result)

if __name__ == '__main__':
    app.run(port=5000, host='0.0.0.0')
