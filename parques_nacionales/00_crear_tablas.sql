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

Script de creación de base de datos, esquemas y tablas para el sistema de gestión de parques nacionales.
*/

---------------------------------------------
--------- CREACIÓN DE BASE DE DATOS ---------
---------------------------------------------
USE master;
GO

ALTER DATABASE BD_Parques_Nacionales
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE BD_Parques_Nacionales;
GO

IF DB_ID(N'BD_Parques_Nacionales') IS NULL
BEGIN
	EXEC(N'CREATE DATABASE BD_Parques_Nacionales');
END;
GO

USE BD_Parques_Nacionales;
GO

----------------------------------------
--------- CREACIÓN DE ESQUEMAS ---------
----------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'parques')
	EXEC(N'CREATE SCHEMA parques');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'ventas')
	EXEC(N'CREATE SCHEMA ventas');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'concesiones')
	EXEC(N'CREATE SCHEMA concesiones');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'rrhh')
	EXEC(N'CREATE SCHEMA rrhh');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'seguridad')
BEGIN
	EXEC(N'CREATE SCHEMA seguridad');
END;
GO

--------------------------------------
--------- CREACIÓN DE TABLAS ---------
--------------------------------------

IF OBJECT_ID(N'parques.provincia', N'U') IS NULL
BEGIN
	CREATE TABLE parques.provincia
	(
		id_provincia INT IDENTITY(1,1) NOT NULL,
		nombre VARCHAR(100) NOT NULL,
		CONSTRAINT pk_provincia PRIMARY KEY CLUSTERED (id_provincia),
		CONSTRAINT uq_provincia_nombre UNIQUE (nombre)
	);
END;
GO

IF OBJECT_ID(N'parques.tipo_parque', N'U') IS NULL
BEGIN
	CREATE TABLE parques.tipo_parque
	(
		id_tipo_parque INT IDENTITY(1,1) NOT NULL,
		descripcion VARCHAR(100) NOT NULL,
		CONSTRAINT pk_tipo_parque PRIMARY KEY CLUSTERED (id_tipo_parque),
		CONSTRAINT uq_tipo_parque_descripcion UNIQUE (descripcion)
	);
END;
GO

IF OBJECT_ID(N'parques.tipo_actividad_turistica', N'U') IS NULL
BEGIN
	CREATE TABLE parques.tipo_actividad_turistica
	(
		id_tipo_actividad_turistica INT IDENTITY(1,1) NOT NULL,
		descripcion VARCHAR(100) NOT NULL,
		CONSTRAINT pk_parques_tipo_actividad PRIMARY KEY CLUSTERED (id_tipo_actividad_turistica),
		CONSTRAINT uq_parques_tipo_actividad_descripcion UNIQUE (descripcion)
	);
END;
GO

IF OBJECT_ID(N'parques.tipo_visitante', N'U') IS NULL
BEGIN
	CREATE TABLE parques.tipo_visitante
	(
		id_tipo_visitante INT IDENTITY(1,1) NOT NULL,
		descripcion VARCHAR(100) NOT NULL,
		porcentaje_descuento DECIMAL(5,2) NOT NULL,
		CONSTRAINT pk_tipo_visitante PRIMARY KEY CLUSTERED (id_tipo_visitante),
		CONSTRAINT uq_tipo_visitante_descripcion UNIQUE (descripcion),
		CONSTRAINT ck_tipo_visitante_porcentaje_descuento CHECK (porcentaje_descuento >= 0 AND porcentaje_descuento <= 100)
	);
END;
GO

IF OBJECT_ID(N'rrhh.titulo', N'U') IS NULL
BEGIN
	CREATE TABLE rrhh.titulo
	(
		id_titulo INT IDENTITY(1,1) NOT NULL,
		descripcion VARCHAR(100) NOT NULL,
		CONSTRAINT pk_titulo PRIMARY KEY CLUSTERED (id_titulo),
		CONSTRAINT uq_titulo_descripcion UNIQUE (descripcion)
	);
