# Layer 10: Botpress Integration

## Context
This layer connects Universal-DB's PostgreSQL analytics to AI-driven recommendations and automation via Botpress. The Flask API (`db_api.py`) exposes analytics endpoints for Botpress and other clients to fetch and analyze system data.

- The database contains call records and system events for NJT OPS and related infrastructure.
- The API is designed to be flexible, supporting multiple analytics queries via a single endpoint.
- The API is publicly accessible via ngrok for integration with Botpress Cloud and other external services.

## Goal
Enable an AI (Botpress bot or other agent) to:
- Fetch analytics and error data from Universal-DB via a simple HTTP API.
- Use this data to provide recommendations, detect anomalies, and automate troubleshooting or reporting.
- Support flexible queries for different analytics needs (error analysis, system failure, etc.).

## Tasks for AI
1. **Connect to the API**
   - Use the public endpoint (e.g., `https://<ngrok-url>/api/analytics?query=error_analysis`).
   - Fetch data using HTTP GET requests (e.g., with axios or fetch).

2. **Understand the Data Structure**
   - The API returns JSON arrays of objects, each representing a time bucket (day or hour) with analytics fields.
   - Field names are descriptive (e.g., `swmi_disconnections`, `total_calls`, `system_errors_total`).

3. **Support Multiple Queries**
   - Use the `query` parameter to select the type of analytics needed:
     - `error_analysis`: Error breakdown by day for NJT OPS.
     - `system_failure`: System failure analytics by hour for all bases.
   - The API can be extended to support more queries as needed.

4. **Provide Recommendations**
   - Analyze the returned data for trends, anomalies, or actionable insights.
   - Generate recommendations (e.g., "High SBS Errors detected on 2025-08-20, investigate base station X").
   - Automate reporting or alerting based on analytics.

5. **Troubleshooting & Automation**
   - If the API is unreachable, check ngrok status, Flask server status, and port configuration.
   - If data is missing or unexpected, verify database connection and query logic.

## Example API Usage
```js
const apiUrl = 'https://<ngrok-url>/api/analytics?query=error_analysis';
const response = await axios.get(apiUrl);
const data = response.data;
// Use data for recommendations, reporting, etc.
```

## Integration Checklist
- [x] Flask API running and accessible on public port (e.g., 5434)
- [x] ngrok tunnel active and URL shared with Botpress
- [x] CORS enabled in Flask for external requests
- [x] Database connection parameters set via environment variables or defaults
- [x] API endpoint `/api/analytics` supports multiple queries
- [x] Botpress bot configured to fetch and use analytics data

## For AI Agents
- Always check API health before making requests.
- Use descriptive prompts and context when generating recommendations.
- Adapt to new queries or analytics needs as Universal-DB evolves.
- Document any new endpoints, queries, or integration steps for future agents/users.

---

**This README is designed to give any AI agent or developer the context, goals, and actionable steps needed to work with Layer 10 and help users as effectively as GitHub Copilot.**
