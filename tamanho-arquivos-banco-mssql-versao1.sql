SELECT
    DB_NAME() AS [Base de Dados],
    Name Nome,
    physical_name [Arquivo],
    CAST(
        CAST(
            ROUND(CAST(SIZE AS DECIMAL) * 8.0 / 1024.0, 2) AS DECIMAL(18, 2)
        ) AS NVARCHAR
    ) Tamanho,
    CAST(
        CAST(
            ROUND(CAST(SIZE AS DECIMAL) * 8.0 / 1024.0, 2) AS DECIMAL(18, 2)
        ) - CAST(
            FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024.0 AS DECIMAL(18, 2)
        ) AS NVARCHAR
    ) AS [Disponível],
TYPE Tipo
FROM
    Sys.database_files