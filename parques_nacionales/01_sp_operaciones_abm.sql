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

Script de creacion de SPs de operaciones ABM (Alta, Baja, Modificación) 
para todas las tablas del sistema de gestión de Parques Nacionales.
*/

USE BD_Parques_Nacionales;
GO

-- ============================================================
--  ESQUEMA: parques
-- ============================================================

-- ----------------------------------------------------------
--  parques.provincia
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_provincia_alta
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@nombre)) = '' OR @nombre IS NULL
        SET @errores = @errores + '- El nombre de la provincia no puede estar vacío.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.provincia WHERE nombre = LTRIM(RTRIM(@nombre)))
        SET @errores = @errores + '- Ya existe una provincia con ese nombre.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.provincia (nombre) VALUES (LTRIM(RTRIM(@nombre)));
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_provincia_modificacion
    @id_provincia INT,
    @nombre       VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.provincia WHERE id_provincia = @id_provincia)
        SET @errores = @errores + '- No existe una provincia con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@nombre)) = '' OR @nombre IS NULL
        SET @errores = @errores + '- El nombre de la provincia no puede estar vacío.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.provincia WHERE nombre = LTRIM(RTRIM(@nombre)) AND id_provincia <> @id_provincia)
        SET @errores = @errores + '- Ya existe otra provincia con ese nombre.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.provincia SET nombre = LTRIM(RTRIM(@nombre)) WHERE id_provincia = @id_provincia;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_provincia_baja
    @id_provincia INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.provincia WHERE id_provincia = @id_provincia)
        SET @errores = @errores + '- No existe una provincia con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.localidad WHERE id_provincia = @id_provincia)
        SET @errores = @errores + '- No se puede eliminar: existen localidades asociadas a esta provincia.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.provincia WHERE id_provincia = @id_provincia;
END;
GO

-- ----------------------------------------------------------
--  parques.localidad
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_localidad_alta
    @nombre       VARCHAR(100),
    @id_provincia INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@nombre)) = '' OR @nombre IS NULL
        SET @errores = @errores + '- El nombre de la localidad no puede estar vacío.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.provincia WHERE id_provincia = @id_provincia)
        SET @errores = @errores + '- No existe la provincia indicada.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.localidad WHERE nombre = LTRIM(RTRIM(@nombre)) AND id_provincia = @id_provincia)
        SET @errores = @errores + '- Ya existe una localidad con ese nombre en esa provincia.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.localidad (nombre, id_provincia) VALUES (LTRIM(RTRIM(@nombre)), @id_provincia);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_localidad_modificacion
    @id_localidad INT,
    @nombre       VARCHAR(100),
    @id_provincia INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.localidad WHERE id_localidad = @id_localidad)
        SET @errores = @errores + '- No existe una localidad con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@nombre)) = '' OR @nombre IS NULL
        SET @errores = @errores + '- El nombre de la localidad no puede estar vacío.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.provincia WHERE id_provincia = @id_provincia)
        SET @errores = @errores + '- No existe la provincia indicada.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.localidad WHERE nombre = LTRIM(RTRIM(@nombre)) AND id_provincia = @id_provincia AND id_localidad <> @id_localidad)
        SET @errores = @errores + '- Ya existe otra localidad con ese nombre en esa provincia.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.localidad SET nombre = LTRIM(RTRIM(@nombre)), id_provincia = @id_provincia WHERE id_localidad = @id_localidad;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_localidad_baja
    @id_localidad INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.localidad WHERE id_localidad = @id_localidad)
        SET @errores = @errores + '- No existe una localidad con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.parque WHERE id_localidad = @id_localidad)
        SET @errores = @errores + '- No se puede eliminar: existen parques asociados a esta localidad.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.localidad WHERE id_localidad = @id_localidad;
END;
GO

-- ----------------------------------------------------------
--  parques.tipo_parque
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_tipo_parque_alta
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción del tipo de parque no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.tipo_parque WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe un tipo de parque con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.tipo_parque (descripcion) VALUES (LTRIM(RTRIM(@descripcion)));
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_tipo_parque_modificacion
    @id_tipo_parque INT,
    @descripcion    VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_parque WHERE id_tipo_parque = @id_tipo_parque)
        SET @errores = @errores + '- No existe un tipo de parque con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.tipo_parque WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_tipo_parque <> @id_tipo_parque)
        SET @errores = @errores + '- Ya existe otro tipo de parque con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.tipo_parque SET descripcion = LTRIM(RTRIM(@descripcion)) WHERE id_tipo_parque = @id_tipo_parque;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_tipo_parque_baja
    @id_tipo_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_parque WHERE id_tipo_parque = @id_tipo_parque)
        SET @errores = @errores + '- No existe un tipo de parque con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.parque WHERE id_tipo_parque = @id_tipo_parque)
        SET @errores = @errores + '- No se puede eliminar: existen parques asociados a este tipo.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.tipo_parque WHERE id_tipo_parque = @id_tipo_parque;
END;
GO

-- ----------------------------------------------------------
--  parques.tipo_actividad_turistica
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_tipo_actividad_turistica_alta
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.tipo_actividad_turistica WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe un tipo de actividad con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.tipo_actividad_turistica (descripcion) VALUES (LTRIM(RTRIM(@descripcion)));
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_tipo_actividad_turistica_modificacion
    @id_tipo_actividad_turistica INT,
    @descripcion                 VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_actividad_turistica WHERE id_tipo_actividad_turistica = @id_tipo_actividad_turistica)
        SET @errores = @errores + '- No existe un tipo de actividad con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.tipo_actividad_turistica WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_tipo_actividad_turistica <> @id_tipo_actividad_turistica)
        SET @errores = @errores + '- Ya existe otro tipo de actividad con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.tipo_actividad_turistica SET descripcion = LTRIM(RTRIM(@descripcion)) WHERE id_tipo_actividad_turistica = @id_tipo_actividad_turistica;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_tipo_actividad_turistica_baja
    @id_tipo_actividad_turistica INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_actividad_turistica WHERE id_tipo_actividad_turistica = @id_tipo_actividad_turistica)
        SET @errores = @errores + '- No existe un tipo de actividad con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.actividad_turistica WHERE id_tipo_actividad_turistica = @id_tipo_actividad_turistica)
        SET @errores = @errores + '- No se puede eliminar: existen actividades turísticas asociadas a este tipo.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.tipo_actividad_turistica WHERE id_tipo_actividad_turistica = @id_tipo_actividad_turistica;
END;
GO

-- ----------------------------------------------------------
--  parques.tipo_visitante
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_tipo_visitante_alta
    @descripcion         VARCHAR(100),
    @porcentaje_descuento DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF @porcentaje_descuento < 0 OR @porcentaje_descuento > 100
        SET @errores = @errores + '- El porcentaje de descuento debe estar entre 0 y 100.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.tipo_visitante WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe un tipo de visitante con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.tipo_visitante (descripcion, porcentaje_descuento) VALUES (LTRIM(RTRIM(@descripcion)), @porcentaje_descuento);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_tipo_visitante_modificacion
    @id_tipo_visitante   INT,
    @descripcion         VARCHAR(100),
    @porcentaje_descuento DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_visitante WHERE id_tipo_visitante = @id_tipo_visitante)
        SET @errores = @errores + '- No existe un tipo de visitante con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF @porcentaje_descuento < 0 OR @porcentaje_descuento > 100
        SET @errores = @errores + '- El porcentaje de descuento debe estar entre 0 y 100.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.tipo_visitante WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_tipo_visitante <> @id_tipo_visitante)
        SET @errores = @errores + '- Ya existe otro tipo de visitante con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.tipo_visitante SET descripcion = LTRIM(RTRIM(@descripcion)), porcentaje_descuento = @porcentaje_descuento
    WHERE id_tipo_visitante = @id_tipo_visitante;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_tipo_visitante_baja
    @id_tipo_visitante INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_visitante WHERE id_tipo_visitante = @id_tipo_visitante)
        SET @errores = @errores + '- No existe un tipo de visitante con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.entrada WHERE id_tipo_visitante = @id_tipo_visitante)
        SET @errores = @errores + '- No se puede eliminar: existen entradas asociadas a este tipo de visitante.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.tipo_visitante WHERE id_tipo_visitante = @id_tipo_visitante;
END;
GO

