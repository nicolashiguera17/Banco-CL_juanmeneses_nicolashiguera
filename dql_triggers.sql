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

-- 8. Al eliminar un cliente, borrar todas sus tarjetas y pagos asociados.

-- 9. Al actualizar el estado de una cuota a "pagada", insertar un registro en el historial de pagos.

-- 10. Al cambiar el estado de una transacción a "fallida", generar una alerta o registro de auditoría.

-- 11. Al eliminar un método de pago, desvincularlo automáticamente de las tarjetas del cliente.

-- 12. Al modificar una fecha de vencimiento de una cuota, recalcular la alerta de pago.

-- 13. Al insertar una nueva cuota, verificar si hay promociones vigentes y aplicarlas automáticamente.

-- 14. Al cambiar el tipo de tarjeta, reasignar el monto de apertura y su nueva cuota de manejo.

-- 15. Al insertar una nueva transacción, validar si el monto excede cierto límite y registrar alerta.

-- 16. Al eliminar una promoción, eliminar también su relación con las tarjetas afectadas.

-- 17. Al insertar un nuevo estado de cuota, asociarlo automáticamente a las cuotas creadas ese día.

-- 18. Al actualizar los datos del cliente, registrar el cambio en una tabla de auditoría.

-- 19. Al eliminar un historial de pagos, actualizar el saldo pendiente del cliente.

-- 20. Al asignar un nuevo rol de usuario, registrar el evento en un log de control de acceso.


