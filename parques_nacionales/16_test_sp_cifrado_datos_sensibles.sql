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

Script de testing de cifrado de datos sensibles
*/

USE BD_Parques_Nacionales;
GO

-- 1) Mostrar datos sin cifrar
SELECT TOP 5 * FROM rrhh.guardaparques;
SELECT TOP 5 * FROM rrhh.guia;
GO
-- 2) Ejecutar scrip de cifrado

-- 3) Mostrar datos cifrados
SELECT TOP 5 * FROM rrhh.guardaparques;
SELECT TOP 5 * FROM rrhh.guia;
GO
-- 4) Ejecutar SPs para descifrar
EXEC seguridad.sp_descifrar_guardaparques N'ClaveSecreta123$';
EXEC seguridad.sp_descifrar_guias N'ClaveSecreta123$';
GO