END;
GO

IF OBJECT_ID(N'rrhh.especialidad', N'U') IS NULL
BEGIN
	CREATE TABLE rrhh.especialidad
	(
		id_especialidad INT IDENTITY(1,1) NOT NULL,
		descripcion VARCHAR(100) NOT NULL,
		CONSTRAINT pk_especialidad PRIMARY KEY CLUSTERED (id_especialidad),
		CONSTRAINT uq_especialidad_descripcion UNIQUE (descripcion)
	);
END;
GO

IF OBJECT_ID(N'rrhh.estado_guia', N'U') IS NULL
BEGIN
	CREATE TABLE rrhh.estado_guia
	(
		id_estado_guia INT IDENTITY(1,1) NOT NULL,
		descripcion VARCHAR(100) NOT NULL,
		CONSTRAINT pk_estado_guia PRIMARY KEY CLUSTERED (id_estado_guia),
		CONSTRAINT uq_estado_guia_descripcion UNIQUE (descripcion),
		CONSTRAINT ck_estado_guia_descripcion CHECK (descripcion IN ('Activo', 'Inactivo', 'Suspendido', 'Retirado'))
	);
END;
GO

IF OBJECT_ID(N'ventas.punto_venta', N'U') IS NULL
BEGIN
	CREATE TABLE ventas.punto_venta
	(
		id_punto_venta INT IDENTITY(1,1) NOT NULL,
		descripcion VARCHAR(100) NULL,
		CONSTRAINT pk_punto_venta PRIMARY KEY CLUSTERED (id_punto_venta),
		CONSTRAINT uq_punto_venta_nombre UNIQUE (descripcion)
	);
END;
GO

IF OBJECT_ID(N'ventas.clima', N'U') IS NULL
BEGIN
	CREATE TABLE ventas.clima
	(
		id_clima INT IDENTITY(1,1) NOT NULL,
		codigo_wmo INT NOT NULL, -- para almacenar el código WMO (World Meteorological Organization) del clima
		descripcion VARCHAR(100) NOT NULL,
		CONSTRAINT pk_clima PRIMARY KEY CLUSTERED (id_clima),
		CONSTRAINT uq_clima_descripcion UNIQUE (descripcion)
	);
END;
GO

IF OBJECT_ID(N'ventas.tipo_moneda', N'U') IS NULL
BEGIN
	CREATE TABLE ventas.tipo_moneda
	(
		id_tipo_moneda INT IDENTITY(1,1) NOT NULL,
		descripcion VARCHAR(100) NOT NULL,
		valor DECIMAL(18,6) NOT NULL,
		fecha_hora_valor DATETIME2(0) NOT NULL CONSTRAINT df_tipo_moneda_fecha_hora_valor DEFAULT (SYSDATETIME()),
		CONSTRAINT pk_tipo_moneda PRIMARY KEY CLUSTERED (id_tipo_moneda),
		CONSTRAINT uq_tipo_moneda_descripcion UNIQUE (descripcion),
		CONSTRAINT ck_tipo_moneda_valor CHECK (valor > 0)
	);
END;
GO

IF OBJECT_ID(N'ventas.forma_pago', N'U') IS NULL
BEGIN
	CREATE TABLE ventas.forma_pago
	(
		id_forma_pago INT IDENTITY(1,1) NOT NULL,
		descripcion VARCHAR(100) NOT NULL,
		CONSTRAINT pk_forma_pago PRIMARY KEY CLUSTERED (id_forma_pago),
		CONSTRAINT uq_forma_pago_descripcion UNIQUE (descripcion)
	);
END;
GO

IF OBJECT_ID(N'concesiones.empresa', N'U') IS NULL
BEGIN
	CREATE TABLE concesiones.empresa
	(
		id_empresa INT IDENTITY(1,1) NOT NULL,
		nombre VARCHAR(150) NOT NULL,
		direccion VARCHAR(200) NOT NULL,
		telefono VARCHAR(20) NULL,
		email VARCHAR(254) NOT NULL,
		CONSTRAINT pk_empresa PRIMARY KEY CLUSTERED (id_empresa),
		CONSTRAINT uq_empresa_nombre UNIQUE (nombre),
		CONSTRAINT uq_empresa_email UNIQUE (email)
	);
