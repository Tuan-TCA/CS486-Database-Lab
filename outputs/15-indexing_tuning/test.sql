SELECT
    t.name AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.is_unique,
    i.is_primary_key,
    i.is_unique_constraint
FROM sys.indexes AS i
JOIN sys.tables AS t
    ON i.object_id = t.object_id
WHERE t.name IN (
    'BOOKING_REQUEST',
    'BOOKING_DECISION',
    'FACILITY',
    'MAINTENANCE_RECORD',
    'SPACES'
)
ORDER BY t.name, i.index_id;
