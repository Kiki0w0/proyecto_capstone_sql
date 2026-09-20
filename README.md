## Problema de negocio

El objetivo de este proyecto es analizar los datos de un comercio electrónico para
obtener información sobre sus ventas y operaciones.

El análisis busca identificar cuáles son los clientes que realizan un mayor gasto,
observar cómo evolucionan las ventas a lo largo del tiempo y analizar las
operaciones realizadas dentro de las distintas categorías.

Esta información permite obtener una visión general del comportamiento de las
ventas y de los clientes a partir de los datos disponibles.


## Hallazgos

### Clientes con mayor gasto

Se identificaron los cinco clientes con mayor gasto total:

- U434268: $229.853,10
- U902761: $207.234,79
- U454661: $199.875,10
- U384705: $195.983,73
- U706383: $195.247,80

El cliente con mayor gasto total fue U434268, con $229.853,10.

### Ventas por mes

Se analizaron las ventas totales agrupadas por mes, utilizando la fecha de
compra y el importe final de cada operación.

El período analizado abarca desde marzo de 2024 hasta marzo de 2026. Marzo de
2024 presenta un período parcial, ya que el primer registro disponible
corresponde al 31/03/2024.

El mayor importe mensual registrado fue en diciembre de 2025, con
$428.142.327,81.

### Ranking de operaciones por categoría

Se utilizó la función de ventana `RANK()` para ordenar las operaciones dentro
de cada categoría según su importe final, de mayor a menor.

Durante la limpieza de los datos se detectó que un mismo `product_id` puede
estar asociado a distintas categorías. Por este motivo, los resultados deben
interpretarse teniendo en cuenta esta inconsistencia del dataset.


## Cómo ejecutar el proyecto

El proyecto utiliza PostgreSQL 17.10 y puede ejecutarse mediante DBeaver u otro cliente
compatible.

### Requisitos

- PostgreSQL 17.10.
- DBeave 26.1.1.202606211757 (opcional, para ejecutar las consultas y administrar la base de datos).
- Archivo CSV original del dataset. Se encuentra en https://www.kaggle.com/datasets/sharmajicoder/amazon-e-commerce/data

### Pasos

1. Crear la base de datos `capstone_project` en PostgreSQL y conectarse a ella.
2. Crear la tabla `datos_originales` ejecutando la sección correspondiente de
   `estructura.sql` e importar el archivo CSV mediante DBeaver.
3. Ejecutar el resto de `estructura.sql` para limpiar los datos, crear las tablas
   del modelo y cargar los datos.
4. Ejecutar `analisis.sql` para realizar las consultas de análisis.

### Archivos del proyecto

- `estructura.sql`: contiene la creación de las tablas, la limpieza y la carga
  de los datos.
- `analisis.sql`: contiene las consultas utilizadas para el análisis.
- `README.md`: contiene la documentación del proyecto.
