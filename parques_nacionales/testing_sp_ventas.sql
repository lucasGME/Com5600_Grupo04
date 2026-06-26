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

Script de testing de procedimientos almacenados para gestión de ventas
- testing registrar venta de entrada
- testing programar actividad
- testing asignar guía a actividad programada
- testing registrar venta de actividad
- testing registrar venta completa (entrada + actividad)
*/

USE BD_Parques_Nacionales;
GO


---------------------------------------------------------------------------------------
---------- INSERCIONES PARA EL TESTING ------------------------------------------------
---------------------------------------------------------------------------------------
-- se tiene en cuenta que las tablas estan vacias

-- TIPO VISITANTE, ENTRADA, FORMA PAGO, PUNTO VENTA
INSERT INTO parques.tipo_visitante (descripcion, porcentaje_descuento)
VALUES ('Adulto', 0.0),
       ('Niño', 50.0), 
       ('Jubilado', 30.0);

-- entrada
INSERT INTO parques.entrada (precio_base, fecha_desde, fecha_hasta, id_parque, id_tipo_visitante)
VALUES (1000.00, '2026-01-01', '2027-12-31', 1, 1), -- adulto
       (1000.00, '2026-01-01', '2027-12-31', 1, 2), -- niño
       (1000.00, '2026-01-01', '2027-12-31', 1, 3); -- jubilado

-- forma pago
INSERT INTO ventas.forma_pago (descripcion)
VALUES ('Efectivo'), 
       ('Tarjeta de Crédito'), 
       ('Transferencia Bancaria'); 

-- punto venta
INSERT INTO ventas.punto_venta (descripcion)
VALUES ('Taquilla Parque'), 
       ('Online'),
       ('Agencia de Viajes');

-- para programar actividad: TIPO ACTIVIDAD TURISTICA, ACTIVIDAD TURISTICA
INSERT INTO parques.tipo_actividad_turistica (descripcion)
VALUES  ('Senderismo'),
        ('Avistaje de Fauna'),
        ('Kayak'),
        ('Cabalgata'),
        ('Observación Astronómica');

INSERT INTO parques.actividad_turistica (nombre, duracion_horas, costo, cupo_maximo, id_parque, id_tipo_actividad_turistica)
VALUES  ('Sendero al Mirador del Cóndor', 1.00, 1000.00, 20, 1, 1),
        ('Safari Fotográfico de Fauna Nativa', 2.00, 2500.00, 15, 1, 2),
        ('Travesía en Kayak por el Lago Cristal', 3.00, 3000.00, 10, 1, 3),
        ('Cabalgata por los Valles Patagónicos', 4.00, 6000.00, 25, 1, 4),
        ('Noche de Observación del Cielo Patagónico', 8.00, 500.00, 30, 1, 5);

-- para asignar guía a actividad: TITULO, ESPECIALIDAD, ESTADO GUIA, GUIA, AUTORIZACION
INSERT INTO rrhh.titulo (descripcion)
VALUES ('Licenciatura en Turismo');

INSERT INTO rrhh.especialidad (descripcion)
VALUES ('Guía de Parque Nacional');

INSERT INTO rrhh.estado_guia (descripcion)
VALUES ('Activo'), 
       ('Inactivo'),
       ('Suspendido'),
       ('Retirado');

INSERT INTO rrhh.guia (legajo, apellido_y_nombre, fecha_nacimiento, email, telefono, id_titulo, id_especialidad, id_estado_guia)
VALUES  (1001, 'Juan Pérez', '1985-05-15', 'juan.perez@email.com', '123456789', 1, 1, 1),
        (1002, 'María Gómez', '1990-08-20', 'maria.gomez@email.com', '987654321', 1, 1, 2),
        (1003, 'Carlos Rodríguez', '1978-12-10', 'carlos.rodriguez@email.com', '456789123', 1, 1, 3),
        (1004, 'Laura Fernández', '1982-03-25', 'laura.fernandez@email.com', '321654987', 1, 1, 4);

INSERT INTO rrhh.autorizacion (id_guia, fecha_emision, fecha_vencimiento)
VALUES  (1, '2026-01-01', '2028-12-31'), -- autorización vigente para Juan Pérez
        (2, '2025-01-01', '2025-12-31'), -- autorización vencida para María Gómez
        (3, '2026-06-01', '2028-12-31'), -- autorización vigente para Carlos Rodríguez
        (4, '2024-01-01', '2024-12-31'); -- autorización vencida para Laura Fernández


