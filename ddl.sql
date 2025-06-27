-- Active: 1750963035337@@127.0.0.1@3307@banco_cl
-- Crear base de datos --
CREATE DATABASE IF NOT EXISTS banco_cl;
-- usar la bas de datos --
USE banco_cl;

-- Eliminar tablas si existen previamente para evitar errores de duplicación --
DROP TABLE IF EXISTS Tarjetas_Promociones;
DROP TABLE IF EXISTS Contactos_Clientes;
DROP TABLE IF EXISTS Promociones;
DROP TABLE IF EXISTS Notificaciones;
DROP TABLE IF EXISTS Transacciones;
DROP TABLE IF EXISTS Pagos;
DROP TABLE IF EXISTS Metodos_Pago;
DROP TABLE IF EXISTS Cuotas_de_Manejo;
DROP TABLE IF EXISTS Estado_Cuota;
DROP TABLE IF EXISTS Historial_Descuentos;
DROP TABLE IF EXISTS Tarjetas;
DROP TABLE IF EXISTS Descuentos;
DROP TABLE IF EXISTS Tipos_Tarjeta;
DROP TABLE IF EXISTS Clientes;
DROP TABLE IF EXISTS Empleados;

-- Tabla: Empleados --
CREATE TABLE `Empleados` (
    `id_empleado` BIGINT NOT NULL AUTO_INCREMENT,
    `nombre_empleado` VARCHAR(255),
    `fecha_ingreso` DATE,
    `cargo` VARCHAR(50),
    `correo` VARCHAR(255),
    PRIMARY KEY (`id_empleado`)
);

-- Tabla: Clientes --
CREATE TABLE `Clientes` (
    `id_cliente` BIGINT NOT NULL AUTO_INCREMENT,
    `nombre` VARCHAR(255),
    `numero_cuenta` VARCHAR(50),
    `telefono` VARCHAR(20),
    `correo` VARCHAR(255),
    `id_empleado` BIGINT,
    PRIMARY KEY (`id_cliente`)
);

-- Tabla: Tipos_Tarjeta --
CREATE TABLE `Tipos_Tarjeta` (
    `id_tipo_tarjeta` BIGINT NOT NULL AUTO_INCREMENT,
    `nombre_tipo` VARCHAR(100),
    `monto_apertura` DECIMAL(10,2),
    PRIMARY KEY (`id_tipo_tarjeta`)
);

-- Tabla: Descuentos --
CREATE TABLE `Descuentos` (
    `id_descuento` BIGINT NOT NULL AUTO_INCREMENT,
    `nombre_categoria` VARCHAR(100),
    `descripcion` VARCHAR(255),
    PRIMARY KEY (`id_descuento`)
);

-- Tabla: Tarjetas --
CREATE TABLE `Tarjetas` (
    `id_tarjeta` BIGINT NOT NULL AUTO_INCREMENT,
    `id_cliente` BIGINT,
    `id_tipo_tarjeta` BIGINT,
    `id_descuento` BIGINT,
    PRIMARY KEY (`id_tarjeta`)
);

-- Tabla: Historial_Descuentos --
CREATE TABLE `Historial_Descuentos` (
    `id_historial_descuento` BIGINT NOT NULL AUTO_INCREMENT,
    `id_tarjeta` BIGINT,
    `porcentaje_anterior` DECIMAL(10,2),
    `porcentaje_nuevo` DECIMAL(10,2),
    `fecha_cambio` DATE,
    PRIMARY KEY (`id_historial_descuento`)
);

-- Tabla: Estado_Cuota --
CREATE TABLE `Estado_Cuota` (
    `id_estado_cuota` BIGINT NOT NULL AUTO_INCREMENT,
    `descripcion` VARCHAR(100),
    PRIMARY KEY (`id_estado_cuota`)
);

