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

-- 18. Verificar y corregir inconsistencias en transacciones todos los domingos.

-- 19. Eliminar automáticamente registros de alertas antiguas cada mes.

-- 20. Cerrar el ciclo mensual de gestión de pagos y generar reporte anual en diciembre.