-- ----------------------------------------------------------
--  parques.entrada
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_entrada_alta
    @precio_base       DECIMAL(12,2),
    @fecha_desde       DATE,
    @fecha_hasta       DATE,
    @id_parque         INT,
    @id_tipo_visitante INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF @precio_base < 0
        SET @errores = @errores + '- El precio base no puede ser negativo.' + CHAR(13);

    IF @fecha_desde IS NULL OR @fecha_hasta IS NULL
        SET @errores = @errores + '- Las fechas de vigencia no pueden ser nulas.' + CHAR(13);
    ELSE IF @fecha_hasta < @fecha_desde
        SET @errores = @errores + '- La fecha "hasta" no puede ser anterior a la fecha "desde".' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No existe el parque indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_visitante WHERE id_tipo_visitante = @id_tipo_visitante)
        SET @errores = @errores + '- No existe el tipo de visitante indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.entrada (precio_base, fecha_desde, fecha_hasta, id_parque, id_tipo_visitante)
    VALUES (@precio_base, @fecha_desde, @fecha_hasta, @id_parque, @id_tipo_visitante);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_entrada_modificacion
    @id_entrada        INT,
    @precio_base       DECIMAL(12,2),
    @fecha_desde       DATE,
    @fecha_hasta       DATE,
    @id_parque         INT,
    @id_tipo_visitante INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.entrada WHERE id_entrada = @id_entrada)
        SET @errores = @errores + '- No existe una entrada con el ID indicado.' + CHAR(13);

    IF @precio_base < 0
        SET @errores = @errores + '- El precio base no puede ser negativo.' + CHAR(13);

    IF @fecha_desde IS NULL OR @fecha_hasta IS NULL
        SET @errores = @errores + '- Las fechas de vigencia no pueden ser nulas.' + CHAR(13);
    ELSE IF @fecha_hasta < @fecha_desde
        SET @errores = @errores + '- La fecha "hasta" no puede ser anterior a la fecha "desde".' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No existe el parque indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_visitante WHERE id_tipo_visitante = @id_tipo_visitante)
        SET @errores = @errores + '- No existe el tipo de visitante indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.entrada
    SET precio_base = @precio_base,
        fecha_desde = @fecha_desde,
        fecha_hasta = @fecha_hasta,
        id_parque = @id_parque,
        id_tipo_visitante = @id_tipo_visitante
    WHERE id_entrada = @id_entrada;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_entrada_baja
    @id_entrada INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.entrada WHERE id_entrada = @id_entrada)
        SET @errores = @errores + '- No existe una entrada con el ID indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.entrada WHERE id_entrada = @id_entrada;
END;
GO

-- ----------------------------------------------------------
--  parques.parque
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_parque_alta
    @nombre        VARCHAR(150),
    @direccion     VARCHAR(200),
    @latitud       DECIMAL(9,6),
    @longitud      DECIMAL(9,6),
    @superficie_km2 DECIMAL(10,2),
    @id_localidad  INT,
    @id_tipo_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@nombre)) = '' OR @nombre IS NULL
        SET @errores = @errores + '- El nombre del parque no puede estar vacío.' + CHAR(13);

    IF LTRIM(RTRIM(@direccion)) = '' OR @direccion IS NULL
        SET @errores = @errores + '- La dirección no puede estar vacía.' + CHAR(13);

    IF @latitud < -90 OR @latitud > 90
        SET @errores = @errores + '- La latitud debe estar entre -90 y 90.' + CHAR(13);

    IF @longitud < -180 OR @longitud > 180
        SET @errores = @errores + '- La longitud debe estar entre -180 y 180.' + CHAR(13);

    IF @superficie_km2 <= 0
        SET @errores = @errores + '- La superficie debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.localidad WHERE id_localidad = @id_localidad)
        SET @errores = @errores + '- No existe la localidad indicada.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_parque WHERE id_tipo_parque = @id_tipo_parque)
        SET @errores = @errores + '- No existe el tipo de parque indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.parque WHERE nombre = LTRIM(RTRIM(@nombre)))
        SET @errores = @errores + '- Ya existe un parque con ese nombre.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.parque (nombre, direccion, latitud, longitud, superficie_km2, id_localidad, id_tipo_parque)
    VALUES (LTRIM(RTRIM(@nombre)), LTRIM(RTRIM(@direccion)), @latitud, @longitud, @superficie_km2, @id_localidad, @id_tipo_parque);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_parque_modificacion
    @id_parque     INT,
    @nombre        VARCHAR(150),
    @direccion     VARCHAR(200),
    @latitud       DECIMAL(9,6),
    @longitud      DECIMAL(9,6),
    @superficie_km2 DECIMAL(10,2),
    @id_localidad  INT,
    @id_tipo_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No existe un parque con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@nombre)) = '' OR @nombre IS NULL
        SET @errores = @errores + '- El nombre del parque no puede estar vacío.' + CHAR(13);

    IF LTRIM(RTRIM(@direccion)) = '' OR @direccion IS NULL
        SET @errores = @errores + '- La dirección no puede estar vacía.' + CHAR(13);

    IF @latitud < -90 OR @latitud > 90
        SET @errores = @errores + '- La latitud debe estar entre -90 y 90.' + CHAR(13);

    IF @longitud < -180 OR @longitud > 180
        SET @errores = @errores + '- La longitud debe estar entre -180 y 180.' + CHAR(13);

    IF @superficie_km2 <= 0
        SET @errores = @errores + '- La superficie debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.localidad WHERE id_localidad = @id_localidad)
        SET @errores = @errores + '- No existe la localidad indicada.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_parque WHERE id_tipo_parque = @id_tipo_parque)
        SET @errores = @errores + '- No existe el tipo de parque indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.parque WHERE nombre = LTRIM(RTRIM(@nombre)) AND id_parque <> @id_parque)
        SET @errores = @errores + '- Ya existe otro parque con ese nombre.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.parque
    SET nombre = LTRIM(RTRIM(@nombre)),
        direccion = LTRIM(RTRIM(@direccion)),
        latitud = @latitud,
        longitud = @longitud,
        superficie_km2 = @superficie_km2,
        id_localidad = @id_localidad,
        id_tipo_parque = @id_tipo_parque
    WHERE id_parque = @id_parque;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_parque_baja
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No existe un parque con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.actividad_turistica WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No se puede eliminar: existen actividades turísticas asociadas a este parque.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.venta WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No se puede eliminar: existen ventas asociadas a este parque.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.asignacion_guardaparques WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No se puede eliminar: existen asignaciones de guardaparques en este parque.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.contrato_concesion WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No se puede eliminar: existen contratos de concesión en este parque.' + CHAR(13);
	
	IF EXISTS (SELECT 1 FROM parques.entrada WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No se puede eliminar: existen entradas asociadas a este parque.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.parque WHERE id_parque = @id_parque;
END;
GO

-- ----------------------------------------------------------
--  parques.actividad_turistica
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE parques.sp_actividad_turistica_alta
    @nombre                      VARCHAR(150),
    @duracion_horas              DECIMAL(4,2),
    @costo                       DECIMAL(12,2),
    @cupo_maximo                 SMALLINT,
    @id_parque                   INT,
    @id_tipo_actividad_turistica INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@nombre)) = '' OR @nombre IS NULL
        SET @errores = @errores + '- El nombre de la actividad no puede estar vacío.' + CHAR(13);

    IF @duracion_horas <= 0
        SET @errores = @errores + '- La duración debe ser mayor a cero.' + CHAR(13);

    IF @costo < 0
        SET @errores = @errores + '- El costo no puede ser negativo.' + CHAR(13);

    IF @cupo_maximo <= 0
        SET @errores = @errores + '- El cupo máximo debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No existe el parque indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_actividad_turistica WHERE id_tipo_actividad_turistica = @id_tipo_actividad_turistica)
        SET @errores = @errores + '- No existe el tipo de actividad turística indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.actividad_turistica WHERE nombre = LTRIM(RTRIM(@nombre)) AND id_parque = @id_parque)
        SET @errores = @errores + '- Ya existe una actividad con ese nombre en el parque indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO parques.actividad_turistica (nombre, duracion_horas, costo, cupo_maximo, id_parque, id_tipo_actividad_turistica)
    VALUES (LTRIM(RTRIM(@nombre)), @duracion_horas, @costo, @cupo_maximo, @id_parque, @id_tipo_actividad_turistica);
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_actividad_turistica_modificacion
    @id_actividad_turistica      INT,
    @nombre                      VARCHAR(150),
    @duracion_horas              DECIMAL(4,2),
    @costo                       DECIMAL(12,2),
    @cupo_maximo                 SMALLINT,
    @id_parque                   INT,
    @id_tipo_actividad_turistica INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.actividad_turistica WHERE id_actividad_turistica = @id_actividad_turistica)
        SET @errores = @errores + '- No existe una actividad turística con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@nombre)) = '' OR @nombre IS NULL
        SET @errores = @errores + '- El nombre de la actividad no puede estar vacío.' + CHAR(13);

    IF @duracion_horas <= 0
        SET @errores = @errores + '- La duración debe ser mayor a cero.' + CHAR(13);

    IF @costo < 0
        SET @errores = @errores + '- El costo no puede ser negativo.' + CHAR(13);

    IF @cupo_maximo <= 0
        SET @errores = @errores + '- El cupo máximo debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No existe el parque indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.tipo_actividad_turistica WHERE id_tipo_actividad_turistica = @id_tipo_actividad_turistica)
        SET @errores = @errores + '- No existe el tipo de actividad turística indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM parques.actividad_turistica WHERE nombre = LTRIM(RTRIM(@nombre)) AND id_parque = @id_parque AND id_actividad_turistica <> @id_actividad_turistica)
        SET @errores = @errores + '- Ya existe otra actividad con ese nombre en el parque indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE parques.actividad_turistica
    SET nombre = LTRIM(RTRIM(@nombre)),
        duracion_horas = @duracion_horas,
        costo = @costo,
        cupo_maximo = @cupo_maximo,
        id_parque = @id_parque,
        id_tipo_actividad_turistica = @id_tipo_actividad_turistica
    WHERE id_actividad_turistica = @id_actividad_turistica;
