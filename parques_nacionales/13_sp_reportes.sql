/*
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas (5600)
Cuatrimestre: 2026 - Primer Cuatrimestre, viernes tarde

Integrantes:
Mamani Estrada, Lucas Gabriel - 43624305 
Juarez, Javier David - 43446615 
Corpu, Matias Ariel - 43744403 
Capandegui, Damian Leonel - 45807823 

Grupo: 4

Script de la Entrega 7.
*/

USE BD_Parques_Nacionales;
GO

-- REPORTE 1
-- STORE PROCEDURE — REPORTE DE VISITAS POR SEMANA, MES Y AÑO, POR PARQUE.
-- PARAMETROS: @tipoPeriodo ('A' para reporte Anual, 'M' para reporte Mensual, 'S' para reporte Semanal).
--             @nombreParque (Nombre de un parque registrado en la tabla Parques). 

CREATE OR ALTER PROCEDURE ventas.sp_reporte_visitas
(
    @tipoPeriodo CHAR(1),
    @nombreParque VARCHAR(150)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @tipoPeriodo NOT IN ('S','M','A')
    BEGIN
        RAISERROR(
            'El tipo de periodo debe ser S (Semana), M (Mes) o A (Año).',
            16,
            1
        );
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM parques.parque
        WHERE nombre = @nombreParque
    )
    BEGIN
        RAISERROR(
            'El parque indicado no existe.',
            16,
            1
        );
        RETURN;
    END;

    IF @tipoPeriodo = 'A'
    BEGIN
        SELECT
            p.nombre AS Nombre,
            YEAR(pe.fecha_acceso) AS Año,
            SUM(dv.cantidad) AS Cantidad_Visitantes
        FROM parques.parque p
        INNER JOIN parques.entrada e
            ON e.id_parque = p.id_parque
        INNER JOIN ventas.pase_entrada pe
            ON pe.id_entrada = e.id_entrada
        INNER JOIN ventas.detalle_venta dv
            ON dv.id_detalle_venta = pe.id_detalle_venta
        WHERE p.nombre = @nombreParque
        GROUP BY
            p.nombre,
            YEAR(pe.fecha_acceso)
        ORDER BY
            Año;
    END

    ELSE IF @tipoPeriodo = 'M'
    BEGIN
        SELECT
            p.nombre AS Nombre,
            YEAR(pe.fecha_acceso) AS Año,
            MONTH(pe.fecha_acceso) AS Mes,
            SUM(dv.cantidad) AS Cantidad_Visitantes
        FROM parques.parque p
        INNER JOIN parques.entrada e
            ON e.id_parque = p.id_parque
        INNER JOIN ventas.pase_entrada pe
            ON pe.id_entrada = e.id_entrada
        INNER JOIN ventas.detalle_venta dv
            ON dv.id_detalle_venta = pe.id_detalle_venta
        WHERE p.nombre = @nombreParque
        GROUP BY
            p.nombre,
            YEAR(pe.fecha_acceso),
            MONTH(pe.fecha_acceso)
        ORDER BY
            Año,
            Mes;
    END

    ELSE
    BEGIN
        SELECT
            p.nombre AS Nombre,
            YEAR(pe.fecha_acceso) AS Año,
            DATEPART(ISO_WEEK, pe.fecha_acceso) AS Semana,
            SUM(dv.cantidad) AS Cantidad_Visitantes
        FROM parques.parque p
        INNER JOIN parques.entrada e
            ON e.id_parque = p.id_parque
        INNER JOIN ventas.pase_entrada pe
            ON pe.id_entrada = e.id_entrada
        INNER JOIN ventas.detalle_venta dv
            ON dv.id_detalle_venta = pe.id_detalle_venta
        WHERE p.nombre = @nombreParque
        GROUP BY
            p.nombre,
            YEAR(pe.fecha_acceso),
            DATEPART(ISO_WEEK, pe.fecha_acceso)
        ORDER BY
            Año,
            Semana;
    END
END
GO

-- REPORTE 1
-- STORE PROCEDURE — REPORTE DE VISITAS POR SEMANA, MES Y AÑO, POR PARQUE (SALIDA XML)