-- INSERTADO EN testing_sp_apis.sql
-- id_clima = 1, cielo despejado
-- id_clima = 2, mayormente nublado
-- id_clima = 3, partialmente nublado

-- id_moneda = 1, Argentine Peso
-- id_moneda = 48, Euro
-- id_moneda = 153, United States Dollar


---------------------------------------------------------------------------------------
---------- TESTING REGISTRAR VENTA ENTRADA --------------------------------------------
---------------------------------------------------------------------------------------

----------------------------
-- INTENTO VALIDO ----------
----------------------------
/*
venta de: 
parque:         1       -> Parque 1
punto venta:    1       -> Taquilla Parque
tipo moneda:    1       -> Peso Argentino
forma pago:     1       -> Efectivo
entrada:        1       -> Adulto (0% descuento - precio base $1000)
clima:          1       -> Cielo despejado
cantidad:       5
fecha acceso:   2026-06-25

se espera:
precio unitario:    $1000
total venta:        $5000
monto pago:         $5000 (pesos argentinos)
*/

EXEC ventas.sp_registrar_venta_entrada
    @p_id_parque = 1, 
	@p_id_punto_venta = 1, 
	@p_id_tipo_moneda = 1,
	@p_id_forma_pago = 1, 
	@p_id_entrada = 1, 
	@p_id_clima = 1, 
	@p_cantidad = 5, 
	@p_fecha_acceso = '2026-06-26',
	@p_id_venta = NULL,
	@p_id_pago = NULL, 
	@p_id_detalle_venta = NULL

SELECT  v.id_venta AS 'ID Venta', 
        dv.id_detalle_venta AS 'ID Detalle Venta', 
        tv.descripcion AS 'Entrada Tipo Visitante', 
        pe.fecha_acceso AS 'Fecha Acceso',
        dv.cantidad AS 'Cantidad', 
        dv.precio_unitario AS 'Precio Unitario', 
        v.total AS 'Total Venta',
        fp.descripcion AS 'Forma Pago',
        tm.descripcion AS 'Tipo Moneda',
        tm.valor AS 'Valor Moneda',
        p.monto AS 'Monto Pagado'
FROM ventas.venta v
JOIN ventas.detalle_venta dv ON v.id_venta = dv.id_venta
JOIN ventas.pase_entrada pe ON dv.id_detalle_venta = pe.id_detalle_venta
JOIN parques.entrada e ON pe.id_entrada = e.id_entrada
JOIN parques.tipo_visitante tv ON e.id_tipo_visitante = tv.id_tipo_visitante
JOIN ventas.pago p ON v.id_pago = p.id_pago
JOIN ventas.forma_pago fp ON p.id_forma_pago = fp.id_forma_pago
JOIN ventas.tipo_moneda tm ON p.id_tipo_moneda = tm.id_tipo_moneda
WHERE   e.id_parque = 1 
        AND v.id_parque = 1
        AND v.id_venta = 1


/*
venta de: 
parque:         1       -> Parque 1
punto venta:    1       -> Taquilla Parque
tipo moneda:    153     -> United States Dollar
forma pago:     2       -> Tarjeta de Crédito
entrada:        2       -> Niño (50% descuento - precio base $1000)
clima:          1       -> Cielo despejado
cantidad:       10
fecha acceso:   2027-06-25

se espera:
precio unitario:    $500 (aplicando el 50% de descuento)
total venta:        $5000 
monto pago:         $(5000 / precio USD)
*/

EXEC ventas.sp_registrar_venta_entrada
    @p_id_parque = 1, 
	@p_id_punto_venta = 1,
	@p_id_tipo_moneda = 153, 
	@p_id_forma_pago = 2, 
	@p_id_entrada = 2, 
	@p_id_clima = 1,
	@p_cantidad = 10,
	@p_fecha_acceso = '2027-06-25',
	@p_id_venta = NULL,
	@p_id_pago = NULL, 
	@p_id_detalle_venta = NULL 


