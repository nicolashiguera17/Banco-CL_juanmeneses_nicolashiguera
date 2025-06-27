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

-- 10. Validar y suspender tarjetas con tres cuotas vencidas al finalizar cada semana.

-- 11. Migrar cuotas vencidas de un mes al historial el primer día del mes siguiente.

-- 12. Asignar promociones especiales automáticamente cada viernes del mes.

-- 13. Recalcular el saldo pendiente de cada cliente el primer día del mes.

-- 14. Crear copias de seguridad lógicas de pagos y cuotas cada día a las 2:00 AM.

-- 15. Reasignar automáticamente métodos de pago inactivos después de 90 días.

-- 16. Enviar resumen de descuentos aplicados a cada cliente el último día del mes.

-- 17. Recalcular estadísticas de uso de promociones cada semana.

-- 18. Verificar y corregir inconsistencias en transacciones todos los domingos.

-- 19. Eliminar automáticamente registros de alertas antiguas cada mes.

-- 20. Cerrar el ciclo mensual de gestión de pagos y generar reporte anual en diciembre.

-- 1. Generar reportes automáticos de cuotas de manejo al finalizar cada mes.
-- 3. Enviar alertas por correo electrónico cuando se registre un pago pendiente de más de un mes.
-- 5. Actualizar los registros de pagos mensuales de clientes a partir de las transacciones realizadas.
-- 7. Borrar registros temporales y logs de sistema cada domingo a medianoche.
-- 9. Generar un resumen semanal de transacciones para la gerencia.
-- 11. Migrar cuotas vencidas de un mes al historial el primer día del mes siguiente.
-- 13. Recalcular el saldo pendiente de cada cliente el primer día del mes.
-- 15. Reasignar automáticamente métodos de pago inactivos después de 90 días.
-- 17. Recalcular estadísticas de uso de promociones cada semana.
-- 19. Eliminar automáticamente registros de alertas antiguas cada mes.