CREATE OR ALTER PROCEDURE ventas.sp_reporte_visitas_xml
(
    @tipoPeriodo CHAR(1),
    @nombreParque VARCHAR(150)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @tipoPeriodo NOT IN ('S','M','A')
    BEGIN
        RAISERROR(
            'El tipo de periodo debe ser S (Semana), M (Mes) o A (Año).',
            16,
            1
        );
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM parques.parque
        WHERE nombre = @nombreParque
    )
    BEGIN
        RAISERROR(
            'El parque indicado no existe.',
            16,
            1
        );
        RETURN;
    END;

    IF @tipoPeriodo = 'A'
    BEGIN
        SELECT
            @nombreParque AS '@nombre',
            (
                SELECT
                    YEAR(pe.fecha_acceso) AS '@valor',
                    SUM(dv.cantidad) AS '@visitantes'
                FROM parques.parque p
                INNER JOIN parques.entrada e
                    ON e.id_parque = p.id_parque
                INNER JOIN ventas.pase_entrada pe
                    ON pe.id_entrada = e.id_entrada
                INNER JOIN ventas.detalle_venta dv
                    ON dv.id_detalle_venta = pe.id_detalle_venta
                WHERE p.nombre = @nombreParque
                GROUP BY YEAR(pe.fecha_acceso)
                ORDER BY YEAR(pe.fecha_acceso)
                FOR XML PATH('Año'), TYPE
            )
        FOR XML PATH('Parque'), ROOT('ReporteVisitas');
    END

    ELSE IF @tipoPeriodo = 'M'
    BEGIN
        SELECT
            @nombreParque AS '@nombre',
            (
                SELECT
                    YEAR(pe.fecha_acceso) AS '@anio',
                    MONTH(pe.fecha_acceso) AS '@numero',
                    SUM(dv.cantidad) AS '@visitantes'
                FROM parques.parque p
                INNER JOIN parques.entrada e
                    ON e.id_parque = p.id_parque
                INNER JOIN ventas.pase_entrada pe
                    ON pe.id_entrada = e.id_entrada
                INNER JOIN ventas.detalle_venta dv
                    ON dv.id_detalle_venta = pe.id_detalle_venta
                WHERE p.nombre = @nombreParque
                GROUP BY
                    YEAR(pe.fecha_acceso),
                    MONTH(pe.fecha_acceso)
                ORDER BY
                    YEAR(pe.fecha_acceso),
                    MONTH(pe.fecha_acceso)
                FOR XML PATH('Mes'), TYPE
            )
        FOR XML PATH('Parque'), ROOT('ReporteVisitas');
    END

    ELSE
    BEGIN
        SELECT
            @nombreParque AS '@nombre',
            (
                SELECT
                    YEAR(pe.fecha_acceso) AS '@anio',
                    DATEPART(ISO_WEEK, pe.fecha_acceso) AS '@numero',
                    SUM(dv.cantidad) AS '@visitantes'
                FROM parques.parque p
                INNER JOIN parques.entrada e
                    ON e.id_parque = p.id_parque
                INNER JOIN ventas.pase_entrada pe
                    ON pe.id_entrada = e.id_entrada
                INNER JOIN ventas.detalle_venta dv
                    ON dv.id_detalle_venta = pe.id_detalle_venta
                WHERE p.nombre = @nombreParque
                GROUP BY
                    YEAR(pe.fecha_acceso),
                    DATEPART(ISO_WEEK, pe.fecha_acceso)
                ORDER BY
                    YEAR(pe.fecha_acceso),
                    DATEPART(ISO_WEEK, pe.fecha_acceso)
                FOR XML PATH('Semana'), TYPE
            )
        FOR XML PATH('Parque'), ROOT('ReporteVisitas');
    END
END
GO

-- REPORTE 2
-- STORE PROCEDURE — REPORTE DE INGRESOS POR SEMANA, MES Y AÑO, POR PARQUE.
-- PARAMETROS: @tipoPeriodo ('A' para reporte Anual, 'M' para reporte Mensual, 'S' para reporte Semanal).
--             @nombreParque (Nombre de un parque registrado en la tabla Parques).

