/*
Objetivo: Este script SQL lista todos os bancos de dados em uma instância MSSQL,
recuperando a data de criação, o tamanho em GB e a versão da tabela CFGGERAL para cada um.
Tentamos recuperar CFGGERAL.VERSAO de cada base com diferentes owners ('engeman', 'dbo', nome do banco de dados, etc.).
Autor: Helbert Miranda
Data: Dez/2023

-- Versões
Autor:
Data:
Alteração:
 */
CREATE TABLE
	#DatabaseVersions (DatabaseName NVARCHAR(128), Version NVARCHAR(128));

CREATE TABLE
	#TempVersion (VERSAO NVARCHAR(128));

DECLARE @DatabaseName NVARCHAR(128),
@Query NVARCHAR(MAX),
@Version NVARCHAR(128);

DECLARE db_cursor CURSOR FOR
SELECT
	name
FROM
	sys.databases
WHERE
	name NOT IN ('master', 'tempdb', 'model', 'msdb');

OPEN db_cursor
FETCH NEXT
FROM
	db_cursor INTO @DatabaseName WHILE @@FETCH_STATUS = 0 BEGIN
SET
	@Version = NULL;

DELETE FROM #TempVersion;

--Geralmente as bases restauradas têm um destes owners: engeman, dbo, o próprio nome da base ou este último com _HML. Cada um será testado para recuperar a versão.
--Owner: engeman
SET
	@Query = 'INSERT INTO #TempVersion SELECT VERSAO FROM [' + @DatabaseName + '].[engeman].CFGGERAL';

BEGIN TRY EXEC sp_executesql @Query;

SELECT
	@Version = VERSAO
FROM
	#TempVersion;

END TRY BEGIN CATCH
-- Ignorar erros e continuar
END CATCH
--Owner: dbo
SET
	@Query = 'INSERT INTO #TempVersion SELECT VERSAO FROM [' + @DatabaseName + '].[dbo].CFGGERAL';

BEGIN TRY EXEC sp_executesql @Query;

SELECT
	@Version = VERSAO
FROM
	#TempVersion;

END TRY BEGIN CATCH
-- Ignorar erros e continuar
END CATCH
--Owner: nome do banco
SET
	@Query = 'INSERT INTO #TempVersion SELECT VERSAO FROM [' + @DatabaseName + '].[' + @DatabaseName + '].CFGGERAL';

BEGIN TRY EXEC sp_executesql @Query;

SELECT
	@Version = VERSAO
FROM
	#TempVersion;

END TRY BEGIN CATCH
-- Ignorar erros e continuar
END CATCH
--Owner: nome do banco_HML
SET
	@Query = 'INSERT INTO #TempVersion SELECT VERSAO FROM [' + @DatabaseName + '].[' + @DatabaseName + '_hml].CFGGERAL';

BEGIN TRY EXEC sp_executesql @Query;

SELECT
	@Version = VERSAO
FROM
	#TempVersion;

END TRY BEGIN CATCH
-- Ignorar erros e continuar
END CATCH
INSERT INTO
	#DatabaseVersions (DatabaseName, Version)
VALUES
	(@DatabaseName, @Version);

FETCH NEXT
FROM
	db_cursor INTO @DatabaseName END CLOSE db_cursor;

DEALLOCATE db_cursor;

SELECT
	db.name AS Base,
	FORMAT(db.create_date, 'dd/MM/yy HH:mm') AS Data_Restore,
	CAST(
		SUM(mf.size) * 8 / 1024.0 / 1024.0 AS DECIMAL(10, 2)
	) AS "Tamanho-GB",
	dv.Version "Versão"
FROM
	sys.databases db
	INNER JOIN sys.master_files mf ON db.database_id = mf.database_id
	LEFT JOIN #DatabaseVersions dv ON db.name = dv.DatabaseName
WHERE
	db.name NOT IN ('master', 'tempdb', 'model', 'msdb')
GROUP BY
	db.name,
	db.create_date,
	dv.Version
ORDER BY
	1;

DROP TABLE #DatabaseVersions;

DROP TABLE #TempVersion;