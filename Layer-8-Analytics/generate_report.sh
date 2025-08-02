#!/bin/bash
# Database Report Generator
# Wrapper script for analytics tools

# Load environment variables
if [ -f "../Layer-1-Infrastructure/.env" ]; then
    export $(grep -v '^#' ../Layer-1-Infrastructure/.env | xargs)
fi

echo "==========================================="
echo "  Universal DB - Database Report Generator"
echo "==========================================="
echo

# Check if analytics.py exists
if [ ! -f "analytics.py" ]; then
    echo "Error: analytics.py no encontrado"
    exit 1
fi

# Menu for report selection
echo "Seleccione el tipo de reporte:"
echo
echo "1) Análisis Completo (recomendado)"
echo "2) Estadísticas Básicas"
echo "3) Patrones de Llamadas"
echo "4) Calidad de Datos"
echo "5) Exportar Resumen JSON"
echo "6) Análisis Personalizado"
echo
echo "q) Salir"
echo

read -p "Opción [1-6,q]: " choice

case $choice in
    1)
        echo "Ejecutando análisis completo..."
        python3 analytics.py full
        ;;
    2)
        echo "Generando estadísticas básicas..."
        python3 analytics.py basic
        ;;
    3)
        echo "Analizando patrones de llamadas..."
        python3 analytics.py patterns
        ;;
    4)
        echo "Generando reporte de calidad..."
        python3 analytics.py quality
        ;;
    5)
        echo "Exportando resumen a JSON..."
        python3 analytics.py export
        ;;
    6)
        echo "Modo interactivo - SQL personalizado"
        echo "Conectando a la base de datos..."
        PGPASSWORD=$PGPASSWORD psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE
        ;;
    q|Q)
        echo "Saliendo..."
        exit 0
        ;;
    *)
        echo "Opción inválida"
        exit 1
        ;;
esac

echo
echo "Reporte completado. Los archivos se guardan en este directorio."
echo "Para ver logs del sistema: journalctl -u universal-db-auto-import"