CREATE OR ALTER PROCEDURE ventas.sp_reporte_ingresos
(
    @tipoPeriodo CHAR(1),
    @nombreParque VARCHAR(150)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @tipoPeriodo NOT IN ('S','M','A')
    BEGIN
        RAISERROR(
            'El tipo de periodo debe ser S (Semana), M (Mes) o A (Año).',
            16,
            1
        );
        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM parques.parque
        WHERE nombre = @nombreParque
    )
    BEGIN
        RAISERROR(
            'El parque indicado no existe.',
            16,
            1
        );
        RETURN;
    END;

    DECLARE @Ingresos TABLE
    (
        fecha DATETIME2(0),
        ingresos_entradas DECIMAL(25,2),
        ingresos_tours DECIMAL(25,2),
        ingresos_concesiones DECIMAL(25,2)
    );

    INSERT INTO @Ingresos
    (
        fecha,
        ingresos_entradas,
        ingresos_tours,
        ingresos_concesiones
    )

    -- ENTRADAS
    SELECT
        v.fecha_hora,
        SUM(dv.cantidad * dv.precio_unitario),
        CAST(0 AS DECIMAL(25,2)),
        CAST(0 AS DECIMAL(25,2))
    FROM parques.parque p
    INNER JOIN parques.entrada e
        ON e.id_parque = p.id_parque
    INNER JOIN ventas.pase_entrada pe
        ON pe.id_entrada = e.id_entrada
    INNER JOIN ventas.detalle_venta dv
        ON dv.id_detalle_venta = pe.id_detalle_venta
    INNER JOIN ventas.venta v
        ON v.id_venta = dv.id_venta
    WHERE p.nombre = @nombreParque
    GROUP BY v.fecha_hora

    UNION ALL

    -- TOURS
    SELECT
        v.fecha_hora,
        CAST(0 AS DECIMAL(25,2)),
        SUM(dv.cantidad * dv.precio_unitario),
        CAST(0 AS DECIMAL(25,2))
    FROM parques.parque p
    INNER JOIN parques.actividad_turistica at
        ON at.id_parque = p.id_parque
    INNER JOIN ventas.actividad_programada ap
        ON ap.id_actividad_turistica = at.id_actividad_turistica
    INNER JOIN ventas.pase_actividad pa
        ON pa.id_actividad_programada = ap.id_actividad_programada
    INNER JOIN ventas.detalle_venta dv
        ON dv.id_detalle_venta = pa.id_detalle_venta
    INNER JOIN ventas.venta v
        ON v.id_venta = dv.id_venta
    WHERE p.nombre = @nombreParque
    GROUP BY v.fecha_hora

    UNION ALL

    -- CONCESIONES
    SELECT
        pc.fecha_hora,
        CAST(0 AS DECIMAL(25,2)),
        CAST(0 AS DECIMAL(25,2)),
        SUM(pc.monto)
    FROM parques.parque p
    INNER JOIN concesiones.contrato_concesion cc
        ON cc.id_parque = p.id_parque
    INNER JOIN concesiones.canon c
        ON c.id_contrato_concesion = cc.id_contrato_concesion
    INNER JOIN concesiones.pago_canon pc
        ON pc.id_canon = c.id_canon
    WHERE p.nombre = @nombreParque
    GROUP BY pc.fecha_hora;

    -- REPORTE ANUAL
    IF @tipoPeriodo = 'A'
    BEGIN
        SELECT
            YEAR(fecha) AS Año,
            SUM(ingresos_entradas) AS Ingresos_Entradas,
            SUM(ingresos_tours) AS Ingresos_Tours,
            SUM(ingresos_concesiones) AS Ingresos_Concesiones,
            SUM(ingresos_entradas + ingresos_tours + ingresos_concesiones) AS Total_Ingresos
        FROM @Ingresos
        GROUP BY YEAR(fecha)
        ORDER BY Año;
    END

    -- REPORTE MENSUAL
    ELSE IF @tipoPeriodo = 'M'
    BEGIN
        SELECT
            YEAR(fecha) AS Año,
            MONTH(fecha) AS Mes,
            SUM(ingresos_entradas) AS Ingresos_Entradas,
            SUM(ingresos_tours) AS Ingresos_Tours,
            SUM(ingresos_concesiones) AS Ingresos_Concesiones,
            SUM(ingresos_entradas + ingresos_tours + ingresos_concesiones) AS Total_Ingresos
        FROM @Ingresos
        GROUP BY
            YEAR(fecha),
            MONTH(fecha)
        ORDER BY
            Año,
            Mes;
    END

    -- REPORTE SEMANAL
    ELSE
    BEGIN
        SELECT
            YEAR(fecha) AS Año,
            DATEPART(ISO_WEEK, fecha) AS Semana,
            SUM(ingresos_entradas) AS Ingresos_Entradas,
            SUM(ingresos_tours) AS Ingresos_Tours,
            SUM(ingresos_concesiones) AS Ingresos_Concesiones,
            SUM(ingresos_entradas + ingresos_tours + ingresos_concesiones) AS Total_Ingresos
        FROM @Ingresos
        GROUP BY
            YEAR(fecha),
            DATEPART(ISO_WEEK, fecha)
        ORDER BY
            Año,
            Semana;
    END
