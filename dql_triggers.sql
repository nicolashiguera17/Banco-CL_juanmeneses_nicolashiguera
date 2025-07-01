-- 1. Al insertar un nuevo pago, actualizar automáticamente el estado de la cuota de manejo.
DELIMITER $$

CREATE TRIGGER actualizar_estado_cuota_despues_pago
AFTER INSERT ON Pagos
FOR EACH ROW
BEGIN
  UPDATE Cuotas_de_Manejo
  SET estado = 'Pagada'
  WHERE id_cuota_manejo = NEW.id_cuota_manejo;
END $$

DELIMITER ;


-- 2. Al modificar el monto de apertura de una tarjeta, recalcular la cuota de manejo correspondiente.

DELIMITER $$

CREATE TRIGGER RegistrarPagoHistorial
AFTER INSERT ON Pagos
FOR EACH ROW
BEGIN
    INSERT INTO Historial_Pagos (id_cliente, descripcion, monto_pagado)
    SELECT t.id_cliente, 'Nuevo pago', NEW.monto
    FROM Cuotas_de_Manejo cm
    JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
    WHERE cm.id_cuota_manejo = NEW.id_cuota_manejo;
END $$

DELIMITER;

-- 3. Al registrar una nueva tarjeta, asignar automáticamente el descuento basado en el tipo de tarjeta.
DELIMITER $$

CREATE TRIGGER asignar_descuento_nueva_tarjeta
AFTER INSERT ON Tarjetas
FOR EACH ROW
BEGIN
  INSERT INTO Descuentos_Tarjeta (id_tarjeta, id_descuento)
  SELECT NEW.id_tarjeta, id_descuento
  FROM Tipos_Tarjeta
  WHERE id_tipo_tarjeta = NEW.id_tipo_tarjeta;
END $$

DELIMITER ;

-- 4. Al eliminar una tarjeta, eliminar todas las cuotas de manejo asociadas a esa tarjeta.

DELIMITER $$

CREATE TRIGGER EliminarCuotasTarjeta
AFTER DELETE ON Tarjetas
FOR EACH ROW
BEGIN
    DELETE FROM Cuotas_de_Manejo
    WHERE id_tarjeta = OLD.id_tarjeta;
END $$

DELIMITER;

-- 5. Al actualizar un descuento, recalcular las cuotas de manejo de las tarjetas afectadas.

DELIMITER $$

CREATE TRIGGER recalcular_cuotas_despues_descuento
AFTER UPDATE ON Descuentos
FOR EACH ROW
BEGIN
  UPDATE Cuotas_de_Manejo AS c
  JOIN Descuentos_Tarjeta AS dt ON c.id_tarjeta = dt.id_tarjeta
  SET c.monto = c.monto * 0.9
  WHERE dt.id_descuento = NEW.id_descuento;
END $$

DELIMITER ;


-- 6. Al insertar una nueva promoción, asignarla automáticamente a las tarjetas elegibles.

DELIMITER $$

CREATE TRIGGER AsignarPromocionTarjetas
AFTER INSERT ON Promociones
FOR EACH ROW
BEGIN
    INSERT INTO Tarjetas_Promociones (id_tarjeta, id_promocion, fecha_aplicacion)
    SELECT id_tarjeta, NEW.id_promocion, CURDATE()
    FROM Tarjetas
    WHERE id_estado = 1;
END $$

DELIMITER;

-- 7. Al registrar un nuevo cliente, crear automáticamente su historial vacío de pagos y cuotas.

DELIMITER $$

CREATE TRIGGER crear_historial_cliente
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
  INSERT INTO Historial_Pagos (id_cliente, descripcion)
  VALUES (NEW.id_cliente, 'Historial inicial vacío');

  INSERT INTO Historial_Cuotas (id_cliente, descripcion)
  VALUES (NEW.id_cliente, 'Historial de cuotas inicial vacío');
END $$

DELIMITER ;


-- 8. Al eliminar un cliente, borrar todas sus tarjetas y pagos asociados.

DELIMITER $$

CREATE TRIGGER EliminarTarjetasPagosCliente
AFTER DELETE ON Clientes
FOR EACH ROW
BEGIN
    DELETE p FROM Pagos p
    JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
    JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
    WHERE t.id_cliente = OLD.id_cliente;
    
    DELETE cm FROM Cuotas_de_Manejo cm
    JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
    WHERE t.id_cliente = OLD.id_cliente;
    
    DELETE FROM Tarjetas
    WHERE id_cliente = OLD.id_cliente;
END $$

DELIMITER;

-- 9. Al actualizar el estado de una cuota a "pagada", insertar un registro en el historial de pagos.

DELIMITER $$

CREATE TRIGGER registrar_historial_al_pagar
AFTER UPDATE ON Cuotas_de_Manejo
FOR EACH ROW
BEGIN
  IF NEW.id_estado_cuota = 1 AND OLD.id_estado_cuota <> 1 THEN
    INSERT INTO Historial_Pagos (id_cliente, descripcion)
    SELECT t.id_cliente, CONCAT('Pago de cuota ', NEW.id_cuota_manejo, ' registrado.')
    FROM Tarjetas t
    WHERE t.id_tarjeta = NEW.id_tarjeta;
  END IF;
END $$

DELIMITER ;



-- 10. Al cambiar el estado de una transacción a "fallida", generar una alerta o registro de auditoría.

DELIMITER $$

CREATE TRIGGER RegistrarAlertaTransaccionFallida
AFTER UPDATE ON Transacciones
FOR EACH ROW
BEGIN
    IF NEW.tipo_transaccion = 'fallida' THEN
        INSERT INTO Notificaciones (id_cliente, mensaje, tipo, fecha_envio, leido)
        SELECT t.id_cliente, CONCAT('Transacción fallida: ', NEW.id_transaccion), 'Alerta', CURDATE(), FALSE
        FROM Pagos p
        JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
        JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
        WHERE p.id_pago = NEW.id_pago;
    END IF;