SELECT  v.id_venta AS 'ID Venta', 
        dv.id_detalle_venta AS 'ID Detalle Venta', 
        tv.descripcion AS 'Entrada Tipo Visitante', 
        pe.fecha_acceso AS 'Fecha Acceso',
        dv.cantidad AS 'Cantidad', 
        dv.precio_unitario AS 'Precio Unitario', 
        v.total AS 'Total Venta',
        fp.descripcion AS 'Forma Pago',
        tm.descripcion AS 'Tipo Moneda',
        tm.valor AS 'Valor Moneda',
        p.monto AS 'Monto Pagado'
FROM ventas.venta v
JOIN ventas.detalle_venta dv ON v.id_venta = dv.id_venta
JOIN ventas.pase_entrada pe ON dv.id_detalle_venta = pe.id_detalle_venta
JOIN parques.entrada e ON pe.id_entrada = e.id_entrada
JOIN parques.tipo_visitante tv ON e.id_tipo_visitante = tv.id_tipo_visitante
JOIN ventas.pago p ON v.id_pago = p.id_pago
JOIN ventas.forma_pago fp ON p.id_forma_pago = fp.id_forma_pago
JOIN ventas.tipo_moneda tm ON p.id_tipo_moneda = tm.id_tipo_moneda
WHERE   e.id_parque = 1 
        AND v.id_parque = 1


----------------------------
-- INTENTO NO VALIDO -------
----------------------------

-- cantidad no positiva 
-- fecha de acceso es anterior a la fecha actual
-- clima no existe
-- parque no existe
-- punto de venta no existe
-- tipo moneda no existe
-- forma de pago no existe
-- entrada no existe
EXEC ventas.sp_registrar_venta_entrada
    @p_id_parque = 999, 
    @p_id_punto_venta = 999, 
    @p_id_tipo_moneda = 999, 
    @p_id_forma_pago = 999, 
    @p_id_entrada = 999, 
    @p_id_clima = 999, 
    @p_cantidad = -5,
    @p_fecha_acceso = '2020-01-01',
    @p_id_venta = NULL, 
    @p_id_pago = NULL, 
    @p_id_detalle_venta = NULL


---------------------------------------------------------------------------------------
---------- TESTING PROGRAMAR ACTIVIDAD ------------------------------------------------
---------------------------------------------------------------------------------------

----------------------------
-- INTENTO VALIDO ----------
----------------------------

/*
programar:
actividad: 1 -> Sendero al Mirador del Cóndor
fecha hora inicio: '2027-10-10 9:00:00'
*/

EXEC ventas.sp_programar_actividad
	@p_id_actividad_turistica = 1,
	@p_fecha_hora_inicio = '2027-10-10 9:00:00',
	@p_id_actividad_programada = NULL

SELECT  at.id_parque AS "ID Parque",
        ap.id_actividad_programada AS "ID Actividad Programada",
        at.nombre AS "Actividad Turística", 
        at.duracion_horas AS "Duración (Horas)", 
        at.costo AS "Costo", 
        at.cupo_maximo AS "Cupo Máximo", 
        tat.descripcion AS "Tipo Actividad Turística",
        ap.fecha_hora AS "Fecha Hora Inicio"
FROM ventas.actividad_programada ap
JOIN parques.actividad_turistica at ON ap.id_actividad_turistica = at.id_actividad_turistica
JOIN parques.tipo_actividad_turistica tat ON at.id_tipo_actividad_turistica = tat.id_tipo_actividad_turistica
WHERE at.id_parque = 1


/*
programar:
actividad: 2 -> Safari Fotográfico de Fauna Nativa
fecha hora inicio: '2027-10-10 9:30:00'
*/
EXEC ventas.sp_programar_actividad
	@p_id_actividad_turistica = 2,
	@p_fecha_hora_inicio = '2027-10-10 9:30:00',
	@p_id_actividad_programada = NULL

SELECT  at.id_parque AS "ID Parque",
        ap.id_actividad_programada AS "ID Actividad Programada",
        at.nombre AS "Actividad Turística", 
        at.duracion_horas AS "Duración (Horas)", 
        at.costo AS "Costo", 
        at.cupo_maximo AS "Cupo Máximo", 
        tat.descripcion AS "Tipo Actividad Turística",
        ap.fecha_hora AS "Fecha Hora Inicio"
FROM ventas.actividad_programada ap
JOIN parques.actividad_turistica at ON ap.id_actividad_turistica = at.id_actividad_turistica
JOIN parques.tipo_actividad_turistica tat ON at.id_tipo_actividad_turistica = tat.id_tipo_actividad_turistica
WHERE at.id_parque = 1


