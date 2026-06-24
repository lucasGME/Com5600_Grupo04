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

Script de cifrado de datos sensibles.
*/

USE BD_Parques_Nacionales;
GO

---------------------------------------------------------
-- SP para agregar columnas para cifrado
---------------------------------------------------------
CREATE OR ALTER PROCEDURE seguridad.sp_agregar_columna_para_cifrado
AS
BEGIN
	SET NOCOUNT ON;

	-- Guardaparques
    IF COL_LENGTH('rrhh.guardaparques', 'apellido_y_nombre_Cif') IS NULL
		ALTER TABLE rrhh.guardaparques ADD apellido_y_nombre_Cif VARBINARY(512) NULL;
	IF COL_LENGTH('rrhh.guardaparques', 'telefono_Cif') IS NULL
		ALTER TABLE rrhh.guardaparques ADD telefono_Cif VARBINARY(256) NULL;
	IF COL_LENGTH('rrhh.guardaparques', 'email_Cif') IS NULL
		ALTER TABLE rrhh.guardaparques ADD email_Cif VARBINARY(512) NULL;

	-- Guías
	IF COL_LENGTH('rrhh.guia', 'apellido_y_nombre_Cif') IS NULL
		ALTER TABLE rrhh.guia ADD apellido_y_nombre_Cif VARBINARY(512) NULL;
	IF COL_LENGTH('rrhh.guia', 'telefono_Cif') IS NULL
		ALTER TABLE rrhh.guia ADD telefono_Cif VARBINARY(256) NULL;
	IF COL_LENGTH('rrhh.guia', 'email_Cif') IS NULL
		ALTER TABLE rrhh.guia ADD email_Cif VARBINARY(512) NULL;
END;
GO

EXEC seguridad.sp_agregar_columna_para_cifrado;
GO

---------------------------------------------------------
-- SP para cifrar datos sensibles
---------------------------------------------------------
CREATE OR ALTER PROCEDURE seguridad.sp_cifrar_datos_sensibles
    @FraseClave NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;
	
    -- Cifrado de guardaparques
	UPDATE rrhh.guardaparques
	SET apellido_y_nombre_Cif = EncryptByPassPhrase(@FraseClave, apellido_y_nombre, 1, CONVERT(VARBINARY, id_guardaparques)),
		telefono_Cif = EncryptByPassPhrase(@FraseClave, telefono, 1, CONVERT(VARBINARY, id_guardaparques)),
		email_Cif = EncryptByPassPhrase(@FraseClave, email, 1, CONVERT(VARBINARY, id_guardaparques))
	WHERE apellido_y_nombre_Cif IS NULL
	   OR email_Cif IS NULL;

	-- Cifrado de guías
	UPDATE rrhh.guia
	SET apellido_y_nombre_Cif = EncryptByPassPhrase(@FraseClave, apellido_y_nombre, 1, CONVERT(VARBINARY, id_guia)),
		telefono_Cif = EncryptByPassPhrase(@FraseClave, telefono, 1, CONVERT(VARBINARY, id_guia)),
		email_Cif = EncryptByPassPhrase(@FraseClave, email, 1, CONVERT(VARBINARY, id_guia))
	WHERE apellido_y_nombre_Cif IS NULL
	   OR email_Cif IS NULL;
END;
GO

EXEC seguridad.sp_cifrar_datos_sensibles N'ClaveSecreta123$';
GO

