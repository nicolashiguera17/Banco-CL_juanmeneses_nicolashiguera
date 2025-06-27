-- 1. Calcular la cuota de manejo para un cliente según su tipo de tarjeta y monto de apertura.

DELIMITER $$

CREATE FUNCTION CalcularCuotaManejo(id_cliente BIGINT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE monto DECIMAL(10,2);
  SELECT tt.monto_apertura INTO monto
  FROM Tarjetas t
  JOIN Tipos_Tarjeta tt ON t.id_tipo_tarjeta = tt.id_tipo_tarjeta
  WHERE t.id_cliente = id_cliente
  LIMIT 1;
  RETURN monto;
END $$

DELIMITER ;


-- 2. Estimar el descuento total aplicado sobre la cuota de manejo de una tarjeta.

-- 3. Calcular el saldo pendiente de pago de un cliente.

DELIMITER $$

CREATE FUNCTION saldo_pendiente_cliente(p_id_cliente INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE saldo DECIMAL(10,2);

    SELECT IFNULL(SUM(monto_total - monto_pagado), 0)
    INTO saldo
    FROM transacciones
    WHERE id_cliente = p_id_cliente AND estado = 'pendiente';

    RETURN saldo;
END $$

DELIMITER ;


-- 4. Estimar el total de pagos realizados por tipo de tarjeta durante un período determinado.

-- 5. Calcular el monto total de las cuotas de manejo para todos los clientes de un mes.

DELIMITER $$

CREATE FUNCTION total_cuotas_manejo_por_mes(p_mes INT, p_anio INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT IFNULL(SUM(cuota_manejo), 0)
    INTO total
    FROM tarjetas
    WHERE MONTH(fecha_emision) = p_mes
      AND YEAR(fecha_emision) = p_anio;

    RETURN total;
END $$

DELIMITER ;


-- 6. Determinar si una tarjeta tiene promociones activas en una fecha dada.

-- 7. Obtener el número total de transacciones de un cliente.

DELIMITER $$

CREATE FUNCTION total_transacciones_cliente(p_id_cliente INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;

    SELECT COUNT(*)
    INTO total
    FROM transacciones
    WHERE id_cliente = p_id_cliente;

    RETURN total;
END $$

DELIMITER ;


-- 8. Calcular el promedio de cuotas de manejo pagadas por cliente.

-- 9. Evaluar si una tarjeta está al día con sus pagos.

DELIMITER $$

CREATE FUNCTION tarjeta_al_dia(p_id_tarjeta INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE estado VARCHAR(10);

    IF EXISTS (
        SELECT 1
        FROM transacciones
        WHERE id_tarjeta = p_id_tarjeta
          AND estado = 'pendiente'
    ) THEN
        SET estado = 'NO';
    ELSE
        SET estado = 'SI';
    END IF;

    RETURN estado;
END $$

DELIMITER ;


-- 10. Calcular la edad del cliente según su fecha de nacimiento (si la tabla la incluye).

-- 11. Calcular el total de cuotas vencidas de un cliente.

DELIMITER $$

CREATE FUNCTION total_cuotas_vencidas_cliente(p_id_cliente INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT IFNULL(SUM(monto_total - monto_pagado), 0)
    INTO total
    FROM transacciones
    WHERE id_cliente = p_id_cliente
      AND estado = 'vencida';

    RETURN total;
END $$

DELIMITER ;


-- 12. Determinar el porcentaje de uso de promociones de un cliente.

-- 13. Calcular el total recaudado por un tipo específico de promoción.

DELIMITER $$

CREATE FUNCTION total_recaudado_por_promocion(p_tipo_promocion VARCHAR(50))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT IFNULL(SUM(monto_pagado), 0)
    INTO total
    FROM transacciones
    WHERE tipo_promocion = p_tipo_promocion;

    RETURN total;
END $$

DELIMITER ;


-- 14. Obtener el monto acumulado de pagos de un cliente en el año actual.

-- 15. Evaluar si una tarjeta ha superado el monto de apertura inicial.

-- 16. Calcular cuántos métodos de pago tiene registrado un cliente.

-- 17. Determinar el total de descuentos aplicados en un año específico.

-- 18. Calcular la proporción de pagos en efectivo vs electrónicos por cliente.

-- 19. Obtener el total de cuotas emitidas para un tipo de tarjeta.

-- 20. Evaluar si un cliente es elegible para promociones especiales (por historial).

