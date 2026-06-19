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

Script de testing para procedimientos almacenados relacionados a concesiones de parques nacionales
*/

USE BD_Parques_Nacionales;
GO


-----------------------------------------------------
------------ INSERCIONES PARA EL TESTING ------------
-----------------------------------------------------

-- los id comienzan en uno por ser tablas vacias, y se insertan en orden de dependencia

-- PROVINCIAS, LOCALIDADES, TIPO DE PARQUE, PARQUE
INSERT INTO parques.provincia (nombre)
VALUES ('Buenos Aires');

INSERT INTO parques.localidad (nombre, id_provincia)
VALUES ('La Plata', 1);

INSERT INTO parques.tipo_parque (descripcion)
VALUES ('Parque Nacional');

INSERT INTO parques.parque (nombre, direccion, latitud, longitud, superficie_km2, id_localidad, id_tipo_parque)
VALUES ('Parque 1', 'Calle Falsa 123', -34.9214, -57.9544, 1500.00, 1, 1);

-- TIPOS DE ACTIVIDAD CONCESION, EMPRESA
INSERT INTO concesiones.tipo_actividad_concesion (descripcion)
VALUES ('Restaurante');

INSERT INTO concesiones.empresa (nombre, direccion, telefono, email)
VALUES ('Empresa 1', 'Avenida Siempre Viva 456', '1234567890', 'empresa1@example.com');

-- ESTADOS CANON
INSERT INTO concesiones.estado_canon (descripcion)
VALUES 
        ('Pendiente'), 
        ('Pagado'), 
        ('Vencido'), 
        ('Anulado');

--------------------------------------------------------------
------------ TESTING REGISTRAR CONTRATO CONCESIÓN ------------
--------------------------------------------------------------

--------------------
-- INTENTO VALIDO --
--------------------

-- creación del contrato concesión y generación de los canones asociados al contrato concesión

SELECT * FROM concesiones.contrato_concesion
WHERE id_empresa = 1

EXEC concesiones.sp_registrar_contrato_concesion
    @p_id_parque = 1,
    @p_id_tipo_actividad_concesion = 1,
    @p_id_empresa = 1,
    @p_monto_mensual = 1000.00,
    @p_fecha_inicio = '2027-01-01',
    @p_fecha_fin = '2027-12-31',
    @p_id_contrato_concesion = NULL

-- contrato    
SELECT * 
FROM concesiones.contrato_concesion
WHERE id_empresa = 1 

-- canones generados
SELECT e.id_empresa, cc.id_contrato_concesion, c.id_canon, c.fecha_vencimiento, c.importe, ec.descripcion AS estado_canon
FROM concesiones.canon c 
JOIN concesiones.estado_canon ec ON c.id_estado_canon = ec.id_estado_canon
JOIN concesiones.contrato_concesion cc ON c.id_contrato_concesion = cc.id_contrato_concesion
JOIN concesiones.empresa e ON cc.id_empresa = e.id_empresa
WHERE cc.id_contrato_concesion = 1

-------------------------
--- INTENTO NO VALIDO ---
-------------------------

-- todos los errores juntos:

-- parque no existe
-- tipo actividad concesion no existe
-- empresa no existe
-- monto mensual negativo
-- fecha inicio anterior a fecha de hoy
-- fecha fin anterior a fecha inicio
EXEC concesiones.sp_registrar_contrato_concesion
    @p_id_parque = 999,
    @p_id_tipo_actividad_concesion = 999,
    @p_id_empresa = 999,
    @p_monto_mensual = -1000.00,
    @p_fecha_inicio = '2020-01-01',
    @p_fecha_fin = '2019-01-01',
    @p_id_contrato_concesion = NULL



------------------------------------------------------
------------ TESTING REGISTRAR PAGO CANON ------------
------------------------------------------------------

--------------------
-- INTENTO VALIDO --
--------------------

-- actualizar estado del primer canon de "Pendiente" a "Pagado" y registrar el pago del canon

-- canones estado antes del pago
SELECT e.id_empresa, cc.id_contrato_concesion, c.id_canon, c.fecha_vencimiento, c.importe, ec.descripcion AS estado_canon
FROM concesiones.canon c 
JOIN concesiones.estado_canon ec ON c.id_estado_canon = ec.id_estado_canon
JOIN concesiones.contrato_concesion cc ON c.id_contrato_concesion = cc.id_contrato_concesion
JOIN concesiones.empresa e ON cc.id_empresa = e.id_empresa
WHERE cc.id_contrato_concesion = 1

EXEC concesiones.sp_registrar_pago_canon
    @p_id_contrato_concesion = 1,
    @p_id_canon = 1,
    @p_monto_pagar = 1000.00