END;
GO

CREATE OR ALTER PROCEDURE parques.sp_actividad_turistica_baja
    @id_actividad_turistica INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM parques.actividad_turistica WHERE id_actividad_turistica = @id_actividad_turistica)
        SET @errores = @errores + '- No existe una actividad turística con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.actividad_programada WHERE id_actividad_turistica = @id_actividad_turistica)
        SET @errores = @errores + '- No se puede eliminar: existen actividades programadas asociadas.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM parques.actividad_turistica WHERE id_actividad_turistica = @id_actividad_turistica;
END;
GO

-- ============================================================
--  ESQUEMA: rrhh
-- ============================================================

-- ----------------------------------------------------------
--  rrhh.titulo
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE rrhh.sp_titulo_alta
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción del título no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.titulo WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe un título con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO rrhh.titulo (descripcion) 
    VALUES (LTRIM(RTRIM(@descripcion)));
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_titulo_modificacion
    @id_titulo   INT,
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.titulo WHERE id_titulo = @id_titulo)
        SET @errores = @errores + '- No existe un título con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.titulo WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_titulo <> @id_titulo)
        SET @errores = @errores + '- Ya existe otro título con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE rrhh.titulo SET descripcion = LTRIM(RTRIM(@descripcion)) WHERE id_titulo = @id_titulo;
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_titulo_baja
    @id_titulo INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.titulo WHERE id_titulo = @id_titulo)
        SET @errores = @errores + '- No existe un título con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.guia WHERE id_titulo = @id_titulo)
        SET @errores = @errores + '- No se puede eliminar: existen guías asociados a este título.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM rrhh.titulo WHERE id_titulo = @id_titulo;
END;
GO

-- ----------------------------------------------------------
--  rrhh.especialidad
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE rrhh.sp_especialidad_alta
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción de la especialidad no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.especialidad WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe una especialidad con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO rrhh.especialidad (descripcion) VALUES (LTRIM(RTRIM(@descripcion)));
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_especialidad_modificacion
    @id_especialidad INT,
    @descripcion     VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.especialidad WHERE id_especialidad = @id_especialidad)
        SET @errores = @errores + '- No existe una especialidad con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.especialidad WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_especialidad <> @id_especialidad)
        SET @errores = @errores + '- Ya existe otra especialidad con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE rrhh.especialidad SET descripcion = LTRIM(RTRIM(@descripcion)) WHERE id_especialidad = @id_especialidad;
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_especialidad_baja
    @id_especialidad INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.especialidad WHERE id_especialidad = @id_especialidad)
        SET @errores = @errores + '- No existe una especialidad con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.guia WHERE id_especialidad = @id_especialidad)
        SET @errores = @errores + '- No se puede eliminar: existen guías asociados a esta especialidad.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM rrhh.especialidad WHERE id_especialidad = @id_especialidad;
END;
GO

-- ----------------------------------------------------------
--  rrhh.estado_guia
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE rrhh.sp_estado_guia_alta
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción del estado no puede estar vacía.' + CHAR(13);

	IF @descripcion NOT IN ('Activo', 'Inactivo', 'Suspendido', 'Retirado')
        SET @errores = @errores + '- La descripción debe ser Activo, Inactivo, Suspendido o Retirado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.estado_guia WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe un estado de guía con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO rrhh.estado_guia (descripcion) 
    VALUES (LTRIM(RTRIM(@descripcion)));
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_estado_guia_modificacion
    @id_estado_guia INT,
    @descripcion    VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.estado_guia WHERE id_estado_guia = @id_estado_guia)
        SET @errores = @errores + '- No existe un estado de guía con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

	IF @descripcion NOT IN ('Activo', 'Inactivo', 'Suspendido', 'Retirado')
        SET @errores = @errores + '- La descripción debe ser Activo, Inactivo, Suspendido o Retirado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.estado_guia WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_estado_guia <> @id_estado_guia)
        SET @errores = @errores + '- Ya existe otro estado con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE rrhh.estado_guia 
    SET descripcion = LTRIM(RTRIM(@descripcion)) 
    WHERE id_estado_guia = @id_estado_guia;
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_estado_guia_baja
    @id_estado_guia INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.estado_guia WHERE id_estado_guia = @id_estado_guia)
        SET @errores = @errores + '- No existe un estado de guía con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.guia WHERE id_estado_guia = @id_estado_guia)
        SET @errores = @errores + '- No se puede eliminar: existen guías asociados a este estado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM rrhh.estado_guia WHERE id_estado_guia = @id_estado_guia;
END;
GO

-- ----------------------------------------------------------
--  rrhh.guardaparques
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE rrhh.sp_guardaparques_alta
    @legajo            VARCHAR(20),
    @apellido_y_nombre VARCHAR(150),
    @fecha_nacimiento  DATE,
    @telefono          VARCHAR(20) = NULL,
    @email             VARCHAR(254)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@legajo)) = '' OR @legajo IS NULL
        SET @errores = @errores + '- El legajo no puede estar vacío.' + CHAR(13);

    IF LTRIM(RTRIM(@apellido_y_nombre)) = '' OR @apellido_y_nombre IS NULL
        SET @errores = @errores + '- El apellido y nombre no puede estar vacío.' + CHAR(13);

    IF @fecha_nacimiento IS NULL OR @fecha_nacimiento > CONVERT(date, SYSDATETIME())
        SET @errores = @errores + '- La fecha de nacimiento no puede ser mayor a la fecha actual.' + CHAR(13);

    IF LTRIM(RTRIM(@email)) = '' OR @email IS NULL
        SET @errores = @errores + '- El email no puede estar vacío.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.guardaparques WHERE legajo = LTRIM(RTRIM(@legajo)))
        SET @errores = @errores + '- Ya existe un guardaparques con ese legajo.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.guardaparques WHERE email = LTRIM(RTRIM(@email)))
        SET @errores = @errores + '- Ya existe un guardaparques con ese email.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO rrhh.guardaparques (legajo, apellido_y_nombre, fecha_nacimiento, telefono, email, activo)
    VALUES (LTRIM(RTRIM(@legajo)), LTRIM(RTRIM(@apellido_y_nombre)), @fecha_nacimiento, @telefono, LTRIM(RTRIM(@email)), 1);
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_guardaparques_modificacion
    @id_guardaparques  INT,
    @legajo            VARCHAR(20),
    @apellido_y_nombre VARCHAR(150),
    @fecha_nacimiento  DATE,
    @telefono          VARCHAR(20) = NULL,
    @email             VARCHAR(254),
    @activo            BIT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.guardaparques WHERE id_guardaparques = @id_guardaparques)
        SET @errores = @errores + '- No existe un guardaparques con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@legajo)) = '' OR @legajo IS NULL
        SET @errores = @errores + '- El legajo no puede estar vacío.' + CHAR(13);

    IF LTRIM(RTRIM(@apellido_y_nombre)) = '' OR @apellido_y_nombre IS NULL
        SET @errores = @errores + '- El apellido y nombre no puede estar vacío.' + CHAR(13);

    IF @fecha_nacimiento IS NULL OR @fecha_nacimiento > CONVERT(date, SYSDATETIME())
        SET @errores = @errores + '- La fecha de nacimiento no puede ser mayor a la fecha actual.' + CHAR(13);

    IF LTRIM(RTRIM(@email)) = '' OR @email IS NULL
        SET @errores = @errores + '- El email no puede estar vacío.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.guardaparques WHERE legajo = LTRIM(RTRIM(@legajo)) AND id_guardaparques <> @id_guardaparques)
        SET @errores = @errores + '- Ya existe otro guardaparques con ese legajo.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.guardaparques WHERE email = LTRIM(RTRIM(@email)) AND id_guardaparques <> @id_guardaparques)
        SET @errores = @errores + '- Ya existe otro guardaparques con ese email.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE rrhh.guardaparques
    SET legajo = LTRIM(RTRIM(@legajo)),
        apellido_y_nombre = LTRIM(RTRIM(@apellido_y_nombre)),
        fecha_nacimiento = @fecha_nacimiento,
        telefono = @telefono,
        email = LTRIM(RTRIM(@email)),
        activo = @activo
    WHERE id_guardaparques = @id_guardaparques;
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_guardaparques_baja
    @id_guardaparques INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.guardaparques WHERE id_guardaparques = @id_guardaparques)
        SET @errores = @errores + '- No existe un guardaparques con el ID indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM rrhh.guardaparques WHERE id_guardaparques = @id_guardaparques AND activo = 1)
        SET @errores = @errores + '- El guardaparques ya se encuentra inactivo.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE rrhh.guardaparques 
    SET activo = 0 
    WHERE id_guardaparques = @id_guardaparques;
