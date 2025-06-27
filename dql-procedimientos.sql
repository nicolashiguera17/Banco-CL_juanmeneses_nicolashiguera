-- 1. Registrar una nueva cuota de manejo calculando automáticamente el descuento según la tarjeta.--
DELIMITER $$

CREATE PROCEDURE RegistrarCuotaManejo(
    IN p_id_tarjeta BIGINT,
    IN p_monto_base DECIMAL(10,2),
    IN p_fecha_vencimiento DATE
)
BEGIN
    DECLARE v_id_descuento BIGINT;
    DECLARE v_descuento_porcentaje DECIMAL(5,2);
    DECLARE v_monto_final DECIMAL(10,2);

    SELECT id_descuento INTO v_id_descuento
    FROM Tarjetas
    WHERE id_tarjeta = p_id_tarjeta;

    SELECT CAST(descripcion AS DECIMAL(5,2)) INTO v_descuento_porcentaje
    FROM Descuentos
    WHERE id_descuento = v_id_descuento;

    SET v_monto_final = p_monto_base - (p_monto_base * v_descuento_porcentaje / 100);

    INSERT INTO Cuotas_de_Manejo (id_tarjeta, monto, fecha_vencimiento, id_estado_cuota)
    VALUES (p_id_tarjeta, v_monto_final, p_fecha_vencimiento, 1);
END $$

DELIMITER ;


-- 2. Procesar el pago de una cuota de manejo y actualizar el historial de pagos del cliente.

DELIMITER $$


CREATE PROCEDURE ProcesarPagoCuota(
    IN p_id_cuota_manejo INT,
    IN p_monto DECIMAL(10,2),
    IN p_id_metodo INT,
    IN p_estado VARCHAR(20)
)
BEGIN
    INSERT INTO Pagos (id_cuota_manejo, fecha_pago, monto, estado, id_metodo)
    VALUES (p_id_cuota_manejo, CURDATE(), p_monto, p_estado, p_id_metodo);

    UPDATE Cuotas_de_Manejo
    SET id_estado_cuota = (SELECT id_estado_cuota FROM Estado_Cuota WHERE descripcion = 'Pagada')
    WHERE id_cuota_manejo = p_id_cuota_manejo;
END $$

DELIMITER ;

CALL ProcesarPagoCuota(1, 15000.00, 5, 'Completado', '2025-06-26');

-- 3. Generar el reporte mensual de cuotas de manejo por tarjeta y cliente.

DELIMITER $$

CREATE PROCEDURE ReporteMensualCuotas(
    IN p_mes INT,
    IN p_anio INT
)
BEGIN
    SELECT 
        c.id_cliente,
        t.id_tarjeta,
        cm.id_cuota_manejo,
        cm.monto,
        cm.fecha_vencimiento
    FROM 
        Clientes c
    JOIN Tarjetas t ON c.id_cliente = t.id_cliente
    JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
    WHERE 
        MONTH(cm.fecha_vencimiento) = p_mes
        AND YEAR(cm.fecha_vencimiento) = p_anio;
END $$

DELIMITER ;


-- 4. Actualizar los descuentos asignados a tarjetas si se cambian las políticas del banco.

DELIMITER $$

CREATE PROCEDURE ActualizarDescuentosTarjetas(
    IN p_id_tipo_tarjeta INT,
    IN p_id_descuento_nuevo INT
)
BEGIN
    INSERT INTO Historial_Descuentos (id_tarjeta, porcentaje_anterior, porcentaje_nuevo, fecha_cambio)
    SELECT id_tarjeta, 0.0, 0.0, CURDATE()
    FROM Tarjetas
    WHERE id_tipo_tarjeta = p_id_tipo_tarjeta;

    UPDATE Tarjetas
    SET id_descuento = p_id_descuento_nuevo
    WHERE id_tipo_tarjeta = p_id_tipo_tarjeta;
END $$

DELIMITER ;

CALL ActualizarDescuentosTarjetas(1241, 7);

-- 5. Registrar automáticamente un nuevo cliente junto con su primera tarjeta y método de pago.

DELIMITER $$

CREATE PROCEDURE RegistrarClienteConTarjetaYMetodoPago(
    IN p_nombre VARCHAR(100),
    IN p_numero_cuenta VARCHAR(20),
    IN p_telefono VARCHAR(20),
    IN p_correo VARCHAR(100),
    IN p_id_tipo_tarjeta BIGINT,
    IN p_id_descuento BIGINT,
    IN p_id_tipo_pago BIGINT
)
BEGIN
    DECLARE v_id_cliente BIGINT;
    DECLARE v_id_tarjeta BIGINT;

    INSERT INTO Clientes (nombre, numero_cuenta, telefono, correo)
    VALUES (p_nombre, p_numero_cuenta, p_telefono, p_correo);

    SET v_id_cliente = LAST_INSERT_ID();

    INSERT INTO Tarjetas (id_cliente, id_tipo_tarjeta, id_descuento)
    VALUES (v_id_cliente, p_id_tipo_tarjeta, p_id_descuento);

    SET v_id_tarjeta = LAST_INSERT_ID();

    INSERT INTO Metodos_Pago (id_tarjeta, id_tipo_pago)
    VALUES (v_id_tarjeta, p_id_tipo_pago);
