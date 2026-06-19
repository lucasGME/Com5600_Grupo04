/*
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas (5600)
Cuatrimestre: 2026 - Primer Cuatrimestre, viernes tarde

Integrantes:
Mamani Estrada, Lucas Gabriel � 43624305 
Ju�rez, Javier David � 43446615 
Corpu, Mat�as Ariel - 43744403 
Capandegui, Damian Leonel � 45807823 

Grupo: 4

Script de testing de SPs de operaciones ABM (Alta, Baja, Modificaci�n) 
de las tablas del sistema de gesti�n de Parques Nacionales.
*/
USE BD_Parques_Nacionales;
GO

SET NOCOUNT ON;

-- ==========================================================
--  ESQUEMA: parques
-- ==========================================================
----------------------------------------------------------
-- parques.provincia
----------------------------------------------------------
SELECT * FROM parques.provincia;
-- Caso exitoso
EXEC parques.sp_provincia_alta @nombre = 'Misiones';
EXEC parques.sp_provincia_alta @nombre = 'Neuqu�n'; -- Para baja
-- Caso no exitoso (Nombre vac�o)
EXEC parques.sp_provincia_alta @nombre = '';
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_provincia_modificacion @id_provincia = 1, @nombre = 'Misiones (Modificado)';
-- Caso no exitoso (ID inexistente, nombre vac�o)
EXEC parques.sp_provincia_modificacion @id_provincia = 999, @nombre = '';
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_provincia_baja @id_provincia = 2;
-- Caso no exitoso (ID inexistente)
EXEC parques.sp_provincia_baja @id_provincia = 999;

----------------------------------------------------------
-- parques.localidad
----------------------------------------------------------
SELECT * FROM parques.localidad;
-- Caso exitoso
EXEC parques.sp_localidad_alta @nombre = 'Puerto Iguaz�', @id_provincia = 1;
EXEC parques.sp_localidad_alta @nombre = 'Localidad a Borrar', @id_provincia = 1;
-- Caso no exitoso (Nombre vac�o, Provincia inexistente)
EXEC parques.sp_localidad_alta @nombre = '', @id_provincia = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_localidad_modificacion @id_localidad = 1, @nombre = 'Iguaz�', @id_provincia = 1;
-- Caso no exitoso (ID inexistente, Nombre vac�o, Provincia inexistente)
EXEC parques.sp_localidad_modificacion @id_localidad = 999, @nombre = '', @id_provincia = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_localidad_baja @id_localidad = 2;
-- Caso no exitoso (ID inexistente)
EXEC parques.sp_localidad_baja @id_localidad = 999;

----------------------------------------------------------
-- parques.tipo_parque
----------------------------------------------------------
SELECT * FROM parques.tipo_parque;
-- Caso exitoso
EXEC parques.sp_tipo_parque_alta @descripcion = 'Parque Nacional';
EXEC parques.sp_tipo_parque_alta @descripcion = 'Reserva Natural';
-- Caso no exitoso (Duplicado)
EXEC parques.sp_tipo_parque_alta @descripcion = 'Parque Nacional';
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_tipo_parque_modificacion @id_tipo_parque = 1, @descripcion = 'Parque Nacional Argentino';
-- Caso no exitoso (ID inexistente, Nombre vac�o)
EXEC parques.sp_tipo_parque_modificacion @id_tipo_parque = 999, @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_tipo_parque_baja @id_tipo_parque = 2;
-- Caso no exitoso (ID inexistente)
EXEC parques.sp_tipo_parque_baja @id_tipo_parque = 999;

----------------------------------------------------------
-- parques.tipo_actividad_turistica
----------------------------------------------------------
SELECT * FROM parques.tipo_actividad_turistica;
-- Caso exitoso
EXEC parques.sp_tipo_actividad_turistica_alta @descripcion = 'Senderismo';
EXEC parques.sp_tipo_actividad_turistica_alta @descripcion = 'Navegaci�n';
-- Caso no exitoso (Vac�o)
EXEC parques.sp_tipo_actividad_turistica_alta @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_tipo_actividad_turistica_modificacion @id_tipo_actividad_turistica = 1, @descripcion = 'Trekking';
-- Caso no exitoso (ID inexistente, Nombre vac�o)
EXEC parques.sp_tipo_actividad_turistica_modificacion @id_tipo_actividad_turistica = 999, @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_tipo_actividad_turistica_baja @id_tipo_actividad_turistica = 2;
-- Caso no exitoso (ID inexistente)
EXEC parques.sp_tipo_parque_baja @id_tipo_parque = 999;

