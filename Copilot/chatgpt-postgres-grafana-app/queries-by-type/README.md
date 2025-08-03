# 📊 GRAFANA QUERIES BY TYPE - UNIVERSAL DB ANALYTICS

Este directorio contiene todas las consultas SQL de Grafana organizadas por categorías funcionales para facilitar la revisión y mantenimiento.

## 📁 Estructura de Archivos

### 1. **01-basic-overview-metrics.sql**
📈 **BASIC OVERVIEW METRICS**
- Total Call Records (Stat)
- System Health Score (Gauge)
- Critical Failures Count (Stat)
- Interference Events (Stat)
- Network Load (Gauge)

### 2. **02-system-failure-analytics.sql**
🚨 **SYSTEM FAILURE ANALYTICS - CAUSAS DE CAÍDAS**
- System Failures Over Time (Time series)
- Failure Rate by Location (Heatmap)
- Critical System Alerts (Alert list)

### 3. **03-interference-detection.sql**
📡 **INTERFERENCE DETECTION - ANÁLISIS DE INTERFERENCIAS**
- Interference Pattern Analysis (Time series)
- Cell Reselection Impact Analysis (Bar chart)
- Location-Based Interference Hotspots (Table)
- Network Quality Heatmap (Heatmap)

### 4. **04-network-controller-analysis.sql**
🔍 **NETWORK CONTROLLER ANALYSIS - PUNTOS DE COMPARACIÓN**
- Controller Performance Comparison (Bar chart)
- ISSI vs VOIP Interference Comparison (Table)
- Fleet Interference Analysis (Bar gauge)

### 5. **05-priority-queue-analysis.sql**
📊 **PRIORITY & QUEUE ANALYSIS**
- Priority Impact on Success Rate (XY Chart)
- Queue Time vs Failure Correlation (XY Chart)
- Call Duration Distribution (Histogram)
- Queue Time Analysis (Histogram)
- Queue vs Call Duration (XY Chart)
- Average Queue Time by Priority (Bar gauge)

### 6. **06-state-analysis-trends.sql**
🔄 **STATE ANALYSIS & TRENDS**
- System State Timeline (State timeline)
- Network Capacity Trend (Trend)
- Call Pattern Trends (Trend)
- Calls Over Time by Hour (Time series)
- Average Duration Over Time (Time series)
- Call Success Rate Over Time (Time series)

### 7. **07-real-time-monitoring.sql**
🔥 **REAL-TIME MONITORING QUERIES**
- Current Hour System Health (Gauge)
- Active Interference Events (Stat)
- Network Load Distribution (Pie chart)

### 8. **08-advanced-alerts.sql**
🚨 **ADVANCED ALERT QUERIES**
- System Degradation Alerts (Alert list)
- Interference Detection Summary (Text)
- High Failure Rate Sources (Alert list)

### 9. **09-distribution-analytics.sql**
📊 **DISTRIBUTION ANALYTICS**
- Source Type Distribution (Pie chart)
- Call Duration Distribution (Histogram)
- Priority Distribution (Pie chart)
- Duration Categories (Pie chart)
- Error Distribution by Time (Pie chart)

### 10. **10-fleet-operational-analytics.sql**
🏢 **FLEET & OPERATIONAL ANALYTICS**
- Top Source Fleets Performance (Table)
- Fleet Activity Heatmap (Heatmap)
- Destination Fleet Analysis (Bar chart)
- Most Problematic Sources (Table)

## 🎯 Características de las Consultas

### ✅ Formato Completo
Cada consulta incluye:
- **📊 OVERVIEW**: Tipo de panel, descripción, unidad, decimales
- **🎯 SETTINGS**: Valores min/max, paginación, umbrales, mapeo de valores
- **💡 BEST PRACTICE**: Recomendaciones de configuración de Grafana
- **Comentarios línea por línea**: Explicación detallada de cada componente SQL

### 🔧 Compatibilidad
- ✅ PostgreSQL 13+ compatible
- ✅ Función ROUND() con casting ::numeric
- ✅ Filtros FILTER() para agregaciones condicionales
- ✅ Intervalos de tiempo con NOW() - INTERVAL

### 📊 Base de Datos
- **Tabla principal**: `call_records`
- **Registros**: 24,842 llamadas TETRA
- **Arquitectura**: Sistema Universal DB de 8 capas

## 🚀 Uso

1. **Para revisión individual**: Abrir cada archivo por separado
2. **Para implementación**: Copiar consultas directamente a Grafana
3. **Para mantenimiento**: Editar archivos específicos sin afectar otros
4. **Para testing**: Ejecutar consultas en PostgreSQL directamente

## 📋 Notas Importantes

- Todas las consultas mantienen el formato original exacto
- Los comentarios línea por línea están incluidos
- No interfiere con otros scripts del proyecto
- Estructura modular para fácil mantenimiento
- Compatible con el archivo original `grafana-queries.sql`

## 🔗 Relación con el Proyecto

Esta organización **NO interfiere** con:
- ✅ `docker-compose.yml`
- ✅ Scripts de importación (`import_*.sh`)
- ✅ Base de datos PostgreSQL
- ✅ Configuración de Grafana
- ✅ Archivo original `grafana-queries.sql`

**Propósito**: Facilitar la revisión, mantenimiento y implementación selectiva de consultas analíticas.