END;
GO

-- ----------------------------------------------------------
--  rrhh.asignacion_guardaparques
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE rrhh.sp_asignacion_guardaparques_alta
    @id_guardaparques INT,
    @id_parque        INT,
    @fecha_ingreso    DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.guardaparques WHERE id_guardaparques = @id_guardaparques)
        SET @errores = @errores + '- No existe el guardaparques indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM rrhh.guardaparques WHERE id_guardaparques = @id_guardaparques AND activo = 1)
        SET @errores = @errores + '- El guardaparques está inactivo y no puede ser asignado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No existe el parque indicado.' + CHAR(13);

    IF @fecha_ingreso IS NULL
        SET @errores = @errores + '- La fecha de ingreso no puede ser nula.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.asignacion_guardaparques WHERE id_guardaparques = @id_guardaparques AND fecha_egreso IS NULL)
        SET @errores = @errores + '- El guardaparques ya tiene una asignación activa. Debe registrar el egreso antes de reasignarlo.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO rrhh.asignacion_guardaparques (id_guardaparques, id_parque, fecha_ingreso)
    VALUES (@id_guardaparques, @id_parque, @fecha_ingreso);
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_asignacion_guardaparques_egreso
    @id_guardaparques INT,
    @fecha_egreso     DATE,
    @motivo_egreso    VARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores       VARCHAR(MAX) = '';
    DECLARE @id_asignacion INT;
    DECLARE @fecha_ingreso DATE;

    SELECT @id_asignacion = id_asignacion,
           @fecha_ingreso = fecha_ingreso
    FROM rrhh.asignacion_guardaparques
    WHERE id_guardaparques = @id_guardaparques AND fecha_egreso IS NULL;

    IF @id_asignacion IS NULL
        SET @errores = @errores + '- El guardaparques no tiene ninguna asignación activa.' + CHAR(13);

    IF @fecha_egreso IS NULL
        SET @errores = @errores + '- La fecha de egreso no puede ser nula.' + CHAR(13);

    IF @fecha_ingreso IS NOT NULL AND @fecha_egreso < @fecha_ingreso
        SET @errores = @errores + '- La fecha de egreso no puede ser anterior a la fecha de ingreso.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE rrhh.asignacion_guardaparques
    SET fecha_egreso = @fecha_egreso,
        motivo_egreso = @motivo_egreso
    WHERE id_asignacion = @id_asignacion;
END;
GO

-- ----------------------------------------------------------
--  rrhh.guia
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE rrhh.sp_guia_alta
    @legajo            VARCHAR(20),
    @apellido_y_nombre VARCHAR(150),
    @fecha_nacimiento  DATE,
    @email             VARCHAR(254),
    @telefono          VARCHAR(20) = NULL,
    @id_titulo         INT = NULL,
    @id_especialidad   INT,
    @id_estado_guia    INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@legajo)) = '' OR @legajo IS NULL
        SET @errores = @errores + '- El legajo no puede estar vacío.' + CHAR(13);

    IF LTRIM(RTRIM(@apellido_y_nombre)) = '' OR @apellido_y_nombre IS NULL
        SET @errores = @errores + '- El apellido y nombre no puede estar vacío.' + CHAR(13);

    IF @fecha_nacimiento IS NULL OR @fecha_nacimiento > CONVERT(date, SYSDATETIME())
        SET @errores = @errores + '- La fecha de nacimiento no puede ser mayor a la fecha actual.' + CHAR(13);

    IF LTRIM(RTRIM(@email)) = '' OR @email IS NULL
        SET @errores = @errores + '- El email no puede estar vacío.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM rrhh.especialidad WHERE id_especialidad = @id_especialidad)
        SET @errores = @errores + '- No existe la especialidad indicada.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM rrhh.estado_guia WHERE id_estado_guia = @id_estado_guia)
        SET @errores = @errores + '- No existe el estado de guía indicado.' + CHAR(13);

    IF @id_titulo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM rrhh.titulo WHERE id_titulo = @id_titulo)
        SET @errores = @errores + '- No existe el título indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.guia WHERE legajo = LTRIM(RTRIM(@legajo)))
        SET @errores = @errores + '- Ya existe un guía con ese legajo.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.guia WHERE email = LTRIM(RTRIM(@email)))
        SET @errores = @errores + '- Ya existe un guía con ese email.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO rrhh.guia (legajo, apellido_y_nombre, fecha_nacimiento, email, telefono, id_titulo, id_especialidad, id_estado_guia)
    VALUES (LTRIM(RTRIM(@legajo)), LTRIM(RTRIM(@apellido_y_nombre)), @fecha_nacimiento,
            LTRIM(RTRIM(@email)), @telefono, @id_titulo, @id_especialidad, @id_estado_guia);
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_guia_modificacion
    @id_guia           INT,
    @legajo            VARCHAR(20),
    @apellido_y_nombre VARCHAR(150),
    @fecha_nacimiento  DATE,
    @email             VARCHAR(254),
    @telefono          VARCHAR(20) = NULL,
    @id_titulo         INT = NULL,
    @id_especialidad   INT,
    @id_estado_guia    INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.guia WHERE id_guia = @id_guia)
        SET @errores = @errores + '- No existe un guía con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@legajo)) = '' OR @legajo IS NULL
        SET @errores = @errores + '- El legajo no puede estar vacío.' + CHAR(13);

    IF LTRIM(RTRIM(@apellido_y_nombre)) = '' OR @apellido_y_nombre IS NULL
        SET @errores = @errores + '- El apellido y nombre no puede estar vacío.' + CHAR(13);

    IF @fecha_nacimiento IS NULL OR @fecha_nacimiento > CONVERT(date, SYSDATETIME())
        SET @errores = @errores + '- La fecha de nacimiento no puede ser mayor a la fecha actual.' + CHAR(13);

    IF LTRIM(RTRIM(@email)) = '' OR @email IS NULL
        SET @errores = @errores + '- El email no puede estar vacío.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM rrhh.especialidad WHERE id_especialidad = @id_especialidad)
        SET @errores = @errores + '- No existe la especialidad indicada.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM rrhh.estado_guia WHERE id_estado_guia = @id_estado_guia)
        SET @errores = @errores + '- No existe el estado de guía indicado.' + CHAR(13);

    IF @id_titulo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM rrhh.titulo WHERE id_titulo = @id_titulo)
        SET @errores = @errores + '- No existe el título indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.guia WHERE legajo = LTRIM(RTRIM(@legajo)) AND id_guia <> @id_guia)
        SET @errores = @errores + '- Ya existe otro guía con ese legajo.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.guia WHERE email = LTRIM(RTRIM(@email)) AND id_guia <> @id_guia)
        SET @errores = @errores + '- Ya existe otro guía con ese email.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE rrhh.guia
    SET legajo = LTRIM(RTRIM(@legajo)),
        apellido_y_nombre = LTRIM(RTRIM(@apellido_y_nombre)),
        fecha_nacimiento = @fecha_nacimiento,
        email = LTRIM(RTRIM(@email)),
        telefono = @telefono,
        id_titulo = @id_titulo,
        id_especialidad = @id_especialidad,
        id_estado_guia = @id_estado_guia
    WHERE id_guia = @id_guia;
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_guia_baja
    @id_guia        INT,
    @id_estado_baja INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.guia WHERE id_guia = @id_guia)
        SET @errores = @errores + '- No existe un guía con el ID indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM rrhh.estado_guia WHERE id_estado_guia = @id_estado_baja)
        SET @errores = @errores + '- No existe el estado de baja indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE rrhh.guia 
    SET id_estado_guia = @id_estado_baja 
    WHERE id_guia = @id_guia;
END;
GO