----------------------------------------------------------
-- parques.tipo_visitante
----------------------------------------------------------
SELECT * FROM parques.tipo_visitante;
-- Caso exitoso
EXEC parques.sp_tipo_visitante_alta @descripcion = 'General', @porcentaje_descuento = 0.00;
EXEC parques.sp_tipo_visitante_alta @descripcion = 'Jubilado', @porcentaje_descuento = 50.00;
-- Caso no exitoso (Nombre vac�o, Descuento fuera de rango)
EXEC parques.sp_tipo_visitante_alta @descripcion = '', @porcentaje_descuento = 150.00;
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_tipo_visitante_modificacion @id_tipo_visitante = 1, @descripcion = 'P�blico General', @porcentaje_descuento = 0.00;
-- Caso no exitoso (ID inexistente, Nombre vac�o, Descuento fuera de rango)
EXEC parques.sp_tipo_visitante_modificacion @id_tipo_visitante = 999, @descripcion = '', @porcentaje_descuento = 150.00;
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_tipo_visitante_baja @id_tipo_visitante = 2;
-- Caso no exitoso (ID inexistente)
EXEC parques.sp_tipo_visitante_baja @id_tipo_visitante = 999;

----------------------------------------------------------
-- parques.parque
----------------------------------------------------------
SELECT * FROM parques.parque;
-- Caso exitoso
EXEC parques.sp_parque_alta @nombre = 'Iguaz�', @direccion = 'Ruta 101', @latitud = -25.68, @longitud = -54.44, @superficie_km2 = 677.20, @id_localidad = 1, @id_tipo_parque = 1;
EXEC parques.sp_parque_alta @nombre = 'A Borrar', @direccion = 'XXX', @latitud = 0, @longitud = 0, @superficie_km2 = 10.0, @id_localidad = 1, @id_tipo_parque = 1;
-- Caso no exitoso (Nombre y dir vac�os, latitud/longitud inv�lidas, superficie 0, FKs inexistentes)
EXEC parques.sp_parque_alta @nombre = '', @direccion = '', @latitud = -150.0, @longitud = 200.0, @superficie_km2 = 0, @id_localidad = 999, @id_tipo_parque = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_parque_modificacion @id_parque = 1, @nombre = 'PN Iguaz�', @direccion = 'Ruta Nacional 101', @latitud = -25.6866, @longitud = -54.4442, @superficie_km2 = 677.20, @id_localidad = 1, @id_tipo_parque = 1;
-- Caso no exitoso (ID inexistente, Nombre y dir vac�os, latitud/longitud inv�lidas, superficie 0, FKs inexistentes)
EXEC parques.sp_parque_modificacion @id_parque = 999, @nombre = '', @direccion = '', @latitud = -150.0, @longitud = 200.0, @superficie_km2 = 0, @id_localidad = 999, @id_tipo_parque = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_parque_baja @id_parque = 2;
-- Caso no exitoso (ID inexistente)
EXEC parques.sp_parque_baja @id_parque = 999;

----------------------------------------------------------
-- parques.entrada
----------------------------------------------------------
SELECT * FROM parques.entrada;
-- Caso exitoso
EXEC parques.sp_entrada_alta @precio_base = 5000.00, @fecha_desde = '2026-01-01', @fecha_hasta = '2026-12-31', @id_parque = 1, @id_tipo_visitante = 1;
EXEC parques.sp_entrada_alta @precio_base = 1000.00, @fecha_desde = '2026-01-01', @fecha_hasta = '2026-12-31', @id_parque = 1, @id_tipo_visitante = 1;
-- Caso no exitoso (Precio negativo, fechas invertidas, FKs inexistentes)
EXEC parques.sp_entrada_alta @precio_base = -100.00, @fecha_desde = '2026-12-31', @fecha_hasta = '2026-01-01', @id_parque = 999, @id_tipo_visitante = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_entrada_modificacion @id_entrada = 1, @precio_base = 6000.00, @fecha_desde = '2026-01-01', @fecha_hasta = '2026-12-31', @id_parque = 1, @id_tipo_visitante = 1;
-- Caso no exitoso (ID inexistente, Precio negativo, fechas invertidas, FKs inexistentes)
EXEC parques.sp_entrada_modificacion @id_entrada = 999, @precio_base = -100.00, @fecha_desde = '2026-12-31', @fecha_hasta = '2026-01-01', @id_parque = 999, @id_tipo_visitante = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_entrada_baja @id_entrada = 2;
-- Caso no exitoso (ID inexistente)
EXEC parques.sp_entrada_baja @id_entrada = 999;

