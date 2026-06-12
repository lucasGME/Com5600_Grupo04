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

    IF EXISTS (SELECT 1 FROM ventas.entrada WHERE id_tipo_visitante = @id_tipo_visitante)
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