-- ----------------------------------------------------------
--  rrhh.autorizacion
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE rrhh.sp_autorizacion_alta
    @id_guia           INT,
    @fecha_emision     DATE,
    @fecha_vencimiento DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM rrhh.guia WHERE id_guia = @id_guia)
        SET @errores = @errores + '- No existe el guía indicado.' + CHAR(13);

    IF @fecha_emision IS NULL
        SET @errores = @errores + '- La fecha de emisión no puede ser nula.' + CHAR(13);

    IF @fecha_vencimiento IS NULL
        SET @errores = @errores + '- La fecha de vencimiento no puede ser nula.' + CHAR(13);

    IF @fecha_vencimiento < @fecha_emision
        SET @errores = @errores + '- La fecha de vencimiento no puede ser anterior a la de emisión.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM rrhh.autorizacion WHERE id_guia = @id_guia AND fecha_emision = @fecha_emision)
        SET @errores = @errores + '- Ya existe una autorización para este guía con la misma fecha de emisión.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO rrhh.autorizacion (id_guia, fecha_emision, fecha_vencimiento)
    VALUES (@id_guia, @fecha_emision, @fecha_vencimiento);
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_autorizacion_modificacion
    @id_autorizacion   INT,
    @fecha_vencimiento DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores       VARCHAR(MAX) = '';
    DECLARE @fecha_emision DATE;

    SELECT @fecha_emision = fecha_emision FROM rrhh.autorizacion WHERE id_autorizacion = @id_autorizacion;

    IF @fecha_emision IS NULL
        SET @errores = @errores + '- No existe una autorización con el ID indicado.' + CHAR(13);

    IF @fecha_vencimiento IS NULL
        SET @errores = @errores + '- La fecha de vencimiento no puede ser nula.' + CHAR(13);

    IF @fecha_emision IS NOT NULL AND @fecha_vencimiento < @fecha_emision
        SET @errores = @errores + '- La fecha de vencimiento no puede ser anterior a la de emisión.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE rrhh.autorizacion
    SET fecha_vencimiento = @fecha_vencimiento
    WHERE id_autorizacion = @id_autorizacion;
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_autorizacion_baja
    @id_autorizacion INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM rrhh.autorizacion WHERE id_autorizacion = @id_autorizacion)
    BEGIN
        RAISERROR('- No existe una autorización con el ID indicado.', 16, 1);
        RETURN;
    END;

    DELETE FROM rrhh.autorizacion WHERE id_autorizacion = @id_autorizacion;
END;
GO

---Revisar!!!!!!!!!

USE BD_Parques_Nacionales;
GO

-- ============================================================
--  ESQUEMA: ventas
-- ============================================================

-- ----------------------------------------------------------
--  ventas.punto_venta
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_punto_venta_alta
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción del punto de venta no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.punto_venta WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe un punto de venta con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO ventas.punto_venta (descripcion) VALUES (LTRIM(RTRIM(@descripcion)));
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_punto_venta_modificacion
    @id_punto_venta INT,
    @descripcion    VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.punto_venta WHERE id_punto_venta = @id_punto_venta)
        SET @errores = @errores + '- No existe un punto de venta con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.punto_venta WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_punto_venta <> @id_punto_venta)
        SET @errores = @errores + '- Ya existe otro punto de venta con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE ventas.punto_venta SET descripcion = LTRIM(RTRIM(@descripcion)) WHERE id_punto_venta = @id_punto_venta;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_punto_venta_baja
    @id_punto_venta INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.punto_venta WHERE id_punto_venta = @id_punto_venta)
        SET @errores = @errores + '- No existe un punto de venta con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.venta WHERE id_punto_venta = @id_punto_venta)
        SET @errores = @errores + '- No se puede eliminar: existen ventas asociadas a este punto de venta.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM ventas.punto_venta WHERE id_punto_venta = @id_punto_venta;
END;
GO

-- ----------------------------------------------------------
--  ventas.forma_pago
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_forma_pago_alta
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción de la forma de pago no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.forma_pago WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe una forma de pago con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO ventas.forma_pago (descripcion) VALUES (LTRIM(RTRIM(@descripcion)));
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_forma_pago_modificacion
    @id_forma_pago INT,
    @descripcion   VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.forma_pago WHERE id_forma_pago = @id_forma_pago)
        SET @errores = @errores + '- No existe una forma de pago con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.forma_pago WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_forma_pago <> @id_forma_pago)
        SET @errores = @errores + '- Ya existe otra forma de pago con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE ventas.forma_pago SET descripcion = LTRIM(RTRIM(@descripcion)) WHERE id_forma_pago = @id_forma_pago;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_forma_pago_baja
    @id_forma_pago INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.forma_pago WHERE id_forma_pago = @id_forma_pago)
        SET @errores = @errores + '- No existe una forma de pago con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.pago WHERE id_forma_pago = @id_forma_pago)
        SET @errores = @errores + '- No se puede eliminar: existen pagos asociados a esta forma de pago.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM ventas.forma_pago WHERE id_forma_pago = @id_forma_pago;
END;
GO

-- ----------------------------------------------------------
--  ventas.clima
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_clima_alta
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción del clima no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.clima WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe un registro de clima con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO ventas.clima (descripcion) VALUES (LTRIM(RTRIM(@descripcion)));
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_clima_modificacion
    @id_clima    INT,
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.clima WHERE id_clima = @id_clima)
        SET @errores = @errores + '- No existe un registro de clima con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.clima WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_clima <> @id_clima)
        SET @errores = @errores + '- Ya existe otro clima con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE ventas.clima SET descripcion = LTRIM(RTRIM(@descripcion)) WHERE id_clima = @id_clima;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_clima_baja
    @id_clima INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.clima WHERE id_clima = @id_clima)
        SET @errores = @errores + '- No existe un registro de clima con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.pase_entrada WHERE id_clima = @id_clima)
        SET @errores = @errores + '- No se puede eliminar: existen pases de entrada asociados a este clima.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM ventas.clima WHERE id_clima = @id_clima;
END;
GO

-- ----------------------------------------------------------
--  ventas.tipo_moneda
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_tipo_moneda_alta
    @descripcion VARCHAR(100),
    @valor       DECIMAL(18,6)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF @valor <= 0
        SET @errores = @errores + '- El valor de la moneda debe ser mayor a cero.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.tipo_moneda WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe un tipo de moneda con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO ventas.tipo_moneda (descripcion, valor, fecha_hora_valor) VALUES (LTRIM(RTRIM(@descripcion)), @valor, SYSDATETIME());
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_tipo_moneda_modificacion
    @id_tipo_moneda INT,
    @descripcion    VARCHAR(100),
    @valor          DECIMAL(18,6)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.tipo_moneda WHERE id_tipo_moneda = @id_tipo_moneda)
        SET @errores = @errores + '- No existe un tipo de moneda con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF @valor <= 0
        SET @errores = @errores + '- El valor de la moneda debe ser mayor a cero.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.tipo_moneda WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_tipo_moneda <> @id_tipo_moneda)
        SET @errores = @errores + '- Ya existe otro tipo de moneda con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE ventas.tipo_moneda 
    SET descripcion = LTRIM(RTRIM(@descripcion)), 
        valor = @valor,
        fecha_hora_valor = SYSDATETIME()
    WHERE id_tipo_moneda = @id_tipo_moneda;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_tipo_moneda_baja
    @id_tipo_moneda INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.tipo_moneda WHERE id_tipo_moneda = @id_tipo_moneda)
        SET @errores = @errores + '- No existe un tipo de moneda con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.pago WHERE id_tipo_moneda = @id_tipo_moneda)
        SET @errores = @errores + '- No se puede eliminar: existen pagos asociados a este tipo de moneda.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM ventas.tipo_moneda WHERE id_tipo_moneda = @id_tipo_moneda;
END;
GO

-- ----------------------------------------------------------
--  ventas.actividad_programada
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_actividad_programada_alta
    @fecha_hora             DATETIME2(0),
    @id_actividad_turistica INT,
    @id_guia                INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF @fecha_hora IS NULL OR @fecha_hora < SYSDATETIME()
        SET @errores = @errores + '- La fecha y hora de la actividad debe ser actual o futura.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.actividad_turistica WHERE id_actividad_turistica = @id_actividad_turistica)
        SET @errores = @errores + '- No existe la actividad turística indicada.' + CHAR(13);

    IF @id_guia IS NOT NULL AND NOT EXISTS (SELECT 1 FROM rrhh.guia WHERE id_guia = @id_guia)
        SET @errores = @errores + '- No existe el guía indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO ventas.actividad_programada (fecha_hora, id_actividad_turistica, id_guia) VALUES (@fecha_hora, @id_actividad_turistica, @id_guia);
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_actividad_programada_modificacion
    @id_actividad_programada INT,
    @fecha_hora              DATETIME2(0),
    @id_actividad_turistica  INT,
    @id_guia                 INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.actividad_programada WHERE id_actividad_programada = @id_actividad_programada)
        SET @errores = @errores + '- No existe una actividad programada con el ID indicado.' + CHAR(13);

    IF @fecha_hora IS NULL OR @fecha_hora < SYSDATETIME()
        SET @errores = @errores + '- La fecha y hora de la actividad debe ser actual o futura.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.actividad_turistica WHERE id_actividad_turistica = @id_actividad_turistica)
        SET @errores = @errores + '- No existe la actividad turística indicada.' + CHAR(13);

    IF @id_guia IS NOT NULL AND NOT EXISTS (SELECT 1 FROM rrhh.guia WHERE id_guia = @id_guia)
        SET @errores = @errores + '- No existe el guía indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE ventas.actividad_programada 
    SET fecha_hora = @fecha_hora,
        id_actividad_turistica = @id_actividad_turistica,
        id_guia = @id_guia
    WHERE id_actividad_programada = @id_actividad_programada;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_actividad_programada_baja
    @id_actividad_programada INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.actividad_programada WHERE id_actividad_programada = @id_actividad_programada)
        SET @errores = @errores + '- No existe una actividad programada con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.pase_actividad WHERE id_actividad_programada = @id_actividad_programada)
        SET @errores = @errores + '- No se puede eliminar: existen pases de actividad vendidos para esta programación.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM ventas.actividad_programada WHERE id_actividad_programada = @id_actividad_programada;
