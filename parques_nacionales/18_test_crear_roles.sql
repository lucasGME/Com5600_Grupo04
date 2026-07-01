/*
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas (5600)
Cuatrimestre: 2026 - Primer Cuatrimestre, viernes tarde

Integrantes:
Mamani Estrada, Lucas Gabriel - 43624305 
Juárez, Javier David - 43446615 
Corpu, Matías Ariel - 43744403 
Capandegui, Damian Leonel - 45807823 

Grupo: 4

Script de testing de roles y permisos.
Ejecutar cada bloque con el usuario correspondiente para verificar el comportamiento esperado.
*/

USE BD_Parques_Nacionales;
GO

---------------------------------------------------------
-- Verificación estructural (ejecutar como admin/dbo)
-- Confirma que los logins, usuarios y roles existen 
---------------------------------------------------------
-- Logins en el servidor
SELECT name AS login, type_desc FROM sys.server_principals
WHERE name IN ('login_admin', 'login_operador', 'login_consultas');

-- Usuarios en la BD
SELECT name AS usuario, type_desc FROM sys.database_principals
WHERE name IN ('usr_admin', 'usr_operador', 'usr_consultas');

-- Roles asignados a usuarios
SELECT 
    r.name AS rol,
    m.name AS usuario
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
WHERE m.name IN ('usr_admin', 'usr_operador', 'usr_consultas');

-- Permisos sobre esquemas
SELECT 
    pr.name            AS rol,
    dp.state_desc      AS permiso,
    dp.permission_name AS tipo,
    SCHEMA_NAME(dp.major_id) AS esquema
FROM sys.database_permissions dp
JOIN sys.database_principals pr ON pr.principal_id = dp.grantee_principal_id
WHERE pr.name IN ('operador', 'consultas')
  AND dp.class_desc = 'SCHEMA'
ORDER BY rol, esquema;
GO

---------------------------------------------------------
-- Testing rol CONSULTAS (usr_consultas)
-- Conectarse como: login_consultas / Cons#2026!
---------------------------------------------------------
USE BD_Parques_Nacionales;
PRINT 'Usuario activo: ' + USER_NAME();

-- PERMITIDO: SELECT sobre todos los esquemas
SELECT TOP 1 * FROM parques.provincia;
SELECT TOP 1 * FROM rrhh.guardaparques;
SELECT TOP 1 * FROM ventas.venta;
SELECT TOP 1 * FROM concesiones.contrato_concesion;

-- PERMITIDO: EXECUTE de SP de reportes
EXEC concesiones.sp_parques_concesiones_xml;

-- NO PERMITIDO: INSERT directo sobre cualquier tabla
INSERT INTO parques.provincia (nombre) VALUES ('ProvinciaTest');

-- NO PERMITIDO: EXECUTE de SP que no es de reportes
EXEC parques.sp_provincia_alta @nombre = 'ProvinciaTest';

---------------------------------------------------------
-- Testing rol OPERADOR (usr_operador)
-- Conectarse como: login_operador / Oper#2026!
---------------------------------------------------------
USE BD_Parques_Nacionales;
PRINT 'Usuario activo: ' + USER_NAME();

-- PERMITIDO: EXECUTE de SPs en todos los esquemas
EXEC parques.sp_provincia_alta @nombre = 'ProvinciaTest1';

-- NO PERMITIDO: SELECT directo sobre las tablas
SELECT * FROM parques.provincia;

-- NO PERMITIDO: INSERT directo
INSERT INTO parques.provincia (nombre) VALUES ('ProvinciaTest');


---------------------------------------------------------
-- BLOQUE 3: Testing rol ADMIN (usr_admin)
-- Conectarse como: login_admin / Admin#2026!
---------------------------------------------------------
USE BD_Parques_Nacionales;
PRINT 'Usuario activo: ' + USER_NAME();

-- PERMITIDO: SELECT sobre cualquier tabla
SELECT TOP 1 * FROM parques.provincia;

-- PERMITIDO: INSERT directo
INSERT INTO parques.provincia (nombre) VALUES ('ProvinciaTest2');

-- PERMITIDO: crear objetos 
CREATE TABLE dbo.tabla_test_admin (id INT);
DROP TABLE dbo.tabla_test_admin;