END;
GO

IF OBJECT_ID(N'concesiones.tipo_actividad_concesion', N'U') IS NULL
BEGIN
	CREATE TABLE concesiones.tipo_actividad_concesion
	(
		id_tipo_actividad_concesion INT IDENTITY(1,1) NOT NULL,
		descripcion VARCHAR(100) NOT NULL,
		CONSTRAINT pk_concesiones_tipo_actividad PRIMARY KEY CLUSTERED (id_tipo_actividad_concesion),
		CONSTRAINT uq_concesiones_tipo_actividad_descripcion UNIQUE (descripcion)
	);
END;
GO

IF OBJECT_ID(N'concesiones.estado_canon', N'U') IS NULL
BEGIN
	CREATE TABLE concesiones.estado_canon
	(
		id_estado_canon INT IDENTITY(1,1) NOT NULL,
		descripcion VARCHAR(100) NOT NULL,
		CONSTRAINT pk_estado_canon PRIMARY KEY CLUSTERED (id_estado_canon),
		CONSTRAINT uq_estado_canon_descripcion UNIQUE (descripcion),
		CONSTRAINT ck_estado_canon_descripcion CHECK (descripcion IN ('Pendiente', 'Pagado', 'Vencido', 'Anulado'))
	);
END;
GO

IF OBJECT_ID(N'parques.localidad', N'U') IS NULL
BEGIN
	CREATE TABLE parques.localidad
	(
		id_localidad INT IDENTITY(1,1) NOT NULL,
		nombre VARCHAR(100) NOT NULL,
		id_provincia INT NOT NULL,
		CONSTRAINT pk_localidad PRIMARY KEY CLUSTERED (id_localidad),
		CONSTRAINT uq_localidad_nombre_provincia UNIQUE (nombre, id_provincia),
		CONSTRAINT fk_localidad_provincia FOREIGN KEY (id_provincia) REFERENCES parques.provincia (id_provincia)
	);
END;
GO

IF OBJECT_ID(N'parques.parque', N'U') IS NULL
BEGIN
	CREATE TABLE parques.parque
	(
		id_parque INT IDENTITY(1,1) NOT NULL,
		nombre VARCHAR(150) NOT NULL,
		direccion VARCHAR(200) NOT NULL,
		latitud DECIMAL(9,6) NOT NULL,
		longitud DECIMAL(9,6) NOT NULL,
		superficie_km2 DECIMAL(10,2) NOT NULL,
		id_localidad INT NOT NULL,
		id_tipo_parque INT NOT NULL,
		CONSTRAINT pk_parque PRIMARY KEY CLUSTERED (id_parque),
		CONSTRAINT uq_parque_nombre UNIQUE (nombre),
		CONSTRAINT ck_parque_latitud CHECK (latitud BETWEEN -90 AND 90),
		CONSTRAINT ck_parque_longitud CHECK (longitud BETWEEN -180 AND 180),
		CONSTRAINT ck_parque_superficie CHECK (superficie_km2 > 0),
		CONSTRAINT fk_parque_localidad FOREIGN KEY (id_localidad) REFERENCES parques.localidad (id_localidad),
		CONSTRAINT fk_parque_tipo_parque FOREIGN KEY (id_tipo_parque) REFERENCES parques.tipo_parque (id_tipo_parque)
	);
END;
GO