END;
GO

-- ----------------------------------------------------------
--  ventas.pago
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_pago_alta
    @monto          DECIMAL(12,2),
    @id_tipo_moneda INT,
    @id_forma_pago  INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF @monto <= 0
        SET @errores = @errores + '- El monto del pago debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.tipo_moneda WHERE id_tipo_moneda = @id_tipo_moneda)
        SET @errores = @errores + '- No existe el tipo de moneda indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.forma_pago WHERE id_forma_pago = @id_forma_pago)
        SET @errores = @errores + '- No existe la forma de pago indicada.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO ventas.pago (fecha_hora, monto, id_tipo_moneda, id_forma_pago) VALUES (SYSDATETIME(), @monto, @id_tipo_moneda, @id_forma_pago);
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_pago_modificacion
    @id_pago        INT,
    @monto          DECIMAL(12,2),
    @id_tipo_moneda INT,
    @id_forma_pago  INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.pago WHERE id_pago = @id_pago)
        SET @errores = @errores + '- No existe un pago con el ID indicado.' + CHAR(13);

    IF @monto <= 0
        SET @errores = @errores + '- El monto del pago debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.tipo_moneda WHERE id_tipo_moneda = @id_tipo_moneda)
        SET @errores = @errores + '- No existe el tipo de moneda indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.forma_pago WHERE id_forma_pago = @id_forma_pago)
        SET @errores = @errores + '- No existe la forma de pago indicada.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE ventas.pago 
    SET monto = @monto,
        id_tipo_moneda = @id_tipo_moneda,
        id_forma_pago = @id_forma_pago
    WHERE id_pago = @id_pago;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_pago_baja
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.pago WHERE id_pago = @id_pago)
        SET @errores = @errores + '- No existe un pago con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.venta WHERE id_pago = @id_pago)
        SET @errores = @errores + '- No se puede eliminar: existe una venta asociada a este pago.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM ventas.pago WHERE id_pago = @id_pago;
END;
GO

-- ----------------------------------------------------------
--  ventas.venta
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_venta_alta
    @total          DECIMAL(12,2),
    @id_punto_venta INT,
    @id_parque      INT,
    @id_pago        INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF @total < 0
        SET @errores = @errores + '- El total de la venta no puede ser negativo.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.punto_venta WHERE id_punto_venta = @id_punto_venta)
        SET @errores = @errores + '- No existe el punto de venta indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No existe el parque indicado.' + CHAR(13);

    IF @id_pago IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ventas.pago WHERE id_pago = @id_pago)
        SET @errores = @errores + '- No existe el registro de pago indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO ventas.venta (fecha_hora, total, id_punto_venta, id_parque, id_pago) VALUES (SYSDATETIME(), @total, @id_punto_venta, @id_parque, @id_pago);
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_venta_modificacion
    @id_venta       INT,
    @total          DECIMAL(12,2),
    @id_punto_venta INT,
    @id_parque      INT,
    @id_pago        INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE id_venta = @id_venta)
        SET @errores = @errores + '- No existe una venta con el ID indicado.' + CHAR(13);

    IF @total < 0
        SET @errores = @errores + '- El total de la venta no puede ser negativo.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.punto_venta WHERE id_punto_venta = @id_punto_venta)
        SET @errores = @errores + '- No existe el punto de venta indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No existe el parque indicado.' + CHAR(13);

    IF @id_pago IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ventas.pago WHERE id_pago = @id_pago)
        SET @errores = @errores + '- No existe el registro de pago indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE ventas.venta 
    SET total = @total,
        id_punto_venta = @id_punto_venta,
        id_parque = @id_parque,
        id_pago = @id_pago
    WHERE id_venta = @id_venta;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_venta_baja
    @id_venta INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE id_venta = @id_venta)
        SET @errores = @errores + '- No existe una venta con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.detalle_venta WHERE id_venta = @id_venta)
        SET @errores = @errores + '- No se puede eliminar: existen detalles asociados a esta venta.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM ventas.venta WHERE id_venta = @id_venta;
END;
GO

-- ----------------------------------------------------------
--  ventas.detalle_venta
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_detalle_venta_alta
    @cantidad        SMALLINT,
    @precio_unitario DECIMAL(12,2),
    @id_venta        INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF @cantidad <= 0
        SET @errores = @errores + '- La cantidad debe ser mayor a cero.' + CHAR(13);

    IF @precio_unitario < 0
        SET @errores = @errores + '- El precio unitario no puede ser negativo.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE id_venta = @id_venta)
        SET @errores = @errores + '- No existe la venta indicada.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO ventas.detalle_venta (cantidad, precio_unitario, id_venta) VALUES (@cantidad, @precio_unitario, @id_venta);
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_detalle_venta_modificacion
    @id_detalle_venta INT,
    @cantidad         SMALLINT,
    @precio_unitario  DECIMAL(12,2),
    @id_venta         INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.detalle_venta WHERE id_detalle_venta = @id_detalle_venta)
        SET @errores = @errores + '- No existe un detalle de venta con el ID indicado.' + CHAR(13);

    IF @cantidad <= 0
        SET @errores = @errores + '- La cantidad debe ser mayor a cero.' + CHAR(13);

    IF @precio_unitario < 0
        SET @errores = @errores + '- El precio unitario no puede ser negativo.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.venta WHERE id_venta = @id_venta)
        SET @errores = @errores + '- No existe la venta indicada.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE ventas.detalle_venta 
    SET cantidad = @cantidad,
        precio_unitario = @precio_unitario,
        id_venta = @id_venta
    WHERE id_detalle_venta = @id_detalle_venta;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_detalle_venta_baja
    @id_detalle_venta INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.detalle_venta WHERE id_detalle_venta = @id_detalle_venta)
        SET @errores = @errores + '- No existe un detalle de venta con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.pase_entrada WHERE id_detalle_venta = @id_detalle_venta) OR 
       EXISTS (SELECT 1 FROM ventas.pase_actividad WHERE id_detalle_venta = @id_detalle_venta)
        SET @errores = @errores + '- No se puede eliminar: el detalle está vinculado a un pase de entrada o de actividad.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM ventas.detalle_venta WHERE id_detalle_venta = @id_detalle_venta;
END;
GO

-- ----------------------------------------------------------
--  ventas.pase_entrada
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_pase_entrada_alta
    @id_detalle_venta INT,
    @fecha_acceso     DATE,
    @id_entrada       INT,
    @id_clima         INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.detalle_venta WHERE id_detalle_venta = @id_detalle_venta)
        SET @errores = @errores + '- No existe el detalle de venta indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.pase_entrada WHERE id_detalle_venta = @id_detalle_venta)
        SET @errores = @errores + '- Ya existe un pase de entrada asociado a ese detalle de venta.' + CHAR(13);

    IF @fecha_acceso IS NULL OR @fecha_acceso < CONVERT(date, SYSDATETIME())
        SET @errores = @errores + '- La fecha de acceso debe ser actual o futura.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.entrada WHERE id_entrada = @id_entrada)
        SET @errores = @errores + '- No existe la entrada indicada.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.clima WHERE id_clima = @id_clima)
        SET @errores = @errores + '- No existe el clima indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO ventas.pase_entrada (id_detalle_venta, fecha_acceso, id_entrada, id_clima) 
    VALUES (@id_detalle_venta, @fecha_acceso, @id_entrada, @id_clima);
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_pase_entrada_modificacion
    @id_detalle_venta INT,
    @fecha_acceso     DATE,
    @id_entrada       INT,
    @id_clima         INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.pase_entrada WHERE id_detalle_venta = @id_detalle_venta)
        SET @errores = @errores + '- No existe un pase de entrada para el detalle de venta indicado.' + CHAR(13);

    IF @fecha_acceso IS NULL OR @fecha_acceso < CONVERT(date, SYSDATETIME())
        SET @errores = @errores + '- La fecha de acceso debe ser actual o futura.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.entrada WHERE id_entrada = @id_entrada)
        SET @errores = @errores + '- No existe la entrada indicada.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.clima WHERE id_clima = @id_clima)
        SET @errores = @errores + '- No existe el clima indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE ventas.pase_entrada 
    SET fecha_acceso = @fecha_acceso,
        id_entrada = @id_entrada,
        id_clima = @id_clima
    WHERE id_detalle_venta = @id_detalle_venta;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_pase_entrada_baja
    @id_detalle_venta INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM ventas.pase_entrada WHERE id_detalle_venta = @id_detalle_venta)
    BEGIN
        RAISERROR('- No existe un pase de entrada para el detalle indicado.', 16, 1);
        RETURN;
    END;

    DELETE FROM ventas.pase_entrada WHERE id_detalle_venta = @id_detalle_venta;
