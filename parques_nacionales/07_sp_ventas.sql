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

Script de creación de procedimientos almacenados para gestión de ventas
- registrar venta de entrada
- programar actividad
- asignar guía a actividad programada
- registrar venta de actividad
- registrar venta completa (entrada + actividad)
*/

USE BD_Parques_Nacionales;
GO


---------------------------------------------------------------------------------------
---------- REGISTRAR VENTA ENTRADA ----------------------------------------------------
---------------------------------------------------------------------------------------

-- registro de venta entrada, detalle venta, pase entrada y pago asociado

CREATE OR ALTER PROCEDURE ventas.sp_registrar_venta_entrada
	@p_id_parque INT,
	@p_id_punto_venta INT,
	@p_id_tipo_moneda INT,
	@p_id_forma_pago INT,
	@p_id_entrada INT,
	@p_id_clima INT,
	@p_cantidad SMALLINT,
	@p_fecha_acceso DATE,
	@p_id_venta INT OUTPUT,
	@p_id_pago INT OUTPUT,
	@p_id_detalle_venta INT OUTPUT
AS
BEGIN
	BEGIN TRY
		DECLARE @ERRORES VARCHAR(1000) = '';
		DECLARE @v_precio_base DECIMAL(12, 2);
		DECLARE @v_descuento DECIMAL(5, 2);
		DECLARE @v_precio_unitario DECIMAL(12, 2);
		DECLARE @v_cotizacion DECIMAL(18, 6);
		DECLARE @v_monto_venta DECIMAL(12, 2);
		DECLARE @v_monto_pago DECIMAL(12, 2);

		-- Validar cantidad positiva
		IF @p_cantidad <= 0
		BEGIN
			SET @ERRORES += 'La cantidad de entradas debe ser mayor a cero.' + CHAR(13) + CHAR(10);
		END;

		-- Validar fecha de acceso no sea anterior a hoy
		IF @p_fecha_acceso < CONVERT(DATE, SYSDATETIME())
		BEGIN
			SET @ERRORES += 'La fecha de acceso no puede ser anterior a hoy.' + CHAR(13) + CHAR(10);
		END;

        -- Validar clima existe
		IF NOT EXISTS (SELECT 1 FROM ventas.clima WHERE id_clima = @p_id_clima)
		BEGIN
			SET @ERRORES += 'El tipo de clima especificado no existe.' + CHAR(13) + CHAR(10);
		END;

		-- Validar parque existe
		IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @p_id_parque)
		BEGIN
			SET @ERRORES += 'El parque especificado no existe.' + CHAR(13) + CHAR(10);
		END;

		-- Validar punto de venta existe
		IF NOT EXISTS (SELECT 1 FROM ventas.punto_venta WHERE id_punto_venta = @p_id_punto_venta)
		BEGIN
			SET @ERRORES += 'El punto de venta especificado no existe.' + CHAR(13) + CHAR(10);
		END;

		-- Validar tipo de moneda existe
		IF NOT EXISTS (SELECT 1 FROM ventas.tipo_moneda WHERE id_tipo_moneda = @p_id_tipo_moneda)
		BEGIN
			SET @ERRORES += 'El tipo de moneda especificado no existe.' + CHAR(13) + CHAR(10);
		END;

		-- Validar forma de pago existe
		IF NOT EXISTS (SELECT 1 FROM ventas.forma_pago WHERE id_forma_pago = @p_id_forma_pago)
		BEGIN
			SET @ERRORES += 'La forma de pago especificada no existe.' + CHAR(13) + CHAR(10);
		END;

		-- Validar entrada existe y está vigente
		IF NOT EXISTS (SELECT 1 FROM parques.entrada
					   WHERE id_entrada = @p_id_entrada
					   AND id_parque = @p_id_parque
					   AND @p_fecha_acceso BETWEEN fecha_desde AND fecha_hasta)
		BEGIN
			SET @ERRORES += 'La entrada especificada no existe o no es válida para el parque/fecha indicados.' + CHAR(13) + CHAR(10);
		END;
		
		-- Obtener precio base de la entrada
		SELECT @v_precio_base = precio_base FROM parques.entrada WHERE id_entrada = @p_id_entrada;
		
		-- Obtener descuento vigente
		SELECT @v_descuento = ISNULL(tv.porcentaje_descuento, 0) 
							 FROM parques.tipo_visitante tv
							 JOIN parques.entrada e ON tv.id_tipo_visitante = e.id_tipo_visitante
							 WHERE e.id_entrada = @p_id_entrada;

		-- Calcular precio por unidad (considerando descuento)
		SET @v_precio_unitario = @v_precio_base * (1 - @v_descuento / 100);

		IF @ERRORES <> ''
		BEGIN
			THROW 50001, @ERRORES, 1;
		END;

		BEGIN TRANSACTION;
		-- 1. Obtener cotización de moneda
		SELECT @v_cotizacion = valor FROM ventas.tipo_moneda WHERE id_tipo_moneda = @p_id_tipo_moneda;
		
		-- 2. calcular total en moneda local (registro en ventas.venta)
		SET @v_monto_venta = @v_precio_unitario * @p_cantidad;

		-- 3. calcular total en moneda de pago (registro en ventas.pago)
		SET @v_monto_pago = @v_monto_venta / @v_cotizacion;
		
        -- 4. Crear pago
		INSERT INTO ventas.pago (monto, id_tipo_moneda, id_forma_pago)
		VALUES (@v_monto_pago, @p_id_tipo_moneda, @p_id_forma_pago);

		SET @p_id_pago = SCOPE_IDENTITY();

		-- 5. Crear venta
		INSERT INTO ventas.venta (total, id_punto_venta, id_parque, id_pago)
		VALUES (@v_monto_venta, @p_id_punto_venta, @p_id_parque, @p_id_pago);

		SET @p_id_venta = SCOPE_IDENTITY();

		-- 6. Crear detalle venta
		INSERT INTO ventas.detalle_venta (cantidad, precio_unitario, id_venta)
		VALUES (@p_cantidad, @v_precio_unitario, @p_id_venta);

		SET @p_id_detalle_venta = SCOPE_IDENTITY();

		-- 7. Crear pase entrada
		INSERT INTO ventas.pase_entrada (id_detalle_venta, fecha_acceso, id_entrada, id_clima)
		VALUES (@p_id_detalle_venta, @p_fecha_acceso, @p_id_entrada, @p_id_clima);

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH;
END;
GO