----------------------------------------------------------
-- parques.actividad_turistica
----------------------------------------------------------
SELECT * FROM parques.actividad_turistica;
-- Caso exitoso
EXEC parques.sp_actividad_turistica_alta @nombre = 'Garganta del Diablo', @duracion_horas = 2.5, @costo = 1500.00, @cupo_maximo = 50, @id_parque = 1, @id_tipo_actividad_turistica = 1;
EXEC parques.sp_actividad_turistica_alta @nombre = 'Paseo Inferior', @duracion_horas = 1.0, @costo = 0.00, @cupo_maximo = 100, @id_parque = 1, @id_tipo_actividad_turistica = 1;
-- Caso no exitoso (Nombre vac�o, Duraci�n, costo, cupo inv�lido, FKs inexistentes)
EXEC parques.sp_actividad_turistica_alta @nombre = '', @duracion_horas = 0, @costo = -500, @cupo_maximo = 0, @id_parque = 999, @id_tipo_actividad_turistica = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_actividad_turistica_modificacion @id_actividad_turistica = 1, @nombre = 'Tour Garganta del Diablo', @duracion_horas = 3.0, @costo = 2000.00, @cupo_maximo = 45, @id_parque = 1, @id_tipo_actividad_turistica = 1;
-- Caso no exitoso (ID inexistente, Nombre vac�o, Duraci�n, costo, cupo inv�lido, FKs inexistentes)
EXEC parques.sp_actividad_turistica_modificacion @id_actividad_turistica = 999, @nombre = '', @duracion_horas = 0, @costo = -500, @cupo_maximo = 0, @id_parque = 999, @id_tipo_actividad_turistica = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC parques.sp_actividad_turistica_baja @id_actividad_turistica = 2;
-- Caso no exitoso (ID inexistente)
EXEC parques.sp_actividad_turistica_baja @id_actividad_turistica = 999;

-- ==========================================================
--  ESQUEMA: rrhh
-- ==========================================================
----------------------------------------------------------
-- rrhh.titulo
----------------------------------------------------------
SELECT * FROM rrhh.titulo;
-- Caso exitoso
EXEC rrhh.sp_titulo_alta @descripcion = 'Licenciado en Turismo';
EXEC rrhh.sp_titulo_alta @descripcion = 'A Borrar';
-- Caso no exitoso (Nombre vac�o)
EXEC rrhh.sp_titulo_alta @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC rrhh.sp_titulo_modificacion @id_titulo = 1, @descripcion = 'Lic. en Turismo y Hoteler�a';
-- Caso no exitoso(ID inexistente, Nombre vac�o)
EXEC rrhh.sp_titulo_modificacion @id_titulo = 999, @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC rrhh.sp_titulo_baja @id_titulo = 2;
-- Caso no exitoso (ID inexistente)
EXEC rrhh.sp_titulo_baja @id_titulo = 999;

----------------------------------------------------------
-- rrhh.especialidad
----------------------------------------------------------
SELECT * FROM rrhh.especialidad;
-- Caso exitoso
EXEC rrhh.sp_especialidad_alta @descripcion = 'Observaci�n de Aves';
EXEC rrhh.sp_especialidad_alta @descripcion = 'A Borrar';
-- Caso no exitoso (Nombre vac�o)
EXEC rrhh.sp_especialidad_alta @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC rrhh.sp_especialidad_modificacion @id_especialidad = 1, @descripcion = 'Avistaje de Flora y Fauna';
-- Caso no exitoso(ID inexistente, Nombre vac�o)
EXEC rrhh.sp_especialidad_modificacion @id_especialidad = 999, @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC rrhh.sp_especialidad_baja @id_especialidad = 2;
-- Caso no exitoso (ID inexistente)
EXEC rrhh.sp_especialidad_baja @id_especialidad = 999;

----------------------------------------------------------
-- rrhh.estado_guia
----------------------------------------------------------
SELECT * FROM rrhh.estado_guia;
-- Caso exitoso
EXEC rrhh.sp_estado_guia_alta @descripcion = 'Inactivo';
EXEC rrhh.sp_estado_guia_alta @descripcion = 'Retirado';
EXEC rrhh.sp_estado_guia_alta @descripcion = 'Suspendido';
-- Caso no exitoso (Nombre vac�o, falla del CHECK)
EXEC rrhh.sp_estado_guia_alta @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC rrhh.sp_estado_guia_modificacion @id_estado_guia = 1, @descripcion = 'Activo';
-- Caso no exitoso (ID inexistente, Nombre vac�o, falla del CHECK)
EXEC rrhh.sp_estado_guia_modificacion @id_estado_guia = 999, @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC rrhh.sp_estado_guia_baja @id_estado_guia = 2;
-- Caso no exitoso (ID inexistente)
EXEC rrhh.sp_estado_guia_baja @id_estado_guia = 999;

----------------------------------------------------------
-- rrhh.guardaparques
----------------------------------------------------------
SELECT * FROM rrhh.guardaparques;
-- Caso exitoso 
EXEC rrhh.sp_guardaparques_alta @legajo = 'GP-001', @apellido_y_nombre = 'Gomez, Ana', @fecha_nacimiento = '1990-05-15', @telefono = '1122334455', @email = 'ana@parques.gob.ar';
EXEC rrhh.sp_guardaparques_alta @legajo = 'GP-002', @apellido_y_nombre = 'A Borrar', @fecha_nacimiento = '1985-10-20', @telefono = '000', @email = 'borrar@parques.gob.ar';
-- Caso no exitoso (Legajo/Nombre/Email vac�os, fecha futura)
EXEC rrhh.sp_guardaparques_alta @legajo = '', @apellido_y_nombre = '', @fecha_nacimiento = '2050-01-01', @telefono = NULL, @email = '';
----------------------------------------------------------
-- Caso exitoso
EXEC rrhh.sp_guardaparques_modificacion @id_guardaparques = 1, @legajo = 'GP-001', @apellido_y_nombre = 'G�mez, Ana Mar�a', @fecha_nacimiento = '1990-05-15', @telefono = '1122334455', @email = 'anamaria@parques.gob.ar', @activo = 1;
-- Caso no exitoso (ID inexistente, Legajo/Nombre/Email vac�os, fecha futura)
EXEC rrhh.sp_guardaparques_modificacion @id_guardaparques = 999, @legajo = '', @apellido_y_nombre = '', @fecha_nacimiento = '2050-01-01', @telefono = NULL, @email = '', @activo = 1;
----------------------------------------------------------
-- Caso exitoso
EXEC rrhh.sp_guardaparques_baja @id_guardaparques = 2;
-- Caso no exitoso (ID inexistente)
EXEC rrhh.sp_estado_guia_baja @id_estado_guia = 999;