----------------------------
-- INTENTO NO VALIDO -------
----------------------------

-- fecha y hora inicio es anterior a la fecha y hora actual
-- actividad turística no existe
EXEC ventas.sp_programar_actividad
    @p_id_actividad_turistica = 999, 
    @p_fecha_hora_inicio = '2020-01-01 9:00:00',
    @p_id_actividad_programada = NULL


-- actividad turistica ya programada, solapa en fecha y hora
EXEC ventas.sp_programar_actividad
    @p_id_actividad_turistica = 1, 
    @p_fecha_hora_inicio = '2027-10-10 9:30:00',
    @p_id_actividad_programada = NULL


---------------------------------------------------------------------------------------
---------- TESTING ASIGNAR GUÍA A ACTIVIDAD -------------------------------------------
---------------------------------------------------------------------------------------

----------------------------
-- INTENTO VALIDO ----------
----------------------------

/*
actividad programada:
actividad: 1 -> Sendero al Mirador del Cóndor
fecha hora inicio: '2027-10-10 9:00:00'

guia: 1 -> Juan Pérez (autorización vigente y estado activo)
*/

EXEC ventas.sp_asignar_guia_actividad_programada
    @p_id_actividad_programada = 1, 
    @p_id_guia = 1


SELECT ap.id_actividad_programada AS "ID Actividad Programada",
       at.nombre AS "Actividad Turística",
       at.cupo_maximo AS "Cupo Máximo",
       ap.fecha_hora AS "Fecha Hora Inicio", 
       g.apellido_y_nombre AS "Guía Asignado", 
       a.fecha_emision AS "Fecha Emisión Autorización", 
       a.fecha_vencimiento AS "Fecha Vencimiento Autorización", 
       eg.descripcion AS "Estado Guía"
FROM rrhh.autorizacion a
JOIN rrhh.guia g ON g.id_guia = a.id_guia
JOIN rrhh.estado_guia eg ON g.id_estado_guia = eg.id_estado_guia
RIGHT JOIN ventas.actividad_programada ap ON ap.id_guia = g.id_guia
JOIN parques.actividad_turistica at ON ap.id_actividad_turistica = at.id_actividad_turistica


----------------------------
-- INTENTO NO VALIDO -------
----------------------------
-- actividad programada no existe
-- guía no existe
EXEC ventas.sp_asignar_guia_actividad_programada
    @p_id_actividad_programada = 999, 
    @p_id_guia = 999

-- la actividad ya tiene asignada un guía
-- guia inactivo, supendido o retirado
-- sin autorización vigente
EXEC ventas.sp_asignar_guia_actividad_programada
    @p_id_actividad_programada = 1, 
    @p_id_guia = 2 


-- el guia ya tiene una actividad programada asignada que solapa en fecha y hora
select * from ventas.actividad_programada

EXEC ventas.sp_asignar_guia_actividad_programada
    @p_id_actividad_programada = 2,
    @p_id_guia = 1 


---- la actividad programada ya ha finalizado
SELECT name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('ventas.actividad_programada');

-- se desactiva temporalmente la restricción de fecha para insertar una actividad programada con fecha pasada
ALTER TABLE ventas.actividad_programada
NOCHECK CONSTRAINT ck_actividad_programada_fecha_hora;

INSERT INTO ventas.actividad_programada (id_actividad_turistica, fecha_hora, id_guia)
VALUES (1, '2020-01-01 09:00:00', NULL);

ALTER TABLE ventas.actividad_programada
CHECK CONSTRAINT ck_actividad_programada_fecha_hora;

SELECT * FROM ventas.actividad_programada

EXEC ventas.sp_asignar_guia_actividad_programada
    @p_id_actividad_programada = 3,
    @p_id_guia = 1


---------------------------------------------------------------------------------------
---------- TESTING REGISTRAR VENTA ACTIVIDAD ------------------------------------------
---------------------------------------------------------------------------------------

----------------------------
-- INTENTO VALIDO ----------
----------------------------

/*
venta de:
punto venta:    2           -> Online
tipo moneda:    153         -> Dólar estadounidense
forma pago:     1           -> Efectivo
actividad programada: 1     -> Sendero al Mirador del Cóndor, 10/10/2027 a las 9:00 am, guia Juan Pérez
cantidad participantes: 3   


se espera:
costo actividad:    $1000
total venta:        $3000
monto pago:         $(3000 / precio USD)

quedarán 17 lugares disponibles para la actividad programada (cupo máximo 20)
*/

