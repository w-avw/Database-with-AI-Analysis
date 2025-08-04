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