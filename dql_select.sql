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

-- 6. Promociones activas durante una fecha específica

-- 7. Métodos de pago utilizados por un cliente

-- 8. Consultar todas las transacciones realizadas por tarjeta

-- 9. Tarjetas que tienen promociones aplicadas

-- 10. Clientes que han utilizado más de un tipo de tarjeta

-- 11. Cuotas de manejo vencidas hasta la fecha

-- 12. Transacciones registradas durante la última semana

-- 13. Listar los clientes con más de una tarjeta activa

-- 14. Promociones aplicadas a una tarjeta específica

-- 15. Pagos realizados en una fecha determinada

-- 16. Consultar tarjetas sin promociones asignadas

-- 17. Consultar métodos de pago disponibles actualmente

-- 18. Tarjetas con cuota de manejo superior a cierto valor

-- 19. Cuotas de manejo con vencimiento próximo (menos de 7 días)

-- 20. Tarjetas creadas en el último mes

-- 21. Clientes que no han realizado pagos en el último mes

-- 22. Promociones con más de 20% de descuento

-- 23. Listado de tarjetas por tipo

-- 24. Cuotas de manejo agrupadas por cliente

-- 25. Promociones activas por mes

-- 26. Métodos de pago más usados

-- 27. Consultar todos los pagos con tarjeta de crédito

-- 28. Clientes que tienen descuentos activos

-- 29. Cuotas de manejo agrupadas por año

-- 30. Historial de promociones aplicadas a una tarjeta

-- 31. Total de pagos recibidos por mes en el año actual

-- 32. Consultar el monto promedio de las cuotas de manejo

-- 33. Porcentaje de tarjetas con promociones activas

-- 34. Número total de tarjetas por cliente

-- 35. Total de transacciones realizadas este año

-- 36. Cantidad de cuotas emitidas por mes

-- 37. Evolución de pagos mensuales durante el año

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
