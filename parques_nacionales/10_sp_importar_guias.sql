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

Script de importacion de datos de guias tursisticos, entidades relacionadas 
*/

USE BD_Parques_Nacionales
GO

CREATE OR ALTER PROCEDURE rrhh.importar_guias @ruta NVARCHAR(300)
AS 
BEGIN

PRINT 'Importar datos de guias'


SET NOCOUNT ON

DECLARE @json NVARCHAR(MAX)

DECLARE @sql NVARCHAR(MAX) = 
N'SELECT @json1 = BulkColumn FROM 
    OPENROWSET(BULK ''' + @ruta + ''', SINGLE_CLOB) as JsonFile
'
EXEC sp_executesql @sql, N'@json1 NVARCHAR(MAX) OUTPUT',@json1 = @json OUTPUT

-- =Generar Titulo=

    INSERT INTO rrhh.titulo(descripcion) 
            SELECT DISTINCT title FROM OpenJson(@json)
            WITH (
                [legacy] VARCHAR(20),
                [name] VARCHAR(150),
                [date of birth] DATE,
                [phone] VARCHAR(20),
                [email] VARCHAR(254),
                [title] VARCHAR(100),
                [specialty] VARCHAR(100)
            ) WHERE title NOT IN (SELECT descripcion FROM rrhh.titulo)

-- Generar Especialidad
    INSERT INTO rrhh.especialidad(descripcion) 
        SELECT DISTINCT specialty FROM OpenJson(@json)
        WITH (
            [legacy] VARCHAR(20),
            [name] VARCHAR(150),
            [date of birth] DATE,
            [phone] VARCHAR(20),
            [email] VARCHAR(254),
            [title] VARCHAR(100),
            [specialty] VARCHAR(100)
        ) WHERE specialty NOT IN (SELECT descripcion FROM rrhh.especialidad)

-- Generar Estado de Guia

    INSERT INTO rrhh.estado_guia(descripcion)
        SELECT E.descripcion FROM ( 
            VALUES ('Activo'),('Inactivo'),('Suspendido'), ('Retirado')) 
            AS E (descripcion)
        WHERE NOT EXISTS (SELECT 1 FROM rrhh.estado_guia EG WHERE EG.descripcion = E.descripcion)

-- Generar Guia

    DECLARE @upd_values TABLE (
        legajo VARCHAR(20)
    )

    INSERT INTO @upd_values(legajo)
        SELECT legacy FROM OpenJson(@json)
        WITH (
            [legacy] VARCHAR(20),
            [name] VARCHAR(150),
            [date of birth] DATE,
            [phone] VARCHAR(20),
            [email] VARCHAR(254),
            [title] VARCHAR(100),
            [specialty] VARCHAR(100)
        ) WHERE legacy IN (SELECT legajo FROM rrhh.guia);

        --=Insertar Nuevos=
        
            WITH guias (legajo, nombre, nacimiento, tel, email, titulo, especialidad, estado) 
            AS (
                SELECT J.legacy, J.name, J.[date of birth], J.phone, J.email, T.id_titulo, E.id_especialidad, ES.id_estado_guia
                FROM OpenJson(@json)
                WITH (
                    [legacy] VARCHAR(20),
                    [name] VARCHAR(150),
                    [date of birth] DATE,
                    [phone] VARCHAR(20),
                    [email] VARCHAR(254),
                    [title] VARCHAR(100),
                    [specialty] VARCHAR(100)
                ) AS J 
                INNER JOIN rrhh.titulo T ON T.descripcion = J.title
                INNER JOIN rrhh.especialidad E ON E.descripcion = J.specialty
                CROSS JOIN rrhh.estado_guia ES
                WHERE legacy NOT IN (SELECT legajo FROM @upd_values))

            INSERT INTO rrhh.guia(legajo, apellido_y_nombre, fecha_nacimiento, email, telefono, id_titulo, id_especialidad, id_estado_guia)
            SELECT legajo, nombre, nacimiento, email, tel, titulo, especialidad, estado 
                FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY legajo ORDER BY NEWID()) AS rand_order FROM guias)
                AS R WHERE R.rand_order = 1;

        --=Actualizar Viejos=

            WITH guias (legajo, nombre, nacimiento, tel, email, titulo, especialidad, estado) 
            AS (
                SELECT J.legacy, J.name, J.[date of birth], J.phone, J.email, T.id_titulo, E.id_especialidad, ES.id_estado_guia
                FROM OpenJson(@json)
                WITH (
                    [legacy] VARCHAR(20),
                    [name] VARCHAR(150),
                    [date of birth] DATE,
                    [phone] VARCHAR(20),
                    [email] VARCHAR(254),
                    [title] VARCHAR(100),
                    [specialty] VARCHAR(100)
                ) AS J 
                INNER JOIN rrhh.titulo T ON T.descripcion = J.title
                INNER JOIN rrhh.especialidad E ON E.descripcion = J.specialty
                CROSS JOIN rrhh.estado_guia ES
                WHERE legacy IN (SELECT legajo FROM @upd_values))
            
            UPDATE rrhh.guia SET
                apellido_y_nombre = S.nombre, 
                fecha_nacimiento = S.nacimiento, 
                email = S.email, 
                telefono = S.tel, 
                id_titulo = S.titulo, 
                id_especialidad = S.especialidad, 
                id_estado_guia = S.estado
            FROM (
            SELECT legajo, nombre, nacimiento, email, tel, titulo, especialidad, estado 
                FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY legajo ORDER BY NEWID()) AS rand_order FROM guias)
                AS R WHERE R.rand_order = 1)
                AS S WHERE rrhh.guia.legajo = S.legajo

END
GO