EXEC ventas.sp_registrar_venta_actividad
	@p_id_punto_venta = 2,
	@p_id_tipo_moneda = 153, 
	@p_id_forma_pago = 1,
	@p_id_actividad_programada = 1,
	@p_cantidad_participantes = 3,
	@p_id_venta = NULL, 
	@p_id_pago = NULL,
	@p_id_detalle_venta = NULL


SELECT  v.id_venta AS 'ID Venta', 
        dv.id_detalle_venta AS 'ID Detalle Venta', 
        at.nombre AS 'Actividad Turística',
        at.cupo_maximo AS 'Cupo Máximo',
        ap.fecha_hora AS 'Fecha Hora Inicio',
        dv.cantidad AS 'Cantidad Participantes', 
        dv.precio_unitario AS 'Precio Unitario', 
        v.total AS 'Total Venta',
        fp.descripcion AS 'Forma Pago',
        tm.descripcion AS 'Tipo Moneda',
        tm.valor AS 'Valor Moneda',
        p.monto AS 'Monto Pagado'
FROM ventas.venta v
JOIN ventas.detalle_venta dv ON v.id_venta = dv.id_venta
JOIN ventas.pase_actividad pa ON dv.id_detalle_venta = pa.id_detalle_venta
JOIN ventas.actividad_programada ap ON pa.id_actividad_programada = ap.id_actividad_programada
JOIN parques.actividad_turistica at ON ap.id_actividad_turistica = at.id_actividad_turistica
JOIN ventas.pago p ON v.id_pago = p.id_pago
JOIN ventas.forma_pago fp ON p.id_forma_pago = fp.id_forma_pago
JOIN ventas.tipo_moneda tm ON p.id_tipo_moneda = tm.id_tipo_moneda
WHERE   at.id_parque = 1 
        AND v.id_parque = 1

----------------------------
-- INTENTO NO VALIDO -------
----------------------------

-- punto venta no existe
-- tipo moneda no existe
-- forma de pago no existe
-- actividad programada no existe
-- cantidad participantes no positiva
EXEC ventas.sp_registrar_venta_actividad
    @p_id_punto_venta = 999,
    @p_id_tipo_moneda = 999, 
    @p_id_forma_pago = 999,
    @p_id_actividad_programada = 999,
    @p_cantidad_participantes = -3,
    @p_id_venta = NULL, 
    @p_id_pago = NULL,
    @p_id_detalle_venta = NULL

-- actividad programada ya finalizada
select *
from ventas.actividad_programada

EXEC ventas.sp_registrar_venta_actividad
    @p_id_punto_venta = 1,
    @p_id_tipo_moneda = 2, 
    @p_id_forma_pago = 1,
    @p_id_actividad_programada = 3, 
    @p_cantidad_participantes = 1,
    @p_id_venta = NULL, 
    @p_id_pago = NULL,
    @p_id_detalle_venta = NULL



-- actividad programada sin cupo disponible para la cantidad de participantes
/*
venta de:
punto venta:    2           -> Online
tipo moneda:    153         -> Dólar estadounidense
forma pago:     1           -> Efectivo
actividad programada: 1     -> Sendero al Mirador del Cóndor, 10/10/2027 a las 9:00 am, guia Juan Pérez
cantidad participantes: 18  -> quedaban solo 17 lugares disponibles
*/
EXEC ventas.sp_registrar_venta_actividad
    @p_id_punto_venta = 2,
    @p_id_tipo_moneda = 153, 
    @p_id_forma_pago = 1,
    @p_id_actividad_programada = 1,
    @p_cantidad_participantes = 18, 
    @p_id_venta = NULL, 
    @p_id_pago = NULL,
    @p_id_detalle_venta = NULL

----------------------------
-- INTENTO VALIDO ----------
----------------------------
-- mismo caso que el anterior, pero con cantidad de participantes = 17

EXEC ventas.sp_registrar_venta_actividad
    @p_id_punto_venta = 2,
    @p_id_tipo_moneda = 153, 
    @p_id_forma_pago = 1,
    @p_id_actividad_programada = 1,
    @p_cantidad_participantes = 17, 
    @p_id_venta = NULL, 
    @p_id_pago = NULL,
    @p_id_detalle_venta = NULL