-- Tabla: Cuotas_de_Manejo --
CREATE TABLE `Cuotas_de_Manejo` (
    `id_cuota_manejo` BIGINT NOT NULL AUTO_INCREMENT,
    `id_tarjeta` BIGINT,
    `monto` DECIMAL(10,2),
    `fecha_vencimiento` DATE,
    `id_estado_cuota` BIGINT,
    PRIMARY KEY (`id_cuota_manejo`)
);

-- Tabla: Metodos_Pago --
CREATE TABLE `Metodos_Pago` (
    `id_metodo` BIGINT NOT NULL AUTO_INCREMENT,
    `descripcion` VARCHAR(100),
    `estado_cuenta` VARCHAR(50),
    PRIMARY KEY (`id_metodo`)
);

-- Tabla: Pagos --
CREATE TABLE `Pagos` (
    `id_pago` BIGINT NOT NULL AUTO_INCREMENT,
    `id_cuota_manejo` BIGINT,
    `fecha_pago` DATE,
    `monto` DECIMAL(10,2),
    `estado` VARCHAR(50),
    `id_metodo` BIGINT,
    PRIMARY KEY (`id_pago`)
);

-- Tabla: Transacciones --
CREATE TABLE `Transacciones` (
    `id_transaccion` BIGINT NOT NULL AUTO_INCREMENT,
    `id_pago` BIGINT,
    `fecha_transaccion` DATE,
    `monto` DECIMAL(10,2),
    `tipo_transaccion` VARCHAR(50),
    PRIMARY KEY (`id_transaccion`)
);

-- Tabla: Notificaciones --
CREATE TABLE `Notificaciones` (
    `id_notificacion` BIGINT NOT NULL AUTO_INCREMENT,
    `id_cliente` BIGINT,
    `mensaje` VARCHAR(255),
    `fecha_envio` DATE,
    `tipo` VARCHAR(50),
    `leido` BOOLEAN,
    PRIMARY KEY (`id_notificacion`)
);

-- Tabla: Promociones --
CREATE TABLE `Promociones` (
    `id_promocion` BIGINT NOT NULL AUTO_INCREMENT,
    `nombre_promocion` VARCHAR(255),
    `descuento_aplicado` DECIMAL(10,2),
    `fecha_inicio` DATE,
    `fecha_fin` DATE,
    PRIMARY KEY (`id_promocion`)
);

-- Tabla: Contactos_Clientes --
CREATE TABLE `Contactos_Clientes` (
    `id_contacto` BIGINT NOT NULL AUTO_INCREMENT,
    `id_cliente` BIGINT,
    `tipo_contacto` VARCHAR(50),
    `valor` VARCHAR(255),
    `fecha_actualizacion` DATE,
    PRIMARY KEY (`id_contacto`)
);

-- Tabla: Tarjetas_Promociones --
CREATE TABLE `Tarjetas_Promociones` (
    `id_tarjeta_promocion` BIGINT NOT NULL AUTO_INCREMENT,
    `id_tarjeta` BIGINT,
    `id_promocion` BIGINT,
    `fecha_aplicacion` DATE,
    PRIMARY KEY (`id_tarjeta_promocion`)
);

-- Tabla: historial_pagos  --

