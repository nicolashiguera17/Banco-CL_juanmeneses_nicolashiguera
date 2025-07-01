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

SELECT 
    c.id_cliente,
    c.nombre,
    t.id_tarjeta,
    cm.id_cuota_manejo,
    cm.monto,
    d.descripcion AS descuento_aplicado
FROM 
    Clientes c
    JOIN Tarjetas t ON c.id_cliente = t.id_cliente
    JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
    JOIN Descuentos d ON t.id_descuento = d.id_descuento
WHERE 
    t.id_descuento IS NOT NULL;

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

SELECT 
    p.id_promocion,
    p.nombre_promocion,
    p.descuento_aplicado,
    p.fecha_inicio,
    p.fecha_fin
FROM 
    Promociones p
WHERE 
    2025-06-28 BETWEEN p.fecha_inicio AND p.fecha_fin;

-- 7. Métodos de pago utilizados por un cliente

SELECT DISTINCT descripcion AS metodo_pago
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = id_tarjeta
JOIN Pagos p ON id_cuota_manejo = p.id_cuota_manejo
JOIN Metodos_Pago mp ON p.id_metodo = id_metodo
WHERE c.id_cliente = :id_cliente;

-- 8. Consultar todas las transacciones realizadas por tarjeta

SELECT 
    t.id_transaccion,
    t.fecha_transaccion,
    t.monto,
    t.tipo_transaccion,
    tar.id_tarjeta,
    c.nombre AS cliente
FROM 
    Transacciones t
    JOIN Pagos p ON t.id_pago = p.id_pago
    JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
    JOIN Tarjetas tar ON cm.id_tarjeta = tar.id_tarjeta
    JOIN Clientes c ON tar.id_cliente = c.id_cliente;

-- 9. Tarjetas que tienen promociones aplicadas
SELECT DISTINCT t.id_tarjeta,c.nombre AS nombre_cliente,
    nombre_tipo AS tipo_tarjeta
FROM Tarjetas t
JOIN Tarjetas_Promociones tp ON t.id_tarjeta = t.id_tarjeta
JOIN Clientes c ON t.id_cliente = c.id_cliente
JOIN Tipos_Tarjeta tt ON t.id_tipo_tarjeta = t.id_tipo_tarjeta
ORDER BY t.id_tarjeta;

-- 10. Clientes que han utilizado más de un tipo de tarjeta

SELECT 
    c.id_cliente,
    c.nombre,
    COUNT(DISTINCT t.id_tipo_tarjeta) AS tipos_tarjetas
FROM 
    Clientes c
    JOIN Tarjetas t ON c.id_cliente = t.id_cliente
GROUP BY 
    c.id_cliente, c.nombre
HAVING 
    COUNT(DISTINCT t.id_tipo_tarjeta) > 1;

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

SELECT 
    t.id_transaccion,
    t.fecha_transaccion,
    t.monto,
    t.tipo_transaccion,
    c.nombre AS cliente
FROM 
    Transacciones t
    JOIN Pagos p ON t.id_pago = p.id_pago
    JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
    JOIN Tarjetas tar ON cm.id_tarjeta = tar.id_tarjeta
    JOIN Clientes c ON tar.id_cliente = c.id_cliente
WHERE 
    t.fecha_transaccion >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    AND t.fecha_transaccion <= CURDATE();

-- 13. Listar los clientes con más de una tarjeta activa
SELECT c.nombre,COUNT(t.id_tarjeta) AS numero_de_tarjetas
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
GROUP BY c.id_cliente, c.nombre
HAVING COUNT(t.id_tarjeta) > 1;

-- 14. Promociones aplicadas a una tarjeta específica

SELECT 
    p.id_promocion,
    p.nombre_promocion,
    p.descuento_aplicado,
    tp.fecha_aplicacion
FROM 
    Tarjetas_Promociones tp
    JOIN Promociones p ON tp.id_promocion = p.id_promocion
WHERE 
    tp.id_tarjeta = 20001;

-- 15. Pagos realizados en una fecha determinada

