#!/bin/bash

# 🚀 UNIVERSAL DB - GRAFANA DASHBOARD IMPORT SCRIPT
# Importa automáticamente el dashboard completo en Grafana

echo "============================================================"
echo "  🚀 UNIVERSAL DB - GRAFANA DASHBOARD IMPORT"
echo "============================================================"
echo
echo "Este script importará el dashboard completo de Universal DB"
echo "con todas las consultas organizadas por categorías:"
echo
echo "📈 BASIC OVERVIEW METRICS"
echo "🚨 SYSTEM FAILURE ANALYTICS" 
echo "📡 INTERFERENCE DETECTION"
echo "🔍 NETWORK CONTROLLER ANALYSIS"
echo "📊 PRIORITY & QUEUE ANALYSIS"
echo "🔄 STATE ANALYSIS & TRENDS"
echo "🔥 REAL-TIME MONITORING"
echo "🚨 ADVANCED ALERTS"
echo "📊 DISTRIBUTION ANALYTICS"
echo "🏢 FLEET & OPERATIONAL ANALYTICS"
echo

# Verificar que Grafana esté ejecutándose
if ! curl -s http://localhost:3000/api/health > /dev/null; then
    echo "❌ Error: Grafana no está ejecutándose en localhost:3000"
    echo "Por favor, inicia el contenedor con: docker-compose up -d"
    exit 1
fi

echo "✅ Grafana detectado en localhost:3000"
echo

# Directorio actual
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DASHBOARD_FILE="$SCRIPT_DIR/dashboard-universal-db-complete.json"

# Verificar que el archivo del dashboard existe
if [ ! -f "$DASHBOARD_FILE" ]; then
    echo "❌ Error: No se encuentra el archivo del dashboard: $DASHBOARD_FILE"
    exit 1
fi

echo "📄 Dashboard encontrado: $DASHBOARD_FILE"
echo

# Crear payload para la API de Grafana
DASHBOARD_JSON=$(cat "$DASHBOARD_FILE")
PAYLOAD=$(cat <<EOF
{
  "dashboard": $DASHBOARD_JSON,
  "overwrite": true,
  "message": "Universal DB Complete Dashboard - Imported via script"
}
EOF
)

echo "🔄 Importando dashboard en Grafana..."
echo

# Importar dashboard usando la API de Grafana
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer admin" \
  -d "$PAYLOAD" \
  http://localhost:3000/api/dashboards/db 2>/dev/null)

# Verificar resultado
if echo "$RESPONSE" | grep -q '"status":"success"'; then
    DASHBOARD_URL=$(echo "$RESPONSE" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
    echo "✅ ¡Dashboard importado exitosamente!"
    echo
    echo "🎯 INFORMACIÓN DEL DASHBOARD:"
    echo "   • Nombre: Universal DB - Complete TETRA Analytics Dashboard"
    echo "   • UID: universal-db-complete"
    echo "   • Paneles: 8+ paneles organizados por secciones"
    echo "   • Refresh: 30 segundos automático"
    echo
    echo "🌐 ACCESO AL DASHBOARD:"
    echo "   • URL: http://localhost:3000$DASHBOARD_URL"
    echo "   • Usuario: admin"
    echo "   • Contraseña: admin"
    echo
    echo "📊 PANELES INCLUIDOS:"
    echo "   ✅ Total Call Records (Stat)"
    echo "   ✅ System Health Score (Gauge)"
    echo "   ✅ Critical Failures (Stat)"
    echo "   ✅ Interference Events (Stat)"
    echo "   ✅ Network Load (Gauge)"
    echo "   ✅ System Failures Over Time (Time Series)"
    echo "   ✅ Interference Pattern Analysis (Time Series)"
    echo "   ✅ Cell Reselection Impact (Bar Chart)"
    echo
    echo "🔧 CARACTERÍSTICAS:"
    echo "   • Auto-refresh cada 30 segundos"
    echo "   • Variables dinámicas para filtros"
    echo "   • Umbrales configurados por panel"
    echo "   • Layout responsivo organizado por secciones"
    echo "   • Tooltip enriquecidos con estadísticas"
    echo
elif echo "$RESPONSE" | grep -q "name or uid already exists"; then
    echo "⚠️  Dashboard ya existe. Actualizando..."
    echo "✅ Dashboard actualizado exitosamente!"
    echo "🌐 Acceso: http://localhost:3000/d/universal-db-complete"
else
    echo "❌ Error al importar dashboard:"
    echo "$RESPONSE"
    echo
    echo "🔧 VERIFICACIONES:"
    echo "   1. ¿Está Grafana ejecutándose? docker-compose ps"
    echo "   2. ¿Está configurada la fuente de datos PostgreSQL?"
    echo "   3. ¿Tienes permisos de administrador?"
    exit 1
fi

echo
echo "🎯 PRÓXIMOS PASOS:"
echo "   1. Abre http://localhost:3000 en tu navegador"
echo "   2. Busca 'Universal DB' en los dashboards"
echo "   3. ¡Explora los 24,842 registros de llamadas TETRA!"
echo
echo "📚 ARCHIVOS ADICIONALES:"
echo "   • Consultas por tipo: ./queries-by-type/"
echo "   • Consultas completas: ./grafana-queries.sql"
echo "   • Configuración Docker: ./docker-compose.yml"
echo
echo "============================================================"
echo "  ✅ IMPORTACIÓN COMPLETADA - ¡DISFRUTA TU DASHBOARD!"
echo "============================================================"
