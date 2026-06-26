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

Script de creación de procedimientos almacenados para gestión de concesiones en parques nacionales.
- registra contrato concesión
- genera cánones
- registra pago de canon
- anula contrato concesión
- actualiza estado de cánones vencidos
*/

USE BD_Parques_Nacionales;
GO


---------------------------------------------------------------------------------------
---------- REGISTRAR CONTRATO CONCESIÓN -----------------------------------------------
---------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE concesiones.sp_registrar_contrato_concesion
    @p_id_parque INT,
    @p_id_tipo_actividad_concesion INT,
    @p_id_empresa INT,
    @p_monto_mensual DECIMAL(25, 2),
    @p_fecha_inicio DATE,
	@p_fecha_fin DATE,
    @p_id_contrato_concesion INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @ERRORES VARCHAR(1000) = '';

        -- validar parque existe
        IF NOT EXISTS (SELECT 1 FROM parques.parque WHERE id_parque = @p_id_parque)
        BEGIN
            SET @ERRORES += 'El parque especificado no existe.' + CHAR(13) + CHAR(10);
        END

        -- validar tipo actividad concesion existe
        IF NOT EXISTS (SELECT 1 FROM concesiones.tipo_actividad_concesion WHERE id_tipo_actividad_concesion = @p_id_tipo_actividad_concesion)
        BEGIN
            SET @ERRORES += 'El tipo de actividad de concesión especificado no existe.' + CHAR(13) + CHAR(10);
        END

        -- validar empresa existe
        IF NOT EXISTS (SELECT 1 FROM concesiones.empresa WHERE id_empresa = @p_id_empresa)
        BEGIN
            SET @ERRORES += 'La empresa concesionaria especificada no existe.' + CHAR(13) + CHAR(10);
        END

        -- validar monto mensual sea positivo
        IF @p_monto_mensual <= 0
        BEGIN
            SET @ERRORES += 'El monto mensual debe ser un valor positivo.' + CHAR(13) + CHAR(10);
        END

        -- validar fecha inicio no sea anterior a hoy
        IF @p_fecha_inicio < CAST(GETDATE() AS DATE)
        BEGIN
            SET @ERRORES += 'La fecha de inicio no puede ser anterior a la fecha actual.' + CHAR(13) + CHAR(10);
        END

        -- validar fecha fin no sea anterior a fecha inicio
        IF @p_fecha_fin <= @p_fecha_inicio
        BEGIN
            SET @ERRORES += 'La fecha de fin debe ser posterior a la fecha de inicio.' + CHAR(13) + CHAR(10);
        END

        IF @ERRORES <> ''
        BEGIN
            THROW 50001, @ERRORES, 1;
        END

        BEGIN TRANSACTION;
        -- 1. crear contrato concesión
        INSERT INTO concesiones.contrato_concesion (id_parque, id_tipo_actividad_concesion, id_empresa, monto_mensual, fecha_inicio, fecha_fin)
        VALUES (@p_id_parque, @p_id_tipo_actividad_concesion, @p_id_empresa, @p_monto_mensual, @p_fecha_inicio, @p_fecha_fin);
        
        SET @p_id_contrato_concesion = SCOPE_IDENTITY();

        -- 2. generar cánones asociados al contrato concesión
        EXEC concesiones.sp_generar_canones @p_id_contrato_concesion, @p_fecha_inicio, @p_fecha_fin, @p_monto_mensual;

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
---------- GENERAR CANONES ------------------------------------------------------------
---------------------------------------------------------------------------------------

-- solamente se ejecuta desde el procedimiento de registrar contrato concesión,
-- asociando los cánones al contrato concesión creado.

CREATE OR ALTER PROCEDURE concesiones.sp_generar_canones
    @p_id_contrato_concesion INT,
    @p_fecha_inicio DATE,
    @p_fecha_fin DATE,
    @p_monto_mensual DECIMAL(25, 2)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;
        DECLARE @v_fecha_vencimiento DATE = @p_fecha_inicio;

        DECLARE @v_id_estado_canon INT = (
            SELECT id_estado_canon
            FROM concesiones.estado_canon
            WHERE descripcion = 'Pendiente'
        );

        IF @v_id_estado_canon IS NULL
        BEGIN
            THROW 50002, 'El estado de canon "Pendiente" no existe en la base de datos.', 1;
        END

        WHILE @v_fecha_vencimiento <= @p_fecha_fin
        BEGIN
            INSERT INTO concesiones.canon
            (
                id_contrato_concesion,
                importe,
                fecha_vencimiento,
                id_estado_canon
            )
            VALUES
            (
                @p_id_contrato_concesion,
                @p_monto_mensual,
                @v_fecha_vencimiento,
                @v_id_estado_canon
            );

            SET @v_fecha_vencimiento = DATEADD(MONTH, 1, @v_fecha_vencimiento);
        END;

    END TRY
    BEGIN CATCH
		THROW;
	END CATCH;