---------------------------------------------------------
-- SP para eliminar columnas en claro
---------------------------------------------------------
CREATE OR ALTER PROCEDURE seguridad.sp_eliminar_columnas_en_claro
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @errores VARCHAR(MAX) = '';

	-- Validaciones Guardaparques
	IF EXISTS (SELECT 1 FROM rrhh.guardaparques WHERE (apellido_y_nombre IS NOT NULL AND apellido_y_nombre_Cif IS NULL))
			SET @errores += '- Hay nombres de guardaparques sin cifrar.' + CHAR(10);
	IF EXISTS (SELECT 1 FROM rrhh.guardaparques WHERE (email IS NOT NULL AND email_Cif IS NULL))
			SET @errores += '- Hay emails de guardaparques sin cifrar.' + CHAR(10);

    -- Validaciones Guías
	IF EXISTS (SELECT 1 FROM rrhh.guia WHERE (apellido_y_nombre IS NOT NULL AND apellido_y_nombre_Cif IS NULL))
			SET @errores += '- Hay nombres de guías sin cifrar.' + CHAR(10);
	IF EXISTS (SELECT 1 FROM rrhh.guia WHERE (email IS NOT NULL AND email_Cif IS NULL))
			SET @errores += '- Hay emails de guías sin cifrar.' + CHAR(10);
	
	IF @errores <> ''
	BEGIN 
        RAISERROR(@errores, 16, 1);
		RETURN;
	END

	-- Eliminar constraints
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'uq_guardaparques_email' AND parent_object_id = OBJECT_ID('rrhh.guardaparques'))
        ALTER TABLE rrhh.guardaparques DROP CONSTRAINT uq_guardaparques_email;
		
    IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'uq_guia_email' AND parent_object_id = OBJECT_ID('rrhh.guia'))
        ALTER TABLE rrhh.guia DROP CONSTRAINT uq_guia_email;

	-- Eliminar columnas en claro: Guardaparques
	IF COL_LENGTH('rrhh.guardaparques', 'apellido_y_nombre') IS NOT NULL
		ALTER TABLE rrhh.guardaparques DROP COLUMN apellido_y_nombre;
	IF COL_LENGTH('rrhh.guardaparques', 'telefono') IS NOT NULL
		ALTER TABLE rrhh.guardaparques DROP COLUMN telefono;
	IF COL_LENGTH('rrhh.guardaparques', 'email') IS NOT NULL
		ALTER TABLE rrhh.guardaparques DROP COLUMN email;

	-- Eliminar columnas en claro: Guías
	IF COL_LENGTH('rrhh.guia', 'apellido_y_nombre') IS NOT NULL
		ALTER TABLE rrhh.guia DROP COLUMN apellido_y_nombre;
	IF COL_LENGTH('rrhh.guia', 'telefono') IS NOT NULL
		ALTER TABLE rrhh.guia DROP COLUMN telefono;
	IF COL_LENGTH('rrhh.guia', 'email') IS NOT NULL
		ALTER TABLE rrhh.guia DROP COLUMN email;
END;
GO

EXEC seguridad.sp_eliminar_columnas_en_claro;
GO

---------------------------------------------------------
-- SPs para descifrar
---------------------------------------------------------
CREATE OR ALTER PROCEDURE seguridad.sp_descifrar_guardaparques
    @FraseClave NVARCHAR(128)
AS
BEGIN
    SELECT 
        id_guardaparques,
		legajo,
        CONVERT(VARCHAR(150), DecryptByPassPhrase(@FraseClave, apellido_y_nombre_Cif, 1, CONVERT(VARBINARY, id_guardaparques))) AS apellido_y_nombre,
        fecha_nacimiento,
        CONVERT(VARCHAR(20), DecryptByPassPhrase(@FraseClave, telefono_Cif, 1, CONVERT(VARBINARY, id_guardaparques))) AS telefono,
        CONVERT(VARCHAR(254), DecryptByPassPhrase(@FraseClave, email_Cif, 1, CONVERT(VARBINARY, id_guardaparques))) AS email,
		activo
    FROM rrhh.guardaparques;
END;
GO

CREATE OR ALTER PROCEDURE seguridad.sp_descifrar_guias
    @FraseClave NVARCHAR(128)
AS
BEGIN
    SELECT 
        id_guia,
		legajo,
        CONVERT(VARCHAR(150), DecryptByPassPhrase(@FraseClave, apellido_y_nombre_Cif, 1, CONVERT(VARBINARY, id_guia))) AS apellido_y_nombre,
        fecha_nacimiento,
        CONVERT(VARCHAR(254), DecryptByPassPhrase(@FraseClave, email_Cif, 1, CONVERT(VARBINARY, id_guia))) AS email,
        CONVERT(VARCHAR(20), DecryptByPassPhrase(@FraseClave, telefono_Cif, 1, CONVERT(VARBINARY, id_guia))) AS telefono,
		id_titulo,
		id_especialidad,
		id_estado_guia
    FROM rrhh.guia;
END;
GO