SELECT p.id_pago, p.id_cuota_manejo, p.monto,p.estado, mp.descripcion AS metodo_pago
FROM Pagos p
JOIN Metodos_Pago mp ON p.id_metodo = mp.id_metodo
WHERE p.fecha_pago = :fecha_determinada;

-- 16. Consultar tarjetas sin promociones asignadas

SELECT 
    t.id_tarjeta,
    c.nombre AS cliente,
    tt.nombre_tipo AS tipo_tarjeta
FROM 
    Tarjetas t
    JOIN Clientes c ON t.id_cliente = c.id_cliente
    JOIN Tipos_Tarjeta tt ON t.id_tipo_tarjeta = tt.id_tipo_tarjeta
    LEFT JOIN Tarjetas_Promociones tp ON t.id_tarjeta = tp.id_tarjeta
WHERE 
    tp.id_tarjeta_promocion IS NULL;
    
-- 17. Consultar métodos de pago disponibles actualmente
SELECT id_metodo, descripcion, estado_cuenta
FROM Metodos_Pago
WHERE estado_cuenta = 'Activo';

-- 18. Tarjetas con cuota de manejo superior a cierto valor

SELECT 
    t.id_tarjeta,
    c.nombre AS cliente,
    cm.monto AS cuota_manejo
FROM 
    Tarjetas t
    JOIN Clientes c ON t.id_cliente = c.id_cliente
    JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
WHERE 
    cm.monto > 50000;

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

SELECT 
    t.id_tarjeta,
    c.nombre AS cliente,
    tt.nombre_tipo AS tipo_tarjeta
FROM 
    Tarjetas t
    JOIN Clientes c ON t.id_cliente = c.id_cliente
    JOIN Tipos_Tarjeta tt ON t.id_tipo_tarjeta = tt.id_tipo_tarjeta
WHERE 
    t.id_tarjeta IN (
        SELECT id_tarjeta 
        FROM Cuotas_de_Manejo 
        WHERE fecha_vencimiento >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    );

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

SELECT 
    id_promocion,
    nombre_promocion,
    descuento_aplicado
FROM 
    Promociones
WHERE 
    descuento_aplicado > 20;

-- 23. Listado de tarjetas por tipo

SELECT  tt.nombre_tipo, COUNT(t.id_tarjeta) AS cantidad_de_tarjetas
FROM Tipos_Tarjeta tt
JOIN  Tarjetas t ON tt.id_tipo_tarjeta = t.id_tipo_tarjeta
GROUP BY tt.nombre_tipo
ORDER BY cantidad_de_tarjetas DESC;

-- 24. Cuotas de manejo agrupadas por cliente

SELECT 
    c.id_cliente,
    c.nombre,
    COUNT(cm.id_cuota_manejo) AS total_cuotas,
    SUM(cm.monto) AS monto_total
FROM 
    Clientes c
    JOIN Tarjetas t ON c.id_cliente = t.id_cliente
    JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
GROUP BY 
    c.id_cliente, c.nombre;

-- 25. Promociones activas por mes

SELECT
    nombre_promocion,
    descuento_aplicado,
    fecha_inicio,
    fecha_fin
FROM Promociones
WHERE DATE_FORMAT(CURDATE(), '%Y-%m') BETWEEN DATE_FORMAT(fecha_inicio, '%Y-%m') AND DATE_FORMAT(fecha_fin, '%Y-%m');

-- 26. Métodos de pago más usados

SELECT 
    mp.descripcion,
    COUNT(p.id_pago) AS total_pagos
FROM 
    Metodos_Pago mp
    JOIN Pagos p ON mp.id_metodo = p.id_metodo
GROUP BY 
    mp.id_metodo, mp.descripcion
ORDER BY 
    total_pagos DESC;

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

SELECT DISTINCT 
    c.id_cliente,
    c.nombre,
    d.descripcion AS descuento
FROM 
    Clientes c
    JOIN Tarjetas t ON c.id_cliente = t.id_cliente
    JOIN Descuentos d ON t.id_descuento = d.id_descuento;

-- 29. Cuotas de manejo agrupadas por año

