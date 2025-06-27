-- 1. Listado de todas las tarjetas de los clientes junto con su cuota de manejo
SELECT
    c.nombre AS nombre_cliente,
    t.id_tarjeta,
    monto AS cuota_de_manejo,
    fecha_vencimiento
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = id_tarjeta
ORDER BY c.nombre, t.id_tarjeta;


-- 2. Historial de pagos de un cliente específico

    SELECT c.nombre, p.*, cm.*, t.*
    FROM Clientes c
    INNER JOIN Tarjetas t ON c.id_cliente = t.id_cliente
    INNER JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = id_tarjeta
    INNER JOIN Pagos p ON id_cuota_manejo = p.id_cuota_manejo
    WHERE c.id_cliente = :id_cliente;

-- 3. Total de cuotas de manejo pagadas durante un mes

SELECT
    SUM(p.monto) AS total_pagado_en_el_mes
FROM
    Pagos p
WHERE p.estado = 'Completado' AND YEAR(p.fecha_pago) = :anio AND MONTH(p.fecha_pago) = :mes;

-- 4. Cuotas de manejo de los clientes con descuento aplicado

-- 5. Reporte mensual de las cuotas de manejo de cada tarjeta
SELECT
    id_tarjeta,
    YEAR(fecha_vencimiento) AS anio,
    MONTH(fecha_vencimiento) AS mes,
    COUNT(id_cuota_manejo) AS cantidad_cuotas,
    SUM(monto) AS monto_total_mensual
FROM Cuotas_de_Manejo cm
GROUP BY id_tarjeta,anio,mes
ORDER BY id_tarjeta, anio,mes;

-- 6. Promociones activas durante una fecha específica

-- 7. Métodos de pago utilizados por un cliente

SELECT DISTINCT descripcion AS metodo_pago
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = id_tarjeta
JOIN Pagos p ON id_cuota_manejo = p.id_cuota_manejo
JOIN Metodos_Pago mp ON p.id_metodo = id_metodo
WHERE c.id_cliente = :id_cliente;

-- 8. Consultar todas las transacciones realizadas por tarjeta

-- 9. Tarjetas que tienen promociones aplicadas
SELECT DISTINCT t.id_tarjeta,c.nombre AS nombre_cliente,
    nombre_tipo AS tipo_tarjeta
FROM Tarjetas t
JOIN Tarjetas_Promociones tp ON t.id_tarjeta = t.id_tarjeta
JOIN Clientes c ON t.id_cliente = c.id_cliente
JOIN Tipos_Tarjeta tt ON t.id_tipo_tarjeta = t.id_tipo_tarjeta
ORDER BY t.id_tarjeta;

-- 10. Clientes que han utilizado más de un tipo de tarjeta

-- 11. Cuotas de manejo vencidas hasta la fecha

SELECT
    c.nombre AS nombre_cliente,
    cm.id_tarjeta,
    cm.monto,
    cm.fecha_vencimiento,
    ec.descripcion AS estado
FROM Cuotas_de_Manejo cm
JOIN Estado_Cuota ec ON cm.id_estado_cuota = ec.id_estado_cuota
JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
JOIN Clientes c ON t.id_cliente = c.id_cliente
WHERE cm.fecha_vencimiento < CURDATE() AND ec.descripcion = 'Pendiente'
ORDER BY cm.fecha_vencimiento;

-- 12. Transacciones registradas durante la última semana

-- 13. Listar los clientes con más de una tarjeta activa
SELECT c.nombre,COUNT(t.id_tarjeta) AS numero_de_tarjetas
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
GROUP BY c.id_cliente, c.nombre
HAVING COUNT(t.id_tarjeta) > 1;

-- 14. Promociones aplicadas a una tarjeta específica

-- 15. Pagos realizados en una fecha determinada

SELECT p.id_pago, p.id_cuota_manejo, p.monto,p.estado, mp.descripcion AS metodo_pago
FROM Pagos p
JOIN Metodos_Pago mp ON p.id_metodo = mp.id_metodo
WHERE p.fecha_pago = :fecha_determinada;

-- 16. Consultar tarjetas sin promociones asignadas

