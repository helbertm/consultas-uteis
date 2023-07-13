SELECT
  DB_NAME() AS [Base de Dados], 
	name AS [Nome],
	physical_name AS [Arquivo],
	CAST(
		CAST(SIZE * 8.0 / 1024.0 AS DECIMAL(18, 2)) AS NVARCHAR
	) AS [Tamanho (MB)],
	CAST(
		CAST(SIZE * 8.0 / 1024.0 AS DECIMAL(18, 2)) - CAST(
			FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024.0 AS DECIMAL(18, 2)
		) AS NVARCHAR
	) AS [Utilizado (MB)],
	CAST(
		CAST(
			FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024.0 AS DECIMAL(18, 2)
		) AS NVARCHAR
	) AS [Disponível (MB)],
	type_desc AS [Tipo]
FROM
	sys.database_files
ORDER BY
	SIZE DESC