SELECT
    YEAR(fecha_vencimiento) AS anio,
    COUNT(id_cuota_manejo) AS numero_de_cuotas,
    SUM(monto) AS monto_total
FROM Cuotas_de_Manejo
GROUP BY YEAR(fecha_vencimiento)
ORDER BY anio;

-- 30. Historial de promociones aplicadas a una tarjeta

SELECT 
    p.id_promocion,
    p.nombre_promocion,
    p.descuento_aplicado,
    tp.fecha_aplicacion
FROM 
    Tarjetas_Promociones tp
    JOIN Promociones p ON tp.id_promocion = p.id_promocion
WHERE 
    tp.id_tarjeta = 20001;

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

SELECT 
    AVG(monto) AS promedio_cuota_manejo
FROM 
    Cuotas_de_Manejo;

-- 33. Porcentaje de tarjetas con promociones activas

SELECT
    (
        (SELECT COUNT(DISTINCT id_tarjeta) 
        FROM Tarjetas_Promociones) / (SELECT COUNT(*) FROM Tarjetas)
    ) * 100 AS porcentaje_tarjetas_con_promocion;

-- 34. Número total de tarjetas por cliente

SELECT 
    c.id_cliente,
    c.nombre,
    COUNT(t.id_tarjeta) AS total_tarjetas
FROM 
    Clientes c
    LEFT JOIN Tarjetas t ON c.id_cliente = t.id_cliente
GROUP BY 
    c.id_cliente, c.nombre;

-- 35. Total de transacciones realizadas este año

SELECT COUNT(*) AS total_transacciones_este_anio
FROM Transacciones
WHERE YEAR(fecha_transaccion) = YEAR(CURDATE());

-- 36. Cantidad de cuotas emitidas por mes

SELECT 
    DATE_FORMAT(fecha_vencimiento, '%Y-%m') AS mes,
    COUNT(id_cuota_manejo) AS total_cuotas
FROM 
    Cuotas_de_Manejo
GROUP BY 
    DATE_FORMAT(fecha_vencimiento, '%Y-%m')
ORDER BY 
    mes;

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

SELECT 
    c.id_cliente,
    c.nombre,
    SUM(p.monto) AS total_pagado
FROM 
    Clientes c
    JOIN Tarjetas t ON c.id_cliente = t.id_cliente
    JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
    JOIN Pagos p ON cm.id_cuota_manejo = p.id_cuota_manejo
GROUP BY 
    c.id_cliente, c.nombre
ORDER BY 
    total_pagado DESC
LIMIT 10;

-- 39. Evaluación del impacto de promociones en pagos

SELECT
    CASE
        WHEN t.id_tarjeta IN (SELECT DISTINCT id_tarjeta FROM Tarjetas_Promociones) THEN 'Con Promoción'
        ELSE 'Sin Promoción'
    END AS grupo,
    SUM(p.monto) AS total_pagado,
    COUNT(DISTINCT t.id_tarjeta) AS numero_de_tarjetas
FROM
    Pagos p
JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
WHERE p.estado = 'Completado'
GROUP BY grupo;

-- 40. Análisis comparativo de pagos entre trimestres

SELECT 
    DATE_FORMAT(p.fecha_pago, '%Y-Q%q') AS trimestre,
    SUM(p.monto) AS total_pagado
FROM 
    Pagos p
GROUP BY 
    DATE_FORMAT(p.fecha_pago, '%Y-Q%q')
ORDER BY 
    trimestre;

-- 41. Reporte de pagos agrupados por método de pago

SELECT
    mp.descripcion AS metodo_de_pago,
    COUNT(p.id_pago) AS cantidad_de_pagos,
    SUM(p.monto) AS monto_total_procesado
FROM Pagos p
JOIN Metodos_Pago mp ON p.id_metodo = mp.id_metodo
GROUP BY mp.descripcion
ORDER BY monto_total_procesado DESC;

-- 42. Total de pagos por cliente en un rango de fechas

SELECT 
    c.id_cliente,
    c.nombre,
    SUM(p.monto) AS total_pagado