---------------------------------------------------------------------------------------
---------- PROGRAMAR ACTIVIDAD --------------------------------------------------------
---------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_programar_actividad
	@p_id_actividad_turistica INT,
	@p_fecha_hora_inicio DATETIME2(0),
	@p_id_actividad_programada INT OUTPUT
AS
BEGIN
	BEGIN TRY
		DECLARE @ERRORES VARCHAR(1000) = '';
		DECLARE @v_duracion_horas TINYINT;

		-- validar fecha/hora inicio no sea anterior a ahora
		IF @p_fecha_hora_inicio < SYSDATETIME()
		BEGIN
			SET @ERRORES += 'La fecha y hora de inicio no puede ser anterior a ahora.' + CHAR(13) + CHAR(10);
		END;

		-- Validar actividad turística existe
		IF NOT EXISTS (SELECT 1 FROM parques.actividad_turistica WHERE id_actividad_turistica = @p_id_actividad_turistica)
		BEGIN
			SET @ERRORES += 'La actividad turística especificada no existe.' + CHAR(13) + CHAR(10);
		END;

		-- obtener duración de actividad turística
		SELECT @v_duracion_horas = duracion_horas FROM parques.actividad_turistica WHERE id_actividad_turistica = @p_id_actividad_turistica;
		
		-- validar que no exista otra actividad programada para la misma actividad turística que se solape en fecha/hora
		IF EXISTS (SELECT 1 FROM ventas.actividad_programada ap
				   JOIN parques.actividad_turistica at ON ap.id_actividad_turistica = at.id_actividad_turistica
				   WHERE ap.id_actividad_turistica = @p_id_actividad_turistica
				   AND @p_fecha_hora_inicio < DATEADD(HOUR, at.duracion_horas, ap.fecha_hora)
				   AND DATEADD(HOUR, @v_duracion_horas, @p_fecha_hora_inicio) > ap.fecha_hora)
		BEGIN
			SET @ERRORES += 'Ya existe otra actividad programada para la misma actividad turística que se solapa en fecha y hora.' + CHAR(13) + CHAR(10);
		END;
		
		IF @ERRORES <> ''
		BEGIN
			THROW 50002, @ERRORES, 1;
		END;

		BEGIN TRANSACTION;
		-- 1. crear actividad programada (sin asignar guía aún)
		INSERT INTO ventas.actividad_programada (id_guia, id_actividad_turistica, fecha_hora)
		VALUES (NULL, @p_id_actividad_turistica, @p_fecha_hora_inicio);

		SET @p_id_actividad_programada = SCOPE_IDENTITY();

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH;
END;
GO


