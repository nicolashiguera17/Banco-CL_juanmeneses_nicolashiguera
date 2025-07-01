# **Banco CL - Gestión de Cuotas de Manejo**

## **Descripción**

Base de datos para gestionar cuotas de manejo de tarjetas (Joven, Nómina, Visa) en "Banco CL". Permite registrar, calcular y reportar cuotas, gestionar pagos y mantener historiales en 3FN. Incluye:





100 consultas SQL



20 procedimientos almacenados



20 funciones



20 eventos



20 triggers



5 roles de usuario


## **Requisitos**





MySQL 8.0+



Cliente MySQL (Workbench, DBeaver)



Git



~100 MB de espacio



Windows, macOS o Linux


## **Instalación**

### **Clonar Repositorio**

Clonar desde GitHub:

```bash
git clone https://github.com/nicolashiguera17/Banco-CL_juanmeneses_nicolashiguera.git
cd banco-cl

Configurar Base de Datos

Conexión

Conéctate a MySQL con Workbench o DBeaver.

Crear Base

Crea la base de datos:

CREATE DATABASE banco_cl;
USE banco_cl;

Ejecutar Scripts

Ejecuta en orden:
- Estructura: `sql/ddl.sql`
- Datos: `sql/dml.sql`
- Consultas: `sql/dql_select.sql`
- Procedimientos: `sql/dql_procedimientos.sql`
- Funciones: `sql/dql_funciones.sql`
- Triggers: `sql/dql_triggers.sql`
- Eventos: `sql/dql_eventos.sql

mysql -u <usuario> -p banco_cl < sql/ddl.sql
mysql -u <usuario> -p banco_cl < sql/dml.sql
mysql -u <usuario> -p banco_cl < sql/dql_select.sql
mysql -u <usuario> -p banco_cl < sql/dql_procedimientos.sql
mysql -u <usuario> -p banco_cl < sql/dql_funciones.sql
mysql -u <usuario> -p banco_cl < sql/dql_triggers.sql
mysql -u <usuario> -p banco_cl < sql/dql_eventos.sql

Roles

Ver **Roles de Usuario y Permisos** para configuración.

Verificar Modelo

Revisa `Diagrama.jpg` para relaciones entre tablas.

Estructura de la Base

Tablas

- Clientes: ID, nombre, cuenta, tipo de tarjeta, monto apertura
- Tarjetas: ID, tipo (Joven, Nómina, Visa), monto apertura, cliente
- Cuotas_Manejo: Cuotas mensuales con descuentos
- Descuentos: Tipos (Básico, Platino, Diamante), valores
- Historial_Pagos: Pagos vinculados a cuotas

Relaciones

- Clientes → Tarjetas (1:N)
- Tarjetas → Descuentos (1:1)
- Tarjetas → Cuotas_Manejo (1:N)
- Cuotas_Manejo → Historial_Pagos (1:1)
Ver en `Diagrama.jpg`.

Consultas

Básicas





Tarjetas y cuotas:

Lista tarjetas, tipo, cliente y cuota.

SELECT t.id_tarjeta, t.tipo_tarjeta, c.nombre, cm.monto_cuota
FROM Tarjetas t
JOIN Clientes c ON t.id_cliente = c.id_cliente
JOIN Cuotas_Manejo cm ON t.id_tarjeta = cm.id_tarjeta;



Historial de pagos:

Pagos por cliente.

SELECT c.nombre, h.fecha_pago, h.monto_pagado
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Historial_Pagos h ON t.id_tarjeta = h.id_tarjeta
WHERE c.id_cliente = 1;

Avanzadas





Pagos pendientes:

Cuotas sin pagar (últimos 3 meses).

SELECT c.nombre, t.id_tarjeta, cm.fecha_cuota
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Cuotas_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
LEFT JOIN Historial_Pagos h ON cm.id_cuota = h.id_cuota
WHERE h.id_pago IS NULL AND cm.fecha_cuota >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH);



Descuentos 2025:

Descuentos por tipo en 2025.

SELECT d.tipo_descuento, COUNT(cm.id_cuota) AS total_cuotas, SUM(d.valor_descuento) AS total_descuentos
FROM Descuentos d
JOIN Cuotas_Manejo cm ON d.id_descuento = cm.id_descuento
WHERE YEAR(cm.fecha_cuota) = 2025
GROUP BY d.tipo_descuento;

Procedimientos, Funciones, Triggers, Eventos

Procedimientos (20)





**RegistrarCuotaMane-apple

Registra cuotas con descuentos.

CALL RegistrarCuotaManejo(id_tarjeta, mes, anio);

Funciones (20)





CalcularCuotaManejo:

Calcula cuota por tipo y monto.

SELECT CalcularCuotaManejo(id_tarjeta) AS cuota;

Triggers (20)





AfterPagoInsert:

Actualiza estado de cuota a "Pagada".

CREATE TRIGGER AfterPagoInsert
AFTER INSERT ON Historial_Pagos
FOR EACH ROW
UPDATE Cuotas_Manejo SET estado = 'Pagada' WHERE id_cuota = NEW.id_cuota;

Eventos (20)





GenerarReporteMensual:

Reportes mensuales de cuotas.

CREATE EVENT GenerarReporteMensual
ON SCHEDULE EVERY 1 MONTH
DO
INSERT INTO Reportes (fecha, total_cuotas)
SELECT CURDATE(), SUM(monto_cuota) FROM Cuotas_Manejo WHERE MONTH(fecha_cuota) = MONTH(CURDATE());

Roles y Permisos

Administrador

Acceso completo.

CREATE ROLE administrador;
GRANT ALL ON banco_cl.* TO administrador;

Operador de Pagos

Gestiona pagos y consulta cuotas.

CREATE ROLE operador_pagos;
GRANT SELECT, INSERT, UPDATE ON banco_cl.Historial_Pagos TO operador_pagos;
GRANT SELECT ON banco_cl.Cuotas_Manejo TO operador_pagos;

Gerente

Consulta reportes y procedimientos.

CREATE ROLE gerente;
GRANT SELECT, EXECUTE ON banco_cl.* TO gerente;

Consultor de Tarjetas

Consulta tarjetas y cuotas.

CREATE ROLE consultor_tarjetas;
GRANT SELECT ON banco_cl.Tarjetas TO consultor_tarjetas;
GRANT SELECT ON banco_cl.Cuotas_Manejo TO consultor_tarjetas;

Auditor

Consulta reportes.

CREATE ROLE auditor;
GRANT SELECT ON banco_cl.Reportes TO auditor;

Asignar Roles

Ejemplo:

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

- Juan Meneses.
- Nicolás Higuera.
