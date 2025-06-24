-- Creamos la database principal de nuestro banco
CREATE DATABASE banco_cl;

--Usamos la database que acabamos de crear
USE banco_cl;

-- Tabla Empleados (sin id_sucursal)
CREATE TABLE Empleados (
    id_empleado BIGINT PRIMARY KEY,
    nombre_empleado VARCHAR(255),
    fecha_ingreso DATE,
    cargo VARCHAR(50),
    correo VARCHAR(255)
);

-- Tabla Clientes
CREATE TABLE Clientes (
    id_cliente BIGINT PRIMARY KEY,
    nombre VARCHAR(255),
    numero_cuenta VARCHAR(50),
    telefono VARCHAR(20),
    correo VARCHAR(255),
    id_empleado BIGINT,
    FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado)
);

-- Tabla Tipos_Tarjeta
CREATE TABLE Tipos_Tarjeta (
    id_tipo_tarjeta BIGINT PRIMARY KEY,
    nombre_tipo VARCHAR(100),
    monto_apertura DECIMAL(10,2)
);

-- Tabla Descuentos
CREATE TABLE Descuentos (
    id_descuento BIGINT PRIMARY KEY,
    nombre_categoria VARCHAR(100),
    descripcion VARCHAR(255)
);

-- Tabla Tarjetas
CREATE TABLE Tarjetas (
    id_tarjeta BIGINT PRIMARY KEY,
    id_cliente BIGINT,
    id_tipo_tarjeta BIGINT,
    id_descuento BIGINT,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_tipo_tarjeta) REFERENCES Tipos_Tarjeta(id_tipo_tarjeta),
    FOREIGN KEY (id_descuento) REFERENCES Descuentos(id_descuento)
);

-- Tabla Historial_Descuentos
CREATE TABLE Historial_Descuentos (
    id_historial_descuento BIGINT PRIMARY KEY,
    id_tarjeta BIGINT,
    porcentaje_anterior DECIMAL(10,2),
    porcentaje_nuevo DECIMAL(10,2),
    fecha_cambio DATE,
    FOREIGN KEY (id_tarjeta) REFERENCES Tarjetas(id_tarjeta)
);

-- Tabla Estado_Cuota
CREATE TABLE Estado_Cuota (
    id_estado_cuota BIGINT PRIMARY KEY,
    descripcion VARCHAR(100)
);

-- Tabla Cuotas_de_Manejo (con relación a Estado_Cuota)
CREATE TABLE Cuotas_de_Manejo (
    id_cuota_manejo BIGINT PRIMARY KEY,
    id_tarjeta BIGINT,
    monto DECIMAL(10,2),
    fecha_vencimiento DATE,
    id_estado_cuota BIGINT,
    FOREIGN KEY (id_tarjeta) REFERENCES Tarjetas(id_tarjeta),
    FOREIGN KEY (id_estado_cuota) REFERENCES Estado_Cuota(id_estado_cuota)
);

-- Tabla Metodos_Pago
CREATE TABLE Metodos_Pago (
    id_metodo BIGINT PRIMARY KEY,
    descripcion VARCHAR(100),
    estado_cuenta VARCHAR(50)
);

-- Tabla Pagos
CREATE TABLE Pagos (
    id_pago BIGINT PRIMARY KEY,
    id_cuota_manejo BIGINT,
    fecha_pago DATE,
    monto DECIMAL(10,2),
    estado VARCHAR(50),
    id_metodo BIGINT,
    FOREIGN KEY (id_cuota_manejo) REFERENCES Cuotas_de_Manejo(id_cuota_manejo),
    FOREIGN KEY (id_metodo) REFERENCES Metodos_Pago(id_metodo)
);

-- Tabla Transacciones
CREATE TABLE Transacciones (
    id_transaccion BIGINT PRIMARY KEY,
    id_pago BIGINT,
    fecha_transaccion DATE,
    monto DECIMAL(10,2),
    tipo_transaccion VARCHAR(50),
    FOREIGN KEY (id_pago) REFERENCES Pagos(id_pago)
);

-- Tabla Notificaciones
CREATE TABLE Notificaciones (
    id_notificacion BIGINT PRIMARY KEY,
    id_cliente BIGINT,
    mensaje VARCHAR(255),
    fecha_envio DATE,
    tipo VARCHAR(50),
    leido BOOLEAN,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

-- Tabla Promociones
CREATE TABLE Promociones (
    id_promocion BIGINT PRIMARY KEY,
    nombre_promocion VARCHAR(255),
    descuento_aplicado DECIMAL(10,2),
    fecha_inicio DATE,
    fecha_fin DATE
);

-- Tabla Contactos_Clientes
CREATE TABLE Contactos_Clientes (
    id_contacto BIGINT PRIMARY KEY,
    id_cliente BIGINT,
    tipo_contacto VARCHAR(50),
    valor VARCHAR(255),
    fecha_actualizacion DATE,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

-- Nueva tabla intermedia para relacionar Tarjetas y Promociones
CREATE TABLE Tarjetas_Promociones (
    id_tarjeta_promocion BIGINT PRIMARY KEY,
    id_tarjeta BIGINT,
    id_promocion BIGINT,
    fecha_aplicacion DATE,
    FOREIGN KEY (id_tarjeta) REFERENCES Tarjetas(id_tarjeta),
    FOREIGN KEY (id_promocion) REFERENCES Promociones(id_promocion)
);