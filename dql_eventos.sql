-- 1. Generar reportes automáticos de cuotas de manejo al finalizar cada mes.

DELIMITER $$

CREATE EVENT IF NOT EXISTS generar_reporte_cuotas_manejo
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_DATE + INTERVAL 1 MONTH
DO
BEGIN
  INSERT INTO reportes_cuotas_manejo (id_tarjeta, monto, mes, anio)
  SELECT id_tarjeta, cuota_manejo, MONTH(CURRENT_DATE - INTERVAL 1 MONTH), YEAR(CURRENT_DATE - INTERVAL 1 MONTH)
  FROM tarjetas;
END $$

DELIMITER ;


-- 2. Actualizar el estado de las cuotas de manejo al final de cada día.

DELIMITER $$

CREATE EVENT IF NOT EXISTS update_cuotas_manejo_diario
ON SCHEDULE EVERY 1 DAY
STARTS '2025-06-29 23:59:00'
DO
BEGIN
    UPDATE Cuotas_de_Manejo cm
    LEFT JOIN Pagos p ON cm.id_cuota_manejo = p.id_cuota_manejo
    SET cm.id_estado_cuota = 
        CASE
            WHEN p.estado = 'Completado' THEN 5
            WHEN p.estado = 'Reembolsado' THEN 3 
            WHEN (p.id_pago IS NULL OR p.estado IN ('Pendiente', 'Fallido')) AND cm.fecha_vencimiento < CURDATE() THEN 4 
            ELSE 4
        END;
END$$

DELIMITER;

-- 3. Enviar alertas por correo electrónico cuando se registre un pago pendiente de más de un mes.

DELIMITER $$

CREATE EVENT IF NOT EXISTS alerta_pagos_pendientes
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
  INSERT INTO alertas (id_cliente, mensaje, fecha)
  SELECT DISTINCT id_cliente, 'Pago pendiente por más de un mes', NOW()
  FROM transacciones
  WHERE estado = 'pendiente' AND fecha_transaccion < CURRENT_DATE - INTERVAL 1 MONTH;
END $$

DELIMITER ;


-- 4. Recalcular las cuotas de manejo cuando se modifiquen las tarifas de los descuentos.

DELIMITER $$

CREATE EVENT IF NOT EXISTS recalculate_cuotas_manejo_diario
ON SCHEDULE EVERY 1 DAY
STARTS '2025-06-30 23:59:00'
DO
BEGIN
    UPDATE Cuotas_de_Manejo cm
    JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
    JOIN Descuentos d ON t.id_descuento = d.id_descuento
    SET cm.monto = 30000 * (1 - d.porcentaje / 100)
    WHERE cm.id_estado_cuota = 4; -- Solo cuotas pendientes
END $$

DELIMITER;

-- 5. Actualizar los registros de pagos mensuales de clientes a partir de las transacciones realizadas.

DELIMITER $$

CREATE EVENT IF NOT EXISTS actualizar_pagos_mensuales
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN
  UPDATE clientes c
  JOIN (
    SELECT id_cliente, SUM(monto_pagado) AS total_pagado
    FROM transacciones
    WHERE MONTH(fecha_transaccion) = MONTH(CURRENT_DATE - INTERVAL 1 MONTH)
      AND YEAR(fecha_transaccion) = YEAR(CURRENT_DATE - INTERVAL 1 MONTH)
    GROUP BY id_cliente
  ) t ON c.id_cliente = t.id_cliente
  SET c.pagos_mensuales = t.total_pagado;
END $$

DELIMITER ;

-- 6. Registrar automáticamente las nuevas cuotas de manejo para el siguiente mes el día 25.

DELIMITER $$
CREATE EVENT IF NOT EXISTS generate_cuotas_manejo_mensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-07-25 23:59:00'
DO
BEGIN
    INSERT INTO Cuotas_de_Manejo (id_tarjeta, monto, fecha_vencimiento, id_estado_cuota)
    SELECT 
        t.id_tarjeta,
        30000 * (1 - d.porcentaje / 100) AS monto,
        LAST_DAY(DATE_ADD(CURDATE(), INTERVAL 1 MONTH)) AS fecha_vencimiento,
        4 AS id_estado_cuota
    FROM Tarjetas t
    JOIN Descuentos d ON t.id_descuento = d.id_descuento;
END $$

DELIMITER ;

-- 7. Borrar registros temporales y logs de sistema cada domingo a medianoche.

DELIMITER $$

CREATE EVENT IF NOT EXISTS limpiar_registros_temporales
ON SCHEDULE EVERY 1 WEEK
STARTS TIMESTAMP(CURRENT_DATE + INTERVAL (7 - WEEKDAY(CURRENT_DATE)) DAY)
DO
BEGIN
  DELETE FROM logs_temporales WHERE fecha < NOW() - INTERVAL 7 DAY;
END $$

DELIMITER ;


-- 8. Actualizar las promociones activas según fecha de inicio y fin todos los días a las 00:00.

DELIMITER $$

CREATE EVENT IF NOT EXISTS update_promociones_activas_diario
ON SCHEDULE EVERY 1 DAY
STARTS '2025-07-01 00:00:00'
DO
BEGIN
    UPDATE Promociones
    SET activa = 
        CASE
            WHEN CURDATE() BETWEEN fecha_inicio AND fecha_fin THEN 1
            ELSE 0
        END;
END $$

DELIMITER;

-- 9. Generar un resumen semanal de transacciones para la gerencia.
DELIMITER $$