FROM 
    Clientes c
    JOIN Tarjetas t ON c.id_cliente = t.id_cliente
    JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
    JOIN Pagos p ON cm.id_cuota_manejo = p.id_cuota_manejo
WHERE 
    p.fecha_pago BETWEEN 2025-06-30 AND 25-07-04
GROUP BY 
    c.id_cliente, c.nombre;

-- 43. Cuotas vencidas por cliente

SELECT
    c.nombre,
    COUNT(cm.id_cuota_manejo) AS cuotas_vencidas
FROM
    Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
JOIN Estado_Cuota ec ON cm.id_estado_cuota = ec.id_estado_cuota
WHERE cm.fecha_vencimiento < CURDATE()  AND ec.descripcion = 'Pendiente'
GROUP BY  c.nombre
ORDER BY  cuotas_vencidas DESC;

-- 44. Listar promociones activas entre dos fechas

SELECT 
    id_promocion,
    nombre_promocion,
    descuento_aplicado,
    fecha_inicio,
    fecha_fin
FROM 
    Promociones
WHERE 
    fecha_inicio <= 2025-06-30 AND fecha_fin >= 2025-07-08;

-- 45. Consultar tarjetas con múltiples promociones

SELECT
    t.id_tarjeta,
    c.nombre AS nombre_cliente,
    COUNT(tp.id_promocion) AS cantidad_de_promociones
FROM  Tarjetas_Promociones tp
JOIN Tarjetas t ON tp.id_tarjeta = t.id_tarjeta
JOIN Clientes c ON t.id_cliente = c.id_cliente
GROUP BY t.id_tarjeta, c.nombre
HAVING COUNT(tp.id_promocion) > 1;

-- 46. Resumen de pagos por tipo de tarjeta

SELECT 
    tt.nombre_tipo,
    SUM(p.monto) AS total_pagado,
    COUNT(p.id_pago) AS total_pagos
FROM 
    Tipos_Tarjeta tt
    JOIN Tarjetas t ON tt.id_tipo_tarjeta = t.id_tipo_tarjeta
    JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
    JOIN Pagos p ON cm.id_cuota_manejo = p.id_cuota_manejo
GROUP BY 
    tt.id_tipo_tarjeta, tt.nombre_tipo;

-- 47. Transacciones agrupadas por mes

SELECT
    YEAR(fecha_transaccion) AS anio,
    MONTH(fecha_transaccion) AS mes,
    tipo_transaccion,
    COUNT(id_transaccion) AS cantidad_transacciones,
    SUM(monto) AS monto_total
FROM Transacciones
GROUP BY  anio, mes, tipo_transaccion
ORDER BY anio, mes, tipo_transaccion;

-- 48. Tarjetas por tipo con su promedio de cuota de manejo

SELECT 
    tt.nombre_tipo,
    COUNT(t.id_tarjeta) AS total_tarjetas,
    AVG(cm.monto) AS promedio_cuota
FROM 
    Tipos_Tarjeta tt
    JOIN Tarjetas t ON tt.id_tipo_tarjeta = t.id_tipo_tarjeta
    JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
GROUP BY 
    tt.id_tipo_tarjeta, tt.nombre_tipo;

-- 49. Consultar clientes sin cuotas asociadas

SELECT
    c.id_cliente,
    c.nombre
FROM Clientes c
LEFT JOIN Tarjetas t ON c.id_cliente = t.id_cliente
LEFT JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
WHERE  cm.id_cuota_manejo IS NULL;

-- 50. Cuotas de manejo con estado "pendiente"

SELECT 
    cm.id_cuota_manejo,
    cm.monto,
    cm.fecha_vencimiento,
    c.nombre AS cliente
FROM 
    Cuotas_de_Manejo cm
    JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
    JOIN Clientes c ON t.id_cliente = c.id_cliente
    JOIN Estado_Cuota ec ON cm.id_estado_cuota = ec.id_estado_cuota
WHERE 
    ec.descripcion = 'Pendiente';

-- 51. Cuotas con descuentos superiores al 15%

