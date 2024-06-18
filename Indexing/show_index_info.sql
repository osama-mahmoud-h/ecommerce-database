SELECT
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    tablename = 'users'
    AND schemaname = 'public';