END $$

DELIMITER ;


-- 6. Aplicar promociones activas a todas las tarjetas elegibles de los clientes.

DELIMITER $$

CREATE PROCEDURE AplicarPromocionesActivas()
BEGIN
    INSERT INTO Tarjetas_Promociones (id_tarjeta, id_promocion, fecha_aplicacion)
    SELECT t.id_tarjeta, p.id_promocion, CURDATE()
    FROM Tarjetas t, Promociones p
    WHERE p.fecha_inicio <= CURDATE()
    AND p.fecha_fin >= CURDATE();
END $$

DELIMITER ;

CALL AplicarPromocionesActivas();

-- 7. Generar alertas de vencimiento para cuotas de manejo próximas a vencer.

DELIMITER $$

CREATE PROCEDURE AlertasCuotasProximasAVencer()
BEGIN
    SELECT 
        c.id_cliente,
        c.nombre,
        t.id_tarjeta,
        cm.id_cuota_manejo,
        cm.monto,
        cm.fecha_vencimiento
    FROM 
        Clientes c
    JOIN Tarjetas t ON c.id_cliente = t.id_cliente
    JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
    WHERE 
        cm.fecha_vencimiento BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY);
END $$

DELIMITER ;


-- 8. Calcular y registrar el estado de las cuotas (aceptada, vencida, rechazada, etc.) al finalizar el mes.

DELIMITER $$

CREATE PROCEDURE CalcularEstadoCuotas()
BEGIN
    UPDATE Cuotas_de_Manejo cm
    SET id_estado_cuota = (
        CASE
            WHEN EXISTS (SELECT 1 FROM Pagos p WHERE p.id_cuota_manejo = cm.id_cuota_manejo AND p.estado = 'Completado') THEN 5
            WHEN cm.fecha_vencimiento < CURDATE() THEN 3
            ELSE 4
        END
    );
END $$

DELIMITER ;

CALL CalcularEstadoCuotas();

-- 9. Reasignar cuotas impagas a un nuevo período si el pago fue fallido.

DELIMITER $$

CREATE PROCEDURE ReasignarCuotasImpagas()
BEGIN
    UPDATE Cuotas_de_Manejo
    SET fecha_vencimiento = DATE_ADD(fecha_vencimiento, INTERVAL 1 MONTH)
    WHERE id_estado_cuota = 2;
END $$

DELIMITER ;


-- 10. Registrar en lote las cuotas de manejo correspondientes al mes siguiente para todas las tarjetas activas.

DELIMITER $$

CREATE PROCEDURE RegistrarCuotasMesSiguiente()
BEGIN
    INSERT INTO Cuotas_de_Manejo (id_tarjeta, monto, fecha_vencimiento, id_estado_cuota)
    SELECT id_tarjeta, 15000.00, '2025-07-05', 4
    FROM Tarjetas;
END $$

DELIMITER ;

CALL RegistrarCuotasMesSiguiente();

-- 11. Actualizar el estado de una transacción según el resultado del método de pago.

-- 12. Generar un informe consolidado de pagos por tipo de tarjeta y mes.

DELIMITER $$

CREATE PROCEDURE InformePagosPorTipoTarjetaMes()
BEGIN
    SELECT 
        tt.nombre_tipo,
        p.fecha_pago AS mes_pago,
        SUM(p.monto)
    FROM Pagos p, Cuotas_de_Manejo cm, Tarjetas t, Tipos_Tarjeta tt
    WHERE p.id_cuota_manejo = cm.id_cuota_manejo
    AND cm.id_tarjeta = t.id_tarjeta
    AND t.id_tipo_tarjeta = tt.id_tipo_tarjeta
    AND p.estado = 'Completado'
    GROUP BY tt.nombre_tipo, p.fecha_pago;
END $$

DELIMITER ;

CALL InformePagosPorTipoTarjetaMes();

-- 13. Insertar automáticamente el historial de promociones usadas por cada cliente.

-- 14. Suspender temporalmente tarjetas con tres o más cuotas de manejo vencidas.

-- 15. Calcular el monto total adeudado por cliente incluyendo cuotas pendientes y vencidas.

-- 16. Asignar un nuevo método de pago principal a un cliente.

-- 17. Duplicar promociones activas para extender su duración un mes más.

-- 18. Aplicar un descuento especial a todas las cuotas del mes si es Black Friday o fechas especiales.

-- 19. Registrar el resumen mensual de ingresos generados por pagos de cuotas.

-- 20. Eliminar automáticamente los registros de historial de pagos que superen 5 años de antigüedad.