-- 17. Consultar métodos de pago disponibles actualmente
SELECT id_metodo, descripcion, estado_cuenta
FROM Metodos_Pago
WHERE estado_cuenta = 'Activo';

-- 18. Tarjetas con cuota de manejo superior a cierto valor

-- 19. Cuotas de manejo con vencimiento próximo (menos de 7 días)

SELECT
    c.nombre AS nombre_cliente,
    cm.id_tarjeta,
    cm.monto,
    cm.fecha_vencimiento
FROM Cuotas_de_Manejo cm
JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
JOIN Clientes c ON t.id_cliente = c.id_cliente
JOIN Estado_Cuota ec ON cm.id_estado_cuota = ec.id_estado_cuota
WHERE cm.fecha_vencimiento BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)   AND ec.descripcion = 'Pendiente';

-- 20. Tarjetas creadas en el último mes

-- 21. Clientes que no han realizado pagos en el último mes

SELECT c.id_cliente,  c.nombre
FROM Clientes c
WHERE
    c.id_cliente NOT IN (
        SELECT DISTINCT t.id_cliente
        FROM Pagos p
        JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
        JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
        WHERE p.fecha_pago >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    );

-- 22. Promociones con más de 20% de descuento

-- 23. Listado de tarjetas por tipo

SELECT  tt.nombre_tipo, COUNT(t.id_tarjeta) AS cantidad_de_tarjetas
FROM Tipos_Tarjeta tt
JOIN  Tarjetas t ON tt.id_tipo_tarjeta = t.id_tipo_tarjeta
GROUP BY tt.nombre_tipo
ORDER BY cantidad_de_tarjetas DESC;

-- 24. Cuotas de manejo agrupadas por cliente

-- 25. Promociones activas por mes

SELECT
    nombre_promocion,
    descuento_aplicado,
    fecha_inicio,
    fecha_fin
FROM Promociones
WHERE DATE_FORMAT(CURDATE(), '%Y-%m') BETWEEN DATE_FORMAT(fecha_inicio, '%Y-%m') AND DATE_FORMAT(fecha_fin, '%Y-%m');

-- 26. Métodos de pago más usados

-- 27. Consultar todos los pagos con tarjeta de crédito

SELECT
    p.id_pago,
    c.nombre AS nombre_cliente,
    p.monto,
    p.fecha_pago,
    p.estado
FROM Pagos p
JOIN Metodos_Pago mp ON p.id_metodo = mp.id_metodo
JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
JOIN Clientes c ON t.id_cliente = c.id_cliente
WHERE mp.descripcion = 'Tarjeta de crédito';

-- 28. Clientes que tienen descuentos activos

-- 29. Cuotas de manejo agrupadas por año

SELECT
    YEAR(fecha_vencimiento) AS anio,
    COUNT(id_cuota_manejo) AS numero_de_cuotas,
    SUM(monto) AS monto_total
FROM Cuotas_de_Manejo
GROUP BY YEAR(fecha_vencimiento)
ORDER BY anio;

-- 30. Historial de promociones aplicadas a una tarjeta

-- 31. Total de pagos recibidos por mes en el año actual

SELECT
    MONTH(fecha_pago) AS mes,
    SUM(monto) AS total_recibido
FROM
    Pagos
WHERE
    YEAR(fecha_pago) = YEAR(CURDATE())
    AND estado = 'Completado'
GROUP BY
    MONTH(fecha_pago)
ORDER BY
    mes;


-- 32. Consultar el monto promedio de las cuotas de manejo

-- 33. Porcentaje de tarjetas con promociones activas

SELECT
    (
        (SELECT COUNT(DISTINCT id_tarjeta) 
        FROM Tarjetas_Promociones) / (SELECT COUNT(*) FROM Tarjetas)
    ) * 100 AS porcentaje_tarjetas_con_promocion;

-- 34. Número total de tarjetas por cliente

-- 35. Total de transacciones realizadas este año

SELECT COUNT(*) AS total_transacciones_este_anio
FROM Transacciones
WHERE YEAR(fecha_transaccion) = YEAR(CURDATE());

