USE transactions;

# Muestra las principales características del esquema creado y explica las diferentes tablas y variables que existen. 
# Asegúrate de incluir un diagrama que ilustre la relación entre las distintas tablas y variables.

SHOW CREATE TABLE transaction;
SHOW CREATE TABLE company;
DESCRIBE transaction;

# Listado de los países que están generando ventas

SELECT DISTINCT c.country
FROM company c 
JOIN transaction t 
ON c.id = t.company_id
WHERE t.declined = 0
ORDER BY c.country;

# Desde cuántos países se generan las ventas

SELECT COUNT(DISTINCT c.country) AS country_nr
FROM company c 
JOIN transaction t 
ON c.id = t.company_id
WHERE t.declined = 0;

# Identifica a la compañía con la mayor media de ventas

SELECT c.company_name, ROUND(AVG(t.amount), 2) AS average_sales
FROM company c 
JOIN transaction t 
ON c.id = t.company_id
GROUP BY c.company_name
ORDER BY average_sales DESC
LIMIT 1;

# Utilizando sólo subconsultas (sin utilizar JOIN):
# Muestra todas las transacciones realizadas por empresas de Alemania.

SELECT * FROM transaction 
WHERE company_id IN (
	SELECT id FROM company
    WHERE country = 'Germany');
    
# Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.

SELECT DISTINCT company_name
FROM company
WHERE id IN (
	SELECT company_id
	FROM transaction 
	WHERE amount > (
		SELECT AVG(amount) AS average_transaction
		FROM transaction))
ORDER BY company_name;
        
# Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.

SELECT c.id, t.id
FROM company c
LEFT JOIN transaction t 
ON c.id = t.company_id
WHERE t.id IS NULL
AND t.declined = 0;

# Ejercicio 1  
# Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. 
# Muestra la fecha de cada transacción junto con el total de las ventas.

SELECT DATE(t.timestamp) AS date, SUM(t.amount) AS tot_sales
FROM transaction t 
WHERE declined = 0
GROUP BY date
ORDER BY tot_sales DESC
LIMIT 5;


# Ejercicio 2
# ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio.

SELECT c.country, ROUND(AVG(t.amount), 2) AS average_sales
FROM company c
JOIN transaction t 
ON c.id = t.company_id
WHERE declined = 0
GROUP BY c.country
ORDER BY average_sales DESC;

# Ejercicio 3
# En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía “Non Institute”. 
# Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.
# Muestra el listado aplicando JOIN y subconsultas.
# Muestra el listado aplicando solo subconsultas.

SELECT t.id, t.amount, c.id, c.company_name, c.country   # con JOIN y subconsulta
FROM transaction t 
JOIN company c 
ON t.company_id = c.id
WHERE c.country = (
	SELECT country 
	FROM company c 
	WHERE c.company_name = 'Non Institute');
    

SELECT t.id, t.company_id, t.amount       # solo con subconsultas
FROM transaction t 
WHERE t.company_id IN (
	SELECT c.id
	FROM company c 
	WHERE c.country = (
		SELECT country 
		FROM company c 
		WHERE c.company_name = 'Non Institute'));  
        
# Ejercicio 1 Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones 
# con un valor comprendido entre 350 y 400 euros y en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. 
# Ordena los resultados de mayor a menor cantidad.


SELECT c.company_name, c.phone, c.country, t.timestamp, t.amount
FROM company c 
JOIN transaction t 
ON c.id = t.company_id
WHERE t.amount BETWEEN 350 AND 400
AND (t.timestamp LIKE '2015-04-29%' OR t.timestamp LIKE '2018-07-20%' OR t.timestamp LIKE '2024-03-13%')
ORDER BY t.amount DESC; 

# Ejercicio 2
# Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo que te piden 
# la información sobre la cantidad de transacciones que realizan las empresas, pero el departamento de recursos humanos es exigente 
# y quiere un listado de las empresas en las que especifiques si tienen más de 400 transacciones o menos.


SELECT 
    t.company_id, c.company_name, COUNT(t.id) AS transactions_nr,
    CASE 
        WHEN COUNT(t.id) >= 400 THEN '400 transactions or more'
        ELSE 'Less than 400 transactions'
    END AS quantity_text
FROM transaction t 
JOIN company c 
ON c.id = t.company_id
GROUP BY t.company_id, c.company_name
ORDER BY transactions_nr DESC;





    
    
    
