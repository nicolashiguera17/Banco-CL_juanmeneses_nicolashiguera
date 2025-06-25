-- crear la base de datos --
CREATE DATABASE banco_cl;

-- usar la base de datos creada --
USE banco_cl;

-- eliminar tablas si existen previamente para evitar errores de duplicación --
DROP TABLE IF EXISTS Empleados;
DROP TABLE IF EXISTS Clientes;
DROP TABLE IF EXISTS Tipos_Tarjeta;
DROP TABLE IF EXISTS Descuentos;
DROP TABLE IF EXISTS Tarjetas;
DROP TABLE IF EXISTS Historial_Descuentos;
DROP TABLE IF EXISTS Estado_Cuota;
DROP TABLE IF EXISTS Cuotas_de_Manejo;
DROP TABLE IF EXISTS Metodos_Pago;
DROP TABLE IF EXISTS Pagos;
DROP TABLE IF EXISTS Transacciones;
DROP TABLE IF EXISTS Notificaciones;
DROP TABLE IF EXISTS Promociones;
DROP TABLE IF EXISTS Contactos_Clientes;
DROP TABLE IF EXISTS Tarjetas_Promociones;

-- crear tabla de empleados --
CREATE TABLE `Empleados`(
    `id_empleado` BIGINT NOT NULL,
    `nombre_empleado` VARCHAR(255) NULL,
    `fecha_ingreso` DATE NULL,
    `cargo` VARCHAR(50) NULL,
    `correo` VARCHAR(255) NULL,
    PRIMARY KEY(`id_empleado`)
);

-- crear tabla de clientes --
CREATE TABLE `Clientes`(
    `id_cliente` BIGINT NOT NULL,
    `nombre` VARCHAR(255) NULL,
    `numero_cuenta` VARCHAR(50) NULL,
    `telefono` VARCHAR(20) NULL,
    `correo` VARCHAR(255) NULL,
    `id_empleado` BIGINT NULL,
    PRIMARY KEY(`id_cliente`)
);

-- crear tabla de tipos de tarjeta --
CREATE TABLE `Tipos_Tarjeta`(
    `id_tipo_tarjeta` BIGINT NOT NULL,
    `nombre_tipo` VARCHAR(100) NULL,
    `monto_apertura` DECIMAL(10, 2) NULL,
    PRIMARY KEY(`id_tipo_tarjeta`)
);

-- crear tabla de descuentos --
CREATE TABLE `Descuentos`(
    `id_descuento` BIGINT NOT NULL,
    `nombre_categoria` VARCHAR(100) NULL,
    `descripcion` VARCHAR(255) NULL,
    PRIMARY KEY(`id_descuento`)
);

-- crear tabla de tarjetas --
CREATE TABLE `Tarjetas`(
    `id_tarjeta` BIGINT NOT NULL,
    `id_cliente` BIGINT NULL,
    `id_tipo_tarjeta` BIGINT NULL,
    `id_descuento` BIGINT NULL,
    PRIMARY KEY(`id_tarjeta`)
);

-- crear tabla historial de descuentos --
CREATE TABLE `Historial_Descuentos`(
    `id_historial_descuento` BIGINT NOT NULL,
    `id_tarjeta` BIGINT NULL,
    `porcentaje_anterior` DECIMAL(10, 2) NULL,
    `porcentaje_nuevo` DECIMAL(10, 2) NULL,
    `fecha_cambio` DATE NULL,
    PRIMARY KEY(`id_historial_descuento`)
);

-- crear tabla de estado de cuotas --
CREATE TABLE `Estado_Cuota`(
    `id_estado_cuota` BIGINT NOT NULL,
    `descripcion` VARCHAR(100) NULL,
    PRIMARY KEY(`id_estado_cuota`)
);

-- crear tabla de cuotas de manejo --
CREATE TABLE `Cuotas_de_Manejo`(
    `id_cuota_manejo` BIGINT NOT NULL,
    `id_tarjeta` BIGINT NULL,
    `monto` DECIMAL(10, 2) NULL,
    `fecha_vencimiento` DATE NULL,
    `id_estado_cuota` BIGINT NULL,
    PRIMARY KEY(`id_cuota_manejo`)
);

-- crear tabla de métodos de pago --
CREATE TABLE `Metodos_Pago`(
    `id_metodo` BIGINT NOT NULL,
    `descripcion` VARCHAR(100) NULL,
    `estado_cuenta` VARCHAR(50) NULL,
    PRIMARY KEY(`id_metodo`)
);

-- crear tabla de pagos --
CREATE TABLE `Pagos`(
    `id_pago` BIGINT NOT NULL,
    `id_cuota_manejo` BIGINT NULL,
    `fecha_pago` DATE NULL,
    `monto` DECIMAL(10, 2) NULL,
    `estado` VARCHAR(50) NULL,
    `id_metodo` BIGINT NULL,
    PRIMARY KEY(`id_pago`)
);

-- crear tabla de transacciones --
CREATE TABLE `Transacciones`(
    `id_transaccion` BIGINT NOT NULL,
    `id_pago` BIGINT NULL,
    `fecha_transaccion` DATE NULL,
    `monto` DECIMAL(10, 2) NULL,
    `tipo_transaccion` VARCHAR(50) NULL,
    PRIMARY KEY(`id_transaccion`)
);