---------------------------------------------------------------------------------------
---------- ASIGNAR GUÍA A ACTIVIDAD PROGRAMADA ----------------------------------------
---------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE ventas.sp_asignar_guia_actividad_programada
	@p_id_actividad_programada INT,
	@p_id_guia INT
AS
BEGIN
	BEGIN TRY
		DECLARE @ERRORES VARCHAR(1000) = '';
		DECLARE @v_duracion_horas TINYINT;
		DECLARE @v_fecha_hora_inicio DATETIME2(0);
		DECLARE @v_fecha_hora_fin DATETIME2(0);

		-- Validar actividad programada existe
		IF NOT EXISTS (SELECT 1 FROM ventas.actividad_programada WHERE id_actividad_programada = @p_id_actividad_programada)
		BEGIN
			SET @ERRORES += 'La actividad programada especificada no existe.' + CHAR(13) + CHAR(10);
		END;


		-- validar que la actividad programada no tenga ya un guía asignado
		IF EXISTS (SELECT 1 FROM ventas.actividad_programada WHERE id_actividad_programada = @p_id_actividad_programada AND id_guia IS NOT NULL)
		BEGIN
			SET @ERRORES += 'La actividad programada ya tiene un guía asignado.' + CHAR(13) + CHAR(10);
		END;

		-- Validar guía existe y está activo
		IF NOT EXISTS (SELECT 1 FROM rrhh.guia g
					   JOIN rrhh.estado_guia eg ON g.id_estado_guia = eg.id_estado_guia
					   WHERE g.id_guia = @p_id_guia
					   AND eg.descripcion = 'Activo')
		BEGIN
			SET @ERRORES += 'El guía especificado no existe o no está activo.' + CHAR(13) + CHAR(10);
		END;

		-- validar guía tiene autorización para actividad turística
		IF NOT EXISTS (SELECT 1
					   FROM rrhh.guia g
					   JOIN rrhh.autorizacion a ON g.id_guia = a.id_guia
					   WHERE g.id_guia = @p_id_guia AND a.fecha_vencimiento > SYSDATETIME())
		BEGIN
			SET @ERRORES += 'El guía especificado no tiene autorización para la actividad turística.' + CHAR(13) + CHAR(10);
		END;


		-- Obtener duración de actividad turística
		SELECT @v_duracion_horas = at.duracion_horas FROM ventas.actividad_programada ap
									 JOIN parques.actividad_turistica at ON ap.id_actividad_turistica = at.id_actividad_turistica
									 WHERE ap.id_actividad_programada = @p_id_actividad_programada;
		

		-- obtener fecha_hora inicio de actividad programada
		SELECT @v_fecha_hora_inicio = fecha_hora FROM ventas.actividad_programada WHERE id_actividad_programada = @p_id_actividad_programada;
		
		-- obtener fecha_hora fin de actividad programada
		SET @v_fecha_hora_fin = DATEADD(HOUR, @v_duracion_horas, @v_fecha_hora_inicio);
		
		--  validar que la actividad no haya finalizado
		IF @v_fecha_hora_fin < SYSDATETIME()
		BEGIN
			SET @ERRORES += 'La actividad programada ya ha finalizado. No se pueden asignar guías a actividades finalizadas.' + CHAR(13) + CHAR(10);
		END;

		IF @ERRORES <> ''
		BEGIN
			THROW 50003, @ERRORES, 1;
		END;

		BEGIN TRANSACTION;
		-- 1. Validar guía no tiene otra actividad programada que se solape en fecha/hora
		IF EXISTS (SELECT 1 
				   FROM ventas.actividad_programada ap
				   JOIN parques.actividad_turistica at ON ap.id_actividad_turistica = at.id_actividad_turistica
				   WHERE ap.id_guia = @p_id_guia
				   AND @v_fecha_hora_inicio < DATEADD(HOUR, at.duracion_horas, ap.fecha_hora)
				   AND @v_fecha_hora_fin > ap.fecha_hora
				   )
		BEGIN
			THROW 50004, 'El guía tiene otra actividad programada que se solapa en fecha/hora.', 1;
		END;

		-- 2. Asignar guía a actividad programada
		UPDATE ventas.actividad_programada SET id_guia = @p_id_guia 
		WHERE id_actividad_programada = @p_id_actividad_programada;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH;
