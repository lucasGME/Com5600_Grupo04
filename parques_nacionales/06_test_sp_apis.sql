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

Script de testing de procedimientos almacenados utilizando la APIs
-- testing actualizar cotizaciones tipo moneda
-- testing obtener clima
*/

USE BD_Parques_Nacionales;
GO


---------------------------------------------------------------------------------------
---------- TESTING ACTUALIZACIÓN DE VALORES DE TIPO MONEDA ----------------------------
---------------------------------------------------------------------------------------

SELECT * FROM ventas.tipo_moneda;

EXEC ventas.sp_actualizar_cotizaciones_tipo_moneda;

SELECT * FROM ventas.tipo_moneda;


---------------------------------------------------------------------------------------
---------- TESTING OBTENCIÓN DE ESTADOS DE CLIMA --------------------------------------
---------------------------------------------------------------------------------------

DECLARE @id_clima INT;
EXEC ventas.sp_obtener_clima 
    @p_latitud = 10.66536, 
    @p_longitud = 20.727444, 
    @p_fecha_acceso = '2026-06-26', 
    @p_id_clima = @id_clima OUTPUT;

SELECT *
FROM ventas.clima
WHERE id_clima = @id_clima;

-- el id_clima obtenido es lo que luego se utilizará en la venta de entrada


---------------------------------------------------------------------------------------
---------- TESTING OBTENCIÓN DE LATITUD Y LONGITUD DE PARQUE --------------------------
---------------------------------------------------------------------------------------

DECLARE @latitud DECIMAL(9,6);
DECLARE @longitud DECIMAL(9,6);

EXEC parques.sp_obtener_latitud_longitud_parque 
    @p_id_parque = 1, 
    @p_latitud = @latitud OUTPUT, 
    @p_longitud = @longitud OUTPUT;

PRINT 'Latitud: ' + CAST(@latitud AS VARCHAR(20)) + ', Longitud: ' + CAST(@longitud AS VARCHAR(20));
