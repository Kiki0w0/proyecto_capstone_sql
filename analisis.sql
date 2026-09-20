-- TOP 5 CLIENTES POR GASTO TOTAL --

-- En la tabla pedidos el dato que indica cuánto gastó el cliente es final_price.
-- Entonces hay que sumar final_price agrupando por cliente y pididendo que muestre
-- los 5 clientes que mas gastaron en orden descendente:
SELECT
    c.user_id,
    SUM(p.final_price) AS gasto_total
FROM clientes c
JOIN pedidos p
    ON c.user_id = p.user_id
GROUP BY c.user_id
ORDER BY gasto_total DESC
LIMIT 5;




-- VENTAS TOTALES POR MES--

-- Agrupo todas las compras según el mes de purchase_date y sumo final_price ordenando cronologimante
-- (de la fecha más antigua a la más reciente):
SELECT
    DATE_TRUNC('month', purchase_date) AS mes,
    SUM(final_price) AS ventas_totales
FROM pedidos
GROUP BY DATE_TRUNC('month', purchase_date)
ORDER BY mes;




-- 3 PRODUCTOS MENOS VENDIDOS --

-- Cuento cuántas veces aparece cada product_id y muestro los 3 con menor frecuencia:

SELECT
    product_id,
    COUNT(*) AS cantidad_vendida
FROM pedidos
GROUP BY product_id
ORDER BY cantidad_vendida ASC, product_id
LIMIT 3;




-- RANKIG DE PEDIDOS POR CATEGORÍA --

-- Interpreto que la consigna pide un ranking de los productos más vendidos por categoría.

-- Aclaración: Mientras limpiaba los datos me dí cuenta que un mismo product_id puede estar 
-- asociado a distintas categorías. Por eso mismo la interpretación del ranking por categoría
-- es limitado. La consulta se incluyea para cumplir con la consigna de utilizar una función avanzada.

-- Ordeno los pedidos dentro de cada categoría según su importe final. Debido a lo comentado en la aclaración
-- el ranking se limita a las operaciones registradas.

SELECT
    p.order_id,
    c.category,
    p.final_price,
    RANK() OVER (
        PARTITION BY c.category
        ORDER BY p.final_price DESC
    ) AS ranking
FROM pedidos p
JOIN categorias c
    ON p.category_id = c.category_id;