SELECT
    cm.id_cuota_manejo,
    cm.id_tarjeta,
    c.nombre AS nombre_cliente,
    p.nombre_promocion,
    p.descuento_aplicado
FROM Cuotas_de_Manejo cm
JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
JOIN Clientes c ON t.id_cliente = c.id_cliente
JOIN Tarjetas_Promociones tp ON t.id_tarjeta = tp.id_tarjeta
JOIN Promociones p ON tp.id_promocion = p.id_promocion
WHERE p.descuento_aplicado > 15.00;

-- 52. Clientes con más de dos pagos realizados

SELECT 
    c.id_cliente,
    c.nombre,
    COUNT(p.id_pago) AS total_pagos
FROM 
    Clientes c
    JOIN Tarjetas t ON c.id_cliente = t.id_cliente
    JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
    JOIN Pagos p ON cm.id_cuota_manejo = p.id_cuota_manejo
GROUP BY 
    c.id_cliente, c.nombre
HAVING 
    COUNT(p.id_pago) > 2;

-- 53. Total de transacciones por día

SELECT fecha_transaccion,
    SUM(monto) AS monto_total_diario
FROM Transacciones
GROUP BY fecha_transaccion
ORDER BY fecha_transaccion DESC;

-- 54. Transacciones por tipo (crédito/débito/otro)

SELECT 
    t.tipo_transaccion,
    COUNT(t.id_transaccion) AS total_transacciones,
    SUM(t.monto) AS monto_total
FROM 
    Transacciones t
GROUP BY 
    t.tipo_transaccion;

-- 55. Descuentos agrupados por categoría

SELECT
    nombre_categoria,
    COUNT(id_descuento) AS cantidad_de_descuentos
FROM  Descuentos
GROUP BY nombre_categoria
ORDER BY cantidad_de_descuentos DESC;

-- 56. Tarjetas con apertura superior al promedio

SELECT 
    t.id_tarjeta,
    c.nombre AS cliente,
    tt.nombre_tipo,
    tt.monto_apertura
FROM 
    Tarjetas t
    JOIN Clientes c ON t.id_cliente = c.id_cliente
    JOIN Tipos_Tarjeta tt ON t.id_tipo_tarjeta = tt.id_tipo_tarjeta
WHERE 
    tt.monto_apertura > (SELECT AVG(monto_apertura) FROM Tipos_Tarjeta);

-- 57. Consultar clientes que han usado promociones

SELECT DISTINCT
    c.id_cliente,
    c.nombre
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Tarjetas_Promociones tp ON t.id_tarjeta = tp.id_tarjeta;

-- 58. Cuotas pagadas agrupadas por trimestre

SELECT 
    DATE_FORMAT(p.fecha_pago, '%Y-Q%q') AS trimestre,
    COUNT(p.id_pago) AS cuotas_pagadas,
    SUM(p.monto) AS monto_total
FROM 
    Pagos p
WHERE 
    p.estado = 'Pagado'
GROUP BY 
    DATE_FORMAT(p.fecha_pago, '%Y-Q%q')
ORDER BY 
    trimestre;

-- 59. Total de promociones aplicadas por cliente

SELECT
    c.nombre,
    COUNT(tp.id_tarjeta_promocion) AS total_promociones_aplicadas
FROM Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Tarjetas_Promociones tp ON t.id_tarjeta = tp.id_tarjeta
GROUP BY c.nombre
ORDER BY total_promociones_aplicadas DESC;

-- 60. Consultar tarjetas sin cuota de manejo asociada

SELECT 
    t.id_tarjeta,
    c.nombre AS cliente,
    tt.nombre_tipo AS tipo_tarjeta
FROM 
    Tarjetas t
    JOIN Clientes c ON t.id_cliente = c.id_cliente
    JOIN Tipos_Tarjeta tt ON t.id_tipo_tarjeta = tt.id_tipo_tarjeta
    LEFT JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
WHERE 
    cm.id_cuota_manejo IS NULL;
    
-- 61. Tarjetas que no han sido usadas para transacciones