CREATE TABLE Historial_Pagos (
    id_historial BIGINT PRIMARY KEY AUTO_INCREMENT,
    id_cliente BIGINT,
    descripcion TEXT,
    monto_pagado DECIMAL(10,2),
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- Claves foráneas --

-- La tabla Tarjetas se conecta con la tabla Clientes
ALTER TABLE `Tarjetas` 
    ADD CONSTRAINT `tarjetas_id_cliente_foreign` 
    FOREIGN KEY (`id_cliente`) REFERENCES `Clientes` (`id_cliente`);

-- La tabla Tarjetas se conecta con la tabla Tipos_Tarjeta
ALTER TABLE `Tarjetas` 
    ADD CONSTRAINT `tarjetas_id_tipo_tarjeta_foreign` 
    FOREIGN KEY (`id_tipo_tarjeta`) REFERENCES `Tipos_Tarjeta` (`id_tipo_tarjeta`);

-- La tabla Tarjetas se conecta con la tabla Descuentos
ALTER TABLE `Tarjetas` 
    ADD CONSTRAINT `tarjetas_id_descuento_foreign` 
    FOREIGN KEY (`id_descuento`) REFERENCES `Descuentos` (`id_descuento`);

-- La tabla Clientes se conecta con la tabla Empleados
ALTER TABLE `Clientes` 
    ADD CONSTRAINT `clientes_id_empleado_foreign` 
    FOREIGN KEY (`id_empleado`) REFERENCES `Empleados` (`id_empleado`);

-- La tabla Historial_Descuentos se conecta con la tabla Tarjetas
ALTER TABLE `Historial_Descuentos` 
    ADD CONSTRAINT `historial_descuentos_id_tarjeta_foreign` 
    FOREIGN KEY (`id_tarjeta`) REFERENCES `Tarjetas` (`id_tarjeta`);

-- La tabla Cuotas_de_Manejo se conecta con la tabla Tarjetas
ALTER TABLE `Cuotas_de_Manejo` 
    ADD CONSTRAINT `cuotas_de_manejo_id_tarjeta_foreign` 
    FOREIGN KEY (`id_tarjeta`) REFERENCES `Tarjetas` (`id_tarjeta`);

-- La tabla Cuotas_de_Manejo se conecta con la tabla Estado_Cuota
ALTER TABLE `Cuotas_de_Manejo` 
    ADD CONSTRAINT `cuotas_de_manejo_id_estado_cuota_foreign` 
    FOREIGN KEY (`id_estado_cuota`) REFERENCES `Estado_Cuota` (`id_estado_cuota`);

-- La tabla Pagos se conecta con la tabla Cuotas_de_Manejo
ALTER TABLE `Pagos` 
    ADD CONSTRAINT `pagos_id_cuota_manejo_foreign` 
    FOREIGN KEY (`id_cuota_manejo`) REFERENCES `Cuotas_de_Manejo` (`id_cuota_manejo`);

-- La tabla Pagos se conecta con la tabla Metodos_Pago
ALTER TABLE `Pagos` 
    ADD CONSTRAINT `pagos_id_metodo_foreign` 
    FOREIGN KEY (`id_metodo`) REFERENCES `Metodos_Pago` (`id_metodo`);

-- La tabla Transacciones se conecta con la tabla Pagos
ALTER TABLE `Transacciones` 
    ADD CONSTRAINT `transacciones_id_pago_foreign` 
    FOREIGN KEY (`id_pago`) REFERENCES `Pagos` (`id_pago`);

-- La tabla Notificaciones se conecta con la tabla Clientes
ALTER TABLE `Notificaciones` 
    ADD CONSTRAINT `notificaciones_id_cliente_foreign` 
    FOREIGN KEY (`id_cliente`) REFERENCES `Clientes` (`id_cliente`);

-- La tabla Contactos_Clientes se conecta con la tabla Clientes
ALTER TABLE `Contactos_Clientes` 
    ADD CONSTRAINT `contactos_clientes_id_cliente_foreign` 
    FOREIGN KEY (`id_cliente`) REFERENCES `Clientes` (`id_cliente`);

-- La tabla Tarjetas_Promociones se conecta con la tabla Tarjetas
ALTER TABLE `Tarjetas_Promociones` 
    ADD CONSTRAINT `tarjetas_promociones_id_tarjeta_foreign` 
    FOREIGN KEY (`id_tarjeta`) REFERENCES `Tarjetas` (`id_tarjeta`);

-- La tabla Tarjetas_Promociones se conecta con la tabla Promociones
ALTER TABLE `Tarjetas_Promociones` 
    ADD CONSTRAINT `tarjetas_promociones_id_promocion_foreign` 
    FOREIGN KEY (`id_promocion`) REFERENCES `Promociones` (`id_promocion`);
