/*
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas (5600)
Cuatriestre: 2026 - Primer Cuatrimestre, viernes tarde

Integrantes:
Mamani Estrada, Lucas Gabriel – 43624305 
Juárez, Javier David – 43446615 
Corpu, Matías Ariel - 43744403 
Capandegui, Damian Leonel – 45807823 

Grupo: 4

Script de creación de procedimientos almacenados utilizando la APIs
-- actualizar cotizaciones tipo moneda
-- obtener clima
*/

USE BD_Parques_Nacionales;
GO

-- Habilitar procedimientos de automatización OLE
sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;
GO

---------------------------------------------------------------------------------------
---------- API PARA ACTUALIZAR VALORES DE TIPO MONEDA ---------------------------------
---------------------------------------------------------------------------------------

-- funete para el nombre de las monedas: https://api.frankfurter.dev/v2/currencies
-- fuente para el tipo de cambio: https://api.frankfurter.dev/v2/rates?base=ARS
-- sin API Key.

CREATE OR ALTER PROCEDURE ventas.sp_actualizar_cotizaciones_tipo_moneda
AS
BEGIN
    BEGIN TRY
        DECLARE @Object INT;
        DECLARE @jsonCambio TABLE (respuesta NVARCHAR(MAX));
        DECLARE @jsonMonedas TABLE (respuesta NVARCHAR(MAX));
        DECLARE @resultadoCambio NVARCHAR(MAX);
        DECLARE @resultadoMonedas NVARCHAR(MAX);

        DECLARE @base_currency NVARCHAR(3) = 'ARS'; -- Moneda base
        DECLARE @urlCambio NVARCHAR(255) = 'https://api.frankfurter.dev/v2/rates?base=' + @base_currency;
        DECLARE @urlMonedas NVARCHAR(255) = 'https://api.frankfurter.dev/v2/currencies';

        BEGIN TRANSACTION;
        -- Obtener los datos de la API de tipos de cambio
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT	
        EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @urlCambio, 'FALSE' 
        EXEC sp_OAMethod @Object, 'SEND' 
        INSERT INTO @jsonCambio 
            EXEC sp_OAGetProperty @Object, 'RESPONSETEXT' 

        -- Obtener los datos de la API de monedas
        EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT
        EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @urlMonedas, 'FALSE'
        EXEC sp_OAMethod @Object, 'SEND'
        INSERT INTO @jsonMonedas 
            EXEC sp_OAGetProperty @Object, 'RESPONSETEXT'


        -- cruzar las tablas con is_code y quote para obtener el nombre de la moneda y el tipo de cambio
        SET @resultadoCambio = (SELECT respuesta FROM @jsonCambio);
        SET @resultadoMonedas = (SELECT respuesta FROM @jsonMonedas);
        

        -- insertar Argentine Peso (ARS) con valor 1.0 y fecha_hora_valor actual
        IF NOT EXISTS (SELECT 1 FROM ventas.tipo_moneda WHERE descripcion = 'Argentine Peso')
        BEGIN
            INSERT INTO ventas.tipo_moneda (descripcion, valor, fecha_hora_valor)
            VALUES ('Argentine Peso', 1.0, SYSDATETIME());
        END;
        ELSE 
        BEGIN
            UPDATE ventas.tipo_moneda
            SET fecha_hora_valor = SYSDATETIME()
            WHERE descripcion = 'Argentine Peso';
        END;

        WITH cte AS (
            SELECT 
                    m.[name] AS descripcion,
                    ISNULL(1.0 / NULLIF(c.[rate], 0), 0) AS valor
                    , ROW_NUMBER() OVER (PARTITION BY m.[name] ORDER BY c.[rate] DESC) AS rn
                FROM OPENJSON(@resultadoCambio)
                WITH
                (
                    [quote] NVARCHAR(3),
                    [rate] FLOAT 
                ) AS c
                INNER JOIN OPENJSON(@resultadoMonedas)
                WITH
                (
                    [iso_code] NVARCHAR(3),
                    [name] NVARCHAR(100)
                ) AS m ON c.[quote] = m.[iso_code]
                WHERE ISNULL(1.0 / NULLIF(c.[rate], 0), 0) > 0
        ),
        source AS (
            SELECT descripcion, valor
            FROM cte
            WHERE rn = 1
        )
        MERGE ventas.tipo_moneda AS target
        USING source
        ON target.descripcion = source.descripcion
        WHEN MATCHED THEN -- cuando la moneda ya existe, actualizamos el valor y la fecha_hora_valor
            UPDATE SET target.valor = source.valor, target.fecha_hora_valor = SYSDATETIME()
        WHEN NOT MATCHED BY TARGET THEN -- cuando la moneda no existe, la insertamos
            INSERT (descripcion, valor, fecha_hora_valor)
            VALUES (source.descripcion, source.valor, SYSDATETIME())
        WHEN NOT MATCHED BY SOURCE
            AND target.descripcion <> 'Argentine Peso' -- cuando la moneda ya no existe en la API, la eliminamos, excepto el peso argentino
        THEN DELETE;
        
        -- liberar objeto
        EXEC sp_OADestroy @Object;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


---------------------------------------------------------------------------------------
---------- API PARA OBTENER CLIMA -----------------------------------------------------
---------------------------------------------------------------------------------------

-- fuente: https://api.open-meteo.com/v1/forecast?latitude={latitud}&longitude={longitud}&daily=weather_code&timezone=auto&start_date={fecha}&end_date={fecha}
-- sin API Key.