----------------------------------------------------------
-- rrhh.asignacion_guardaparques
----------------------------------------------------------
SELECT * FROM rrhh.asignacion_guardaparques;
-- Caso exitoso
EXEC rrhh.sp_asignacion_guardaparques_alta @id_guardaparques = 1, @id_parque = 1, @fecha_ingreso = '2025-01-01';
-- Caso no exitoso (Guardaparque inexistente, Parque inexistente, Fecha de ingreso nula)
EXEC rrhh.sp_asignacion_guardaparques_alta @id_guardaparques = 999, @id_parque = 999, @fecha_ingreso = NULL;
----------------------------------------------------------
-- Caso exitoso (Egreso)
EXEC rrhh.sp_asignacion_guardaparques_egreso @id_guardaparques = 1, @fecha_egreso = '2026-01-01', @motivo_egreso = 'Traslado';
-- Caso no exitoso (No tiene asignacion activa, Fecha egreso nula)
EXEC rrhh.sp_asignacion_guardaparques_egreso @id_guardaparques = 999, @fecha_egreso = NULL, @motivo_egreso = 'N/A';

----------------------------------------------------------
-- rrhh.guia
----------------------------------------------------------
SELECT * FROM rrhh.guia;
-- Caso exitoso
EXEC rrhh.sp_guia_alta @legajo = 'GU-01', @apellido_y_nombre = 'Perez, Juan', @fecha_nacimiento = '1988-11-03', @email = 'juan@guias.com', @telefono = '123456', @id_titulo = 1, @id_especialidad = 1, @id_estado_guia = 1;
EXEC rrhh.sp_guia_alta @legajo = 'GU-02', @apellido_y_nombre = 'Borrable', @fecha_nacimiento = '1992-04-12', @email = 'del@guias.com', @telefono = '000', @id_titulo = NULL, @id_especialidad = 1, @id_estado_guia = 1;
-- Caso no exitoso(Legajo vac�o, Nombre vac�o, Fecha futura, Email vac�o, FKs inexistentes)
EXEC rrhh.sp_guia_alta @legajo = '', @apellido_y_nombre = '', @fecha_nacimiento = '2050-01-01', @email = '', @telefono = NULL, @id_titulo = 999, @id_especialidad = 999, @id_estado_guia = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC rrhh.sp_guia_modificacion @id_guia = 1, @legajo = 'GU-001', @apellido_y_nombre = 'P�rez, Juan Jos�', @fecha_nacimiento = '1988-11-03', @email = 'juanj@guias.com', @telefono = '123456', @id_titulo = 1, @id_especialidad = 1, @id_estado_guia = 1;
-- Caso no exitoso (ID inexistente, Legajo vac�o, Nombre vac�o, Fecha futura, Email vac�o, FKs inexistentes)
EXEC rrhh.sp_guia_modificacion @id_guia = 999, @legajo = '', @apellido_y_nombre = '', @fecha_nacimiento = '2050-01-01', @email = '', @telefono = NULL, @id_titulo = 999, @id_especialidad = 999, @id_estado_guia = 999;
----------------------------------------------------------
-- Caso exitoso 
EXEC rrhh.sp_guia_baja @id_guia = 2, @id_estado_baja = 3;
-- Caso no exitoso (ID inexistente, Estado inexistente)
EXEC rrhh.sp_guia_baja @id_guia = 999, @id_estado_baja = 999;

----------------------------------------------------------
-- rrhh.autorizacion
----------------------------------------------------------
SELECT * FROM rrhh.autorizacion;
-- Caso exitoso
EXEC rrhh.sp_autorizacion_alta @id_guia = 1, @fecha_emision = '2025-01-01', @fecha_vencimiento = '2026-01-01';
EXEC rrhh.sp_autorizacion_alta @id_guia = 1, @fecha_emision = '2026-01-02', @fecha_vencimiento = '2027-01-01';
-- Caso no exitoso (Gu�a inexistente, Vencimiento < Emisi�n)
EXEC rrhh.sp_autorizacion_alta @id_guia = 999, @fecha_emision = '2026-01-01', @fecha_vencimiento = '2025-01-01';
----------------------------------------------------------
-- Caso exitoso
EXEC rrhh.sp_autorizacion_modificacion @id_autorizacion = 1, @fecha_vencimiento = '2026-12-31';
-- Caso no exitoso (Gu�a inexistente, Fecha nula)
EXEC rrhh.sp_autorizacion_modificacion @id_autorizacion = 999, @fecha_vencimiento = NULL;
----------------------------------------------------------
-- Caso exitoso
EXEC rrhh.sp_autorizacion_baja @id_autorizacion = 2;
-- Caso no exitoso (ID inexistente)
EXEC rrhh.sp_autorizacion_baja @id_autorizacion = 999;