-- crear tabla de notificaciones --
CREATE TABLE `Notificaciones`(
    `id_notificacion` BIGINT NOT NULL,
    `id_cliente` BIGINT NULL,
    `mensaje` VARCHAR(255) NULL,
    `fecha_envio` DATE NULL,
    `tipo` VARCHAR(50) NULL,
    `leido` BOOLEAN NULL,
    PRIMARY KEY(`id_notificacion`)
);

-- crear tabla de promociones --
CREATE TABLE `Promociones`(
    `id_promocion` BIGINT NOT NULL,
    `nombre_promocion` VARCHAR(255) NULL,
    `descuento_aplicado` DECIMAL(10, 2) NULL,
    `fecha_inicio` DATE NULL,
    `fecha_fin` DATE NULL,
    PRIMARY KEY(`id_promocion`)
);

-- crear tabla de contactos de clientes --
CREATE TABLE `Contactos_Clientes`(
    `id_contacto` BIGINT NOT NULL,
    `id_cliente` BIGINT NULL,
    `tipo_contacto` VARCHAR(50) NULL,
    `valor` VARCHAR(255) NULL,
    `fecha_actualizacion` DATE NULL,
    PRIMARY KEY(`id_contacto`)
);

-- crear tabla intermedia tarjetas-promociones --
CREATE TABLE `Tarjetas_Promociones`(
    `id_tarjeta_promocion` BIGINT NOT NULL,
    `id_tarjeta` BIGINT NULL,
    `id_promocion` BIGINT NULL,
    `fecha_aplicacion` DATE NULL,
    PRIMARY KEY(`id_tarjeta_promocion`)
);

-- agregar claves foráneas para relaciones entre tablas --

-- tarjetas → descuentos
ALTER TABLE `Tarjetas` 
    ADD CONSTRAINT `tarjetas_id_descuento_foreign` 
    FOREIGN KEY(`id_descuento`) REFERENCES `Descuentos`(`id_descuento`);

-- transacciones → pagos
ALTER TABLE `Transacciones` 
    ADD CONSTRAINT `transacciones_id_pago_foreign` 
    FOREIGN KEY(`id_pago`) REFERENCES `Pagos`(`id_pago`);

-- cuotas_de_manejo → tarjetas
ALTER TABLE `Cuotas_de_Manejo` 
    ADD CONSTRAINT `cuotas_de_manejo_id_tarjeta_foreign` 
    FOREIGN KEY(`id_tarjeta`) REFERENCES `Tarjetas`(`id_tarjeta`);

-- pagos → métodos de pago
ALTER TABLE `Pagos` 
    ADD CONSTRAINT `pagos_id_metodo_foreign` 
    FOREIGN KEY(`id_metodo`) REFERENCES `Metodos_Pago`(`id_metodo`);

-- contactos_clientes → clientes
ALTER TABLE `Contactos_Clientes` 
    ADD CONSTRAINT `contactos_clientes_id_cliente_foreign` 
    FOREIGN KEY(`id_cliente`) REFERENCES `Clientes`(`id_cliente`);

-- clientes → empleados
ALTER TABLE `Clientes` 
    ADD CONSTRAINT `clientes_id_empleado_foreign` 
    FOREIGN KEY(`id_empleado`) REFERENCES `Empleados`(`id_empleado`);

-- tarjetas_promociones → tarjetas
ALTER TABLE `Tarjetas_Promociones` 
    ADD CONSTRAINT `tarjetas_promociones_id_tarjeta_foreign` 
    FOREIGN KEY(`id_tarjeta`) REFERENCES `Tarjetas`(`id_tarjeta`);

-- tarjetas → clientes
ALTER TABLE `Tarjetas` 
    ADD CONSTRAINT `tarjetas_id_cliente_foreign` 
    FOREIGN KEY(`id_cliente`) REFERENCES `Clientes`(`id_cliente`);

-- cuotas_de_manejo → estado_cuota
ALTER TABLE `Cuotas_de_Manejo` 
    ADD CONSTRAINT `cuotas_de_manejo_id_estado_cuota_foreign` 
    FOREIGN KEY(`id_estado_cuota`) REFERENCES `Estado_Cuota`(`id_estado_cuota`);

-- tarjetas → tipos_tarjeta
ALTER TABLE `Tarjetas` 
    ADD CONSTRAINT `tarjetas_id_tipo_tarjeta_foreign` 
    FOREIGN KEY(`id_tipo_tarjeta`) REFERENCES `Tipos_Tarjeta`(`id_tipo_tarjeta`);

-- historial_descuentos → tarjetas
ALTER TABLE `Historial_Descuentos` 
    ADD CONSTRAINT `historial_descuentos_id_tarjeta_foreign` 
    FOREIGN KEY(`id_tarjeta`) REFERENCES `Tarjetas`(`id_tarjeta`);

-- notificaciones → clientes
ALTER TABLE `Notificaciones` 
    ADD CONSTRAINT `notificaciones_id_cliente_foreign` 
    FOREIGN KEY(`id_cliente`) REFERENCES `Clientes`(`id_cliente`);

-- pagos → cuotas_de_manejo
ALTER TABLE `Pagos` 
    ADD CONSTRAINT `pagos_id_cuota_manejo_foreign` 
    FOREIGN KEY(`id_cuota_manejo`) REFERENCES `Cuotas_de_Manejo`(`id_cuota_manejo`);

-- tarjetas_promociones → promociones
ALTER TABLE `Tarjetas_Promociones` 
    ADD CONSTRAINT `tarjetas_promociones_id_promocion_fore

