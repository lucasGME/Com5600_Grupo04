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

Script de importacion de datos de guardaparques y asignaciones
*/

USE BD_Parques_Nacionales
GO

CREATE OR ALTER PROCEDURE rrhh.importar_guardaparques @ruta NVARCHAR(300)
AS 
BEGIN

PRINT 'Importar datos de guardaparques'

SET NOCOUNT ON

DECLARE @json NVARCHAR(MAX)

DECLARE @sql NVARCHAR(MAX) = 
N'SELECT @json1 = BulkColumn FROM 
    OPENROWSET(BULK ''' + @ruta + ''', SINGLE_CLOB) as JsonFile
'

EXEC sp_executesql @sql, N'@json1 NVARCHAR(MAX) OUTPUT',@json1 = @json OUTPUT

--=Generar Guardaparques=

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
            [email] VARCHAR(254)
        ) WHERE legacy IN (SELECT legajo FROM rrhh.guardaparques)

    --=Insertar Nuevos=

        INSERT INTO rrhh.guardaparques (legajo,apellido_y_nombre,fecha_nacimiento,telefono,email)
        SELECT * FROM OpenJson(@json)
        WITH (
            [legacy] VARCHAR(20),
            [name] VARCHAR(150),
            [date of birth] DATE,
            [phone] VARCHAR(20),
            [email] VARCHAR(254)
        ) WHERE legacy NOT IN (SELECT legajo FROM @upd_values)

    --=Actualizar Viejos=

        UPDATE rrhh.guardaparques SET 
            apellido_y_nombre = J.name,
            fecha_nacimiento = J.[date of birth],
            telefono = J.phone,
            email = J.email
        FROM OpenJson(@json)
        WITH (
            [legacy] VARCHAR(20),
            [name] VARCHAR(150),
            [date of birth] DATE,
            [phone] VARCHAR(20),
            [email] VARCHAR(254)
        ) AS J WHERE rrhh.guardaparques.legajo = J.legacy AND legacy IN (SELECT legajo FROM @upd_values)

END
GO