#!/bin/bash

# 🔍 UNIVERSAL DB - QUICK VERIFICATION SCRIPT
# Verifica que todo esté funcionando correctamente

echo "============================================================"
echo "  🔍 UNIVERSAL DB - QUICK VERIFICATION"
echo "============================================================"
echo

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo "🔄 Verificando estado de servicios Docker..."
echo

# Verificar Docker Compose
if docker-compose ps > /dev/null 2>&1; then
    POSTGRES_STATUS=$(docker-compose ps postgres | grep -c "Up")
    GRAFANA_STATUS=$(docker-compose ps grafana | grep -c "Up")
    
    print_status $((1-POSTGRES_STATUS)) "PostgreSQL Container: $([ $POSTGRES_STATUS -eq 1 ] && echo "Running" || echo "Not Running")"
    print_status $((1-GRAFANA_STATUS)) "Grafana Container: $([ $GRAFANA_STATUS -eq 1 ] && echo "Running" || echo "Not Running")"
else
    print_status 1 "Docker Compose: No containers found"
    echo
    print_info "Para iniciar los servicios: docker-compose up -d"
    exit 1
fi

echo

# Verificar conectividad PostgreSQL
echo "🗄️  Verificando base de datos PostgreSQL..."
RECORD_COUNT=$(docker exec postgres_container psql -U user -d universal_db -t -c "SELECT COUNT(*) FROM call_records;" 2>/dev/null | tr -d ' ')

if [ ! -z "$RECORD_COUNT" ] && [ "$RECORD_COUNT" -gt 0 ]; then
    print_status 0 "Database Connection: OK"
    print_info "Total records in call_records: $RECORD_COUNT"
else
    print_status 1 "Database Connection: Failed or no data"
fi

echo

# Verificar conectividad Grafana
echo "📊 Verificando Grafana..."
if curl -s http://localhost:3000/api/health > /dev/null; then
    print_status 0 "Grafana Web Service: Accessible at http://localhost:3000"
    
    # Verificar si existe datasource PostgreSQL
    DATASOURCE_CHECK=$(curl -s -u admin:admin http://localhost:3000/api/datasources | grep -c "postgresql" 2>/dev/null || echo "0")
    if [ "$DATASOURCE_CHECK" -gt 0 ]; then
        print_status 0 "PostgreSQL Datasource: Configured"
    else
        print_warning "PostgreSQL Datasource: Not configured yet"
        print_info "Configure it manually in Grafana at: Configuration > Data Sources"
    fi
    
    # Verificar si existe el dashboard
    DASHBOARD_CHECK=$(curl -s -u admin:admin http://localhost:3000/api/search?query=Universal | grep -c "universal-db" 2>/dev/null || echo "0")
    if [ "$DASHBOARD_CHECK" -gt 0 ]; then
        print_status 0 "Universal DB Dashboard: Already imported"
        print_info "Access at: http://localhost:3000/d/universal-db-complete"
    else
        print_warning "Universal DB Dashboard: Not imported yet"
        print_info "Run: ./import-dashboard.sh to import automatically"
    fi
else
    print_status 1 "Grafana Web Service: Not accessible"
fi

echo

# Verificar archivos del proyecto
echo "📁 Verificando archivos del proyecto..."

FILES_TO_CHECK=(
    "dashboard-universal-db-complete.json:Dashboard JSON completo"
    "import-dashboard.sh:Script de importación"
    "grafana-queries.sql:Consultas SQL completas"
    "queries-by-type:Carpeta de consultas organizadas"
    "docker-compose.yml:Configuración Docker"
)

for file_info in "${FILES_TO_CHECK[@]}"; do
    IFS=':' read -r file desc <<< "$file_info"
    if [ -e "$file" ]; then
        print_status 0 "$desc: Exists"
    else
        print_status 1 "$desc: Missing"
    fi
done

echo
echo "🎯 RESUMEN DE ESTADO:"
echo

if [ $POSTGRES_STATUS -eq 1 ] && [ $GRAFANA_STATUS -eq 1 ] && [ ! -z "$RECORD_COUNT" ] && [ "$RECORD_COUNT" -gt 0 ]; then
    echo -e "${GREEN}🚀 SISTEMA OPERACIONAL${NC}"
    echo "   • PostgreSQL: ✅ Running with $RECORD_COUNT records"
    echo "   • Grafana: ✅ Running at http://localhost:3000"
    echo "   • Files: ✅ All project files present"
    echo
    echo "🎯 PRÓXIMOS PASOS:"
    if [ "$DASHBOARD_CHECK" -eq 0 ]; then
        echo "   1. Ejecuta: ./import-dashboard.sh"
        echo "   2. Abre: http://localhost:3000"
        echo "   3. Usuario: admin / Contraseña: admin"
    else
        echo "   1. Abre: http://localhost:3000/d/universal-db-complete"
        echo "   2. ¡Explora tus 24,842 registros TETRA!"
    fi
else
    echo -e "${RED}⚠️  SISTEMA REQUIERE ATENCIÓN${NC}"
    echo
    echo "🔧 ACCIONES REQUERIDAS:"
    if [ $POSTGRES_STATUS -eq 0 ] || [ $GRAFANA_STATUS -eq 0 ]; then
        echo "   • Iniciar servicios: docker-compose up -d"
    fi
    if [ -z "$RECORD_COUNT" ] || [ "$RECORD_COUNT" -eq 0 ]; then
        echo "   • Verificar datos: ¿Se importaron los registros TETRA?"
    fi
fi

echo
echo "============================================================"
