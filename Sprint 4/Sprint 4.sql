# Nivel 1
# Descarga los archivos CSV, estudiales y diseña una base de datos con un esquema de estrella que contenga, 
# al menos 4 tablas de las que puedas realizar las siguientes consultas:

CREATE DATABASE IF NOT EXISTS world_transactions;
USE world_transactions;

CREATE TABLE transactions (
id VARCHAR(150) PRIMARY KEY,
card_id VARCHAR(100),
business_id VARCHAR(100),
timestamp DATETIME,
amount DECIMAL(10,2),
declined TINYINT,
product_ids VARCHAR(250),
user_id INT,
lat DECIMAL(30,15),
longitude DECIMAL(30,15)
);

LOAD DATA INFILE 'C:\\mysql-uploads\\transactions.csv' 
INTO TABLE transactions
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE users (
id INT PRIMARY KEY,
name VARCHAR(100),
surname VARCHAR(100),
phone VARCHAR(100),
email VARCHAR(150),
birth_date VARCHAR(50),
country VARCHAR(150),
city VARCHAR(150),
postal_code VARCHAR(50),
address VARCHAR(150));

LOAD DATA INFILE 'C:\\mysql-uploads\\american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

LOAD DATA INFILE 'C:\\mysql-uploads\\european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, name, surname, phone, email, birth_date, country, city, postal_code, address);

CREATE TABLE credit_cards (
id VARCHAR(100) PRIMARY KEY,
user_id INT,
iban VARCHAR(100),
pan VARCHAR(100),
pin CHAR(4),
cvv CHAR(4),
track1 VARCHAR(255),
track2 VARCHAR(255),
expiring_date VARCHAR(50)
);

LOAD DATA INFILE 'C:\\mysql-uploads\\credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE companies (
company_id VARCHAR(100) PRIMARY KEY,
company_name VARCHAR(255),
phone VARCHAR(100),
email VARCHAR(150),
country VARCHAR(150),
website VARCHAR(250));

LOAD DATA INFILE 'C:\\mysql-uploads\\companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

ALTER TABLE transactions
ADD CONSTRAINT FK_cards_transactions
FOREIGN KEY (card_id) REFERENCES credit_cards(id);

ALTER TABLE transactions
ADD CONSTRAINT FK_users_transactions
FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE transactions
ADD CONSTRAINT FK_companies_transactions
FOREIGN KEY (business_id) REFERENCES companies(company_id);

# Ejercicio 1
# Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.

SELECT u.id, u.name, u.surname			# no pide confirmadas/declinadas
FROM users u 
WHERE u.id IN (
	SELECT t.user_id
	FROM transactions t
	GROUP BY t.user_id
	HAVING COUNT(t.id) > 80);
    
# Ejercicio 2
# Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas.

SELECT cc.iban, ROUND(AVG(t.amount), 2) AS average_amount     #JOIN sin subconsultas màs agil, duration 0.031 sec
FROM transactions t 
JOIN credit_cards cc 
ON t.card_id = cc.id
JOIN companies c 
ON t.business_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban
ORDER BY cc.iban;

SELECT cc.iban, ROUND(AVG(t.amount), 2) AS average_amount   # con subconsulta, màs lento 0.344 sec
FROM transactions t 
JOIN credit_cards cc 
ON t.card_id = cc.id
WHERE t.business_id IN (
		SELECT c.company_id
        FROM companies c 
        WHERE c.company_name = 'Donec Ltd')
GROUP BY cc.iban
ORDER BY cc.iban;

# Nivel 2
# Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las tres últimas transacciones
# han sido declinadas entonces es inactivo, si al menos una no es rechazada entonces es activo . 

SET SQL_SAFE_UPDATES = 0;

UPDATE credit_cards
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');

ALTER TABLE credit_cards
MODIFY expiring_date DATETIME;

UPDATE users
SET birth_date = STR_TO_DATE(birth_date, '%b %d, %Y');

ALTER TABLE users
MODIFY birth_date DATETIME;

SET SQL_SAFE_UPDATES = 1;

ALTER TABLE transactions
RENAME COLUMN timestamp to date_time;

CREATE TABLE IF NOT EXISTS credit_card_status (
id INT AUTO_INCREMENT PRIMARY KEY,
credit_card_id VARCHAR(100),
card_status ENUM('active', 'inactive'));

ALTER TABLE credit_card_status
ADD CONSTRAINT FK_status_card
FOREIGN KEY (credit_card_id) REFERENCES credit_cards(id);

INSERT INTO credit_card_status(credit_card_id, card_status)
SELECT card_id,
	   CASE 
         WHEN SUM(declined) = 3 THEN 'inactive'
         ELSE 'active'
	   END AS card_status
FROM (
	SELECT card_id, 
	   date_time,
       declined,
       ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY date_time DESC ) AS rn
	FROM transactions) AS ranking
WHERE rn <= 3
GROUP BY card_id;

# Partiendo de esta tabla responde:   
# Ejercicio 1   ¿Cuántas tarjetas están activas?

SELECT COUNT(*) AS active_cards
FROM credit_card_status
WHERE card_status = 'active';

# Nivel 3 
# Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, 
# teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:

CREATE TABLE IF NOT EXISTS products (
id VARCHAR(100) PRIMARY KEY ,
product_name VARCHAR(250),
price VARCHAR(50),
colour VARCHAR(100),
weight DECIMAL(10,2),
warehouse_id VARCHAR(100)
);

LOAD DATA INFILE 'C:\\mysql-uploads\\products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# Ejercicio 1
# Necesitamos conocer el número de veces que se ha vendido cada producto.

SELECT 
    p.id,
    p.product_name,
    COUNT(*) AS times_sold
FROM products p
JOIN transactions t
ON FIND_IN_SET(
       p.id,
       REPLACE(t.product_ids, ' ', '')
   ) > 0
GROUP BY p.id, p.product_name
ORDER BY times_sold DESC;