-- ==========================================================
--  ESQUEMA: ventas
-- ==========================================================
----------------------------------------------------------
-- ventas.punto_venta
----------------------------------------------------------
SELECT * FROM ventas.punto_venta;
-- Caso exitoso
EXEC ventas.sp_punto_venta_alta @descripcion = 'Boleter�a Principal';
EXEC ventas.sp_punto_venta_alta @descripcion = 'A Borrar';
-- Caso no exitoso (Nombre vac�o)
EXEC ventas.sp_punto_venta_alta @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_punto_venta_modificacion @id_punto_venta = 1, @descripcion = 'Boleter�a Norte';
-- Caso no exitoso (ID inexistente, Nombre vac�o)
EXEC ventas.sp_punto_venta_modificacion @id_punto_venta = 999, @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_punto_venta_baja @id_punto_venta = 2;
-- Caso no exitoso (ID inexistente)
EXEC ventas.sp_punto_venta_baja @id_punto_venta = 999;

----------------------------------------------------------
-- ventas.forma_pago
----------------------------------------------------------
SELECT * FROM ventas.forma_pago;
-- Caso exitoso
EXEC ventas.sp_forma_pago_alta @descripcion = 'Efectivo';
EXEC ventas.sp_forma_pago_alta @descripcion = 'A Borrar';
-- Caso no exitoso (Nombre vac�o)
EXEC ventas.sp_forma_pago_alta @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_forma_pago_modificacion @id_forma_pago = 1, @descripcion = 'Mercado Pago';
-- Caso no exitoso (ID inexistente, Nombre vac�o)
EXEC ventas.sp_forma_pago_modificacion @id_forma_pago = 999, @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_forma_pago_baja @id_forma_pago = 2;
-- Caso no exitoso (ID inexistente)
EXEC ventas.sp_forma_pago_baja @id_forma_pago = 999;

----------------------------------------------------------
--  ventas.clima
----------------------------------------------------------
SELECT * FROM ventas.clima;
-- Caso exitoso
EXEC ventas.sp_clima_alta @descripcion = 'Nublado';
EXEC ventas.sp_clima_alta @descripcion = 'A Borrar';
-- Caso no exitoso (Nombre vac�o)
EXEC ventas.sp_clima_alta @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_clima_modificacion @id_clima = 1, @descripcion = 'Soleado';
-- Caso no exitoso (ID inexistente, Nombre vac�o)
EXEC ventas.sp_clima_modificacion @id_clima = 999, @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_clima_baja @id_clima = 2;
-- Caso no exitoso (ID inexistente)
EXEC ventas.sp_clima_baja @id_clima = 999;

----------------------------------------------------------
-- ventas.tipo_moneda
----------------------------------------------------------
SELECT * FROM ventas.tipo_moneda;
-- Caso exitoso
EXEC ventas.sp_tipo_moneda_alta @descripcion = 'Peso', @valor = 1.0;
EXEC ventas.sp_tipo_moneda_alta @descripcion = 'A Borrar', @valor = 5.0;
-- Caso no exitoso (Nombre vac�o, Valor negativo)
EXEC ventas.sp_tipo_moneda_alta @descripcion = '', @valor = -1.0;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_tipo_moneda_modificacion @id_tipo_moneda = 1, @descripcion = 'Pesos Argentinos (ARS)', @valor = 1.0;
-- Caso no exitoso (ID inexistente, Nombre vac�o, Valor negativo)
EXEC ventas.sp_tipo_moneda_modificacion @id_tipo_moneda = 999, @descripcion = '', @valor = -1.0;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_tipo_moneda_baja @id_tipo_moneda = 2;
-- Caso no exitoso (ID inexistente)
EXEC ventas.sp_tipo_moneda_baja @id_tipo_moneda = 999;

----------------------------------------------------------
-- ventas.pago
----------------------------------------------------------
SELECT * FROM ventas.pago;
-- Caso exitoso
EXEC ventas.sp_pago_alta @monto = 6000.00, @id_tipo_moneda = 1, @id_forma_pago = 1;
EXEC ventas.sp_pago_alta @monto = 9000.00, @id_tipo_moneda = 1, @id_forma_pago = 1;
-- Caso no exitoso (Monto 0, FKs inexistentes)
EXEC ventas.sp_pago_alta @monto = 0.00, @id_tipo_moneda = 999, @id_forma_pago = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_pago_modificacion @id_pago = 1, @monto = 6500.00, @id_tipo_moneda = 1, @id_forma_pago = 1;
-- Caso no exitoso (ID inexistente, Monto 0, FKs inexistentes)
EXEC ventas.sp_pago_modificacion @id_pago = 999, @monto = 0, @id_tipo_moneda = 999, @id_forma_pago = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_pago_baja @id_pago = 2;
-- Caso no exitoso (ID inexistente)
EXEC ventas.sp_pago_baja @id_pago = 999;