-- canones estado después del pago
SELECT e.id_empresa, cc.id_contrato_concesion, c.id_canon, c.fecha_vencimiento, c.importe, ec.descripcion AS estado_canon
FROM concesiones.canon c 
JOIN concesiones.estado_canon ec ON c.id_estado_canon = ec.id_estado_canon
JOIN concesiones.contrato_concesion cc ON c.id_contrato_concesion = cc.id_contrato_concesion
JOIN concesiones.empresa e ON cc.id_empresa = e.id_empresa
WHERE cc.id_contrato_concesion = 1

-- pago registrado
SELECT *
FROM concesiones.pago_canon 
WHERE id_canon = 1


-------------------------
-- INTENTOS NO VALIDOS --
-------------------------

-- contrato concesion no existe
-- canon no existe
EXEC concesiones.sp_registrar_pago_canon
    @p_id_contrato_concesion = 999,
    @p_id_canon = 999,
    @p_monto_pagar = 1000.00

-- canon ya pagado
-- el monto pagado debe ser igual al importe del canon
EXEC concesiones.sp_registrar_pago_canon
    @p_id_contrato_concesion = 1,
    @p_id_canon = 1,
    @p_monto_pagar = 2000.00

------------------------------------------------------
----- TESTING ACTUALIZAR ESTADO CANONES VENCIDOS -----
------------------------------------------------------

-- actualizar el estado de los cánones vencidos que no hayan sido pagados, ni anulados, a "Vencido"

INSERT INTO concesiones.canon (fecha_vencimiento, importe, id_contrato_concesion, id_estado_canon)
VALUES ('2020-01-01', 1000.00, 1, 1)

-- canones estado antes del la actualización de canones vencidos
SELECT e.id_empresa, cc.id_contrato_concesion, c.id_canon, c.fecha_vencimiento, c.importe, ec.descripcion AS estado_canon
FROM concesiones.canon c 
JOIN concesiones.estado_canon ec ON c.id_estado_canon = ec.id_estado_canon
JOIN concesiones.contrato_concesion cc ON c.id_contrato_concesion = cc.id_contrato_concesion
JOIN concesiones.empresa e ON cc.id_empresa = e.id_empresa
WHERE cc.id_contrato_concesion = 1

EXEC concesiones.sp_actualizar_estado_canones_vencidos

-- canones estado antes del pago después de la actualización de canones vencidos
SELECT e.id_empresa, cc.id_contrato_concesion, c.id_canon, c.fecha_vencimiento, c.importe, ec.descripcion AS estado_canon
FROM concesiones.canon c 
JOIN concesiones.estado_canon ec ON c.id_estado_canon = ec.id_estado_canon
JOIN concesiones.contrato_concesion cc ON c.id_contrato_concesion = cc.id_contrato_concesion
JOIN concesiones.empresa e ON cc.id_empresa = e.id_empresa
WHERE cc.id_contrato_concesion = 1



-----------------------------------------------------------
------------ TESTING ANULAR CONTRATO CONCESIÓN ------------
-----------------------------------------------------------

--------------------
-- INTENTO VALIDO --
--------------------

-- actualizar el estado de los cánones asociados al contrato concesión a "Anulado", excepto aquellos que ya se encuentran en estado "Pagado" o "Vencido"

-- antes de la anulación del contrato concesión
SELECT e.id_empresa, cc.id_contrato_concesion, c.id_canon, c.fecha_vencimiento, c.importe, ec.descripcion AS estado_canon
FROM concesiones.canon c 
JOIN concesiones.estado_canon ec ON c.id_estado_canon = ec.id_estado_canon
JOIN concesiones.contrato_concesion cc ON c.id_contrato_concesion = cc.id_contrato_concesion
JOIN concesiones.empresa e ON cc.id_empresa = e.id_empresa
WHERE cc.id_contrato_concesion = 1

EXEC concesiones.sp_anular_contrato_concesion
    @p_id_contrato_concesion = 1

-- después de la anulación del contrato concesión
SELECT e.id_empresa, cc.id_contrato_concesion, c.id_canon, c.fecha_vencimiento, c.importe, ec.descripcion AS estado_canon
FROM concesiones.canon c 
JOIN concesiones.estado_canon ec ON c.id_estado_canon = ec.id_estado_canon
JOIN concesiones.contrato_concesion cc ON c.id_contrato_concesion = cc.id_contrato_concesion
JOIN concesiones.empresa e ON cc.id_empresa = e.id_empresa
WHERE cc.id_contrato_concesion = 1


-------------------------
-- INTENTOS NO VALIDOS --
-------------------------
-- contrato concesion no existe
EXEC concesiones.sp_anular_contrato_concesion
    @p_id_contrato_concesion = 999


-------------------------------------
-- INTENTO NO VALIDO DE PAGO CANON --
-------------------------------------

-- pagar canon anulado 
EXEC concesiones.sp_registrar_pago_canon
    @p_id_contrato_concesion = 1,
    @p_id_canon = 3,
    @p_monto_pagar = 1000.00