IF OBJECT_ID(N'parques.entrada', N'U') IS NULL
BEGIN
	CREATE TABLE parques.entrada
	(
		id_entrada INT IDENTITY(1,1) NOT NULL,
		precio_base DECIMAL(12,2) NOT NULL,
		fecha_desde DATE NOT NULL,
		fecha_hasta DATE NOT NULL,
		id_parque INT NOT NULL,
		id_tipo_visitante INT NOT NULL,
		CONSTRAINT pk_entrada PRIMARY KEY CLUSTERED (id_entrada),
		CONSTRAINT ck_entrada_precio_base CHECK (precio_base >= 0),
		CONSTRAINT ck_entrada_fechas CHECK (fecha_hasta >= fecha_desde),
		CONSTRAINT fk_entrada_parque FOREIGN KEY (id_parque) REFERENCES parques.parque (id_parque),
		CONSTRAINT fk_entrada_tipo_visitante FOREIGN KEY (id_tipo_visitante) REFERENCES parques.tipo_visitante (id_tipo_visitante)
	);
END;
GO

IF OBJECT_ID(N'parques.actividad_turistica', N'U') IS NULL
BEGIN
	CREATE TABLE parques.actividad_turistica
	(
		id_actividad_turistica INT IDENTITY(1,1) NOT NULL,
		nombre VARCHAR(150) NOT NULL,
		duracion_horas TINYINT NOT NULL,
		costo DECIMAL(12,2) NOT NULL,
		cupo_maximo SMALLINT NOT NULL,
		id_parque INT NOT NULL,
		id_tipo_actividad_turistica INT NOT NULL,
		CONSTRAINT pk_actividad_turistica PRIMARY KEY CLUSTERED (id_actividad_turistica),
		CONSTRAINT uq_actividad_turistica_nombre_parque UNIQUE (nombre, id_parque),
		CONSTRAINT ck_actividad_turistica_duracion CHECK (duracion_horas > 0),
		CONSTRAINT ck_actividad_turistica_costo CHECK (costo >= 0),
		CONSTRAINT ck_actividad_turistica_cupo CHECK (cupo_maximo > 0),
		CONSTRAINT fk_actividad_turistica_parque FOREIGN KEY (id_parque) REFERENCES parques.parque (id_parque),
		CONSTRAINT fk_actividad_turistica_tipo_actividad FOREIGN KEY (id_tipo_actividad_turistica) REFERENCES parques.tipo_actividad_turistica (id_tipo_actividad_turistica)
	);
END;
GO

IF OBJECT_ID(N'rrhh.guardaparques', N'U') IS NULL
BEGIN
	CREATE TABLE rrhh.guardaparques
	(
		id_guardaparques INT IDENTITY(1,1) NOT NULL,
		legajo VARCHAR(20) NOT NULL,
		apellido_y_nombre VARCHAR(150) NOT NULL,
		fecha_nacimiento DATE NOT NULL,
		telefono VARCHAR(20) NULL,
		email VARCHAR(254) NOT NULL,
		activo BIT NOT NULL CONSTRAINT df_guardaparques_activo DEFAULT (1),
		CONSTRAINT pk_guardaparques PRIMARY KEY CLUSTERED (id_guardaparques),
		CONSTRAINT uq_guardaparques_legajo UNIQUE (legajo),
		CONSTRAINT uq_guardaparques_email UNIQUE (email),
		CONSTRAINT ck_guardaparques_fecha_nacimiento CHECK (fecha_nacimiento <= CONVERT(date, SYSDATETIME()))
	);
END;
GO

IF OBJECT_ID(N'rrhh.guia', N'U') IS NULL
BEGIN
	CREATE TABLE rrhh.guia
	(
		id_guia INT IDENTITY(1,1) NOT NULL,
		legajo VARCHAR(20) NOT NULL,
		apellido_y_nombre VARCHAR(150) NOT NULL,
		fecha_nacimiento DATE NOT NULL,
		email VARCHAR(254) NOT NULL,
		telefono VARCHAR(20) NULL,
		id_titulo INT NULL, -- Permite guías sin título asignado
		id_especialidad INT NOT NULL,
		id_estado_guia INT NOT NULL,
		CONSTRAINT pk_guia PRIMARY KEY CLUSTERED (id_guia),
		CONSTRAINT uq_guia_legajo UNIQUE (legajo),
		CONSTRAINT uq_guia_email UNIQUE (email),
		CONSTRAINT ck_guia_fecha_nacimiento CHECK (fecha_nacimiento <= CONVERT(date, SYSDATETIME())),
		CONSTRAINT fk_guia_titulo FOREIGN KEY (id_titulo) REFERENCES rrhh.titulo (id_titulo),
		CONSTRAINT fk_guia_especialidad FOREIGN KEY (id_especialidad) REFERENCES rrhh.especialidad (id_especialidad),
		CONSTRAINT fk_guia_estado_guia FOREIGN KEY (id_estado_guia) REFERENCES rrhh.estado_guia (id_estado_guia)
	);