-- 36. Cantidad de cuotas emitidas por mes

-- 37. Evolución de pagos mensuales durante el año

SELECT
    YEAR(fecha_pago) AS anio,
    MONTH(fecha_pago) AS mes,
    SUM(monto) AS total_pagado
FROM Pagos
WHERE estado = 'Completado'
GROUP BY anio, mes
ORDER BY anio, mes;

-- 38. Top clientes por valor total pagado

-- 39. Evaluación del impacto de promociones en pagos

-- 40. Análisis comparativo de pagos entre trimestres

-- 41. Reporte de pagos agrupados por método de pago

-- 42. Total de pagos por cliente en un rango de fechas

-- 43. Cuotas vencidas por cliente

-- 44. Listar promociones activas entre dos fechas

-- 45. Consultar tarjetas con múltiples promociones

-- 46. Resumen de pagos por tipo de tarjeta

-- 47. Transacciones agrupadas por mes

-- 48. Tarjetas por tipo con su promedio de cuota de manejo

-- 49. Consultar clientes sin cuotas asociadas

-- 50. Cuotas de manejo con estado "pendiente"

-- 51. Cuotas con descuentos superiores al 15%

-- 52. Clientes con más de dos pagos realizados

-- 53. Total de transacciones por día

-- 54. Transacciones por tipo (crédito/débito/otro)

-- 55. Descuentos agrupados por categoría

-- 56. Tarjetas con apertura superior al promedio

-- 57. Consultar clientes que han usado promociones

-- 58. Cuotas pagadas agrupadas por trimestre

-- 59. Total de promociones aplicadas por cliente

-- 60. Consultar tarjetas sin cuota de manejo asociada

-- 61. Tarjetas que no han sido usadas para transacciones

-- 62. Cuotas de manejo mayores al promedio

-- 63. Cuotas agrupadas por estado (aceptada, rechazada, etc.)

-- 64. Consultar pagos y promociones por cliente

-- 65. Consultar promociones que vencen este mes

-- 66. Clientes con múltiples descuentos aplicados

-- 67. Tarjetas que aplican para promociones exclusivas

-- 68. Consultar transacciones superiores a $500.000

-- 69. Clientes nuevos registrados en el último trimestre

-- 70. Consultar tarjetas activas con más de 5 cuotas pagadas

-- 71. Clientes con pagos pendientes en los últimos tres meses

-- 72. Cuotas aplicadas a cada tipo de tarjeta en un período específico

-- 73. Reporte de descuentos aplicados durante un año

-- 74. Tarjetas con el mayor y menor monto de apertura

-- 75. Total de pagos realizados por tipo de tarjeta

-- 76. Top 5 clientes con más pagos realizados

-- 77. Total de promociones utilizadas por mes

-- 78. Clientes que nunca han aplicado promociones

-- 79. Clientes que han pagado puntualmente todas sus cuotas

-- 80. Tarjetas con más movimientos de transacciones

-- 81. Promedios de pagos por cliente

-- 82. Clientes que han tenido cuotas rechazadas

-- 83. Análisis de pagos por método (efectivo, tarjeta, etc.)

-- 84. Cuotas más costosas del sistema

-- 85. Clientes con mayor gasto mensual promedio

-- 86. Promociones con duración mayor a 30 días

-- 87. Comparación de uso entre tipos de tarjeta

-- 88. Ranking de promociones más utilizadas

-- 89. Clientes con más transacciones en el año

-- 90. Comparar número de cuotas por tipo de tarjeta

-- 91. Descuentos con más frecuencia de aplicación

-- 92. Total recaudado por promociones activas

-- 93. Clientes con más métodos de pago registrados

-- 94. Cuotas vencidas vs cuotas pagadas por cliente

-- 95. Clientes con historial limpio (sin mora ni rechazo)

-- 96. Tarjetas usadas exclusivamente con un método de pago

-- 97. Historial de transacciones agrupado por trimestre

-- 98. Análisis de promociones efectivas vs inefectivas

-- 99. Clientes que acumulan más beneficios en descuentos

-- 100. Promociones utilizadas en el último Black Friday