SELECT  v.id_venta AS 'ID Venta', 
        dv.id_detalle_venta AS 'ID Detalle Venta', 
        at.nombre AS 'Actividad Turística',
        at.cupo_maximo AS 'Cupo Máximo',
        ap.fecha_hora AS 'Fecha Hora Inicio',
        dv.cantidad AS 'Cantidad Participantes', 
        dv.precio_unitario AS 'Precio Unitario', 
        v.total AS 'Total Venta',
        fp.descripcion AS 'Forma Pago',
        tm.descripcion AS 'Tipo Moneda',
        tm.valor AS 'Valor Moneda',
        p.monto AS 'Monto Pagado'
FROM ventas.venta v
JOIN ventas.detalle_venta dv ON v.id_venta = dv.id_venta
JOIN ventas.pase_actividad pa ON dv.id_detalle_venta = pa.id_detalle_venta
JOIN ventas.actividad_programada ap ON pa.id_actividad_programada = ap.id_actividad_programada
JOIN parques.actividad_turistica at ON ap.id_actividad_turistica = at.id_actividad_turistica
JOIN ventas.pago p ON v.id_pago = p.id_pago
JOIN ventas.forma_pago fp ON p.id_forma_pago = fp.id_forma_pago
JOIN ventas.tipo_moneda tm ON p.id_tipo_moneda = tm.id_tipo_moneda
WHERE   at.id_parque = 1 
        AND v.id_parque = 1


---------------------------------------------------------------------------------------
---------- TESTING REGISTRAR VENTA COMPLETA -------------------------------------------
---------------------------------------------------------------------------------------

----------------------------
-- INTENTO VALIDO ----------
----------------------------

/*
venta de:
parque:                 1           -> Parque 1
punto venta:            2           -> Online
tipo moneda:            153         -> Dólar estadounidense
forma pago:             1           -> Efectivo
entrada:                3           -> Jubilado (30% descuento - precio base $1000)
clima:                  8           -> Llovisna moderada
cantidad entradas:      5
fecha acceso:           2027-10-10
actividad programada:   2           -> Safari Fotográfico de Fauna Nativa, 10/10/2027 a las 9:30 am, sin guía asignado
cantidad participantes: 3   

se espera:
precio unitario entrada:    $700 (aplicando el 30% de descuento)
costo actividad:            $2500
total venta:                (700 * 5) + (2500 * 3) = $12000
monto pago:                 $(12000 / precio USD)

quedarán 12 lugares disponibles para la actividad programada (cupo máximo 15)
*/

EXEC ventas.sp_registrar_venta_completa
	@p_id_parque = 1,
	@p_id_punto_venta = 2,
	@p_id_tipo_moneda = 153, 
	@p_id_forma_pago = 1, 
	@p_id_entrada = 3, 
	@p_id_clima = 8, 
	@p_cantidad_entradas = 5, 
	@p_fecha_acceso = '2027-10-10',
	@p_id_actividad_programada = 2,
	@p_cantidad_participantes = 3,
	@p_id_venta = NULL,
	@p_id_pago = NULL

-- venta de entradas y actividad turística registrada
SELECT v.id_venta, dv.id_detalle_venta, v.total, v.id_pago, tm.descripcion, tm.valor,  p.monto
FROM ventas.venta v
JOIN ventas.detalle_venta dv ON v.id_venta = dv.id_venta
JOIN ventas.pago p ON v.id_pago = p.id_pago
JOIN ventas.tipo_moneda tm ON p.id_tipo_moneda = tm.id_tipo_moneda

-- venta de entradas registrada
SELECT  v.id_venta AS 'ID Venta', 
        dv.id_detalle_venta AS 'ID Detalle Venta', 
        tv.descripcion AS 'Entrada Tipo Visitante', 
        pe.fecha_acceso AS 'Fecha Acceso',
        dv.cantidad AS 'Cantidad', 
        dv.precio_unitario AS 'Precio Unitario', 
        v.total AS 'Total Venta',
        fp.descripcion AS 'Forma Pago',
        tm.descripcion AS 'Tipo Moneda',
        tm.valor AS 'Valor Moneda',
        p.monto AS 'Monto Pagado'
