Banco CL - Sistema de Gestión de Cuotas de Manejo

Descripción del Proyecto

El proyecto Banco CL tiene como objetivo diseñar e implementar una base de datos para gestionar de manera eficiente las operaciones relacionadas con las cuotas de manejo de tarjetas bancarias (Joven, Nómina, Visa) en el banco ficticio "Banco CL". La solución permite registrar, calcular y reportar cuotas de manejo, gestionar pagos, y mantener un historial de transacciones, garantizando la integridad y consistencia de los datos.

El sistema incluye entidades clave como Clientes, Tarjetas, Cuotas de Manejo, Descuentos, y Historial de Pagos, modeladas en tercera forma normal (3FN) para evitar redundancias. Además, se implementan consultas SQL, procedimientos almacenados, funciones, eventos, triggers, y roles de usuario para automatizar tareas y asegurar la seguridad de los datos.

Requisitos del Sistema

Para ejecutar los scripts SQL y configurar la base de datos, se requiere lo siguiente:





MySQL: Versión 8.0 o superior.



Cliente MySQL: MySQL Workbench, DBeaver, o cualquier cliente compatible con MySQL.



Git: Para clonar el repositorio.



Sistema Operativo: Cualquier sistema compatible con MySQL (Windows, macOS, Linux).



Espacio en disco: Mínimo 100 MB para la base de datos y los scripts.

Instalación y Configuración

Sigue estos pasos para configurar y ejecutar el proyecto:





Clonar el repositorio:

git clone <https://github.com/nicolashiguera17/Banco-CL_juanmeneses_nicolashiguera.git>

cd banco-cl



Configurar la base de datos:





Abre MySQL Workbench o tu cliente MySQL preferido.



Conéctate a tu servidor MySQL local o remoto.



Crea una base de datos vacía:

CREATE DATABASE banco_cl;
USE banco_cl;



Ejecutar los scripts SQL en el siguiente orden:





Estructura de la base de datos: Ejecuta ddl.sql para crear las tablas y relaciones.

mysql -u <usuario> -p banco_cl < sql/ddl.sql



Datos iniciales: Ejecuta dml.sql para insertar al menos 50 registros por entidad.

mysql -u <usuario> -p banco_cl < sql/dml.sql



Consultas, procedimientos, funciones, triggers y eventos:





Ejecuta dql_select.sql para consultas.



Ejecuta dql_procedimientos.sql para procedimientos almacenados.



Ejecuta dql_funciones.sql para funciones.



Ejecuta dql_triggers.sql para triggers.



Ejecuta dql_eventos.sql para eventos.

mysql -u <usuario> -p banco_cl < sql/dql_select.sql
mysql -u <usuario> -p banco_cl < sql/dql_procedimientos.sql
mysql -u <usuario> -p banco_cl < sql/dql_funciones.sql
mysql -u <usuario> -p banco_cl < sql/dql_triggers.sql
mysql -u <usuario> -p banco_cl < sql/dql_eventos.sql



Configurar roles de usuario:





Consulta la sección "Roles de Usuario y Permisos" para crear usuarios y asignarles roles.



Verificar el modelo de datos:





Revisa el archivo Diagrama.jpg para entender las relaciones entre las tablas.

Estructura de la Base de Datos

La base de datos está diseñada en tercera forma normal (3FN) y consta de las siguientes tablas:





Clientes: Almacena información personal de los clientes (ID, nombre, número de cuenta, tipo de tarjeta, monto de apertura).



Tarjetas: Registra detalles de las tarjetas (ID, tipo: Joven, Nómina, Visa, monto de apertura, cliente asociado).



Cuotas_Manejo: Contiene las cuotas mensuales calculadas para cada tarjeta, incluyendo descuentos aplicados.



Descuentos: Define los tipos de descuentos (Básico, Platino, Diamante) y sus valores.



Historial_Pagos: Registra los pagos realizados por los clientes, vinculados a las cuotas de manejo.

Relaciones:





Un cliente puede tener múltiples tarjetas (1:N).



Cada tarjeta está asociada a un descuento (1:1).



Cada tarjeta genera cuotas de manejo mensuales (1:N).



Los pagos están vinculados a cuotas de manejo específicas (1:1).

El modelo de datos se encuentra representado en el archivo Diagrama.jpg.

Ejemplos de Consultas

A continuación, se presentan ejemplos de consultas SQL implementadas:

Consultas Básicas





Listado de tarjetas con cuotas de manejo:

SELECT t.id_tarjeta, t.tipo_tarjeta, c.nombre, cm.monto_cuota
FROM Tarjetas t
JOIN Clientes c ON t.id_cliente = c.id_cliente
JOIN Cuotas_Manejo cm ON t.id_tarjeta = cm.id_tarjeta;

Resultado: Muestra todas las tarjetas, el tipo, el nombre del cliente y la cuota de manejo correspondiente.



Historial de pagos de un cliente:

SELECT c.nombre, h.fecha_pago, h.monto_pagado
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Historial_Pagos h ON t.id_tarjeta = h.id_tarjeta
WHERE c.id_cliente = 1;

Resultado: Lista los pagos realizados por un cliente específico.

Consultas Avanzadas





Clientes con pagos pendientes en los últimos tres meses:

SELECT c.nombre, t.id_tarjeta, cm.fecha_cuota
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Cuotas_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
LEFT JOIN Historial_Pagos h ON cm.id_cuota = h.id_cuota
WHERE h.id_pago IS NULL AND cm.fecha_cuota >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH);