----------------------------------------------------------
-- ventas.venta
----------------------------------------------------------
SELECT * FROM ventas.venta;
-- Caso exitoso
EXEC ventas.sp_venta_alta @total = 6500.00, @id_punto_venta = 1, @id_parque = 1, @id_pago = 1;
EXEC ventas.sp_venta_alta @total = 1000.00, @id_punto_venta = 1, @id_parque = 1, @id_pago = NULL;
-- Caso no exitoso (Total negativo, FKs inexistentes)
EXEC ventas.sp_venta_alta @total = -100.00, @id_punto_venta = 999, @id_parque = 999, @id_pago = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_venta_modificacion @id_venta = 1, @total = 7000.00, @id_punto_venta = 1, @id_parque = 1, @id_pago = 1;
-- Caso no exitoso (ID inexistente, Total negativo, FKs inexistentes)
EXEC ventas.sp_venta_modificacion @id_venta = 999, @total = -100.00, @id_punto_venta = 999, @id_parque = 999, @id_pago = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_venta_baja @id_venta = 2;
-- Caso no exitoso (ID inexistente)
EXEC ventas.sp_venta_baja @id_venta = 999;

----------------------------------------------------------
-- ventas.detalle_venta
----------------------------------------------------------
SELECT * FROM ventas.detalle_venta;
-- Caso exitoso 
EXEC ventas.sp_detalle_venta_alta @cantidad = 1, @precio_unitario = 6000.00, @id_venta = 1;
EXEC ventas.sp_detalle_venta_alta @cantidad = 2, @precio_unitario = 500.00, @id_venta = 1;
EXEC ventas.sp_detalle_venta_alta @cantidad = 2, @precio_unitario = 600.00, @id_venta = 1;
EXEC ventas.sp_detalle_venta_alta @cantidad = 1, @precio_unitario = 1000.00, @id_venta = 1; 
-- Caso no exitoso (Cantidad cero, Precio negativo, Venta inexistente)
EXEC ventas.sp_detalle_venta_alta @cantidad = 0, @precio_unitario = -100.00, @id_venta = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_detalle_venta_modificacion @id_detalle_venta = 1, @cantidad = 1, @precio_unitario = 6500.00, @id_venta = 1;
-- Caso no exitoso (ID inexistente, Cantidad cero, Precio negativo, Venta inexistente)
EXEC ventas.sp_detalle_venta_modificacion @id_detalle_venta = 999, @cantidad = 0, @precio_unitario = -100.00, @id_venta = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_detalle_venta_baja @id_detalle_venta = 4;
-- Caso no exitoso (ID inexistente)
EXEC ventas.sp_detalle_venta_baja @id_detalle_venta = 999;

----------------------------------------------------------
-- ventas.pase_entrada
----------------------------------------------------------
SELECT * FROM ventas.pase_entrada;
-- Caso exitoso
EXEC ventas.sp_pase_entrada_alta @id_detalle_venta = 1, @fecha_acceso = '2030-01-01', @id_entrada = 1, @id_clima = 1;
EXEC ventas.sp_pase_entrada_alta @id_detalle_venta = 2, @fecha_acceso = '2030-01-01', @id_entrada = 1, @id_clima = 1;
-- Caso no exitoso (Detalle Inexistente, Fecha pasada, FKs inexistentes)
EXEC ventas.sp_pase_entrada_alta @id_detalle_venta = 999, @fecha_acceso = '2000-01-01', @id_entrada = 999, @id_clima = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_pase_entrada_modificacion @id_detalle_venta = 1, @fecha_acceso = '2030-02-01', @id_entrada = 1, @id_clima = 1;
-- Caso no exitoso (Detalle Inexistente, Fecha pasada, FKs inexistentes)
EXEC ventas.sp_pase_entrada_modificacion @id_detalle_venta = 999, @fecha_acceso = '2000-01-01', @id_entrada = 999, @id_clima = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_pase_entrada_baja @id_detalle_venta = 2;
-- Caso no exitoso (Detalle Inexistente)
EXEC ventas.sp_pase_entrada_baja @id_detalle_venta = 999;

