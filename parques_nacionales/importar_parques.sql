/*
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas (5600)
Cuatrimestre: 2026 - Primer Cuatrimestre, viernes tarde

Integrantes:
Mamani Estrada, Lucas Gabriel – 43624305 
Juárez, Javier David – 43446615 
Corpu, Matías Ariel - 43744403 
Capandegui, Damian Leonel – 45807823 

Grupo: 4

Script de importacion de datos de parques nacionales, tipo de paruqe, provincias, localidades
*/


USE BD_Parques_Nacionales
GO


CREATE OR ALTER PROCEDURE parques.importar_parques @ruta NVARCHAR(300)
AS 
BEGIN

    PRINT 'Importar datos de guardaparques'

    SET NOCOUNT ON

    CREATE TABLE #Parques (
        provincia VARCHAR(100), 
        area_protegida VARCHAR(100),
        ano_de_creacion INT,
        region VARCHAR(100),
        superficie DECIMAL(8,1),
        latitud DECIMAL(9,6),
        longitud DECIMAL(9,6),
        instrumento_de_creacion VARCHAR(200),
        ecoregiones VARCHAR(200),
        cat_internacional VARCHAR(100),
        especies INT,
        animales INT,
        bacterias INT,
        hongos INT,
        plantas INT,
    )

    DECLARE @bulk_insert NVARCHAR(MAX) = 

    'BULK INSERT #Parques
    FROM ''' + @ruta + '''
    WITH
    (
        FORMAT = ''CSV'',
        FIELDTERMINATOR = '','',
        ROWTERMINATOR = ''\n'',
        FIRSTROW = 3
    )'

    EXEC(@bulk_insert)

    -- =Generar Provincias=

        INSERT INTO parques.provincia(nombre) 
            SELECT DISTINCT provincia FROM #Parques 
                WHERE provincia IS NOT NULL AND provincia NOT IN (
                    SELECT nombre FROM parques.provincia
                )

    -- =Generar Localidades=
        -- Nuestro dataset no tiene localidades, asi que crearemos algunas

        DECLARE @cant_prov INT = (SELECT COUNT(1) FROM parques.provincia)
        DECLARE @cant_loc INT = 5
        DECLARE @nombre_loc VARCHAR (100)

    
        WHILE @cant_prov > 0
        BEGIN
            SET @cant_loc = 5
            WHILE @cant_loc > 0
            BEGIN
            
            SELECT @nombre_loc = CONCAT(nombre,' Localidad ', @cant_loc) FROM parques.provincia WHERE id_provincia = @cant_prov

            INSERT INTO parques.localidad (nombre,id_provincia) 
                SELECT @nombre_loc, @cant_prov WHERE @nombre_loc NOT IN (
                    SELECT nombre FROM parques.localidad)
                
            SET @cant_loc = @cant_loc - 1 
            END
        
        SET @cant_prov = @cant_prov - 1 
        END

    -- =Generar Tipos Parque=

        INSERT INTO parques.tipo_parque(descripcion) 
            SELECT DISTINCT cat_internacional FROM #Parques 
                WHERE cat_internacional IS NOT NULL AND cat_internacional NOT IN (
                    SELECT descripcion FROM parques.tipo_parque
                );

    -- =Generar Parques=

        -- En cada caso, asignaremos las localidades de forma random a los parques segun su provincia

        -- Encontrar datos ya ingresados

        DECLARE @upd_values TABLE (
            nombre VARCHAR(100)
        )

        INSERT INTO @upd_values(nombre) 
            SELECT area_protegida FROM #Parques WHERE area_protegida IN (SELECT nombre FROM parques.parque);


        --Insertar Nuevos
            WITH parques (nombre, direccion, latitud, longitud, superficie, provincia, tipo_parque, id_provincia, id_localidad, localidad) 
            AS (
                SELECT p.area_protegida, 'Direccion', p.latitud, p.longitud, p.superficie * 0.01, p.provincia, t.id_tipo_parque, pr.id_provincia, l.id_localidad, l.nombre  
                FROM #Parques p 
                INNER JOIN parques.provincia pr ON  p.provincia = pr.nombre 
                    INNER JOIN parques.tipo_parque t ON p.cat_internacional = t.descripcion
                    RIGHT JOIN parques.localidad l ON l.id_provincia = pr.id_provincia 
                    WHERE p.area_protegida NOT IN (SELECT nombre FROM @upd_values))
                
                INSERT INTO parques.parque (nombre, direccion,latitud,longitud,superficie_km2,id_tipo_parque,id_localidad) 
                SELECT nombre, direccion, latitud, longitud, superficie, tipo_parque, id_localidad FROM (
                    SELECT nombre, direccion, latitud, longitud, superficie, tipo_parque, provincia, id_localidad, 
                    ROW_NUMBER() OVER (PARTITION BY nombre, provincia ORDER BY NEWID()) as rand_order FROM parques)
                    AS R WHERE R.rand_order = 1;
            
        -- Actualizar Viejos

            WITH parques (nombre, direccion, latitud, longitud, superficie, provincia, tipo_parque, id_provincia, id_localidad, localidad) 
            AS (
                SELECT p.area_protegida, 'Direccion', p.latitud, p.longitud, p.superficie * 0.01, p.provincia, t.id_tipo_parque, pr.id_provincia, l.id_localidad, l.nombre  
                FROM #Parques p 
                INNER JOIN parques.provincia pr ON  p.provincia = pr.nombre 
                INNER JOIN parques.tipo_parque t ON p.cat_internacional = t.descripcion
                RIGHT JOIN parques.localidad l ON l.id_provincia = pr.id_provincia 
                WHERE p.area_protegida IN (SELECT nombre FROM @upd_values))

            UPDATE parques.parque SET
                latitud = N.latitud,
                longitud = N.longitud,
                superficie_km2 = N.superficie,
                id_tipo_parque = N.tipo_parque,
                id_localidad = N.id_localidad

            FROM (
            SELECT nombre, direccion, latitud, longitud, superficie, tipo_parque, id_localidad 
            FROM (SELECT nombre, direccion, latitud, longitud, superficie, tipo_parque, provincia, id_localidad, 
                ROW_NUMBER() OVER (PARTITION BY nombre, provincia ORDER BY NEWID()) as rand_order FROM parques)
                AS R WHERE R.rand_order = 1) 
                AS N WHERE parques.parque.nombre = N.nombre

    DROP TABLE #Parques
END
GO