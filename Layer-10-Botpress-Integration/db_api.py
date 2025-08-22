from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
import os

app = Flask(__name__)
CORS(app)

def get_db_connection():
    return psycopg2.connect(
        dbname=os.getenv('POSTGRES_DB', 'mydb'),
        user=os.getenv('POSTGRES_USER', 'myuser'),
        password=os.getenv('POSTGRES_PASSWORD', 'mypass'),
        host=os.getenv('POSTGRES_HOST', 'localhost'),
        port=os.getenv('POSTGRES_PORT', '5433')
    )


# Unified analytics endpoint for Botpress and other clients
@app.route('/api/analytics')
def analytics():
    query_type = request.args.get('query', 'error_analysis')
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        if query_type == 'error_analysis':
            cur.execute("""
                SELECT DATE_TRUNC('day', date_time) as time,
                    COUNT(*) FILTER (WHERE disconnection_cause = '014 - SwMI requested disconnection') as swmi_disconnections,
                    COUNT(*) FILTER (WHERE disconnection_cause = '042 - Invalid calling party SSI') as invalid_caller_ssi,
                    COUNT(*) FILTER (WHERE disconnection_cause = '043 - Calling party is not allowed to make this type of service') as permission_denied,
                    COUNT(*) FILTER (WHERE disconnection_cause = '045 - Group permission denied') as group_permission_denied,
                    COUNT(*) FILTER (WHERE disconnection_cause = '040 - Invalid called party SSI') as invalid_called_ssi,
                    COUNT(*) FILTER (WHERE disconnection_cause = '054 - Empty group') as empty_group,
                    COUNT(*) FILTER (WHERE disconnection_cause = '016 - Unknown TETRA identity') as unknown_identity,
                    COUNT(*) FILTER (WHERE disconnection_cause = '034 - Error in SBS') as sbs_errors,
                    COUNT(*) FILTER (WHERE disconnection_cause = '037 - Timeout in queue') as queue_timeout,
                    COUNT(*) FILTER (WHERE disconnection_cause = '044 - Preemption') as preemption,
                    COUNT(*) FILTER (WHERE disconnection_cause = '019 - Call restoration of the other user failed') as restoration_failed,
                    COUNT(*) FILTER (WHERE disconnection_cause = '023 - Non-call owner disconnection') as non_owner_disconnect,
                    COUNT(*) FILTER (WHERE disconnection_cause = '009 - Pre-emptive resource use') as resource_preemption,
                    COUNT(*) FILTER (WHERE disconnection_cause = '056 - Called party not registered') as not_registered,
                    COUNT(*) FILTER (WHERE disconnection_cause = '017 - Supplementary Service disconnection') as service_disconnect,
                    COUNT(*) FILTER (WHERE disconnection_cause NOT IN ('033 - Speech inactivity timeout', '001 - User requested disconnection', '013 - Expiry of timer')) as total_errors,
                    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as normal_disconnections,
                    COUNT(*) as total_calls
                FROM call_records
                WHERE source_fleet = '100 - NJT OPS'
                    AND date_time IS NOT NULL
                GROUP BY DATE_TRUNC('day', date_time)
                ORDER BY time;
            """)
        elif query_type == 'system_failure':
            cur.execute("""
                SELECT DATE_TRUNC('hour', date_time) as time,
                    COUNT(*) as total_calls,
                    COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') as successful_calls,
                    COUNT(*) FILTER (WHERE disconnection_cause != '001 - User requested disconnection') as disconnected_calls,
                    ROUND((COUNT(*) FILTER (WHERE disconnection_cause = '001 - User requested disconnection') * 100.0 / NULLIF(COUNT(*), 0))::numeric, 2) as success_rate_percent,
                    COUNT(*) FILTER (WHERE disconnection_cause = '034 - Error in SBS') as sbs_errors,
                    COUNT(*) FILTER (WHERE disconnection_cause = '016 - Unknown TETRA identity') as tetra_identity_errors,
                    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%SBS%' OR disconnection_cause LIKE '%Error%') as system_errors_total,
                    COUNT(*) FILTER (WHERE disconnection_cause LIKE '%timeout%' OR disconnection_cause LIKE '%timer%') as timeouts,
                    COUNT(*) FILTER (WHERE cell_reselection = 'Yes') as cell_reselection_events,
                    COUNT(DISTINCT SUBSTRING(source_location FROM 1 FOR 10)) as active_bases
                FROM call_records
                WHERE date_time IS NOT NULL
                GROUP BY DATE_TRUNC('hour', date_time)
                ORDER BY time;
            """)
        else:
            cur.close()
            conn.close()
            return jsonify({'error': 'Invalid query type'}), 400
        rows = cur.fetchall()
        result = [dict(zip([desc[0] for desc in cur.description], row)) for row in rows]
        cur.close()
        conn.close()
        return jsonify(result)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(port=5434, host='0.0.0.0')