CREATE OR ALTER PROCEDURE ventas.sp_obtener_clima
    @p_latitud DECIMAL(9,6),
	@p_longitud DECIMAL(9,6),
    @p_fecha_acceso DATE,
    @p_id_clima INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @ERRORES VARCHAR(1000) = '';	
        
        DECLARE @v_codigo_wmo INT;
        DECLARE @Object INT;
        DECLARE @jsonClima TABLE (respuesta NVARCHAR(MAX));
        DECLARE @resultadoClima NVARCHAR(MAX);
        
        DECLARE @urlClima NVARCHAR(1000);
        DECLARE @fecha_max DATE = DATEADD(DAY, 15, CAST(GETDATE() AS DATE));


        -- validar fecha de acceso
        -- IF @p_fecha_acceso <= GETDATE() OR @p_fecha_acceso > @fecha_max
        -- BEGIN
		-- 	SET @ERRORES += 'La fecha de acceso debe ser mayor o igual a la fecha actual y menor o igual a 15 días después de la fecha actual.' + CHAR(13) + CHAR(10);
		-- END;
        
        -- validar latitud
        IF @p_latitud < -90 OR @p_latitud > 90
        BEGIN
            SET @ERRORES += 'La latitud debe estar entre -90 y 90.' + CHAR(13) + CHAR(10);
        END;

        -- validar longitud
        IF @p_longitud < -180 OR @p_longitud > 180
        BEGIN
            SET @ERRORES += 'La longitud debe estar entre -180 y 180.' + CHAR(13) + CHAR(10);
        END;
        
        IF @ERRORES <> ''
        BEGIN
            RAISERROR(@ERRORES, 16, 1);
            RETURN;
        END;
        
        BEGIN TRANSACTION;
        
        SET @urlClima = 'https://api.open-meteo.com/v1/forecast?latitude=' + CAST(@p_latitud AS NVARCHAR(10)) + '&longitude=' + CAST(@p_longitud AS NVARCHAR(10)) + '&daily=weather_code&timezone=auto&start_date=' + CAST(@p_fecha_acceso AS NVARCHAR(10)) + '&end_date=' + CAST(@p_fecha_acceso AS NVARCHAR(10));
        -- Obtener los datos de la API de clima
        EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @Object OUT
        EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @urlClima, 'FALSE'
        EXEC sp_OAMethod @Object, 'SEND'
        INSERT INTO @jsonClima
            EXEC sp_OAGetProperty @Object, 'RESPONSETEXT'

        SELECT @resultadoClima = respuesta FROM @jsonClima;

        -- obtener el id_clima correspondiente al codigo_clima obtenido de la API
        SET @v_codigo_wmo = (SELECT value FROM OPENJSON(@resultadoClima, '$.daily.weather_code'));

        -- obtener id_clima correspondiente al codigo_wmo obtenido de la API
        SELECT @p_id_clima = id_clima
        FROM ventas.clima
        WHERE codigo_wmo = @v_codigo_wmo;

        -- liberar objeto
        EXEC sp_OADestroy @Object;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


---------------------------------------------------------------------------------------
---------- OBTENER LATITUD Y LONGITUD DE PARQUE ---------------------------------------
---------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_obtener_latitud_longitud_parque
    @p_id_parque INT,
    @p_latitud DECIMAL(9,6) OUTPUT,
    @p_longitud DECIMAL(9,6) OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @ERRORES VARCHAR(1000) = '';	

        -- validar id_parque
        IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @p_id_parque)
        BEGIN
            SET @ERRORES += 'El id_parque no existe.' + CHAR(13) + CHAR(10);
        END;

        IF @ERRORES <> ''
        BEGIN
            RAISERROR(@ERRORES, 16, 1);
            RETURN;
        END;

        SELECT 
            @p_latitud = latitud,
            @p_longitud = longitud
        FROM parques.parque
        WHERE id_parque = @p_id_parque;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;


---------------------------------------------------------------------------------------
---------- INSERSIONES DE LOS TIPO DE CLIMA  ------------------------------------------
---------------------------------------------------------------------------------------

/*
La insersión de los tipos de clima con su respectivo código WMO se realiza de manera manual,
ya que la API no proporciona una lista completa de los tipos de clima y sus códigos.
Cuando se utiliza la API para obtener el clima, se obtiene un código WMO que corresponde a un tipo de clima específico.

los codigo MWMO se presentan en la documentación de la API:
https://open-meteo.com/en/docs#weathervariables
*/

INSERT INTO ventas.clima (codigo_wmo, descripcion)
VALUES
(0, 'Cielo despejado'),

(1, 'Mayormente despejado'),
(2, 'Parcialmente nublado'),
(3, 'Nublado'),

(45, 'Niebla'),
(48, 'Niebla con escarcha'),

(51, 'Llovizna ligera'),
(53, 'Llovizna moderada'),
(55, 'Llovizna intensa'),

(56, 'Llovizna helada ligera'),
(57, 'Llovizna helada intensa'),

(61, 'Lluvia ligera'),
(63, 'Lluvia moderada'),
(65, 'Lluvia intensa'),

(66, 'Lluvia helada ligera'),
(67, 'Lluvia helada intensa'),

(71, 'Nevada ligera'),
(73, 'Nevada moderada'),
(75, 'Nevada intensa'),

(77, 'Granos de nieve'),

(80, 'Chubascos de lluvia ligeros'),
(81, 'Chubascos de lluvia moderados'),
(82, 'Chubascos de lluvia violentos'),

(85, 'Chubascos de nieve ligeros'),
(86, 'Chubascos de nieve intensos'),

(95, 'Tormenta eléctrica'),

(96, 'Tormenta con granizo ligero'),
(99, 'Tormenta con granizo intenso');