END;
GO


---------------------------------------------------------------------------------------
---------- REGISTRAR PAGO CANON -------------------------------------------------------
---------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE concesiones.sp_registrar_pago_canon
    @p_id_contrato_concesion INT,
    @p_id_canon INT,
    @p_monto_pagar DECIMAL(25, 2)
AS
BEGIN
    BEGIN TRY
        DECLARE @ERRORES VARCHAR(1000) = '';
        DECLARE @v_importe DECIMAL(25, 2);
        DECLARE @v_descripcion_estado_canon VARCHAR(100);
        DECLARE @v_id_estado_canon_pagado INT;

        -- validar contrato existe
        IF NOT EXISTS (SELECT 1 FROM concesiones.contrato_concesion WHERE id_contrato_concesion = @p_id_contrato_concesion)
        BEGIN
            SET @ERRORES += 'El contrato de concesión especificado no existe.' + CHAR(13) + CHAR(10);
        END

        -- validar canon existe
        IF NOT EXISTS (SELECT 1 
                        FROM concesiones.canon c
                        JOIN concesiones.contrato_concesion cc ON c.id_contrato_concesion = cc.id_contrato_concesion
                        WHERE c.id_canon = @p_id_canon AND cc.id_contrato_concesion = @p_id_contrato_concesion)
        BEGIN
            SET @ERRORES += 'El canon especificado no existe.' + CHAR(13) + CHAR(10);
        END

        -- obtener estado del canon actual y monto a pagar
        SELECT @v_descripcion_estado_canon = descripcion, @v_importe = importe
            FROM concesiones.canon  c 
            JOIN concesiones.estado_canon ec ON c.id_estado_canon = ec.id_estado_canon
            WHERE id_canon = @p_id_canon;

        -- validar que el canon no haya sido pagado previamente
        IF @v_descripcion_estado_canon = 'Pagado'
        BEGIN
            SET @ERRORES += 'El canon ya ha sido pagado previamente.' + CHAR(13) + CHAR(10);
        END

        -- validar que el monto pagado sea igual al importe del canon
        IF @p_monto_pagar <> @v_importe
        BEGIN
            SET @ERRORES += 'El monto pagado debe ser igual al importe del canon.' + CHAR(13) + CHAR(10);
        END

        -- obtener estado del canon "Pagado"
        SELECT @v_id_estado_canon_pagado = id_estado_canon 
            FROM concesiones.estado_canon 
            WHERE descripcion = 'Pagado';
        
        -- validar que el estado "Pagado" exista en la base de datos
        IF @v_id_estado_canon_pagado IS NULL
        BEGIN
            SET @ERRORES += 'El estado de canon "Pagado" no existe en la base de datos.' + CHAR(13) + CHAR(10);
        END

        -- obtener estado del canon "Anulado"
        IF @v_descripcion_estado_canon = 'Anulado'
        BEGIN
            SET @ERRORES += 'Contrato de concesión "Anulado". No se puede registrar el pago de un canon que se encuentra en estado "Anulado".' + CHAR(13) + CHAR(10);
        END

        IF @ERRORES <> ''
        BEGIN
            THROW 50001, @ERRORES, 1;
        END

        BEGIN TRANSACTION;

        -- 1. registrar pago del canon
        INSERT INTO concesiones.pago_canon (id_canon, monto, fecha_hora)
        VALUES (@p_id_canon, @p_monto_pagar, GETDATE());

        -- 2. actualizar canon con pago registrado
        UPDATE concesiones.canon
        SET id_estado_canon = @v_id_estado_canon_pagado
        WHERE id_canon = @p_id_canon;

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
---------- ANULAR CONTRATO CONCESIÓN --------------------------------------------------
---------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE concesiones.sp_anular_contrato_concesion
    @p_id_contrato_concesion INT