END;
GO

IF OBJECT_ID(N'rrhh.asignacion_guardaparques', N'U') IS NULL
BEGIN
	CREATE TABLE rrhh.asignacion_guardaparques
	(
		id_asignacion INT IDENTITY(1,1) NOT NULL,
		id_guardaparques INT NOT NULL,
		id_parque INT NOT NULL,
		fecha_ingreso DATE NOT NULL,
		fecha_egreso DATE NULL,
		motivo_egreso VARCHAR(150) NULL,
		CONSTRAINT pk_asignacion_guardaparques PRIMARY KEY CLUSTERED (id_asignacion),
		CONSTRAINT ck_asignacion_guardaparques_fechas CHECK (fecha_egreso IS NULL OR fecha_egreso >= fecha_ingreso),
		CONSTRAINT fk_asignacion_guardaparques_guardaparques FOREIGN KEY (id_guardaparques) REFERENCES rrhh.guardaparques (id_guardaparques),
		CONSTRAINT fk_asignacion_guardaparques_parque FOREIGN KEY (id_parque) REFERENCES parques.parque (id_parque)
	);
END;
GO

IF OBJECT_ID(N'rrhh.autorizacion', N'U') IS NULL
BEGIN
	CREATE TABLE rrhh.autorizacion
	(
		id_autorizacion INT IDENTITY(1,1) NOT NULL,
		fecha_emision DATE NOT NULL CONSTRAINT df_autorizacion_fecha_emision DEFAULT (CONVERT(date, SYSDATETIME())),
		fecha_vencimiento DATE NOT NULL,
		id_guia INT NOT NULL,
		CONSTRAINT pk_autorizacion PRIMARY KEY CLUSTERED (id_autorizacion),
		CONSTRAINT ck_autorizacion_fechas CHECK (fecha_vencimiento >= fecha_emision),
		CONSTRAINT uq_autorizacion_guia_emision UNIQUE (id_guia, fecha_emision),
		CONSTRAINT fk_autorizacion_guia FOREIGN KEY (id_guia) REFERENCES rrhh.guia (id_guia)
	);
END;
GO

IF OBJECT_ID(N'ventas.pago', N'U') IS NULL
BEGIN
	CREATE TABLE ventas.pago
	(
		id_pago INT IDENTITY(1,1) NOT NULL,
		fecha_hora DATETIME2(0) NOT NULL CONSTRAINT df_pago_fecha_hora DEFAULT (SYSDATETIME()),
		monto DECIMAL(12,2) NOT NULL,
		id_tipo_moneda INT NOT NULL,
		id_forma_pago INT NOT NULL,
		CONSTRAINT pk_pago PRIMARY KEY CLUSTERED (id_pago),
		CONSTRAINT ck_pago_monto CHECK (monto > 0),
		CONSTRAINT fk_pago_tipo_moneda FOREIGN KEY (id_tipo_moneda) REFERENCES ventas.tipo_moneda (id_tipo_moneda),
		CONSTRAINT fk_pago_forma_pago FOREIGN KEY (id_forma_pago) REFERENCES ventas.forma_pago (id_forma_pago)
	);
END;
GO

