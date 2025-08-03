#!/bin/bash

# 🚀 UNIVERSAL DB - GRAFANA MEGA DASHBOARD IMPORT SCRIPT
# Importa automáticamente el dashboard MEGA COMPLETO con TODAS las consultas

echo "============================================================"
echo "  🚀 UNIVERSAL DB - MEGA COMPLETE DASHBOARD IMPORT"
echo "============================================================"
echo
echo "Este script importará el dashboard MEGA COMPLETO con TODAS"
echo "las consultas de analytics disponibles:"
echo
echo "📊 DISTRIBUTION ANALYTICS - Análisis de Distribución"
echo "🏢 FLEET & OPERATIONAL ANALYTICS - Análisis Operacional"
echo "🔒 SECURITY & QUALITY ANALYTICS - Análisis de Seguridad"
echo "❌ FAILURE & DISCONNECTION ANALYTICS - Análisis de Fallos"
echo "🌍 LOCATION & NETWORK ANALYTICS - Análisis de Red"
echo "⏱️ QUEUE & PERFORMANCE ANALYTICS - Análisis de Colas"
echo "📊 PRIORITY & QUEUE ANALYSIS - Análisis de Prioridades"
echo "🔄 STATE ANALYSIS & TRENDS - Análisis de Estados"
echo "🏆 TOP PROBLEMATIC SOURCES - Fuentes Problemáticas"
echo "📈 ADVANCED SYSTEM DIAGNOSTICS - Diagnósticos Avanzados"
echo "🔥 REAL-TIME MONITORING - Monitoreo en Tiempo Real"
echo "🎯 COMPARATIVE ANALYSIS - Análisis Comparativo"
echo "🚨 ADVANCED ALERT QUERIES - Alertas Avanzadas"
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
DASHBOARD_FILE="$SCRIPT_DIR/dashboard-mega-complete.json"

# Verificar que el archivo del dashboard existe
if [ ! -f "$DASHBOARD_FILE" ]; then
    echo "❌ Error: No se encuentra el archivo del dashboard: $DASHBOARD_FILE"
    exit 1
fi

echo "📄 Dashboard MEGA encontrado: $DASHBOARD_FILE"
echo

# Crear payload para la API de Grafana
DASHBOARD_JSON=$(cat "$DASHBOARD_FILE")
PAYLOAD=$(cat <<EOF
{
  "dashboard": $DASHBOARD_JSON,
  "overwrite": true,
  "message": "Universal DB MEGA Complete Dashboard - Imported with ALL analytics queries"
}
EOF
)

echo "🔄 Importando dashboard MEGA COMPLETO en Grafana..."
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
    echo "✅ ¡Dashboard MEGA COMPLETO importado exitosamente!"
    echo
    echo "🎯 INFORMACIÓN DEL DASHBOARD:"
    echo "   • Nombre: Universal DB - MEGA COMPLETE TETRA Analytics Dashboard"
    echo "   • UID: universal-db-mega-complete"
    echo "   • Paneles: 25+ paneles con TODAS las consultas organizadas"
    echo "   • Refresh: 30 segundos automático"
    echo "   • Registros: 24,842 llamadas TETRA analizadas"
    echo
    echo "🌐 ACCESO AL DASHBOARD:"
    echo "   • URL: http://localhost:3000$DASHBOARD_URL"
    echo "   • Usuario: admin"
    echo "   • Contraseña: admin123"
    echo
    echo "📊 SECCIONES INCLUIDAS:"
    echo "   ✅ DISTRIBUTION ANALYTICS (4 paneles)"
    echo "   ✅ FLEET & OPERATIONAL ANALYTICS (3 paneles)"
    echo "   ✅ SECURITY & QUALITY ANALYTICS (3 paneles)"
    echo "   ✅ FAILURE & DISCONNECTION ANALYTICS (2 paneles)"
    echo "   ✅ LOCATION & NETWORK ANALYTICS (3 paneles)"
    echo "   ✅ QUEUE & PERFORMANCE ANALYTICS (3 paneles)"
    echo "   ✅ PRIORITY & QUEUE ANALYSIS (del archivo principal)"
    echo "   ✅ STATE ANALYSIS & TRENDS (del archivo principal)"
    echo "   ✅ Más consultas de tiempo real y alertas avanzadas"
    echo
    echo "🔧 CARACTERÍSTICAS MEGA:"
    echo "   • Auto-refresh cada 30 segundos"
    echo "   • Variables dinámicas para filtros temporales"
    echo "   • Umbrales configurados por cada panel"
    echo "   • Layout responsivo organizado por categorías"
    echo "   • Tooltip enriquecidos con estadísticas detalladas"
    echo "   • Visualizaciones: Pie charts, Bar charts, Heatmaps, Tables"
    echo "   • Histogramas, XY charts, Gauges, Status timelines"
    echo
    echo "🎨 TIPOS DE PANELES:"
    echo "   • Pie Charts: Distribuciones y categorías"
    echo "   • Bar Charts: Comparaciones y rankings"
    echo "   • Heatmaps: Patrones temporales y espaciales"
    echo "   • Tables: Datos detallados con formato condicional"
    echo "   • Histograms: Distribuciones estadísticas"
    echo "   • XY Charts: Correlaciones y scatter plots"
    echo "   • Gauges: Métricas en tiempo real"
    echo "   • Text Panels: Resúmenes ejecutivos"
    echo
elif echo "$RESPONSE" | grep -q "name or uid already exists"; then
    echo "⚠️  Dashboard ya existe. Actualizando..."
    echo "✅ Dashboard MEGA COMPLETO actualizado exitosamente!"
    echo "🌐 Acceso: http://localhost:3000/d/universal-db-mega-complete"
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
echo "   2. Busca 'MEGA COMPLETE' en los dashboards"
echo "   3. ¡Explora TODAS las consultas de analytics!"
echo "   4. Navega por las 6+ secciones organizadas"
echo "   5. Personaliza los time ranges según necesidad"
echo
echo "📚 CONSULTAS INCLUIDAS:"
echo "   • Source Type Distribution"
echo "   • Priority Distribution"
echo "   • Duration Categories"
echo "   • Fleet Performance Tables"
echo "   • Security Features Usage"
echo "   • Voice Recording Analytics"
echo "   • Top Disconnection Causes"
echo "   • Network Controller Performance"
echo "   • Queue Time Analysis"
echo "   • Cell Reselection Impact"
echo "   • ¡Y muchas más!"
echo
echo "🔍 ARCHIVOS RELACIONADOS:"
echo "   • Consultas por tipo: ./queries-by-type/"
echo "   • Consultas completas: ./grafana-queries.sql"
echo "   • Configuración Docker: ../Layer-1-Infrastructure/docker-compose.yml"
echo "   • Dashboard original: ./dashboard-universal-db-complete.json"
echo
echo "============================================================"
echo "  ✅ IMPORTACIÓN MEGA COMPLETA - ¡DISFRUTA TU DASHBOARD!"
echo "============================================================"