END;
GO

-- REPORTE 3
-- STORE PROCEDURE — REPORTE DE DEUDORES POR PARQUE.
-- PARAMETROS: @nombreParque (Nombre de un parque registrado en la tabla Parques).
--             @fechaCorte (Fecha que limita cuando alguien que debe un pago pasa a considerarse como deudor).

/* Un canon está adeudado cuando:

1) Fecha_vencimiento < Fecha actual
2) No existe un registro en pago_canon asociado a ese canon

Usamos un parametro de @fechaCorte para mostrar de mejor manera el historico en caso de que la carga de datos incluya fechas muy posteriores o
anteriores a la actual — en un caso real de buscar deudores, se usaria un GETDATE() para la fecha de hoy.
En consistencia de los reportes anteriores, el de los deudores tambien se hara POR PARQUE.
*/

CREATE OR ALTER PROCEDURE concesiones.sp_reporte_deudores
(
    @nombreParque VARCHAR(150),
    @fechaCorte DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM parques.parque
        WHERE nombre = @nombreParque
    )
    BEGIN
        RAISERROR(
            'El parque indicado no existe.',
            16,
            1
        );
        RETURN;
    END;

    SELECT
        p.nombre AS Parque,
        emp.nombre AS Empresa,
        c.fecha_vencimiento AS Fecha_Vencimiento,
        MONTH(c.fecha_vencimiento) AS Mes,
        YEAR(c.fecha_vencimiento) AS Año,
        c.importe AS Monto_Adeudado
    FROM concesiones.canon c
    INNER JOIN concesiones.contrato_concesion cc
        ON cc.id_contrato_concesion = c.id_contrato_concesion
    INNER JOIN concesiones.empresa emp
        ON emp.id_empresa = cc.id_empresa
    INNER JOIN parques.parque p
        ON p.id_parque = cc.id_parque
    WHERE p.nombre = @nombreParque
      AND c.fecha_vencimiento < @fechaCorte
      AND NOT EXISTS
      (
          SELECT 1
          FROM concesiones.pago_canon pc
          WHERE pc.id_canon = c.id_canon
      )
    ORDER BY
        c.fecha_vencimiento;
END;
GO

-- REPORTE 3
-- STORE PROCEDURE — REPORTE DE DEUDORES POR PARQUE (SALIDA XML)