END; 
GO


---------------------------------------------------------------------------------------
---------- REGISTRAR VENTA ACTIVIDAD --------------------------------------------------
---------------------------------------------------------------------------------------

-- registro de venta actividad, detalle venta, pase actividad y pago asociado

CREATE OR ALTER PROCEDURE ventas.sp_registrar_venta_actividad
	@p_id_punto_venta INT,
	@p_id_tipo_moneda INT,
	@p_id_forma_pago INT,
	@p_id_actividad_programada INT,
	@p_cantidad_participantes SMALLINT,
	@p_id_venta INT OUTPUT,
	@p_id_pago INT OUTPUT,
	@p_id_detalle_venta INT OUTPUT
AS
BEGIN
	BEGIN TRY
		DECLARE @ERRORES VARCHAR(1000) = '';
		DECLARE @v_cantidad_entradas SMALLINT;
		DECLARE @v_cupo_maximo SMALLINT;
		DECLARE @v_cantidad_participantes_actual SMALLINT;
		DECLARE @v_costo DECIMAL(12, 2);
		DECLARE @v_duracion_horas TINYINT;
		DECLARE @v_cotizacion DECIMAL(18, 6);
		DECLARE @v_monto_venta DECIMAL(12, 2);
		DECLARE @v_monto_pago DECIMAL(12, 2);
		DECLARE @v_fecha_hora_inicio DATETIME2(0);
		DECLARE @v_id_parque INT;


		-- validar punto venta
		IF NOT EXISTS (SELECT 1 FROM ventas.punto_venta WHERE id_punto_venta = @p_id_punto_venta)
		BEGIN
			SET @ERRORES += 'El punto de venta especificado no existe.' + CHAR(13) + CHAR(10);
		END;

		-- validar tipo moneda
		IF NOT EXISTS (SELECT 1 FROM ventas.tipo_moneda WHERE id_tipo_moneda = @p_id_tipo_moneda)
		BEGIN
			SET @ERRORES += 'El tipo de moneda especificado no existe.' + CHAR(13) + CHAR(10);
		END;

		-- validar forma pago
		IF NOT EXISTS (SELECT 1 FROM ventas.forma_pago WHERE id_forma_pago = @p_id_forma_pago)
		BEGIN
			SET @ERRORES += 'La forma de pago especificada no existe.' + CHAR(13) + CHAR(10);
		END;

		-- validar actividad programada
		IF NOT EXISTS (SELECT 1 FROM ventas.actividad_programada WHERE id_actividad_programada = @p_id_actividad_programada)
		BEGIN
			SET @ERRORES += 'La actividad programada especificada no existe.' + CHAR(13) + CHAR(10);
		END;

		-- validar cantidad participantes positiva
		IF @p_cantidad_participantes <= 0
		BEGIN
			SET @ERRORES += 'La cantidad de participantes debe ser mayor a cero.' + CHAR(13) + CHAR(10);
		END;


		-- Obtener cupo máximo, costo y duración de actividad turística
		SELECT  @v_cupo_maximo = cupo_maximo,
				@v_costo = costo,
				@v_duracion_horas = duracion_horas 
		FROM parques.actividad_turistica at
		JOIN ventas.actividad_programada ap ON at.id_actividad_turistica = ap.id_actividad_turistica
		WHERE ap.id_actividad_programada = @p_id_actividad_programada;

		-- validar que la actividad programada no haya finalizado
		SELECT @v_fecha_hora_inicio = fecha_hora FROM ventas.actividad_programada WHERE id_actividad_programada = @p_id_actividad_programada;
		IF DATEADD(HOUR, @v_duracion_horas, @v_fecha_hora_inicio) < SYSDATETIME()
		BEGIN
			SET @ERRORES += 'La actividad programada ya ha finalizado. No se pueden contratar actividades finalizadas.' + CHAR(13) + CHAR(10);
		END;

		-- Obtener parque asociado al la actividad programada
		SELECT @v_id_parque = id_parque FROM ventas.actividad_programada ap
							  JOIN parques.actividad_turistica at ON ap.id_actividad_turistica = at.id_actividad_turistica
							  WHERE ap.id_actividad_programada = @p_id_actividad_programada;
		-- validar parque existe
		IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @v_id_parque)
		BEGIN
			SET @ERRORES += 'El parque asociado a la actividad programada no existe.' + CHAR(13) + CHAR(10);
		END;

		IF @ERRORES <> ''
		BEGIN
			THROW 50005, @ERRORES, 1;
		END;

		BEGIN TRANSACTION;
		-- 1. obtener cantidad de participantes actual de la actividad programada (sumatoria de cantidad participantes de pases actividad asociados a la actividad programada)
		SELECT @v_cantidad_participantes_actual = ISNULL(SUM(dv.cantidad), 0) FROM ventas.pase_actividad pa
		JOIN ventas.detalle_venta dv ON pa.id_detalle_venta = dv.id_detalle_venta
		WHERE pa.id_actividad_programada = @p_id_actividad_programada;

		-- 2. validar cantidad participantes menor o igual al cupo máximo de actividad turística disponible 
		IF @v_cantidad_participantes_actual + @p_cantidad_participantes > @v_cupo_maximo
		BEGIN
			THROW 50006, 'La cantidad de participantes excede el cupo máximo de la actividad turística.', 1;
		END;

		-- 3. obtener cotización de moneda
		SELECT @v_cotizacion = valor FROM ventas.tipo_moneda WHERE id_tipo_moneda = @p_id_tipo_moneda;

		-- 4. calcular total en moneda local (registro en ventas.venta)
		SET @v_monto_venta = @v_costo * @p_cantidad_participantes;

		-- 5. calcular total en moneda de pago (registro en ventas.pago)
		SET @v_monto_pago = @v_monto_venta / @v_cotizacion;

		-- 6. Crear pago
		INSERT INTO ventas.pago (monto, id_tipo_moneda, id_forma_pago)
		VALUES (@v_monto_pago, @p_id_tipo_moneda, @p_id_forma_pago);

		SET @p_id_pago = SCOPE_IDENTITY();

		-- 7. Crear venta
		INSERT INTO ventas.venta (total, id_punto_venta, id_parque, id_pago)
		VALUES (@v_monto_venta, @p_id_punto_venta, @v_id_parque, @p_id_pago);

		SET @p_id_venta = SCOPE_IDENTITY();

		-- 8. Crear detalle venta
		INSERT INTO ventas.detalle_venta (cantidad, precio_unitario, id_venta)
		VALUES (@p_cantidad_participantes, @v_costo, @p_id_venta);

		SET @p_id_detalle_venta = SCOPE_IDENTITY();

		-- 9. Crear pase actividad
		INSERT INTO ventas.pase_actividad (id_detalle_venta, id_actividad_programada)
		VALUES (@p_id_detalle_venta, @p_id_actividad_programada);
		
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH;
END;
GO