END;
GO

-- ----------------------------------------------------------
--  ventas.pase_actividad
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_pase_actividad_alta
    @id_detalle_venta        INT,
    @id_actividad_programada INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.detalle_venta WHERE id_detalle_venta = @id_detalle_venta)
        SET @errores = @errores + '- No existe el detalle de venta indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ventas.pase_actividad WHERE id_detalle_venta = @id_detalle_venta)
        SET @errores = @errores + '- Ya existe un pase de actividad asociado a ese detalle de venta.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.actividad_programada WHERE id_actividad_programada = @id_actividad_programada)
        SET @errores = @errores + '- No existe la actividad programada indicada.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO ventas.pase_actividad (id_detalle_venta, id_actividad_programada) 
    VALUES (@id_detalle_venta, @id_actividad_programada);
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_pase_actividad_modificacion
    @id_detalle_venta        INT,
    @id_actividad_programada INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ventas.pase_actividad WHERE id_detalle_venta = @id_detalle_venta)
        SET @errores = @errores + '- No existe un pase de actividad para el detalle de venta indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ventas.actividad_programada WHERE id_actividad_programada = @id_actividad_programada)
        SET @errores = @errores + '- No existe la actividad programada indicada.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE ventas.pase_actividad 
    SET id_actividad_programada = @id_actividad_programada
    WHERE id_detalle_venta = @id_detalle_venta;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_pase_actividad_baja
    @id_detalle_venta INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM ventas.pase_actividad WHERE id_detalle_venta = @id_detalle_venta)
    BEGIN
        RAISERROR('- No existe un pase de actividad para el detalle indicado.', 16, 1);
        RETURN;
    END;

    DELETE FROM ventas.pase_actividad WHERE id_detalle_venta = @id_detalle_venta;
END;
GO

USE BD_Parques_Nacionales;
GO

-- ============================================================
--  ESQUEMA: concesiones
-- ============================================================

-- ----------------------------------------------------------
--  concesiones.empresa
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE concesiones.sp_empresa_alta
    @nombre    VARCHAR(150),
    @direccion VARCHAR(200),
    @telefono  VARCHAR(20) = NULL,
    @email     VARCHAR(254)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@nombre)) = '' OR @nombre IS NULL
        SET @errores = @errores + '- El nombre de la empresa no puede estar vacío.' + CHAR(13);

    IF LTRIM(RTRIM(@direccion)) = '' OR @direccion IS NULL
        SET @errores = @errores + '- La dirección no puede estar vacía.' + CHAR(13);

    IF LTRIM(RTRIM(@email)) = '' OR @email IS NULL
        SET @errores = @errores + '- El email no puede estar vacío.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.empresa WHERE nombre = LTRIM(RTRIM(@nombre)))
        SET @errores = @errores + '- Ya existe una empresa con ese nombre.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.empresa WHERE email = LTRIM(RTRIM(@email)))
        SET @errores = @errores + '- Ya existe una empresa con ese email.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO concesiones.empresa (nombre, direccion, telefono, email) 
    VALUES (LTRIM(RTRIM(@nombre)), LTRIM(RTRIM(@direccion)), LTRIM(RTRIM(@telefono)), LTRIM(RTRIM(@email)));
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_empresa_modificacion
    @id_empresa INT,
    @nombre     VARCHAR(150),
    @direccion  VARCHAR(200),
    @telefono   VARCHAR(20) = NULL,
    @email      VARCHAR(254)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM concesiones.empresa WHERE id_empresa = @id_empresa)
        SET @errores = @errores + '- No existe una empresa con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@nombre)) = '' OR @nombre IS NULL
        SET @errores = @errores + '- El nombre de la empresa no puede estar vacío.' + CHAR(13);

    IF LTRIM(RTRIM(@direccion)) = '' OR @direccion IS NULL
        SET @errores = @errores + '- La dirección no puede estar vacía.' + CHAR(13);

    IF LTRIM(RTRIM(@email)) = '' OR @email IS NULL
        SET @errores = @errores + '- El email no puede estar vacío.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.empresa WHERE nombre = LTRIM(RTRIM(@nombre)) AND id_empresa <> @id_empresa)
        SET @errores = @errores + '- Ya existe otra empresa con ese nombre.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.empresa WHERE email = LTRIM(RTRIM(@email)) AND id_empresa <> @id_empresa)
        SET @errores = @errores + '- Ya existe otra empresa con ese email.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE concesiones.empresa 
    SET nombre = LTRIM(RTRIM(@nombre)),
        direccion = LTRIM(RTRIM(@direccion)),
        telefono = LTRIM(RTRIM(@telefono)),
        email = LTRIM(RTRIM(@email))
    WHERE id_empresa = @id_empresa;
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_empresa_baja
    @id_empresa INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM concesiones.empresa WHERE id_empresa = @id_empresa)
        SET @errores = @errores + '- No existe una empresa con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.contrato_concesion WHERE id_empresa = @id_empresa)
        SET @errores = @errores + '- No se puede eliminar: la empresa tiene contratos de concesión asociados.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM concesiones.empresa WHERE id_empresa = @id_empresa;
END;
GO

-- ----------------------------------------------------------
--  concesiones.tipo_actividad_concesion
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE concesiones.sp_tipo_actividad_concesion_alta
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.tipo_actividad_concesion WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe un tipo de actividad de concesión con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO concesiones.tipo_actividad_concesion (descripcion) VALUES (LTRIM(RTRIM(@descripcion)));
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_tipo_actividad_concesion_modificacion
    @id_tipo_actividad_concesion INT,
    @descripcion                 VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM concesiones.tipo_actividad_concesion WHERE id_tipo_actividad_concesion = @id_tipo_actividad_concesion)
        SET @errores = @errores + '- No existe un tipo de actividad con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.tipo_actividad_concesion WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_tipo_actividad_concesion <> @id_tipo_actividad_concesion)
        SET @errores = @errores + '- Ya existe otro tipo de actividad con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE concesiones.tipo_actividad_concesion SET descripcion = LTRIM(RTRIM(@descripcion)) 
    WHERE id_tipo_actividad_concesion = @id_tipo_actividad_concesion;
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_tipo_actividad_concesion_baja
    @id_tipo_actividad_concesion INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM concesiones.tipo_actividad_concesion WHERE id_tipo_actividad_concesion = @id_tipo_actividad_concesion)
        SET @errores = @errores + '- No existe un tipo de actividad con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.contrato_concesion WHERE id_tipo_actividad_concesion = @id_tipo_actividad_concesion)
        SET @errores = @errores + '- No se puede eliminar: existen contratos asociados a este tipo de actividad.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM concesiones.tipo_actividad_concesion WHERE id_tipo_actividad_concesion = @id_tipo_actividad_concesion;
END;
GO

-- ----------------------------------------------------------
--  concesiones.estado_canon
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE concesiones.sp_estado_canon_alta
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción del estado no puede estar vacía.' + CHAR(13);

    IF @descripcion NOT IN ('Pendiente', 'Pagado', 'Vencido', 'Anulado')
        SET @errores = @errores + '- La descripción debe ser Pendiente, Pagado, Vencido o Anulado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.estado_canon WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = @errores + '- Ya existe un estado de canon con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO concesiones.estado_canon (descripcion) VALUES (LTRIM(RTRIM(@descripcion)));
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_estado_canon_modificacion
    @id_estado_canon INT,
    @descripcion     VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM concesiones.estado_canon WHERE id_estado_canon = @id_estado_canon)
        SET @errores = @errores + '- No existe un estado con el ID indicado.' + CHAR(13);

    IF LTRIM(RTRIM(@descripcion)) = '' OR @descripcion IS NULL
        SET @errores = @errores + '- La descripción no puede estar vacía.' + CHAR(13);

    IF @descripcion NOT IN ('Pendiente', 'Pagado', 'Vencido', 'Anulado')
        SET @errores = @errores + '- La descripción debe ser Pendiente, Pagado, Vencido o Anulado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.estado_canon WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_estado_canon <> @id_estado_canon)
        SET @errores = @errores + '- Ya existe otro estado con esa descripción.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE concesiones.estado_canon SET descripcion = LTRIM(RTRIM(@descripcion)) WHERE id_estado_canon = @id_estado_canon;
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_estado_canon_baja
    @id_estado_canon INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM concesiones.estado_canon WHERE id_estado_canon = @id_estado_canon)
        SET @errores = @errores + '- No existe un estado con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.canon WHERE id_estado_canon = @id_estado_canon)
        SET @errores = @errores + '- No se puede eliminar: existen cánones asociados a este estado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM concesiones.estado_canon WHERE id_estado_canon = @id_estado_canon;