IF OBJECT_ID(N'ventas.actividad_programada', N'U') IS NULL
BEGIN
	CREATE TABLE ventas.actividad_programada
	(
		id_actividad_programada INT IDENTITY(1,1) NOT NULL,
		fecha_hora DATETIME2(0) NOT NULL,
		id_actividad_turistica INT NOT NULL,
		id_guia INT NULL, -- Permite programar actividades sin guía asignado
		CONSTRAINT pk_actividad_programada PRIMARY KEY CLUSTERED (id_actividad_programada),
		CONSTRAINT ck_actividad_programada_fecha_hora CHECK (fecha_hora >= SYSDATETIME()),
		CONSTRAINT fk_actividad_programada_actividad_turistica FOREIGN KEY (id_actividad_turistica) REFERENCES parques.actividad_turistica (id_actividad_turistica),
		CONSTRAINT fk_actividad_programada_guia FOREIGN KEY (id_guia) REFERENCES rrhh.guia (id_guia)
	);
END;
GO

IF OBJECT_ID(N'concesiones.contrato_concesion', N'U') IS NULL
BEGIN
	CREATE TABLE concesiones.contrato_concesion
	(
		id_contrato_concesion INT IDENTITY(1,1) NOT NULL,
		fecha_inicio DATE NOT NULL,
		fecha_fin DATE NOT NULL,
		monto_mensual DECIMAL(25,2) NOT NULL,
		id_empresa INT NOT NULL,
		id_tipo_actividad_concesion INT NOT NULL,
		id_parque INT NOT NULL,
		CONSTRAINT pk_contrato_concesion PRIMARY KEY CLUSTERED (id_contrato_concesion),
		CONSTRAINT ck_contrato_concesion_fechas CHECK (fecha_fin >= fecha_inicio),
		CONSTRAINT ck_contrato_concesion_monto CHECK (monto_mensual > 0),
		CONSTRAINT fk_contrato_concesion_empresa FOREIGN KEY (id_empresa) REFERENCES concesiones.empresa (id_empresa),
		CONSTRAINT fk_contrato_concesion_tipo_actividad FOREIGN KEY (id_tipo_actividad_concesion) REFERENCES concesiones.tipo_actividad_concesion (id_tipo_actividad_concesion),
		CONSTRAINT fk_contrato_concesion_parque FOREIGN KEY (id_parque) REFERENCES parques.parque (id_parque)
	);
END;
GO

IF OBJECT_ID(N'ventas.venta', N'U') IS NULL
BEGIN
	CREATE TABLE ventas.venta
	(
		id_venta INT IDENTITY(1,1) NOT NULL,
		fecha_hora DATETIME2(0) NOT NULL CONSTRAINT df_venta_fecha_hora DEFAULT (SYSDATETIME()),
		total DECIMAL(12,2) NOT NULL,
		id_punto_venta INT NOT NULL,
		id_parque INT NOT NULL,
		id_pago INT NULL, -- Permite registrar ventas sin pago asociado (sin costo)
		CONSTRAINT pk_venta PRIMARY KEY CLUSTERED (id_venta),
		CONSTRAINT ck_venta_total CHECK (total >= 0),
		CONSTRAINT fk_venta_punto_venta FOREIGN KEY (id_punto_venta) REFERENCES ventas.punto_venta (id_punto_venta),
		CONSTRAINT fk_venta_parque FOREIGN KEY (id_parque) REFERENCES parques.parque (id_parque),
		CONSTRAINT fk_venta_pago FOREIGN KEY (id_pago) REFERENCES ventas.pago (id_pago)
	);
END;
GO

IF OBJECT_ID(N'concesiones.canon', N'U') IS NULL
BEGIN
	CREATE TABLE concesiones.canon
	(
		id_canon INT IDENTITY(1,1) NOT NULL,
		fecha_vencimiento DATE NOT NULL,
		importe DECIMAL(25,2) NOT NULL,
		id_contrato_concesion INT NOT NULL,
		id_estado_canon INT NOT NULL,
		CONSTRAINT pk_canon PRIMARY KEY CLUSTERED (id_canon),
		CONSTRAINT uq_canon_contrato_vencimiento UNIQUE (id_contrato_concesion, fecha_vencimiento),
		CONSTRAINT ck_canon_importe CHECK (importe > 0),
		CONSTRAINT fk_canon_contrato_concesion FOREIGN KEY (id_contrato_concesion) REFERENCES concesiones.contrato_concesion (id_contrato_concesion),
		CONSTRAINT fk_canon_estado_canon FOREIGN KEY (id_estado_canon) REFERENCES concesiones.estado_canon (id_estado_canon)
	);
