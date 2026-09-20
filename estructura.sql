-- La base de datos capstone_project se creó previamente desde PostgreSQL.
-- CREATE DATABASE capstone_project;

-- Paso la tabla csv a dbeaver con los datos originales como varchar:

CREATE TABLE datos_originales (
    user_id VARCHAR(100),
    product_id VARCHAR(100),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    brand VARCHAR(100),
    price VARCHAR(100),
    discount VARCHAR(50),
    final_price VARCHAR(30),
    rating VARCHAR(30),
    review_count VARCHAR(50),
    stock VARCHAR(100),
    seller_id VARCHAR(100),
    seller_rating VARCHAR(50),
    purchase_date VARCHAR(50),
    shipping_time_days VARCHAR(50),
    location VARCHAR(100),
    device VARCHAR(50),
    payment_method VARCHAR(100),
    is_returned VARCHAR(50),
    delivery_status VARCHAR(50)
);

SELECT *
FROM datos_originales
LIMIT 10;

SELECT COUNT(*)
FROM datos_originales;


--------------------------------
-- Limpieza de datos:
--------------------------------

-- Inndico qué tipo de dato se guarda en cada columna.
-- Ejecuto create table para saber si tiene datos nulos o vacíos:

CREATE TABLE datos_limpios (
    user_id VARCHAR,
    product_id VARCHAR,
    category VARCHAR,
    subcategory VARCHAR,
    brand VARCHAR,
    price NUMERIC(10,2),
    discount NUMERIC(5,2),
    final_price NUMERIC(10,2),
    rating NUMERIC(2,1),
    review_count INTEGER,
    stock INTEGER,
    seller_id VARCHAR,
    seller_rating NUMERIC(2,1),
    purchase_date DATE,
    shipping_time_days INTEGER,
    location VARCHAR,
    device VARCHAR,
    payment_method VARCHAR,
    is_returned BOOLEAN,
    delivery_status VARCHAR
);


-- Compruebo si hay valores nulos. Si hay, uso COALESCE:

SELECT
    COUNT(*) AS total_filas,
    COUNT(user_id) AS user_id,
    COUNT(product_id) AS product_id,
    COUNT(category) AS category,
    COUNT(subcategory) AS subcategory,
    COUNT(brand) AS brand,
    COUNT(price) AS price,
    COUNT(discount) AS discount,
    COUNT(final_price) AS final_price,
    COUNT(rating) AS rating,
    COUNT(review_count) AS review_count,
    COUNT(stock) AS stock,
    COUNT(seller_id) AS seller_id,
    COUNT(seller_rating) AS seller_rating,
    COUNT(purchase_date) AS purchase_date,
    COUNT(shipping_time_days) AS shipping_time_days,
    COUNT(location) AS location,
    COUNT(device) AS device,
    COUNT(payment_method) AS payment_method,
    COUNT(is_returned) AS is_returned,
    COUNT(delivery_status) AS delivery_status
FROM datos_originales;
-- en todas las columnas figura 1.000.000, entonces no hay datos nulos.


-- Paso los datos desde la tabla original:

INSERT INTO datos_limpios
SELECT
    user_id,
    product_id,
    category,
    subcategory,
    brand,
    price::NUMERIC(10,2),
    discount::NUMERIC(5,2),
    final_price::NUMERIC(10,2),
    rating::NUMERIC(2,1),
    review_count::INTEGER,
    stock::INTEGER,
    seller_id,
    seller_rating::NUMERIC(2,1),
    purchase_date::DATE,
    shipping_time_days::INTEGER,
    location,
    device,
    payment_method,
    is_returned::BOOLEAN,
    delivery_status
FROM datos_originales;


-- Veo si pasaron todos los datos:

SELECT COUNT(*)
FROM datos_limpios;
-- Aparece 1000000, o sea que se pasaron bien todas las filas.

-- Me fijo si se produjo correctamente la conversión de tipo de datos:

SELECT *
FROM datos_limpios
LIMIT 10;

SELECT
    MIN(purchase_date) AS fecha_minima,
    MAX(purchase_date) AS fecha_maxima,
    MIN(price) AS precio_minimo,
    MAX(price) AS precio_maximo,
    MIN(rating) AS rating_minimo,
    MAX(rating) AS rating_maximo
FROM datos_limpios;
-- Se convirtieron correctamente.

-- Reviso si hay ids duplicadas:

-- Para usuarios:
SELECT COUNT(DISTINCT user_id) AS usuarios
FROM datos_limpios;
-- Devuelve 603.815 usuarios.

-- Para productos:
SELECT COUNT(DISTINCT product_id) AS productos
FROM datos_limpios;
-- Devuelve 89.999 productos.

-- Para vendedores:
SELECT COUNT(DISTINCT seller_id) AS vendedores
FROM datos_limpios;
-- Devuelve 9000 vendedores.


-- Corroboro que cada usuario tenga una única locación/location:

SELECT user_id, COUNT(DISTINCT location) AS cantidad_locations
FROM datos_limpios
GROUP BY user_id
HAVING COUNT(DISTINCT location) > 1
LIMIT 10;
-- Hay user_ids que aparecen asociados con mas de una locación/location.
-- Por esta razón, location no se considera un atributo fijo de clientes
-- Se mantiene en pedidos, ya que puede variar entre distintas operaciones.

-- Averiguo si un mismo product_id está asociado a distintas categorías o subacategorías:

SELECT product_id,
       COUNT(DISTINCT category) AS cantidad_categorias,
       COUNT(DISTINCT subcategory) AS cantidad_subcategorias
FROM datos_limpios
GROUP BY product_id
HAVING COUNT(DISTINCT category) > 1
    OR COUNT(DISTINCT subcategory) > 1
LIMIT 10;
-- A través de la tabla puedo ver que efectivamente hay product_ids asociados a más de una categoría y más de una subcategoría.

-- Averiguo si cada subcategoría pertenece a una categoría:

SELECT
    subcategory,
    COUNT(DISTINCT category) AS cantidad_categorias
FROM datos_limpios
GROUP BY subcategory
HAVING COUNT(DISTINCT category) > 1
LIMIT 10;
-- No devuelve filas, entonces cada subcategoría pertenece a una única categoría.

-- Averiguo si un seller_id tiene varios seller_rating:

SELECT seller_id,
       COUNT(DISTINCT seller_rating) AS cantidad_ratings
FROM datos_limpios
GROUP BY seller_id
HAVING COUNT(DISTINCT seller_rating) > 1
LIMIT 10;

-- Hay mas de un vendedor con más de un seller_rating, por eso la columna seller_rating no va a formar parte de la tabla vendedores (así
-- evito la multidependencia).

-- Corroboro que product_id no tenga mas de un brand:

SELECT
    product_id,
    COUNT(DISTINCT brand) AS cantidad_brands
FROM datos_limpios
GROUP BY product_id
HAVING COUNT(DISTINCT brand) > 1
LIMIT 10;
-- En la tabla se vé que hay product_ids asociadas a mas de una brand.
-- La columna brand conviene que esté en la tabla pedidos y no en la tabla productos para evitar la multidependencia.

-- Veo si un mismo producto tiene siempre el mismo precio o no:

SELECT
    product_id,
    COUNT(DISTINCT price) AS cantidad_precios
FROM datos_limpios
GROUP BY product_id
HAVING COUNT(DISTINCT price) > 1
LIMIT 10;
-- Hay varios product_id con mas de un price asociado, entonces price no puede ser un atributo fijo de product_id.

---------------------------------
-- Creación de tablas:
---------------------------------

-- Busco todas las distintas categorías que tiene el dataset para crear la tabla Categorias creandole PK:

SELECT DISTINCT category
FROM datos_limpios
ORDER BY category;

-- Creo la tabla creandole una PK a cada categoría:

CREATE TABLE categorias (
    category_id INTEGER PRIMARY KEY,
    category VARCHAR NOT NULL
);

-- Inserto las PK y los correspondientes nombres de las categorías:

INSERT INTO categorias (category_id, category)
VALUES
    (1, 'Beauty'),
    (2, 'Clothing'),
    (3, 'Electronics'),
    (4, 'Home'),
    (5, 'Sports');

-- Visualizo la tabla:

SELECT * FROM categorias;

-- Veo qué subacategorías aparecen y a qué categoría corresponden:

SELECT DISTINCT
    subcategory,
    category
FROM datos_limpios
ORDER BY category, subcategory;

-- Ahora creo la tabla subategorias:

CREATE TABLE subcategorias (
    subcategory_id INTEGER PRIMARY KEY,
    subcategory VARCHAR NOT NULL,
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categorias(category_id)
);

-- Ingreso las subcategoías que ví y les creo una PK a cada una: 
INSERT INTO subcategorias (subcategory_id, subcategory, category_id)
VALUES
    (1, 'Haircare', 1),
    (2, 'Makeup', 1),
    (3, 'Skincare', 1),
    (4, 'Kids', 2),
    (5, 'Men', 2),
    (6, 'Women', 2),
    (7, 'Camera', 3),
    (8, 'Headphones', 3),
    (9, 'Laptop', 3),
    (10, 'Mobile', 3),
    (11, 'Decor', 4),
    (12, 'Furniture', 4),
    (13, 'Kitchen', 4),
    (14, 'Cycling', 5),
    (15, 'Fitness', 5),
    (16, 'Outdoor', 5);

SELECT * FROM subcategorias;

-- Creo la tabla clientes:

CREATE TABLE clientes (
    user_id VARCHAR PRIMARY KEY
);

-- Cargo la tabla con los usuarios sin repetir:

INSERT INTO clientes (user_id)
SELECT DISTINCT user_id
FROM datos_limpios;

-- La cantidad de clientes:  