CREATE EVENT IF NOT EXISTS resumen_semanal_transacciones
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_DATE + INTERVAL 1 WEEK
DO
BEGIN
  INSERT INTO resumen_transacciones (semana, total_transacciones, total_monto, fecha_generacion)
  SELECT WEEK(CURRENT_DATE - INTERVAL 1 WEEK),
         COUNT(*),
         SUM(monto_total),
         NOW()
  FROM transacciones
  WHERE fecha_transaccion >= CURRENT_DATE - INTERVAL 1 WEEK
    AND fecha_transaccion < CURRENT_DATE;
END $$

DELIMITER ;


-- 10. Validar y suspender tarjetas con tres cuotas vencidas al finalizar cada semana.

DELIMITER $$

CREATE EVENT IF NOT EXISTS suspend_tarjetas_vencidas_semanal
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-07-06 23:59:00' 
DO
BEGIN
    UPDATE Tarjetas t
    JOIN (
        SELECT id_tarjeta
        FROM Cuotas_de_Manejo
        WHERE id_estado_cuota = 4 AND fecha_vencimiento < CURDATE()
        GROUP BY id_tarjeta
        HAVING COUNT(*) >= 3
    ) cm ON t.id_tarjeta = cm.id_tarjeta
    SET t.estado = 'Suspendida';
END $$

DELIMITER;

-- 11. Migrar cuotas vencidas de un mes al historial el primer día del mes siguiente.

DELIMITER $$

CREATE EVENT IF NOT EXISTS migrar_cuotas_vencidas
ON SCHEDULE EVERY 1 MONTH
STARTS DATE_FORMAT(CURRENT_DATE + INTERVAL 1 MONTH, '%Y-%m-01')
DO
BEGIN
  INSERT INTO historial_cuotas (id_transaccion, id_cliente, monto, fecha)
  SELECT id_transaccion, id_cliente, monto_total, NOW()
  FROM transacciones
  WHERE estado = 'vencida';

  DELETE FROM transacciones WHERE estado = 'vencida';
END $$

DELIMITER ;


-- 12. Asignar promociones especiales automáticamente cada viernes del mes.

DELIMITER $$

CREATE EVENT IF NOT EXISTS assign_promociones_especiales_viernes
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-07-04 23:59:00' -- Primer viernes después de la fecha actual
DO
BEGIN
    INSERT INTO Tarjetas_Promociones (id_tarjeta, id_promocion)
    SELECT 
        t.id_tarjeta,
        100 AS id_promocion -- Promoción especial
    FROM Tarjetas t
    WHERE NOT EXISTS (
        SELECT 1 
        FROM Tarjetas_Promociones tp 
        WHERE tp.id_tarjeta = t.id_tarjeta 
        AND tp.id_promocion = 100
        AND YEAR(CURDATE()) = YEAR(CURDATE()) 
        AND MONTH(CURDATE()) = MONTH(CURDATE())
    );
END $$

DELIMITER;

-- 13. Recalcular el saldo pendiente de cada cliente el primer día del mes.

DELIMITER $$

CREATE EVENT IF NOT EXISTS recalcular_saldo_pendiente
ON SCHEDULE EVERY 1 MONTH
STARTS DATE_FORMAT(CURRENT_DATE + INTERVAL 1 MONTH, '%Y-%m-01')
DO
BEGIN
  UPDATE clientes c
  JOIN (
    SELECT id_cliente, SUM(monto_total - monto_pagado) AS saldo
    FROM transacciones
    WHERE estado = 'pendiente'
    GROUP BY id_cliente
  ) t ON c.id_cliente = t.id_cliente
  SET c.saldo_pendiente = t.saldo;
END $$

DELIMITER ;


-- 14. Crear copias de seguridad lógicas de pagos y cuotas cada día a las 2:00 AM.

-- 15. Reasignar automáticamente métodos de pago inactivos después de 90 días.

DELIMITER $$

CREATE EVENT IF NOT EXISTS reasignar_metodos_pago
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
  UPDATE metodos_pago
  SET estado = 'inactivo_reasignado'
  WHERE estado = 'inactivo' AND fecha_ultima_actividad < NOW() - INTERVAL 90 DAY;
END $$

DELIMITER ;


-- 16. Enviar resumen de descuentos aplicados a cada cliente el último día del mes.

-- 17. Recalcular estadísticas de uso de promociones cada semana.

DELIMITER $$

CREATE EVENT IF NOT EXISTS estadisticas_promociones
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_DATE + INTERVAL 1 WEEK
DO
BEGIN
  INSERT INTO estadisticas_promociones (tipo_promocion, total_usos, total_recaudado, semana)
  SELECT tipo_promocion,
         COUNT(*),
         SUM(monto_pagado),
         WEEK(CURRENT_DATE - INTERVAL 1 WEEK)
  FROM transacciones
  WHERE tipo_promocion IS NOT NULL
    AND fecha_transaccion >= CURRENT_DATE - INTERVAL 1 WEEK
    AND fecha_transaccion < CURRENT_DATE
  GROUP BY tipo_promocion;
END $$

DELIMITER ;


-- 18. Verificar y corregir inconsistencias en transacciones todos los domingos.

-- 19. Eliminar automáticamente registros de alertas antiguas cada mes.

DELIMITER $$

CREATE EVENT IF NOT EXISTS eliminar_alertas_antiguas
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN
  DELETE FROM alertas
  WHERE fecha < NOW() - INTERVAL 6 MONTH;
END $$

DELIMITER ;


-- 20. Cerrar el ciclo mensual de gestión de pagos y generar reporte anual en diciembre.

