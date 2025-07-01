
# **Banco CL - Sistema de Gestión de Cuotas de Manejo**

## **Descripción del Proyecto**
El proyecto Banco CL implementa una base de datos para gestionar las cuotas de manejo de tarjetas bancarias (Joven, Nómina, Visa) en el banco ficticio "Banco CL". Permite registrar, calcular y reportar cuotas, gestionar pagos y mantener un historial de transacciones, asegurando la integridad de los datos en tercera forma normal (3FN). Incluye:

100 consultas SQL (básicas y avanzadas).

20 procedimientos almacenados.

20 funciones.

20 eventos.

20 triggers.

5 roles de usuario para automatización y seguridad.


## **Requisitos del Sistema**
MySQL: Versión 8.0 o superior

Cliente MySQL: MySQL Workbench, DBeaver o similar

Git: Para clonar el repositorio

Espacio en disco: ~100 MB

Sistema Operativo: Windows, macOS o Linux


## **Instalación y Configuración**

### **Clonar el Repositorio**
Clona el repositorio desde GitHub:

```bash
git clone https://github.com/nicolashiguera17/Banco-CL_juanmeneses_nicolashiguera.git
cd banco-cl
Configurar la Base de Datos
Conexión a MySQL
Conéctate a MySQL usando un cliente como MySQL Workbench o DBeaver.
Crear la Base de Datos
Ejecuta los siguientes comandos para crear y seleccionar la base de datos:
CREATE DATABASE banco_cl;
USE banco_cl;
Ejecutar los Scripts SQL
Ejecuta los scripts en el siguiente orden:
- **Estructura**: `sql/ddl.sql` (creación de tablas y relaciones)
- **Datos iniciales**: `sql/dml.sql` (inserciones de datos)
- **Consultas**: `sql/dql_select.sql` (consultas SQL)
- **Procedimientos**: `sql/dql_procedimientos.sql` (procedimientos almacenados)
- **Funciones**: `sql/dql_funciones.sql` (funciones SQL)
- **Triggers**: `sql/dql_triggers.sql` (triggers SQL)
- **Eventos**: `sql/dql_eventos.sql` (eventos SQL)

Comandos para ejecutar los scripts:
mysql -u <usuario> -p banco_cl < sql/ddl.sql
mysql -u <usuario> -p banco_cl < sql/dml.sql
mysql -u <usuario> -p banco_cl < sql/dql_select.sql
mysql -u <usuario> -p banco_cl < sql/dql_procedimientos.sql
mysql -u <usuario> -p banco_cl < sql/dql_funciones.sql
mysql -u <usuario> -p banco_cl < sql/dql_triggers.sql
mysql -u <usuario> -p banco_cl < sql/dql_eventos.sql
Configurar Roles
Consulta la sección **Roles de Usuario y Permisos** para crear y asignar roles.
Verificar el Modelo
Revisa el archivo `Diagrama.jpg` para visualizar las relaciones entre las tablas.
Estructura de la Base de Datos
Tablas
- **Clientes**: Almacena ID, nombre, número de cuenta, tipo de tarjeta, monto de apertura.
- **Tarjetas**: Registra ID, tipo (Joven, Nómina, Visa), monto de apertura, cliente asociado.
- **Cuotas_Manejo**: Contiene cuotas mensuales con descuentos aplicados.
- **Descuentos**: Define tipos (Básico, Platino, Diamante) y sus valores.
- **Historial_Pagos**: Registra pagos vinculados a cuotas.
Relaciones
- **Clientes → Tarjetas**: Relación 1:N (un cliente puede tener múltiples tarjetas).
- **Tarjetas → Descuentos**: Relación 1:1 (cada tarjeta tiene un descuento asociado).
- **Tarjetas → Cuotas_Manejo**: Relación 1:N (una tarjeta genera múltiples cuotas).
- **Cuotas_Manejo → Historial_Pagos**: Relación 1:1 (cada cuota está vinculada a un pago).

Ver el modelo completo en `Diagrama.jpg`.
Ejemplos de Consultas
Consultas Básicas
Listado de tarjetas y cuotas:

Muestra todas las tarjetas, su tipo, el nombre del cliente y la cuota de manejo.
SELECT t.id_tarjeta, t.tipo_tarjeta, c.nombre, cm.monto_cuota
FROM Tarjetas t
JOIN Clientes c ON t.id_cliente = c.id_cliente
JOIN Cuotas_Manejo cm ON t.id_tarjeta = cm.id_tarjeta;
Historial de pagos por cliente:

Lista los pagos realizados por un cliente específico.
SELECT c.nombre, h.fecha_pago, h.monto_pagado
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Historial_Pagos h ON t.id_tarjeta = h.id_tarjeta
WHERE c.id_cliente = 1;
Consultas Avanzadas
Pagos pendientes (últimos 3 meses):

Identifica cuotas sin pagar en los últimos tres meses.
SELECT c.nombre, t.id_tarjeta, cm.fecha_cuota
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Cuotas_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
LEFT JOIN Historial_Pagos h ON cm.id_cuota = h.id_cuota
WHERE h.id_pago IS NULL AND cm.fecha_cuota >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH);
Descuentos aplicados en 2025:

Reporta los descuentos aplicados por tipo en el año 2025.
SELECT d.tipo_descuento, COUNT(cm.id_cuota) AS total_cuotas, SUM(d.valor_descuento) AS total_descuentos
FROM Descuentos d
JOIN Cuotas_Manejo cm ON d.id_descuento = cm.id_descuento
WHERE YEAR(cm.fecha_cuota) = 2025
GROUP BY d.tipo_descuento;
Procedimientos, Funciones, Triggers y Eventos
Procedimientos Almacenados (20)
RegistrarCuotaManejo:

Calcula y registra cuotas de manejo con descuentos aplicados.
CALL RegistrarCuotaManejo(id_tarjeta, mes, anio);
Funciones (20)
CalcularCuotaManejo:

Calcula la cuota de manejo según el tipo de tarjeta y monto de apertura.
SELECT CalcularCuotaManejo(id_tarjeta) AS cuota;
Triggers (20)
AfterPagoInsert:

Actualiza el estado de una cuota a "Pagada" al registrar un pago.
CREATE TRIGGER AfterPagoInsert
AFTER INSERT ON Historial_Pagos
FOR EACH ROW
UPDATE Cuotas_Manejo SET estado = 'Pagada' WHERE id_cuota = NEW.id_cuota;
Eventos (20)
GenerarReporteMensual:

Genera reportes mensuales de cuotas.
CREATE EVENT GenerarReporteMensual
ON SCHEDULE EVERY 1 MONTH
DO
INSERT INTO Reportes (fecha, total_cuotas)
SELECT CURDATE(), SUM(monto_cuota) FROM Cuotas_Manejo WHERE MONTH(fecha_cuota) = MONTH(CURDATE());
Roles de Usuario y Permisos
Administrador
Acceso completo a todas las tablas y ejecución de procedimientos.
CREATE ROLE administrador;
GRANT ALL ON banco_cl.* TO administrador;
Operador de Pagos
Gestiona pagos y consulta cuotas de manejo.
CREATE ROLE operador_pagos;
GRANT SELECT, INSERT, UPDATE ON banco_cl.Historial_Pagos TO operador_pagos;
GRANT SELECT ON banco_cl.Cuotas_Manejo TO operador_pagos;
Gerente
Consulta reportes y ejecuta procedimientos.
CREATE ROLE gerente;
GRANT SELECT ON banco_cl.* TO gerente;
GRANT EXECUTE ON banco_cl.* TO gerente;
Consultor de Tarjetas
Consulta información de tarjetas y cuotas.
CREATE ROLE consultor_tarjetas;
GRANT SELECT ON banco_cl.Tarjetas TO consultor_tarjetas;
GRANT SELECT ON banco_cl.Cuotas_Manejo TO consultor_tarjetas;
Auditor
Consulta reportes generados.
CREATE ROLE auditor;
GRANT SELECT ON banco_cl.Reportes TO auditor;
Asignar Roles
Crea un usuario y asigna un rol, por ejemplo:
CREATE USER 'usuario_admin'@'localhost' IDENTIFIED BY 'password';
GRANT administrador TO 'usuario_admin'@'localhost';
SET DEFAULT ROLE administrador FOR 'usuario_admin'@'localhost';
Estructura del Repositorio
banco-cl/
├── sql/
│   ├── ddl.sql
│   ├── dml.sql
│   ├── dql_select.sql
│   ├── dql_procedimientos.sql
│   ├── dql_funciones.sql
│   ├── dql_triggers.sql
│   ├── dql_eventos.sql
├── Diagrama.jpg
├── README.md
Contribuciones
- **Estudiante 1**: Juan Meneses .
- **Estudiante 2**: Nicolás Higuera .