SELECT COUNT(*)
FROM clientes;
-- coincide con la que me mostró para saber si no hay duplicados.

-- Creo la tabla vendedores:

CREATE TABLE vendedores (
    seller_id VARCHAR PRIMARY KEY
);

-- Inserto en la tabla los vendedores que no se repiten:

INSERT INTO vendedores (seller_id)
SELECT DISTINCT seller_id
FROM datos_limpios;

-- Veo cuántos vendedores hay:

SELECT COUNT(*)
FROM vendedores;
-- Hay 9000 como ví anteriormente.

--Me fijo si todas las sub-categorias de datos limpios están en la tabla sub-categorias para poder obtener correctamente el 
-- subcategory_id:

SELECT COUNT(*)
FROM datos_limpios d
LEFT JOIN subcategorias s
    ON d.subcategory = s.subcategory
WHERE s.subcategory_id IS NULL;
-- Devolvió 0, entonces están.

-- Hago lo mismo con la tabla categorías:

SELECT COUNT(*)
FROM datos_limpios d
LEFT JOIN categorias c
    ON d.category = c.category
WHERE c.category_id IS NULL;
-- Devolvió 0

-- Creo la tabla pedidos:

CREATE TABLE pedidos (
    order_id INTEGER PRIMARY KEY,
    user_id VARCHAR NOT NULL,
    product_id VARCHAR NOT NULL,
    seller_id VARCHAR NOT NULL,
    category_id INTEGER NOT NULL,
    subcategory_id INTEGER NOT NULL,
    brand VARCHAR,
    price NUMERIC(10,2),
    discount NUMERIC(5,2),
    final_price NUMERIC(10,2),
    rating NUMERIC(2,1),
    review_count INTEGER,
    stock INTEGER,
    seller_rating NUMERIC(2,1),
    purchase_date DATE,
    shipping_time_days INTEGER,
    location VARCHAR,
    device VARCHAR,
    payment_method VARCHAR,
    is_returned BOOLEAN,
    delivery_status VARCHAR,

    FOREIGN KEY (user_id) REFERENCES clientes(user_id),
    FOREIGN KEY (seller_id) REFERENCES vendedores(seller_id),
    FOREIGN KEY (category_id) REFERENCES categorias(category_id),
    FOREIGN KEY (subcategory_id) REFERENCES subcategorias(subcategory_id)
);

-- Inserto los datos:

INSERT INTO pedidos (
    order_id,
    user_id,
    product_id,
    seller_id,
    category_id,
    subcategory_id,
    brand,
    price,
    discount,
    final_price,
    rating,
    review_count,
    stock,
    seller_rating,
    purchase_date,
    shipping_time_days,
    location,
    device,
    payment_method,
    is_returned,
    delivery_status
)
SELECT
    ROW_NUMBER() OVER () AS order_id,
    d.user_id,
    d.product_id,
    d.seller_id,
    s.category_id,
    s.subcategory_id,
    d.brand,
    d.price,
    d.discount,
    d.final_price,
    d.rating,
    d.review_count,
    d.stock,
    d.seller_rating,
    d.purchase_date,
    d.shipping_time_days,
    d.location,
    d.device,
    d.payment_method,
    d.is_returned,
    d.delivery_status
FROM datos_limpios d
JOIN subcategorias s
    ON d.subcategory = s.subcategory;

-- Veo si se cargaron bien todos los registros de pedidos:

SELECT COUNT(*)
FROM pedidos;
-- Se cargaron los 1.000.000.

-- Averiguo si los category_id y los sub_category_id en pedidos quedaron bien relacionados:

SELECT COUNT(*)
FROM pedidos p
JOIN subcategorias s
    ON p.subcategory_id = s.subcategory_id
WHERE p.category_id <> s.category_id;
-- Devolvió 0, entonces está bien.

-- Averiguo si no hay algún pedido sin un cliente:

SELECT COUNT(*)
FROM pedidos p
LEFT JOIN clientes c
    ON p.user_id = c.user_id
WHERE c.user_id IS NULL;
-- Devolvió 0, está bien.

-- Hago lo mismo con vendedores:

SELECT COUNT(*)
FROM pedidos p
LEFT JOIN vendedores v
    ON p.seller_id = v.seller_id
WHERE v.seller_id IS NULL;
-- Dió 0, está bien.

-- Verifico que no haya valores NULL contando solo los valores no NULL:

SELECT
    COUNT(*) AS total,
    COUNT(order_id) AS order_id,
    COUNT(user_id) AS user_id,
    COUNT(product_id) AS product_id,
    COUNT(seller_id) AS seller_id,
    COUNT(category_id) AS category_id,
    COUNT(subcategory_id) AS subcategory_id,
    COUNT(price) AS price,
    COUNT(final_price) AS final_price,
    COUNT(purchase_date) AS purchase_date
FROM pedidos;
-- Todas las columnas tienen 1.000.000, entonces no hay valores NULL.