CREATE OR ALTER PROCEDURE concesiones.sp_reporte_deudores_xml
(
    @nombreParque VARCHAR(150),
    @fechaCorte DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM parques.parque
        WHERE nombre = @nombreParque
    )
    BEGIN
        RAISERROR(
            'El parque indicado no existe.',
            16,
            1
        );
        RETURN;
    END;

    SELECT
        p.nombre AS [Parque],
        emp.nombre AS [Empresa],
        c.fecha_vencimiento AS [Fecha_Vencimiento],
        MONTH(c.fecha_vencimiento) AS [Mes],
        YEAR(c.fecha_vencimiento) AS [Año],
        c.importe AS [Monto_Adeudado]
    FROM concesiones.canon c
    INNER JOIN concesiones.contrato_concesion cc
        ON cc.id_contrato_concesion = c.id_contrato_concesion
    INNER JOIN concesiones.empresa emp
        ON emp.id_empresa = cc.id_empresa
    INNER JOIN parques.parque p
        ON p.id_parque = cc.id_parque
    WHERE p.nombre = @nombreParque
      AND c.fecha_vencimiento < @fechaCorte
      AND NOT EXISTS
      (
          SELECT 1
          FROM concesiones.pago_canon pc
          WHERE pc.id_canon = c.id_canon
      )
    ORDER BY
        c.fecha_vencimiento
    FOR XML PATH('Deuda'),
            ROOT('Reporte_Deudores');
END;
GO

-- REPORTE 4
-- STORE PROCEDURE — MATRIZ DE VISITAS USANDO PIVOT.
-- PARAMETROS: @anio (Año sobre el cual hacer el reporte de visitar por mes, por parque).

CREATE OR ALTER PROCEDURE ventas.sp_matriz_visitas
(
    @anio INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Parque,
        ISNULL([1], 0)  AS Enero,
        ISNULL([2], 0)  AS Febrero,
        ISNULL([3], 0)  AS Marzo,
        ISNULL([4], 0)  AS Abril,
        ISNULL([5], 0)  AS Mayo,
        ISNULL([6], 0)  AS Junio,
        ISNULL([7], 0)  AS Julio,
        ISNULL([8], 0)  AS Agosto,
        ISNULL([9], 0)  AS Septiembre,
        ISNULL([10], 0) AS Octubre,
        ISNULL([11], 0) AS Noviembre,
        ISNULL([12], 0) AS Diciembre
    FROM
    (
        SELECT
            p.nombre AS Parque,
            MONTH(pe.fecha_acceso) AS Mes,
            SUM(dv.cantidad) AS Visitantes
        FROM parques.parque p
        INNER JOIN parques.entrada e
            ON e.id_parque = p.id_parque
        INNER JOIN ventas.pase_entrada pe
            ON pe.id_entrada = e.id_entrada
        INNER JOIN ventas.detalle_venta dv
            ON dv.id_detalle_venta = pe.id_detalle_venta
        WHERE YEAR(pe.fecha_acceso) = @anio
        GROUP BY
            p.nombre,
            MONTH(pe.fecha_acceso)
    ) AS DatosOrigen

    PIVOT
    (
        SUM(Visitantes)
        FOR Mes IN
        (
            [1],[2],[3],[4],[5],[6],
            [7],[8],[9],[10],[11],[12]
        )
    ) AS Matriz

    ORDER BY Parque;
END;
GO

-- REPORTE 5
-- STORE PROCEDURE — REPORTE DE PARQUES Y CONCESIONES (COMO VECTOR ANIDADO) (SALIDA XML)
-- PARAMETROS: n/a.

CREATE OR ALTER PROCEDURE concesiones.sp_parques_concesiones_xml
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.nombre AS [Nombre],

        (
            SELECT
                cc.id_contrato_concesion AS [Id_Contrato],
                emp.nombre AS [Titular],
                tac.descripcion AS [Servicio_Prestado],
                cc.fecha_inicio AS [Fecha_Inicio],
                cc.fecha_fin AS [Fecha_Fin],
                cc.monto_mensual AS [Monto_Mensual]

            FROM concesiones.contrato_concesion cc

            INNER JOIN concesiones.empresa emp
                ON emp.id_empresa = cc.id_empresa

            INNER JOIN concesiones.tipo_actividad_concesion tac
                ON tac.id_tipo_actividad_concesion =
                   cc.id_tipo_actividad_concesion

            WHERE cc.id_parque = p.id_parque

            FOR XML PATH('Concesion'), TYPE
        ) AS [Concesiones]

    FROM parques.parque p

    ORDER BY p.nombre

    FOR XML PATH('Parque'),
            ROOT('Reporte_Parques_Concesiones');
END;
GO