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

Script de ejecucion de los stored procedure de importacion
*/

-- Ruta Madre '/home/tempy/'

USE BD_Parques_Nacionales
GO

-- Ejecutar Importes de Parque
    -- Archivo original es de formato xslx. Para poder importar correctamente se debe convertir a csv
    EXEC parques.importar_parques @ruta = '/home/tempy/Áreas protegidas de Argentina - Sistema de Información de Biodiversidad.csv'
    GO

--Ejecutar Importes de Actividad Turistica
    --EXEC parques.importar_actividades_turisticas @ruta = ''
    GO

-- Ejecutar Importes de Guias
    EXEC rrhh.importar_guias @ruta = '/home/tempy/Guias Testy.json'
    GO

-- Ejecutar Importes de Guardaparques
    EXEC rrhh.importar_guardaparques @ruta = '/home/tempy/Guardaparques Testy.json'
    GO

-- Ejecutar Importes de Concseciones
    --EXEC concesiones.importar_conseciones @ruta = ''
    GO

-- Visualizar Tablas Importadas

    SELECT * FROM parques.provincia
    SELECT * FROM parques.localidad
    SELECT * FROM parques.tipo_parque
    SELECT * FROM parques.parque

    SELECT * FROM rrhh.titulo
    SELECT * FROM rrhh.especialidad
    SELECT * FROM rrhh.estado_guia
    SELECT * FROM rrhh.guia

    SELECT * FROM rrhh.guardaparques
    GO