END $$

DELIMITER;

-- 11. Al eliminar un método de pago, desvincularlo automáticamente de las tarjetas del cliente.

DELIMITER $$

CREATE TRIGGER desvincular_tarjetas_al_eliminar_pago
BEFORE DELETE ON Metodos_Pago
FOR EACH ROW
BEGIN
  UPDATE Tarjetas
  SET id_metodo_pago = NULL
  WHERE id_metodo_pago = OLD.id_metodo;
END $$

DELIMITER ;



-- 12. Al modificar una fecha de vencimiento de una cuota, recalcular la alerta de pago.

DELIMITER $$

CREATE TRIGGER RecalcularAlertaCuota
AFTER UPDATE ON Cuotas_de_Manejo
FOR EACH ROW
BEGIN
    IF NEW.fecha_vencimiento != OLD.fecha_vencimiento THEN
        INSERT INTO Notificaciones (id_cliente, mensaje, tipo, fecha_envio, leido)
        SELECT t.id_cliente, 
               CONCAT('Cuota ', NEW.id_cuota_manejo, ' cambió fecha de vencimiento a ', NEW.fecha_vencimiento), 
               'Alerta', 
               CURDATE(), 
               FALSE
        FROM Tarjetas t
        WHERE t.id_tarjeta = NEW.id_tarjeta;
    END IF;
END $$

DELIMITER;

-- 13. Al insertar una nueva cuota, verificar si hay promociones vigentes y aplicarlas automáticamente.

DELIMITER $$

CREATE TRIGGER aplicar_promocion_nueva_cuota
AFTER INSERT ON Cuotas_de_Manejo
FOR EACH ROW
BEGIN
  DECLARE promo_descuento DECIMAL(5,2);

  SELECT porcentaje INTO promo_descuento
  FROM Promociones
  WHERE estado = 'Activa'
  ORDER BY fecha_inicio DESC
  LIMIT 1;

  IF promo_descuento IS NOT NULL THEN
    UPDATE Cuotas_de_Manejo
    SET monto = monto * (1 - promo_descuento / 100)
    WHERE id_cuota_manejo = NEW.id_cuota_manejo;
  END IF;
END $$

DELIMITER ;


-- 14. Al cambiar el tipo de tarjeta, reasignar el monto de apertura y su nueva cuota de manejo.

DELIMITER $$

CREATE TRIGGER ReasignarCuotaTipoTarjeta
AFTER UPDATE ON Tarjetas
FOR EACH ROW
BEGIN
    IF NEW.id_tipo_tarjeta != OLD.id_tipo_tarjeta THEN
        INSERT INTO Cuotas_de_Manejo (id_tarjeta, monto, fecha_vencimiento, id_estado_cuota)
        VALUES (
            NEW.id_tarjeta,
            CASE NEW.id_tipo_tarjeta
                WHEN 1 THEN 30000
                WHEN 2 THEN 50000
                ELSE 20000
            END,
            DATE_ADD(CURDATE(), INTERVAL 1 MONTH),
            1
        );
    END IF;
END $$

DELIMITER;

-- 15. Al insertar una nueva transacción, validar si el monto excede cierto límite y registrar alerta.

DELIMITER $$

CREATE TRIGGER alerta_transaccion_grande
AFTER INSERT ON Transacciones
FOR EACH ROW
BEGIN
  IF NEW.monto > 1000000 THEN
    INSERT INTO Alertas (id_cliente, mensaje, fecha)
    VALUES (
      NEW.id_cliente,
      CONCAT('Transacción sospechosa de alto monto: $', NEW.monto),
      NOW()
    );
  END IF;
END $$

DELIMITER ;

-- 16. Al eliminar una promoción, eliminar también su relación con las tarjetas afectadas.

DELIMITER $$

CREATE TRIGGER EliminarRelacionesPromocion
AFTER DELETE ON Promociones
FOR EACH ROW
BEGIN
    DELETE FROM Tarjetas_Promociones
    WHERE id_promocion = OLD.id_promocion;
END $$

DELIMITER;

-- 17. Al insertar un nuevo estado de cuota, asociarlo automáticamente a las cuotas creadas ese día.
DELIMITER $$

CREATE TRIGGER asociar_estado_a_cuotas
AFTER INSERT ON Estado_Cuota
FOR EACH ROW
BEGIN
  UPDATE Cuotas_de_Manejo
  SET id_estado_cuota = NEW.id_estado_cuota
  WHERE DATE(fecha_vencimiento) = CURDATE();
END $$

DELIMITER ;



-- 18. Al actualizar los datos del cliente, registrar el cambio en una tabla de auditoría.

DELIMITER $$

CREATE TRIGGER AuditarCambioCliente
AFTER UPDATE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Historial_Pagos (id_cliente, descripcion, monto_pagado, fecha)
    VALUES (NEW.id_cliente, CONCAT('Cambio en datos del cliente ', NEW.id_cliente), 0.00, NOW());
END $$

DELIMITER;

-- 19. Al eliminar un historial de pagos, actualizar el saldo pendiente del cliente.DELIMITER $$
DELIMITER $$

CREATE TRIGGER actualizar_saldo_tras_eliminar_historial
AFTER DELETE ON Historial_Pagos
FOR EACH ROW
BEGIN
  UPDATE Clientes
  SET saldo_pendiente = saldo_pendiente + OLD.monto_pagado
  WHERE id_cliente = OLD.id_cliente;
END $$

DELIMITER ;



-- 20. Al asignar un nuevo rol de usuario, registrar el evento en un log de control de acceso.


