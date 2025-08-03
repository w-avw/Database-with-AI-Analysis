# 🚀 Universal DB - Grafana Dashboard Complete

## 📋 Descripción General

Este directorio contiene un dashboard completo de Grafana para análisis de comunicaciones TETRA con más de **24,842 registros** importados. El dashboard incluye 8+ paneles organizados por secciones funcionales para monitoreo en tiempo real, análisis de fallos e detección de interferencias.

## 🗂️ Estructura de Archivos

```
Copilot/chatgpt-postgres-grafana-app/
├── dashboard-universal-db-complete.json    # 🎯 Dashboard completo (IMPORTAR ESTE)
├── dashboard-complete.json                 # 📊 Dashboard básico (versión anterior)
├── import-dashboard.sh                     # 🚀 Script automático de importación
├── docker-compose.yml                      # 🐳 Configuración Docker
├── grafana-queries.sql                     # 📝 Todas las consultas SQL
├── queries-by-type/                        # 📁 Consultas organizadas por tipo
│   ├── 01-basic-overview-metrics.sql
│   ├── 02-system-failures.sql
│   ├── 03-interference-detection.sql
│   ├── 04-network-controller.sql
│   ├── 05-priority-queue.sql
│   ├── 06-state-analysis.sql
│   ├── 07-real-time-monitoring.sql
│   ├── 08-advanced-alerts.sql
│   ├── 09-distribution-analytics.sql
│   └── 10-fleet-operational-analytics.sql
└── README.md                               # 📚 Esta documentación
```

## 🎯 IMPORTACIÓN RÁPIDA (RECOMENDADO)

### Método 1: Script Automático
```bash
cd /workspaces/Universal-DB/Copilot/chatgpt-postgres-grafana-app/
./import-dashboard.sh
```

### Método 2: Importación Manual
1. **Accede a Grafana**: http://localhost:3000
   - Usuario: `admin`
   - Contraseña: `admin`

2. **Importa el Dashboard**:
   - Vai a **Dashboards** → **Import**
   - Selecciona **Upload JSON file**
   - Carga: `dashboard-universal-db-complete.json`
   - Clic en **Import**

## 📊 PANELES INCLUIDOS

### 🔢 **Section: Basic Overview Metrics**
- **Total Call Records**: Contador total de registros
- **System Health Score**: Puntuación de salud del sistema (0-100)
- **Critical Failures**: Número de fallos críticos

### 📡 **Section: System Failure Analytics**
- **Interference Events**: Eventos de interferencia detectados
- **Network Load**: Carga actual de la red (gauge)
- **System Failures Over Time**: Tendencia temporal de fallos

### 🔍 **Section: Interference Detection**
- **Interference Pattern Analysis**: Análisis de patrones de interferencia
- **Cell Reselection Impact**: Impacto de reselección de celdas

## ⚙️ CONFIGURACIÓN TÉCNICA

### Fuente de Datos
- **Tipo**: PostgreSQL
- **Host**: `postgres:5432`
- **Database**: `universal_db`
- **Usuario**: `user`
- **Contraseña**: `password`

### Variables del Dashboard
- **$__timeFilter()**: Filtro automático de tiempo
- **Refresh**: 30 segundos automático
- **Time Range**: Últimas 6 horas por defecto

### Umbrales Configurados
- **System Health**: Verde (>80), Amarillo (60-80), Rojo (<60)
- **Network Load**: Verde (<70%), Amarillo (70-85%), Rojo (>85%)
- **Critical Failures**: Verde (0), Amarillo (1-5), Rojo (>5)

## 🔧 TROUBLESHOOTING

### Problema: "No data points"
```bash
# Verificar que PostgreSQL esté ejecutándose
docker-compose ps

# Verificar conexión a la base de datos
docker exec -it postgres_container psql -U user -d universal_db -c "SELECT COUNT(*) FROM call_records;"
```

### Problema: "Data source not found"
1. Vai a **Configuration** → **Data Sources**
2. Añade PostgreSQL con las credenciales de arriba
3. Testa la conexión

### Problema: "Dashboard import failed"
```bash
# Verificar que Grafana esté ejecutándose
curl -s http://localhost:3000/api/health

# Reiniciar servicios si es necesario
docker-compose restart
```

## 📈 CONSULTAS PRINCIPALES

### 1. Total de Registros
```sql
SELECT COUNT(*) as total_records 
FROM call_records;
```

### 2. Puntuación de Salud
```sql
SELECT 
    (100.0 - (COUNT(CASE WHEN status = 'failed' THEN 1 END) * 100.0 / COUNT(*)))::numeric(5,2) as health_score
FROM call_records 
WHERE date_time >= NOW() - INTERVAL '1 hour';
```

### 3. Fallos Críticos
```sql
SELECT COUNT(*) as critical_failures
FROM call_records 
WHERE status = 'failed' 
AND priority IN ('emergency', 'critical')
AND date_time >= $__timeFilter(date_time);
```

## 📚 RECURSOS ADICIONALES

### Archivos de Consultas
- **grafana-queries.sql**: Todas las consultas con documentación detallada
- **queries-by-type/**: Consultas organizadas por categoría funcional

### Documentación Técnica
- Cada consulta incluye comentarios línea por línea
- Configuración OVERVIEW/SETTINGS detallada
- Explicaciones de umbrales y alertas

### Datos de Ejemplo
- **24,842 registros** de comunicaciones TETRA
- Datos reales de sistema de radio profesional
- Incluye metadatos de interferencias y estados

## 🎯 CASOS DE USO

### 1. Monitoreo en Tiempo Real
- Dashboard auto-refresh cada 30 segundos
- Alertas visuales con umbrales configurados
- Métricas de rendimiento instantáneas

### 2. Análisis de Fallos
- Tendencias temporales de system failures
- Correlación entre interferencias y fallos
- Impacto de reselección de celdas

### 3. Planificación de Capacidad
- Análisis de carga de red
- Patrones de uso por horas/días
- Predicción de crecimiento

## 🚀 PRÓXIMOS PASOS

1. **Importa el dashboard** usando uno de los métodos de arriba
2. **Explora los paneles** y ajusta time ranges según necesidad
3. **Configura alertas** adicionales si es necesario
4. **Personaliza umbrales** según tus criterios operacionales

---

**✅ Dashboard listo para producción con 24,842 registros TETRA**
