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

Script de creación de roles y asignación de permisos.
*/

USE BD_Parques_Nacionales;
GO

---------------------------------------------------------
-- Verificación de Roles Existentes
---------------------------------------------------------
/*
SELECT name AS rol, principal_id, type_desc 
FROM sys.database_principals
WHERE type = 'R' AND is_fixed_role = 0;
GO
*/

---------------------------------------------------------
-- Creación de Roles
---------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'admin')
    CREATE ROLE admin;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'operador')
    CREATE ROLE operador;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'consultas')
    CREATE ROLE consultas;
GO

---------------------------------------------------------
-- Asignación de Permisos al Admin
---------------------------------------------------------
-- Se asigna al rol fijo db_owner para control total de la base de datos
ALTER ROLE db_owner ADD MEMBER admin;
GO

---------------------------------------------------------
-- Asignación de Permisos al Operador (Carga de Datos)
---------------------------------------------------------
-- El operador interactúa con el sistema únicamente mediante Stored Procedures
GRANT EXECUTE ON SCHEMA::parques     TO operador;
GRANT EXECUTE ON SCHEMA::rrhh        TO operador;
GRANT EXECUTE ON SCHEMA::ventas      TO operador;
GRANT EXECUTE ON SCHEMA::concesiones TO operador;
GO

---------------------------------------------------------
-- Asignación de Permisos de Consultas (Lectura/Reportes)
---------------------------------------------------------
-- El rol de consultas solo puede realizar lecturas directas sobre los esquemas y ejecutar reportes
GRANT SELECT ON SCHEMA::parques     TO consultas;
GRANT SELECT ON SCHEMA::rrhh        TO consultas;
GRANT SELECT ON SCHEMA::ventas      TO consultas;
GRANT SELECT ON SCHEMA::concesiones TO consultas;
GO

-- Agregar SPs de reportes

---------------------------------------------------------
-- Verificación de Roles y Permisos
---------------------------------------------------------
/*
SELECT name AS rol FROM sys.database_principals
WHERE type = 'R' AND is_fixed_role = 0;
GO

SELECT 
    pr.name            AS Rol,
    dp.state_desc      AS Permiso, -- GRANT / DENY
    dp.permission_name AS [Tipo Permiso],   -- SELECT, EXECUTE, etc.
    dp.class_desc      AS [Clase de Objeto],-- SCHEMA
    SCHEMA_NAME(dp.major_id) AS [Nombre Esquema]
FROM sys.database_permissions dp
JOIN sys.database_principals pr ON pr.principal_id = dp.grantee_principal_id
WHERE pr.name IN ('operador', 'consultas')
  AND dp.class_desc = 'SCHEMA'
ORDER BY Rol, [Nombre Esquema];
GO
*/