----------------------------------------------------------
-- ventas.actividad_programada
----------------------------------------------------------
SELECT * FROM ventas.actividad_programada;
-- Caso exitoso
EXEC ventas.sp_actividad_programada_alta @fecha_hora = '2030-10-10 10:00:00', @id_actividad_turistica = 1, @id_guia = 1;
EXEC ventas.sp_actividad_programada_alta @fecha_hora = '2030-10-10 14:00:00', @id_actividad_turistica = 1, @id_guia = NULL; 
-- Caso no exitoso (Fecha pasada, FKs inexistentes)
EXEC ventas.sp_actividad_programada_alta @fecha_hora = '2000-01-01 10:00:00', @id_actividad_turistica = 999, @id_guia = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_actividad_programada_modificacion @id_actividad_programada = 1, @fecha_hora = '2030-10-10 11:00:00', @id_actividad_turistica = 1, @id_guia = 1;
-- Caso no exitoso (ID inexistente, Fecha pasada, FKs inexistentes)
EXEC ventas.sp_actividad_programada_modificacion @id_actividad_programada = 999, @fecha_hora = '2000-01-01 10:00:00', @id_actividad_turistica = 999, @id_guia = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_actividad_programada_baja @id_actividad_programada = 2;
-- Caso no exitoso (ID inexistente)
EXEC ventas.sp_actividad_programada_baja @id_actividad_programada = 999;

----------------------------------------------------------
-- ventas.pase_actividad
----------------------------------------------------------
SELECT * FROM ventas.pase_actividad;
-- Caso exitoso
EXEC ventas.sp_pase_actividad_alta @id_detalle_venta = 2, @id_actividad_programada = 1;
EXEC ventas.sp_pase_actividad_alta @id_detalle_venta = 3, @id_actividad_programada = 1;
-- Caso no exitoso (Detalle inexistente, Actividad programada inexistente)
EXEC ventas.sp_pase_actividad_alta @id_detalle_venta = 999, @id_actividad_programada = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_pase_actividad_modificacion @id_detalle_venta = 2, @id_actividad_programada = 1;
-- Caso no exitoso (Detalle inexistente, Actividad programada inexistente)
EXEC ventas.sp_pase_actividad_modificacion @id_detalle_venta = 999, @id_actividad_programada = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC ventas.sp_pase_actividad_baja @id_detalle_venta = 3;
-- Caso no exitoso (Detalle inexistente)
EXEC ventas.sp_pase_actividad_baja @id_detalle_venta = 999;

-- ==========================================================
--  ESQUEMA: concesiones
-- ==========================================================
----------------------------------------------------------
-- concesiones.empresa
----------------------------------------------------------
SELECT * FROM concesiones.empresa;
-- Caso exitoso
EXEC concesiones.sp_empresa_alta @nombre = 'McDonalds', @direccion = 'Av Siempre Viva 123', @telefono = '112233', @email = 'mc@contacto.com';
EXEC concesiones.sp_empresa_alta @nombre = 'A Borrar', @direccion = 'xxx', @telefono = '0', @email = 'del@contacto.com';
-- Caso no exitoso (Nombre vac�o, Direccon vac�a, Email vac�o)
EXEC concesiones.sp_empresa_alta @nombre = '', @direccion = '', @telefono = NULL, @email = '';
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_empresa_modificacion @id_empresa = 1, @nombre = 'Arcos Dorados S.A.', @direccion = 'Av Siempreviva 123', @telefono = '112233', @email = 'mc@contacto.com';
-- Caso no exitoso (ID inexistente, Nombre vac�o, Direccon vac�a, Email vac�o)
EXEC concesiones.sp_empresa_modificacion @id_empresa = 999, @nombre = '', @direccion = '', @telefono = NULL, @email = '';
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_empresa_baja @id_empresa = 2;
-- Caso no exitoso (ID inexistente)
EXEC concesiones.sp_empresa_baja @id_empresa = 999;

----------------------------------------------------------
-- tipo_actividad_concesion
----------------------------------------------------------
SELECT * FROM concesiones.tipo_actividad_concesion;
-- Caso exitoso
EXEC concesiones.sp_tipo_actividad_concesion_alta @descripcion = 'Gastronom�a';
EXEC concesiones.sp_tipo_actividad_concesion_alta @descripcion = 'A Borrar';
-- Caso no exitoso (Nombre vac�o)
EXEC concesiones.sp_tipo_actividad_concesion_alta @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_tipo_actividad_concesion_modificacion @id_tipo_actividad_concesion = 1, @descripcion = 'Local Gastron�mico';
-- Caso no exitoso (ID inexistente, Nombre vac�o)
EXEC concesiones.sp_tipo_actividad_concesion_modificacion @id_tipo_actividad_concesion = 999, @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_tipo_actividad_concesion_baja @id_tipo_actividad_concesion = 2;
-- Caso no exitoso (ID inexistente)
EXEC concesiones.sp_tipo_actividad_concesion_baja @id_tipo_actividad_concesion = 999;