AS
BEGIN
    BEGIN TRY
        DECLARE @ERRORES VARCHAR(1000) = '';
        DECLARE @v_id_estado_canon_anulado INT;
        DECLARE @v_id_estado_canon_pagado INT;
        DECLARE @v_id_estado_canon_vencido INT;

        -- validar contrato existe
        IF NOT EXISTS (SELECT 1 FROM concesiones.contrato_concesion WHERE id_contrato_concesion = @p_id_contrato_concesion)
        BEGIN
            SET @ERRORES += 'El contrato de concesión especificado no existe.' + CHAR(13) + CHAR(10);
        END

        -- obtener estado del contrato "Anulado"
        SELECT @v_id_estado_canon_anulado = id_estado_canon 
            FROM concesiones.estado_canon 
            WHERE descripcion = 'Anulado';
        
        -- validar que el estado "Anulado" exista en la base de datos
        IF @v_id_estado_canon_anulado IS NULL
        BEGIN
            SET @ERRORES += 'El estado de canon "Anulado" no existe en la base de datos.' + CHAR(13) + CHAR(10);
        END

        -- obtener estado del contrato "Pagado"
        SELECT @v_id_estado_canon_pagado = id_estado_canon 
            FROM concesiones.estado_canon 
            WHERE descripcion = 'Pagado';
        
        -- validar que el estado "Pagado" exista en la base de datos
        IF @v_id_estado_canon_pagado IS NULL
        BEGIN
            SET @ERRORES += 'El estado de canon "Pagado" no existe en la base de datos.' + CHAR(13) + CHAR(10);
        END

        -- obtener estado del contrato "Vencido"
        SELECT @v_id_estado_canon_vencido = id_estado_canon 
            FROM concesiones.estado_canon 
            WHERE descripcion = 'Vencido';

        -- validar que el estado "Vencido" exista en la base de datos
        IF @v_id_estado_canon_vencido IS NULL
        BEGIN
            SET @ERRORES += 'El estado de canon "Vencido" no existe en la base de datos.' + CHAR(13) + CHAR(10);
        END

        IF @ERRORES <> ''
        BEGIN
            THROW 50001, @ERRORES, 1;
        END

        BEGIN TRANSACTION;

        -- 1. actualizar cánones asociados al contrato con estado anulado, excepto aquellos que ya se encuentran en estado pagado o vencido
        UPDATE concesiones.canon
        SET id_estado_canon = @v_id_estado_canon_anulado
        WHERE id_contrato_concesion = @p_id_contrato_concesion 
        AND id_estado_canon <> @v_id_estado_canon_pagado 
        AND id_estado_canon <> @v_id_estado_canon_vencido;

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
---------- ACTUALIZAR ESTADO CANONES VENCIDOS -----------------------------------------
---------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE concesiones.sp_actualizar_estado_canones_vencidos
AS
BEGIN
    BEGIN TRY
        DECLARE @ERRORES VARCHAR(1000) = '';
        DECLARE @v_id_estado_canon_vencido INT;
        DECLARE @v_id_estado_canon_anulado INT;

        -- obtener estado del canon "Vencido"
        SELECT @v_id_estado_canon_vencido = id_estado_canon 
            FROM concesiones.estado_canon 
            WHERE descripcion = 'Vencido';
        
        -- validar que el estado "Vencido" exista en la base de datos
        IF @v_id_estado_canon_vencido IS NULL
        BEGIN
            SET @ERRORES += 'El estado de canon "Vencido" no existe en la base de datos.' + CHAR(13) + CHAR(10);
        END

        -- obtener esatdo del canon "Anulado"
        SELECT @v_id_estado_canon_anulado = id_estado_canon 
            FROM concesiones.estado_canon 
            WHERE descripcion = 'Anulado';
        
        -- validar que el estado "Anulado" exista en la base de datos
        IF @v_id_estado_canon_anulado IS NULL
        BEGIN
            SET @ERRORES += 'El estado de canon "Anulado" no existe en la base de datos.' + CHAR(13) + CHAR(10);
        END

        IF @ERRORES <> ''
        BEGIN
            THROW 50001, @ERRORES, 1;
        END

        -- actualizar estado de cánones vencidos que no hayan sido pagados, ni anulados
        BEGIN TRANSACTION;
        UPDATE concesiones.canon
        SET id_estado_canon = @v_id_estado_canon_vencido
        WHERE fecha_vencimiento < CAST(GETDATE() AS DATE)
            AND id_estado_canon <> @v_id_estado_canon_vencido
            AND id_estado_canon <> @v_id_estado_canon_anulado;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END
