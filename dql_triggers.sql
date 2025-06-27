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

-- 19. Al eliminar un historial de pagos, actualizar el saldo pendiente del cliente.

-- 20. Al asignar un nuevo rol de usuario, registrar el evento en un log de control de acceso.