---------------------------------------------------------------------------------------
---------- REGISTRAR VENTA COMPLETA (ENTRADA + ACTIVIDAD) -----------------------------
---------------------------------------------------------------------------------------

-- registro de venta completa (entrada + actividad), detalle venta, pase entrada, pase actividad y pago asociado
-- hibrido entre sp_registrar_venta_entrada y sp_registrar_venta_actividad, 
-- unica diferencia es que se registran dos detalles de venta, uno para la entrada y otro para la actividad, ambos asociados a la misma venta y pago

CREATE OR ALTER PROCEDURE ventas.sp_registrar_venta_completa
	@p_id_parque INT,
	@p_id_punto_venta INT,
	@p_id_tipo_moneda INT,
	@p_id_forma_pago INT,
	@p_id_entrada INT,
	@p_id_clima INT,
	@p_cantidad_entradas SMALLINT,
	@p_fecha_acceso DATE,
	@p_id_actividad_programada INT,
	@p_cantidad_participantes SMALLINT,
	@p_id_venta INT OUTPUT,
	@p_id_pago INT OUTPUT
AS
BEGIN
	BEGIN TRY 
		DECLARE @ERRORES VARCHAR(1000) = '';	
		-- VARIABLES PARA VALIDACIONES DE ENTRADA
		DECLARE @v_precio_base_entrada DECIMAL(12, 2);
		DECLARE @v_descuento_entrada DECIMAL(5, 2);
		DECLARE @v_precio_unitario_entrada DECIMAL(12, 2);
		DECLARE @v_cotizacion DECIMAL(18, 6);
		DECLARE @v_monto_venta DECIMAL(12, 2);
		DECLARE @v_monto_pago DECIMAL(12, 2);
		DECLARE @v_id_detalle_venta_entrada INT;
		-- VARIABLES PARA VALIDACIONES DE ACTIVIDAD
		DECLARE @v_cupo_maximo_actividad SMALLINT;
		DECLARE @v_cantidad_participantes_actual SMALLINT;
		DECLARE @v_costo_actividad DECIMAL(12, 2);
		DECLARE @v_duracion_horas_actividad TINYINT;
		DECLARE @v_id_detalle_venta_actividad INT;
		DECLARE @v_fecha_hora_inicio DATETIME2(0);

		-- Validar cantidad de entradas positiva
		IF @p_cantidad_entradas <= 0
		BEGIN
			SET @ERRORES += 'La cantidad de entradas debe ser mayor a cero.' + CHAR(13) + CHAR(10);
		END;

		-- validar cantidad de participantes positiva
		IF @p_cantidad_participantes <= 0
		BEGIN
			SET @ERRORES += 'La cantidad de participantes debe ser mayor a cero.' + CHAR(13) + CHAR(10);
		END;

		-- validar cantidad de participantes menor o igual a la cantidad de entradas
		IF @p_cantidad_participantes > @p_cantidad_entradas
		BEGIN
			SET @ERRORES += 'La cantidad de participantes en una actividad no puede exceder la cantidad de entradas.' + CHAR(13) + CHAR(10);
		END;

		-- Validar fecha de acceso no sea anterior a hoy
		IF @p_fecha_acceso < CONVERT(DATE, SYSDATETIME())
		BEGIN
			SET @ERRORES += 'La fecha de acceso no puede ser anterior a hoy.' + CHAR(13) + CHAR(10);
		END;

        -- Validar clima existe
		IF NOT EXISTS (SELECT 1 FROM ventas.clima WHERE id_clima = @p_id_clima)
		BEGIN
			SET @ERRORES += 'El tipo de clima especificado no existe.' + CHAR(13) + CHAR(10);
		END;

		-- Validar parque existe
		IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @p_id_parque)
		BEGIN
			SET @ERRORES += 'El parque especificado no existe.' + CHAR(13) + CHAR(10);
		END;

		-- Validar punto de venta existe
		IF NOT EXISTS (SELECT 1 FROM ventas.punto_venta WHERE id_punto_venta = @p_id_punto_venta)
		BEGIN
			SET @ERRORES += 'El punto de venta especificado no existe.' + CHAR(13) + CHAR(10);
		END;

		-- Validar tipo de moneda existe
		IF NOT EXISTS (SELECT 1 FROM ventas.tipo_moneda WHERE id_tipo_moneda = @p_id_tipo_moneda)
		BEGIN
			SET @ERRORES += 'El tipo de moneda especificado no existe.' + CHAR(13) + CHAR(10);
		END;

		-- Validar forma de pago existe
		IF NOT EXISTS (SELECT 1 FROM ventas.forma_pago WHERE id_forma_pago = @p_id_forma_pago)
		BEGIN
			SET @ERRORES += 'La forma de pago especificada no existe.' + CHAR(13) + CHAR(10);
		END;

		-- Validar entrada existe y está vigente
		IF NOT EXISTS (SELECT 1 FROM parques.entrada
					   WHERE id_entrada = @p_id_entrada
					   AND id_parque = @p_id_parque
					   AND @p_fecha_acceso BETWEEN fecha_desde AND fecha_hasta)
		BEGIN
			SET @ERRORES += 'La entrada especificada no existe o no es válida para el parque/fecha indicados.' + CHAR(13) + CHAR(10);
		END;

		-- validar actividad programada
		IF NOT EXISTS (SELECT 1 FROM ventas.actividad_programada WHERE id_actividad_programada = @p_id_actividad_programada)
		BEGIN
			SET @ERRORES += 'La actividad programada especificada no existe.' + CHAR(13) + CHAR(10);
		END;

		-- validar que la fecha de acceso de la entrada coincida con la fecha de la actividad programada
		IF NOT EXISTS (SELECT 1 FROM ventas.actividad_programada WHERE id_actividad_programada = @p_id_actividad_programada AND CAST(fecha_hora AS DATE) = @p_fecha_acceso)
		BEGIN
			SET @ERRORES += 'La fecha de acceso de la entrada no coincide con la fecha de la actividad programada.' + CHAR(13) + CHAR(10);
		END;

		-- Obtener precio base de la entrada
		SELECT @v_precio_base_entrada = precio_base FROM parques.entrada WHERE id_entrada = @p_id_entrada;
		
		-- Obtener descuento vigente para la entrada
		SELECT @v_descuento_entrada = ISNULL(tv.porcentaje_descuento, 0) 
							 FROM parques.tipo_visitante tv
							 JOIN parques.entrada e ON tv.id_tipo_visitante = e.id_tipo_visitante
							 WHERE e.id_entrada = @p_id_entrada;

		-- Calcular precio por unidad de entrada (considerando descuento)
		SET @v_precio_unitario_entrada = @v_precio_base_entrada * (1 - @v_descuento_entrada / 100);

		-- obtener cupo máximo, costo y duración de actividad turística
		SELECT
			@v_cupo_maximo_actividad = cupo_maximo,
			@v_costo_actividad = costo,
			@v_duracion_horas_actividad = duracion_horas 
		FROM parques.actividad_turistica at
		JOIN ventas.actividad_programada ap ON at.id_actividad_turistica = ap.id_actividad_turistica
		WHERE ap.id_actividad_programada = @p_id_actividad_programada;

		-- validar que la actividad programada no haya finalizado
		SELECT @v_fecha_hora_inicio = fecha_hora FROM ventas.actividad_programada WHERE id_actividad_programada = @p_id_actividad_programada;
		IF DATEADD(HOUR, @v_duracion_horas_actividad, @v_fecha_hora_inicio) < SYSDATETIME()
		BEGIN
			SET @ERRORES += 'La actividad programada ya ha finalizado. No se pueden contratar actividades finalizadas.' + CHAR(13) + CHAR(10);
		END;

		IF @ERRORES <> ''
		BEGIN
			THROW 50011, @ERRORES, 1;
		END;

		BEGIN TRANSACTION;
		
		-- 1. obtener cantidad de participantes actual de la actividad programada (sumatoria de cantidad participantes de pases actividad asociados a la actividad programada)
		SELECT @v_cantidad_participantes_actual = ISNULL(SUM(dv.cantidad), 0) FROM ventas.pase_actividad pa
		JOIN ventas.detalle_venta dv ON pa.id_detalle_venta = dv.id_detalle_venta
		WHERE pa.id_actividad_programada = @p_id_actividad_programada;

		-- 2. validar cantidad participantes menor o igual al cupo máximo de actividad turística disponible 
		IF @v_cantidad_participantes_actual + @p_cantidad_participantes > @v_cupo_maximo_actividad
		BEGIN
			THROW 50012, 'La cantidad de participantes excede el cupo máximo de la actividad turística.', 1;
		END;

		-- 3. Obtener cotización de moneda
		SELECT @v_cotizacion = valor FROM ventas.tipo_moneda WHERE id_tipo_moneda = @p_id_tipo_moneda;
		
		-- 4. calcular total en moneda local (registro en ventas.venta)
		SET @v_monto_venta = (@v_precio_unitario_entrada * @p_cantidad_entradas) + (@v_costo_actividad * @p_cantidad_participantes);

		-- 5. calcular total en moneda de pago (registro en ventas.pago)
		SET @v_monto_pago = @v_monto_venta / @v_cotizacion;
		
        -- 6. Crear pago
		INSERT INTO ventas.pago (monto, id_tipo_moneda, id_forma_pago)
		VALUES (@v_monto_pago, @p_id_tipo_moneda, @p_id_forma_pago);

		SET @p_id_pago = SCOPE_IDENTITY();

		-- 7. Crear venta
		INSERT INTO ventas.venta (total, id_punto_venta, id_parque, id_pago)
		VALUES (@v_monto_venta, @p_id_punto_venta, @p_id_parque, @p_id_pago);

		SET @p_id_venta = SCOPE_IDENTITY();

		-- 8. Crear detalle venta entrada
		INSERT INTO ventas.detalle_venta (cantidad, precio_unitario, id_venta)
		VALUES (@p_cantidad_entradas, @v_precio_unitario_entrada, @p_id_venta);

		SET @v_id_detalle_venta_entrada = SCOPE_IDENTITY();

		-- 9. Crear pase entrada
		INSERT INTO ventas.pase_entrada (id_detalle_venta, fecha_acceso, id_entrada, id_clima)
		VALUES (@v_id_detalle_venta_entrada, @p_fecha_acceso, @p_id_entrada, @p_id_clima);

		-- 10. Crear detalle venta actividad
		INSERT INTO ventas.detalle_venta (cantidad, precio_unitario, id_venta)
		VALUES (@p_cantidad_participantes, @v_costo_actividad, @p_id_venta);

		SET @v_id_detalle_venta_actividad = SCOPE_IDENTITY();

		-- 11. Crear pase actividad
		INSERT INTO ventas.pase_actividad (id_detalle_venta, id_actividad_programada)
		VALUES (@v_id_detalle_venta_actividad, @p_id_actividad_programada);

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH;
END;
GO
