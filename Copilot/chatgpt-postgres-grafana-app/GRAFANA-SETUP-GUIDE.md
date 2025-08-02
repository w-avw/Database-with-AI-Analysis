# 📊 Guía Completa: Universal DB + Grafana Dashboard

## 🎯 Resumen de Datos Importados
- **Total de registros**: 24,842 llamadas
- **Tipos de fuente**: ISSI (18,761) y VOIP (6,081)
- **Duración promedio**: 19 segundos
- **Datos disponibles**: Fuentes, destinos, duración, causas de desconexión, tipos de servicio

## 🚀 Configuración Paso a Paso

### 1. Acceso a Grafana
- **URL**: http://localhost:3000
- **Usuario**: `admin`
- **Contraseña**: `admin123`

### 2. Configurar Data Source
1. Ir a **Configuration** → **Data Sources**
2. Click **Add data source**
3. Seleccionar **PostgreSQL**
4. Configurar:
   ```
   Host: postgres:5432
   Database: mydb
   User: myuser
   Password: mypass
   SSL Mode: disable
   ```
5. Click **Save & Test**

### 3. Importar Dashboard Pre-configurado
1. Ir a **+** → **Import**
2. Copiar el contenido de `call-analytics-dashboard.json`
3. Click **Load** → **Import**

## 📈 Paneles Recomendados

### Panel 1: Estadísticas Generales
```sql
SELECT COUNT(*) as value FROM call_records;
```

### Panel 2: Distribución por Tipo de Fuente
```sql
SELECT source_type as metric, COUNT(*) as value 
FROM call_records 
GROUP BY source_type 
ORDER BY COUNT(*) DESC;
```

### Panel 3: Top 10 Flotas Más Activas
```sql
SELECT source_fleet, COUNT(*) as call_count
FROM call_records 
WHERE source_fleet IS NOT NULL AND source_fleet != '' 
GROUP BY source_fleet 
ORDER BY COUNT(*) DESC 
LIMIT 10;
```

### Panel 4: Causas de Desconexión
```sql
SELECT disconnection_cause, COUNT(*) as value 
FROM call_records 
WHERE disconnection_cause IS NOT NULL 
GROUP BY disconnection_cause 
ORDER BY COUNT(*) DESC 
LIMIT 10;
```

### Panel 5: Duración de Llamadas
```sql
SELECT duration_secs 
FROM call_records 
WHERE duration_secs IS NOT NULL AND duration_secs > 0;
```

## 🎨 Tipos de Visualización Recomendados

1. **Single Stat**: Total de registros, duración promedio
2. **Pie Chart**: Distribución por tipo de fuente
3. **Bar Chart**: Top flotas, causas de desconexión
4. **Table**: Análisis detallado de servicios
5. **Histogram**: Distribución de duración de llamadas

## 🔍 Insights Disponibles

Con tus 24,842 registros puedes analizar:
- ✅ Patrones de uso por tipo de comunicación (ISSI vs VOIP)
- ✅ Rendimiento por flota y operador
- ✅ Análisis de calidad de llamadas
- ✅ Identificación de problemas recurrentes
- ✅ Estadísticas de duración y eficiencia
- ✅ Uso de características de seguridad

## 🚨 Alertas Sugeridas

1. **Llamadas fallidas**: > 5% del total
2. **Duración promedio anómala**: > 180 segundos
3. **Flota inactiva**: 0 llamadas en 1 hora

## 📝 Próximos Pasos

1. Configurar Data Source en Grafana
2. Crear paneles básicos con las consultas proporcionadas
3. Personalizar colores y umbrales
4. Configurar alertas para monitoreo en tiempo real
5. Programar reportes automáticos
