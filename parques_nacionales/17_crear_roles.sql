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

Script de creación de roles, logins, usuarios y asignación de permisos.
*/

USE BD_Parques_Nacionales;
GO

---------------------------------------------------------
-- CREACIÓN DE ROLES
---------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'admin')
    CREATE ROLE admin;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'operador')
    CREATE ROLE operador;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'consultas')
    CREATE ROLE consultas;
GO

---------------------------------------------------------
-- ASIGNACIÓN DE PERMISOS A ROLES
---------------------------------------------------------

-- Admin: control total de la base de datos
ALTER ROLE db_owner ADD MEMBER admin;
GO

-- Operador: interactúa únicamente mediante Stored Procedures
GRANT EXECUTE ON SCHEMA::parques     TO operador;
GRANT EXECUTE ON SCHEMA::rrhh        TO operador;
GRANT EXECUTE ON SCHEMA::ventas      TO operador;
GRANT EXECUTE ON SCHEMA::concesiones TO operador;
GO

-- Consultas: solo lectura + SPs de reportes 
GRANT SELECT ON SCHEMA::parques     TO consultas;
GRANT SELECT ON SCHEMA::rrhh        TO consultas;
GRANT SELECT ON SCHEMA::ventas      TO consultas;
GRANT SELECT ON SCHEMA::concesiones TO consultas;
GO

GRANT EXECUTE ON OBJECT::ventas.sp_reporte_visitas			    TO consultas;
GRANT EXECUTE ON OBJECT::ventas.sp_reporte_visitas_xml          TO consultas;
GRANT EXECUTE ON OBJECT::ventas.sp_reporte_ingresos             TO consultas;
GRANT EXECUTE ON OBJECT::ventas.sp_matriz_visitas               TO consultas;
GRANT EXECUTE ON OBJECT::concesiones.sp_reporte_deudores        TO consultas;
GRANT EXECUTE ON OBJECT::concesiones.sp_reporte_deudores_xml    TO consultas;
GRANT EXECUTE ON OBJECT::concesiones.sp_parques_concesiones_xml TO consultas;
GO

---------------------------------------------------------
-- CREACIÓN DE LOGINS (nivel servidor)
---------------------------------------------------------

USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_admin')
    CREATE LOGIN login_admin    WITH PASSWORD = 'Admin#2026!';
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_operador')
    CREATE LOGIN login_operador WITH PASSWORD = 'Oper#2026!';
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_consultas')
    CREATE LOGIN login_consultas WITH PASSWORD = 'Cons#2026!';
GO

---------------------------------------------------------
-- CREACIÓN DE USUARIOS (nivel base de datos)
---------------------------------------------------------

USE BD_Parques_Nacionales;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_admin')
    CREATE USER usr_admin    FOR LOGIN login_admin;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_operador')
    CREATE USER usr_operador FOR LOGIN login_operador;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'usr_consultas')
    CREATE USER usr_consultas FOR LOGIN login_consultas;
GO

---------------------------------------------------------
-- ASIGNACIÓN DE USUARIOS A ROLES
---------------------------------------------------------

ALTER ROLE admin     ADD MEMBER usr_admin;
ALTER ROLE operador  ADD MEMBER usr_operador;
ALTER ROLE consultas ADD MEMBER usr_consultas;
GO