END;
GO

-- ----------------------------------------------------------
--  concesiones.contrato_concesion
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE concesiones.sp_contrato_concesion_alta
    @fecha_inicio                DATE,
    @fecha_fin                   DATE,
    @monto_mensual               DECIMAL(25,2),
    @id_empresa                  INT,
    @id_tipo_actividad_concesion INT,
    @id_parque                   INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF @fecha_inicio IS NULL OR @fecha_fin IS NULL
        SET @errores = @errores + '- Las fechas del contrato no pueden ser nulas.' + CHAR(13);
    ELSE IF @fecha_fin < @fecha_inicio
        SET @errores = @errores + '- La fecha de finalización no puede ser anterior a la de inicio.' + CHAR(13);

    IF @monto_mensual <= 0
        SET @errores = @errores + '- El monto mensual debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM concesiones.empresa WHERE id_empresa = @id_empresa)
        SET @errores = @errores + '- No existe la empresa indicada.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM concesiones.tipo_actividad_concesion WHERE id_tipo_actividad_concesion = @id_tipo_actividad_concesion)
        SET @errores = @errores + '- No existe el tipo de actividad indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No existe el parque indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO concesiones.contrato_concesion (fecha_inicio, fecha_fin, monto_mensual, id_empresa, id_tipo_actividad_concesion, id_parque) 
    VALUES (@fecha_inicio, @fecha_fin, @monto_mensual, @id_empresa, @id_tipo_actividad_concesion, @id_parque);
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_contrato_concesion_modificacion
    @id_contrato_concesion       INT,
    @fecha_inicio                DATE,
    @fecha_fin                   DATE,
    @monto_mensual               DECIMAL(25,2),
    @id_empresa                  INT,
    @id_tipo_actividad_concesion INT,
    @id_parque                   INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM concesiones.contrato_concesion WHERE id_contrato_concesion = @id_contrato_concesion)
        SET @errores = @errores + '- No existe un contrato con el ID indicado.' + CHAR(13);

    IF @fecha_inicio IS NULL OR @fecha_fin IS NULL
        SET @errores = @errores + '- Las fechas del contrato no pueden ser nulas.' + CHAR(13);
    ELSE IF @fecha_fin < @fecha_inicio
        SET @errores = @errores + '- La fecha de finalización no puede ser anterior a la de inicio.' + CHAR(13);

    IF @monto_mensual <= 0
        SET @errores = @errores + '- El monto mensual debe ser mayor a cero.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM concesiones.empresa WHERE id_empresa = @id_empresa)
        SET @errores = @errores + '- No existe la empresa indicada.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM concesiones.tipo_actividad_concesion WHERE id_tipo_actividad_concesion = @id_tipo_actividad_concesion)
        SET @errores = @errores + '- No existe el tipo de actividad indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @id_parque)
        SET @errores = @errores + '- No existe el parque indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE concesiones.contrato_concesion 
    SET fecha_inicio = @fecha_inicio,
        fecha_fin = @fecha_fin,
        monto_mensual = @monto_mensual,
        id_empresa = @id_empresa,
        id_tipo_actividad_concesion = @id_tipo_actividad_concesion,
        id_parque = @id_parque
    WHERE id_contrato_concesion = @id_contrato_concesion;
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_contrato_concesion_baja
    @id_contrato_concesion INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM concesiones.contrato_concesion WHERE id_contrato_concesion = @id_contrato_concesion)
        SET @errores = @errores + '- No existe un contrato con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.canon WHERE id_contrato_concesion = @id_contrato_concesion)
        SET @errores = @errores + '- No se puede eliminar: el contrato tiene cánones generados asociados.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM concesiones.contrato_concesion WHERE id_contrato_concesion = @id_contrato_concesion;
END;
GO

-- ----------------------------------------------------------
--  concesiones.canon
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE concesiones.sp_canon_alta
    @fecha_vencimiento     DATE,
    @importe               DECIMAL(25,2),
    @id_contrato_concesion INT,
    @id_estado_canon       INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF @importe <= 0
        SET @errores = @errores + '- El importe del canon debe ser mayor a cero.' + CHAR(13);

    IF @fecha_vencimiento IS NULL
        SET @errores = @errores + '- La fecha de vencimiento no puede ser nula.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM concesiones.contrato_concesion WHERE id_contrato_concesion = @id_contrato_concesion)
        SET @errores = @errores + '- No existe el contrato indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM concesiones.estado_canon WHERE id_estado_canon = @id_estado_canon)
        SET @errores = @errores + '- No existe el estado indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.canon WHERE id_contrato_concesion = @id_contrato_concesion AND fecha_vencimiento = @fecha_vencimiento)
        SET @errores = @errores + '- Ya existe un canon para este contrato con la misma fecha de vencimiento.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO concesiones.canon (fecha_vencimiento, importe, id_contrato_concesion, id_estado_canon) 
    VALUES (@fecha_vencimiento, @importe, @id_contrato_concesion, @id_estado_canon);
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_canon_modificacion
    @id_canon              INT,
    @fecha_vencimiento     DATE,
    @importe               DECIMAL(25,2),
    @id_contrato_concesion INT,
    @id_estado_canon       INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM concesiones.canon WHERE id_canon = @id_canon)
        SET @errores = @errores + '- No existe un canon con el ID indicado.' + CHAR(13);

    IF @importe <= 0
        SET @errores = @errores + '- El importe del canon debe ser mayor a cero.' + CHAR(13);

    IF @fecha_vencimiento IS NULL
        SET @errores = @errores + '- La fecha de vencimiento no puede ser nula.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM concesiones.contrato_concesion WHERE id_contrato_concesion = @id_contrato_concesion)
        SET @errores = @errores + '- No existe el contrato indicado.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM concesiones.estado_canon WHERE id_estado_canon = @id_estado_canon)
        SET @errores = @errores + '- No existe el estado indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.canon WHERE id_contrato_concesion = @id_contrato_concesion AND fecha_vencimiento = @fecha_vencimiento AND id_canon <> @id_canon)
        SET @errores = @errores + '- Ya existe otro canon para este contrato con la misma fecha de vencimiento.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE concesiones.canon 
    SET fecha_vencimiento = @fecha_vencimiento,
        importe = @importe,
        id_contrato_concesion = @id_contrato_concesion,
        id_estado_canon = @id_estado_canon
    WHERE id_canon = @id_canon;
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_canon_baja
    @id_canon INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM concesiones.canon WHERE id_canon = @id_canon)
        SET @errores = @errores + '- No existe un canon con el ID indicado.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM concesiones.pago_canon WHERE id_canon = @id_canon)
        SET @errores = @errores + '- No se puede eliminar: el canon tiene pagos registrados.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    DELETE FROM concesiones.canon WHERE id_canon = @id_canon;
END;
GO

-- ----------------------------------------------------------
--  concesiones.pago_canon
-- ----------------------------------------------------------

CREATE OR ALTER PROCEDURE concesiones.sp_pago_canon_alta
    @monto    DECIMAL(25,2),
    @id_canon INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF @monto < 0
        SET @errores = @errores + '- El monto del pago no puede ser negativo.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM concesiones.canon WHERE id_canon = @id_canon)
        SET @errores = @errores + '- No existe el canon indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    INSERT INTO concesiones.pago_canon (fecha_hora, monto, id_canon) 
    VALUES (SYSDATETIME(), @monto, @id_canon);
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_pago_canon_modificacion
    @id_pago  INT,
    @monto    DECIMAL(25,2),
    @id_canon INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores VARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM concesiones.pago_canon WHERE id_pago = @id_pago)
        SET @errores = @errores + '- No existe un pago con el ID indicado.' + CHAR(13);

    IF @monto < 0
        SET @errores = @errores + '- El monto del pago no puede ser negativo.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM concesiones.canon WHERE id_canon = @id_canon)
        SET @errores = @errores + '- No existe el canon indicado.' + CHAR(13);

    IF @errores <> ''
    BEGIN
        RAISERROR(@errores, 16, 1);
        RETURN;
    END;

    UPDATE concesiones.pago_canon 
    SET monto = @monto,
        id_canon = @id_canon
    WHERE id_pago = @id_pago;
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_pago_canon_baja
    @id_pago INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM concesiones.pago_canon WHERE id_pago = @id_pago)
    BEGIN
        RAISERROR('- No existe un pago con el ID indicado.', 16, 1);
        RETURN;
    END;

    DELETE FROM concesiones.pago_canon WHERE id_pago = @id_pago;
END;
GO