SELECT
    t.id_tarjeta,
    c.nombre AS nombre_cliente
FROM Tarjetas t
LEFT JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
LEFT JOIN Pagos p ON cm.id_cuota_manejo = p.id_cuota_manejo
LEFT JOIN Transacciones tr ON p.id_pago = tr.id_pago
JOIN Clientes c ON t.id_cliente = c.id_cliente
WHERE  tr.id_transaccion IS NULL;

-- 62. Cuotas de manejo mayores al promedio

-- 63. Cuotas agrupadas por estado (aceptada, rechazada, etc.)

SELECT
    ec.descripcion,
    COUNT(cm.id_cuota_manejo) AS cantidad_de_cuotas
FROM Cuotas_de_Manejo cm
JOIN Estado_Cuota ec ON cm.id_estado_cuota = ec.id_estado_cuota
GROUP BY ec.descripcion
ORDER BY cantidad_de_cuotas DESC;

-- 64. Consultar pagos y promociones por cliente

-- 65. Consultar promociones que vencen este mes
SELECT
    id_promocion,
    nombre_promocion,
    fecha_fin
FROM  Promociones
WHEREYEAR(fecha_fin) = YEAR(CURDATE()) AND MONTH(fecha_fin) = MONTH(CURDATE());
-- 66. Clientes con múltiples descuentos aplicados

-- 67. Tarjetas que aplican para promociones exclusivas

SELECT DISTINCT
    t.id_tarjeta,
    c.nombre AS nombre_cliente,
    tt.nombre_tipo
FROM Tarjetas t
JOIN Tipos_Tarjeta tt ON t.id_tipo_tarjeta = tt.id_tipo_tarjeta
JOIN Tarjetas_Promociones tp ON t.id_tarjeta = tp.id_tarjeta
JOIN Clientes c ON t.id_cliente = c.id_cliente
WHERE tt.nombre_tipo IN ('Black', 'Premium', 'Platina');

-- 68. Consultar transacciones superiores a $500.000

-- 69. Clientes nuevos registrados en el último trimestre

SELECT
    c.id_cliente,
    c.nombre,
    MIN(cc.fecha_actualizacion) AS fecha_registro
FROM Clientes c
JOIN  Contactos_Clientes cc ON c.id_cliente = cc.id_cliente
GROUP BY c.id_cliente, c.nombre
HAVING fecha_registro >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH);

-- 70. Consultar tarjetas activas con más de 5 cuotas pagadas

-- 71. Clientes con pagos pendientes en los últimos tres meses

SELECT DISTINCT
    c.id_cliente,
    c.nombre
FROM
    Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
JOIN Estado_Cuota ec ON cm.id_estado_cuota = ec.id_estado_cuota
WHERE ec.descripcion = 'Pendiente' AND cm.fecha_vencimiento >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH);

-- 72. Cuotas aplicadas a cada tipo de tarjeta en un período específico

-- 73. Reporte de descuentos aplicados durante un año

SELECT
    YEAR(fecha_aplicacion) AS anio,
    MONTH(fecha_aplicacion) AS mes,
    COUNT(*) AS promociones_aplicadas
FROM Tarjetas_Promociones
WHERE YEAR(fecha_aplicacion) = :anio
GROUP BY anio, mes
ORDER BY mes;

-- 74. Tarjetas con el mayor y menor monto de apertura

-- 75. Total de pagos realizados por tipo de tarjeta
SELECT
    tt.nombre_tipo,
    SUM(p.monto) AS total_pagado
FROM
    Pagos p
JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
JOIN Tipos_Tarjeta tt ON t.id_tipo_tarjeta = tt.id_tipo_tarjeta
WHERE p.estado = 'Completado'
GROUP BY tt.nombre_tipo
ORDER BY total_pagado DESC;

-- 76. Top 5 clientes con más pagos realizados

-- 77. Total de promociones utilizadas por mes
SELECT
    YEAR(fecha_aplicacion) AS anio,
    MONTH(fecha_aplicacion) AS mes,
    COUNT(id_tarjeta_promocion) AS total_promociones