END;
GO

IF OBJECT_ID(N'ventas.detalle_venta', N'U') IS NULL
BEGIN
	CREATE TABLE ventas.detalle_venta
	(
		id_detalle_venta INT IDENTITY(1,1) NOT NULL,
		cantidad SMALLINT NOT NULL,
		precio_unitario DECIMAL(12,2) NOT NULL,
		id_venta INT NOT NULL,
		CONSTRAINT pk_detalle_venta PRIMARY KEY CLUSTERED (id_detalle_venta),
		CONSTRAINT ck_detalle_venta_cantidad CHECK (cantidad > 0),
		CONSTRAINT ck_detalle_venta_precio_unitario CHECK (precio_unitario >= 0),
		CONSTRAINT fk_detalle_venta_venta FOREIGN KEY (id_venta) REFERENCES ventas.venta (id_venta)
	);
END;
GO

IF OBJECT_ID(N'concesiones.pago_canon', N'U') IS NULL
BEGIN
	CREATE TABLE concesiones.pago_canon
	(
		id_pago INT IDENTITY(1,1) NOT NULL,
		fecha_hora DATETIME2(0) NOT NULL CONSTRAINT df_pago_canon_fecha_hora DEFAULT (SYSDATETIME()),
		monto DECIMAL(25,2) NOT NULL,
		id_canon INT NOT NULL,
		CONSTRAINT pk_pago_canon PRIMARY KEY CLUSTERED (id_pago),
		CONSTRAINT ck_pago_canon_monto CHECK (monto >= 0),
		CONSTRAINT fk_pago_canon_canon FOREIGN KEY (id_canon) REFERENCES concesiones.canon (id_canon)
	);
END;
GO

IF OBJECT_ID(N'ventas.pase_entrada', N'U') IS NULL
BEGIN
	CREATE TABLE ventas.pase_entrada
	(
		id_detalle_venta INT NOT NULL,
		fecha_acceso DATE NOT NULL,
		id_entrada INT NOT NULL,
		id_clima INT NULL,
		CONSTRAINT pk_pase_entrada PRIMARY KEY CLUSTERED (id_detalle_venta),
		CONSTRAINT ck_pase_entrada_fecha_acceso CHECK (fecha_acceso >= CONVERT(date, SYSDATETIME())),
		CONSTRAINT fk_pase_entrada_detalle_venta FOREIGN KEY (id_detalle_venta) REFERENCES ventas.detalle_venta (id_detalle_venta),
		CONSTRAINT fk_pase_entrada_entrada FOREIGN KEY (id_entrada) REFERENCES parques.entrada (id_entrada),
		CONSTRAINT fk_pase_entrada_clima FOREIGN KEY (id_clima) REFERENCES ventas.clima (id_clima)
	);
END;
GO

IF OBJECT_ID(N'ventas.pase_actividad', N'U') IS NULL
BEGIN
	CREATE TABLE ventas.pase_actividad
	(
		id_detalle_venta INT NOT NULL,
		id_actividad_programada INT NOT NULL,
		CONSTRAINT pk_pase_actividad PRIMARY KEY CLUSTERED (id_detalle_venta),
		CONSTRAINT fk_pase_actividad_detalle_venta FOREIGN KEY (id_detalle_venta) REFERENCES ventas.detalle_venta (id_detalle_venta),
		CONSTRAINT fk_pase_actividad_actividad_programada FOREIGN KEY (id_actividad_programada) REFERENCES ventas.actividad_programada (id_actividad_programada)
	);
END;
GO
