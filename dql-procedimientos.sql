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

-- 5. Registrar automáticamente un nuevo cliente junto con su primera tarjeta y método de pago.

-- 6. Aplicar promociones activas a todas las tarjetas elegibles de los clientes.

-- 7. Generar alertas de vencimiento para cuotas de manejo próximas a vencer.

-- 8. Calcular y registrar el estado de las cuotas (aceptada, vencida, rechazada, etc.) al finalizar el mes.

-- 9. Reasignar cuotas impagas a un nuevo período si el pago fue fallido.

-- 10. Registrar en lote las cuotas de manejo correspondientes al mes siguiente para todas las tarjetas activas.

-- 11. Actualizar el estado de una transacción según el resultado del método de pago.

-- 12. Generar un informe consolidado de pagos por tipo de tarjeta y mes.

-- 13. Insertar automáticamente el historial de promociones usadas por cada cliente.

-- 14. Suspender temporalmente tarjetas con tres o más cuotas de manejo vencidas.

-- 15. Calcular el monto total adeudado por cliente incluyendo cuotas pendientes y vencidas.

-- 16. Asignar un nuevo método de pago principal a un cliente.

-- 17. Duplicar promociones activas para extender su duración un mes más.

-- 18. Aplicar un descuento especial a todas las cuotas del mes si es Black Friday o fechas especiales.

-- 19. Registrar el resumen mensual de ingresos generados por pagos de cuotas.

-- 20. Eliminar automáticamente los registros de historial de pagos que superen 5 años de antigüedad.