FROM ventas.venta v
JOIN ventas.detalle_venta dv ON v.id_venta = dv.id_venta
JOIN ventas.pase_entrada pe ON dv.id_detalle_venta = pe.id_detalle_venta
JOIN parques.entrada e ON pe.id_entrada = e.id_entrada
JOIN parques.tipo_visitante tv ON e.id_tipo_visitante = tv.id_tipo_visitante
JOIN ventas.pago p ON v.id_pago = p.id_pago
JOIN ventas.forma_pago fp ON p.id_forma_pago = fp.id_forma_pago
JOIN ventas.tipo_moneda tm ON p.id_tipo_moneda = tm.id_tipo_moneda
WHERE   e.id_parque = 1 
        AND v.id_parque = 1

-- venta de actividad turística registrada
SELECT  v.id_venta AS 'ID Venta', 
        dv.id_detalle_venta AS 'ID Detalle Venta', 
        at.nombre AS 'Actividad Turística',
        at.cupo_maximo AS 'Cupo Máximo',
        ap.fecha_hora AS 'Fecha Hora Inicio',
        dv.cantidad AS 'Cantidad Participantes', 
        dv.precio_unitario AS 'Precio Unitario', 
        v.total AS 'Total Venta',
        fp.descripcion AS 'Forma Pago',
        tm.descripcion AS 'Tipo Moneda',
        tm.valor AS 'Valor Moneda',
        p.monto AS 'Monto Pagado'
FROM ventas.venta v
JOIN ventas.detalle_venta dv ON v.id_venta = dv.id_venta
JOIN ventas.pase_actividad pa ON dv.id_detalle_venta = pa.id_detalle_venta
JOIN ventas.actividad_programada ap ON pa.id_actividad_programada = ap.id_actividad_programada
JOIN parques.actividad_turistica at ON ap.id_actividad_turistica = at.id_actividad_turistica
JOIN ventas.pago p ON v.id_pago = p.id_pago
JOIN ventas.forma_pago fp ON p.id_forma_pago = fp.id_forma_pago
JOIN ventas.tipo_moneda tm ON p.id_tipo_moneda = tm.id_tipo_moneda
WHERE   at.id_parque = 1 
        AND v.id_parque = 1


----------------------------
-- INTENTO NO VALIDO -------
----------------------------

-- cantidad de entradas no positiva
-- cantidad de participantes no positiva
-- cantidad participantes mayor a cantidad de entradas
-- fecha de acceso es anterior a la fecha actual
-- clima no existe
-- parque no existe
-- punto de venta no existe
-- tipo moneda no existe
-- forma de pago no existe
-- entrada no existe
-- actividad programada no existe
EXEC ventas.sp_registrar_venta_completa
    @p_id_parque = 999,
    @p_id_punto_venta = 999,
    @p_id_tipo_moneda = 999, 
    @p_id_forma_pago = 999, 
    @p_id_entrada = 999, 
    @p_id_clima = 999, 
    @p_cantidad_entradas = -5, 
    @p_fecha_acceso = '2020-10-10',
    @p_id_actividad_programada = 999,
    @p_cantidad_participantes = -3,
    @p_id_venta = NULL,
    @p_id_pago = NULL   

-- actividad programada ya finalizada
EXEC ventas.sp_registrar_venta_completa
	@p_id_parque = 1,
	@p_id_punto_venta = 1,
	@p_id_tipo_moneda = 2, 
	@p_id_forma_pago = 1, 
	@p_id_entrada = 2, 
	@p_id_clima = 1, 
	@p_cantidad_entradas = 5, 
	@p_fecha_acceso = '2027-10-10',
	@p_id_actividad_programada = 3,
	@p_cantidad_participantes = 3,
	@p_id_venta = NULL,
	@p_id_pago = NULL

-- actividad programada sin cupo disponible para la cantidad de participantes
EXEC ventas.sp_registrar_venta_completa
	@p_id_parque = 1,
	@p_id_punto_venta = 1,
	@p_id_tipo_moneda = 2, 
	@p_id_forma_pago = 1, 
	@p_id_entrada = 2, 
	@p_id_clima = 1, 
	@p_cantidad_entradas = 5, 
	@p_fecha_acceso = '2027-10-10',
	@p_id_actividad_programada = 1,
	@p_cantidad_participantes = 3,
	@p_id_venta = NULL,
	@p_id_pago = NULL