FROM Tarjetas_Promociones
GROUP BY anio, mes
ORDER BY anio, mes;

-- 78. Clientes que nunca han aplicado promociones

-- 79. Clientes que han pagado puntualmente todas sus cuotas
SELECT
    c.id_cliente,
    c.nombre
FROM  Clientes c
WHERE
    c.id_cliente NOT IN (
        SELECT DISTINCT t.id_cliente
        FROM Cuotas_de_Manejo cm
        JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
        JOIN Estado_Cuota ec ON cm.id_estado_cuota = ec.id_estado_cuota
        WHERE cm.fecha_vencimiento < CURDATE() AND ec.descripcion = 'Pendiente'
    );

-- 80. Tarjetas con más movimientos de transacciones

-- 81. Promedios de pagos por cliente

SELECT
    c.nombre,
    AVG(p.monto) AS promedio_de_pago
FROM
    Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
JOIN Pagos p ON cm.id_cuota_manejo = p.id_cuota_manejo
WHERE p.estado = 'Completado'
GROUP BY c.nombre
ORDER BY promedio_de_pago DESC;

-- 82. Clientes que han tenido cuotas rechazadas

-- 83. Análisis de pagos por método (efectivo, tarjeta, etc.)

SELECT
    mp.descripcion AS metodo_pago,
    COUNT(p.id_pago) AS cantidad_pagos,
    SUM(p.monto) AS suma_total,
    AVG(p.monto) AS promedio_pago,
    MIN(p.monto) AS pago_minimo,
    MAX(p.monto) AS pago_maximo
FROM Pagos p
JOIN Metodos_Pago mp ON p.id_metodo = mp.id_metodo
GROUP BY mp.descripcion
ORDER BY suma_total DESC;

-- 84. Cuotas más costosas del sistema

-- 85. Clientes con mayor gasto mensual promedio

WITH GastoMensual AS (
    SELECT
        t.id_cliente,
        YEAR(p.fecha_pago) AS anio,
        MONTH(p.fecha_pago) AS mes,
        SUM(p.monto) AS gasto_total_mes
    FROM Pagos p
    JOIN Cuotas_de_Manejo cm ON p.id_cuota_manejo = cm.id_cuota_manejo
    JOIN Tarjetas t ON cm.id_tarjeta = t.id_tarjeta
    WHERE p.estado = 'Completado'
    GROUP BY t.id_cliente, anio, mes
)
SELECT
    c.nombre,
    AVG(gm.gasto_total_mes) AS gasto_mensual_promedio
FROM GastoMensual gm
JOIN Clientes c ON gm.id_cliente = c.id_cliente
GROUP BY c.nombre
ORDER BY gasto_mensual_promedio DESC;

-- 86. Promociones con duración mayor a 30 días

-- 87. Comparación de uso entre tipos de tarjeta

SELECT
    tt.nombre_tipo,
    COUNT(p.id_pago) AS numero_de_usos
FROM
    Tipos_Tarjeta tt
JOIN Tarjetas t ON tt.id_tipo_tarjeta = t.id_tipo_tarjeta
JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
JOIN Pagos p ON cm.id_cuota_manejo = p.id_cuota_manejo
GROUP BY
    tt.nombre_tipo
ORDER BY
    numero_de_usos DESC;

-- 88. Ranking de promociones más utilizadas

-- 89. Clientes con más transacciones en el año

SELECT
    c.nombre,
    COUNT(tr.id_transaccion) AS cantidad_transacciones
FROM
    Clientes c
JOIN Tarjetas t ON c.id_cliente = t.id_cliente
JOIN Cuotas_de_Manejo cm ON t.id_tarjeta = cm.id_tarjeta
JOIN Pagos p ON cm.id_cuota_manejo = p.id_cuota_manejo
JOIN Transacciones tr ON p.id_pago = tr.id_pago
WHERE
    YEAR(tr.fecha_transaccion) = YEAR(CURDATE())
GROUP BY
    c.nombre
ORDER BY
    cantidad_transacciones DESC
LIMIT 10;

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