Resultado: Identifica clientes con cuotas de manejo sin pagar en los últimos tres meses.



Reporte de descuentos aplicados en un año:

SELECT d.tipo_descuento, COUNT(cm.id_cuota) as total_cuotas, SUM(d.valor_descuento) as total_descuentos
FROM Descuentos d
JOIN Cuotas_Manejo cm ON d.id_descuento = cm.id_descuento
WHERE YEAR(cm.fecha_cuota) = 2025
GROUP BY d.tipo_descuento;

Resultado: Muestra el total de descuentos aplicados por tipo durante el año 2025.

Procedimientos, Funciones, Triggers y Eventos

Procedimientos Almacenados

Se implementaron 20 procedimientos almacenados para automatizar tareas. Ejemplo:





RegistrarCuotaManejo: Calcula y registra la cuota de manejo de una tarjeta, aplicando el descuento correspondiente.

CALL RegistrarCuotaManejo(id_tarjeta, mes, anio);

Uso: Registra una nueva cuota para el mes y año especificados.

Funciones

Se crearon 20 funciones para cálculos personalizados. Ejemplo:





CalcularCuotaManejo: Calcula la cuota de manejo según el tipo de tarjeta y monto de apertura.

SELECT CalcularCuotaManejo(id_tarjeta) AS cuota;

Uso: Retorna el valor de la cuota para una tarjeta específica.

Triggers

Se definieron 20 triggers para automatizar acciones. Ejemplo:





ActualizarEstadoCuota: Actualiza el estado de una cuota al registrar un pago.

TRIGGER AfterPagoInsert
AFTER INSERT ON Historial_Pagos
FOR EACH ROW
UPDATE Cuotas_Manejo SET estado = 'Pagada' WHERE id_cuota = NEW.id_cuota;

Uso: Cambia el estado de la cuota a "Pagada" tras registrar un pago.

Eventos

Se implementaron 20 eventos para tareas periódicas. Ejemplo:





GenerarReporteMensual: Genera un reporte automático de cuotas al finalizar cada mes.

CREATE EVENT GenerarReporteMensual
ON SCHEDULE EVERY 1 MONTH
DO
INSERT INTO Reportes (fecha, total_cuotas)
SELECT CURDATE(), SUM(monto_cuota) FROM Cuotas_Manejo WHERE MONTH(fecha_cuota) = MONTH(CURDATE());

Uso: Registra el total de cuotas generadas cada mes.

Roles de Usuario y Permisos

Se definieron 5 roles con permisos específicos:





Administrador:





Permisos: Acceso completo (SELECT, INSERT, UPDATE, DELETE) a todas las tablas, ejecución de procedimientos, funciones, triggers y eventos.



Creación:

CREATE ROLE administrador;
GRANT ALL ON banco_cl.* TO administrador;



Operador de Pagos:





Permisos: INSERT, SELECT y UPDATE en Historial_Pagos y consultas en Cuotas_Manejo.



Creación:

CREATE ROLE operador_pagos;
GRANT SELECT, INSERT, UPDATE ON banco_cl.Historial_Pagos TO operador_pagos;
GRANT SELECT ON banco_cl.Cuotas_Manejo TO operador_pagos;



Gerente:





Permisos: SELECT en todas las tablas y ejecución de procedimientos de reportes.



Creación:

CREATE ROLE gerente;
GRANT SELECT ON banco_cl.* TO gerente;
GRANT EXECUTE ON banco_cl.* TO gerente;



Consultor de Tarjetas:





Permisos: SELECT en Tarjetas y Cuotas_Manejo.



Creación:

CREATE ROLE consultor_tarjetas;
GRANT SELECT ON banco_cl.Tarjetas TO consultor_tarjetas;
GRANT SELECT ON banco_cl.Cuotas_Manejo TO consultor_tarjetas;



Auditor:





Permisos: SELECT en reportes generados (vista o tabla Reportes).



Creación:

CREATE ROLE auditor;
GRANT SELECT ON banco_cl.Reportes TO auditor;

Asignar roles a usuarios:

CREATE USER 'usuario_admin'@'localhost' IDENTIFIED BY 'password';
GRANT administrador TO 'usuario_admin'@'localhost';
SET DEFAULT ROLE administrador FOR 'usuario_admin'@'localhost';

Estructura del Repositorio

El repositorio está organizado de la siguiente manera:

banco-cl/
├── sql/
│   ├── ddl.sql                # Creación de tablas y relaciones
│   ├── dml.sql                # Inserciones de datos iniciales
│   ├── dql_select.sql         # Consultas SQL
│   ├── dql_procedimientos.sql # Procedimientos almacenados
│   ├── dql_funciones.sql      # Funciones SQL
│   ├── dql_triggers.sql       # Triggers SQL
│   ├── dql_eventos.sql        # Eventos SQL
├── Diagrama.jpg               # Diagrama del modelo de datos
├── README.md                  # Documentación del proyecto

Contribuciones





Estudiante 1: Diseño del modelo de datos, creación de ddl.sql y dml.sql.



Estudiante 2: Implementación de consultas (dql_select.sql) y procedimientos almacenados.



Estudiante 3: Desarrollo de funciones, triggers y eventos SQL.



Estudiante 4: Configuración de roles de usuario y documentación del README.

Licencia y Contacto

Este proyecto es de uso académico y no está licenciado para uso comercial. Para dudas o problemas con la implementación, contacta al equipo a través del correo: equipo.banco.cl@example.com.