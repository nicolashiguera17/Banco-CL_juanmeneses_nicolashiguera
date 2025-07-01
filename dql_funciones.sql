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

DELIMITER $$

CREATE FUNCTION EstimarDescuentoTotal(idTarjeta BIGINT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(30000 - monto) INTO total
    FROM Cuotas_de_Manejo
    WHERE id_tarjeta = idTarjeta;
    RETURN total;
END $$

DELIMITER;

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

DELIMITER $$

CREATE FUNCTION TotalPagosPorTipoTarjeta(idTipoTarjeta BIGINT, fechaInicio DATE, fechaFin DATE) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(p.monto) INTO total
    FROM Pagos p
    JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
    JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
    WHERE t.id_tipo_tarjeta = idTipoTarjeta
    AND p.fecha_pago BETWEEN fechaInicio AND fechaFin;
    RETURN COALESCE(total, 0.00);
END $$

DELIMITER;

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

DELIMITER $$

CREATE FUNCTION TienePromocionesActivas(idTarjeta BIGINT, fechaDada DATE) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE existe INT;
    SELECT COUNT(*) INTO existe
    FROM Tarjetas_Promociones tp
    JOIN Promociones p ON tp.id_promocion = p.id_promocion
    WHERE tp.id_tarjeta = idTarjeta
    AND fechaDada BETWEEN p.fecha_inicio AND p.fecha_fin;
    RETURN existe > 0;
END $$

DELIMITER;

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

DELIMITER $$

CREATE FUNCTION PromedioCuotasPagadas(idCliente BIGINT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(10,2);
    SELECT AVG(p.monto) INTO promedio
    FROM Pagos p
    JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
    JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
    WHERE t.id_cliente = idCliente;
    RETURN COALESCE(promedio, 0.00);
END $$

DELIMITER;

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

DELIMITER $$

CREATE FUNCTION CalcularEdadCliente(idCliente BIGINT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE edad INT;
    SELECT TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) INTO edad
    FROM Clientes
    WHERE id_cliente = idCliente;
    RETURN COALESCE(edad, 0);
END $$

DELIMITER;

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

DELIMITER $$

CREATE FUNCTION PorcentajeUsoPromociones(idCliente BIGINT) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE total INT;
    DECLARE con_promo INT;
    SELECT COUNT(*) INTO total FROM Tarjetas WHERE id_cliente = idCliente;
    SELECT COUNT(*) INTO con_promo FROM Tarjetas_Promociones tp JOIN Tarjetas t ON tp.id_tarjeta = t.id_tarjeta WHERE t.id_cliente = idCliente;
    IF total > 0 THEN
        RETURN (con_promo / total) * 100;
    END IF;
    RETURN 0.00;
END $$

DELIMITER ;

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

DELIMITER $$

CREATE FUNCTION MontoPagosAnual(idCliente BIGINT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(p.monto) INTO total
    FROM Pagos p
    JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
    JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
    WHERE t.id_cliente = idCliente
    AND YEAR(p.fecha_pago) = YEAR(CURDATE());
    RETURN COALESCE(total, 0.00);
END $$

DELIMITER;

-- 15. Evaluar si una tarjeta ha superado el monto de apertura inicial.

DELIMITER $$

CREATE FUNCTION tarjeta_supero_monto_apertura(p_id_tarjeta INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE monto_apertura DECIMAL(10,2);
    DECLARE total_usado DECIMAL(10,2);

    SELECT monto_apertura INTO monto_apertura
    FROM tarjetas
    WHERE id_tarjeta = p_id_tarjeta;

    SELECT IFNULL(SUM(monto_total), 0)
    INTO total_usado
    FROM transacciones
    WHERE id_tarjeta = p_id_tarjeta;

    IF total_usado > monto_apertura THEN
        RETURN 'SI';
    ELSE
        RETURN 'NO';
    END IF;
END $$

DELIMITER ;


-- 16. Calcular cuántos métodos de pago tiene registrado un cliente.

DELIMITER $$

CREATE FUNCTION ContarMetodosPagoCliente(idCliente BIGINT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cantidad INT;
    SELECT COUNT(DISTINCT p.id_metodo) INTO cantidad
    FROM Pagos p
    JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
    JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
    WHERE t.id_cliente = idCliente;
    RETURN COALESCE(cantidad, 0);
END $$

DELIMITER;

-- 17. Determinar el total de descuentos aplicados en un año específico.

DELIMITER $$

CREATE FUNCTION total_descuentos_por_anio(p_anio INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT IFNULL(SUM(descuento), 0)
    INTO total
    FROM transacciones
    WHERE YEAR(fecha_transaccion) = p_anio;

    RETURN total;
END $$

DELIMITER ;


-- 18. Calcular la proporción de pagos en efectivo vs electrónicos por cliente.

DELIMITER $$

CREATE FUNCTION ProporcionPagosEfectivo(idCliente BIGINT) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE total INT;
    DECLARE efectivo INT;
    SELECT COUNT(*) INTO total FROM Pagos p JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta WHERE t.id_cliente = idCliente;
    SELECT COUNT(*) INTO efectivo FROM Pagos p JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta JOIN Metodos_Pago mp ON p.id_metodo = mp.id_metodo WHERE t.id_cliente = idCliente AND mp.descripcion = 'Efectivo';
    RETURN IF(total > 0, (efectivo / total) * 100, 0.00);
END $$

DELIMITER;

-- 19. Obtener el total de cuotas emitidas para un tipo de tarjeta.

DELIMITER $$

CREATE FUNCTION total_cuotas_por_tipo_tarjeta(p_tipo_tarjeta VARCHAR(50))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT IFNULL(SUM(monto_total), 0)
    INTO total
    FROM transacciones t
    JOIN tarjetas ta ON t.id_tarjeta = ta.id_tarjeta
    WHERE ta.tipo = p_tipo_tarjeta;

    RETURN total;
END $$

DELIMITER ;


-- 20. Evaluar si un cliente es elegible para promociones especiales (por historial).

