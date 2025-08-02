-- Índices optimizados para Grafana dashboards
-- Universal DB - Performance optimization for analytics

-- Índice para consultas de caller_number (Top callers)
CREATE INDEX IF NOT EXISTS idx_call_records_caller_number 
    ON call_records (caller_number) 
    WHERE caller_number IS NOT NULL AND caller_number != '';

-- Índice para consultas de called_number (Top called)
CREATE INDEX IF NOT EXISTS idx_call_records_called_number 
    ON call_records (called_number) 
    WHERE called_number IS NOT NULL AND called_number != '';

-- Índice para call_status (Status distribution)
CREATE INDEX IF NOT EXISTS idx_call_records_call_status 
    ON call_records (call_status);

-- Índice para call_type (Type analysis)
CREATE INDEX IF NOT EXISTS idx_call_records_call_type 
    ON call_records (call_type);

-- Índice para created_at (Time series queries)
CREATE INDEX IF NOT EXISTS idx_call_records_created_at 
    ON call_records (created_at) 
    WHERE created_at IS NOT NULL;

-- Índice compuesto para análisis de duración
CREATE INDEX IF NOT EXISTS idx_call_records_duration_numeric 
    ON call_records (call_duration) 
    WHERE call_duration ~ '^[0-9]+([.,][0-9]+)?$';

-- Índice para búsquedas de timestamp (si existe fecha en los datos)
-- Si tienes un campo de fecha/hora específico, descomenta y ajusta:
-- CREATE INDEX IF NOT EXISTS idx_call_records_timestamp_btree 
--     ON call_records USING btree (your_timestamp_field);

-- Actualizar estadísticas para el optimizador de consultas
ANALYZE call_records;

-- Mostrar información de los índices creados
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'call_records'
ORDER BY indexname;