----------------------------------------------------------
-- concesiones.estado_canon
----------------------------------------------------------
SELECT * FROM concesiones.estado_canon;
-- Caso exitoso
EXEC concesiones.sp_estado_canon_alta @descripcion = 'Pendiente';
EXEC concesiones.sp_estado_canon_alta @descripcion = 'Pagado';
-- Caso no exitoso (Nombre vac�o, falla del CHECK)
EXEC concesiones.sp_estado_canon_alta @descripcion = '';
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_estado_canon_modificacion @id_estado_canon = 1, @descripcion = 'Pendiente'; 
-- Caso no exitoso (ID inexistente, Nombre vac�o, falla del CHECK)
EXEC concesiones.sp_estado_canon_modificacion @id_estado_canon = 999, @descripcion = ''; 
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_estado_canon_baja @id_estado_canon = 2;
-- Caso no exitoso (ID inexistente)
EXEC concesiones.sp_estado_canon_baja @id_estado_canon = 999;

----------------------------------------------------------
-- concesiones.contrato_concesion
----------------------------------------------------------
SELECT * FROM concesiones.contrato_concesion;
-- Caso exitoso
EXEC concesiones.sp_contrato_concesion_alta @fecha_inicio = '2025-01-01', @fecha_fin = '2030-01-01', @monto_mensual = 500000.00, @id_empresa = 1, @id_tipo_actividad_concesion = 1, @id_parque = 1;
EXEC concesiones.sp_contrato_concesion_alta @fecha_inicio = '2025-01-01', @fecha_fin = '2026-01-01', @monto_mensual = 1000.00, @id_empresa = 1, @id_tipo_actividad_concesion = 1, @id_parque = 1; 
-- Caso no exitoso (Fechas invertidas, Monto Cero, FKs inexistentes)
EXEC concesiones.sp_contrato_concesion_alta @fecha_inicio = '2030-01-01', @fecha_fin = '2025-01-01', @monto_mensual = 0, @id_empresa = 999, @id_tipo_actividad_concesion = 999, @id_parque = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_contrato_concesion_modificacion @id_contrato_concesion = 1, @fecha_inicio = '2025-01-01', @fecha_fin = '2030-12-31', @monto_mensual = 550000.00, @id_empresa = 1, @id_tipo_actividad_concesion = 1, @id_parque = 1;
-- Caso no exitoso (ID inexistente, Fechas invertidas, Monto Cero, FKs inexistentes)
EXEC concesiones.sp_contrato_concesion_modificacion @id_contrato_concesion = 999, @fecha_inicio = '2030-01-01', @fecha_fin = '2025-01-01', @monto_mensual = 0, @id_empresa = 999, @id_tipo_actividad_concesion = 999, @id_parque = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_contrato_concesion_baja @id_contrato_concesion = 2;
-- Caso no exitoso (ID inexistente)
EXEC concesiones.sp_contrato_concesion_baja @id_contrato_concesion = 999;

----------------------------------------------------------
-- concesiones.canon
----------------------------------------------------------
SELECT * FROM concesiones.canon;
-- Caso exitoso
EXEC concesiones.sp_canon_alta @fecha_vencimiento = '2025-02-10', @importe = 550000.00, @id_contrato_concesion = 1, @id_estado_canon = 1;
EXEC concesiones.sp_canon_alta @fecha_vencimiento = '2025-03-10', @importe = 550000.00, @id_contrato_concesion = 1, @id_estado_canon = 1;
-- Caso no exitoso (Fecha NULL, Importe Negativo, FKs Inexistentes)
EXEC concesiones.sp_canon_alta @fecha_vencimiento = NULL, @importe = -100.00, @id_contrato_concesion = 999, @id_estado_canon = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_canon_modificacion @id_canon = 1, @fecha_vencimiento = '2025-02-15', @importe = 550000.00, @id_contrato_concesion = 1, @id_estado_canon = 1;
-- Caso no exitoso (ID inexistente, Fecha NULL, Importe Negativo, FKs Inexistentes)
EXEC concesiones.sp_canon_modificacion @id_canon = 999,  @fecha_vencimiento = NULL, @importe = -100.00, @id_contrato_concesion = 999, @id_estado_canon = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_canon_baja @id_canon = 2;
-- Caso no exitoso (ID inexistente)
EXEC concesiones.sp_canon_baja @id_canon = 999;

----------------------------------------------------------
-- concesiones.pago_canon
----------------------------------------------------------
SELECT * FROM concesiones.pago_canon;
-- Caso exitoso
EXEC concesiones.sp_pago_canon_alta @monto = 550000.00, @id_canon = 1;
EXEC concesiones.sp_pago_canon_alta @monto = 100.00, @id_canon = 1; 
-- Caso no exitoso (Monto negativo, FK inexistente)
EXEC concesiones.sp_pago_canon_alta @monto = -50.00, @id_canon = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_pago_canon_modificacion @id_pago = 1, @monto = 550000.00, @id_canon = 1;
-- Caso no exitoso (ID inexistente, Monto negativo, FK inexistente)
EXEC concesiones.sp_pago_canon_modificacion @id_pago = 999, @monto = -50.00, @id_canon = 999;
----------------------------------------------------------
-- Caso exitoso
EXEC concesiones.sp_pago_canon_baja @id_pago = 2;
-- Caso no exitoso (ID inexistente)
EXEC concesiones.sp_pago_canon_baja @id_pago = 999;