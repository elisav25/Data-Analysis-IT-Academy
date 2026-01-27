# Ejercicio 1
# Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. 
# La nueva tabla debe ser capaz de identificar de forma única cada tarjeta y establecer una relación adecuada con las otras dos tablas 
# ("transaction" y "company"). Después de crear la tabla será necesario que ingreses la información del documento denominado "datos_introducir_credit".
# Recuerda mostrar el diagrama y realizar una breve descripción del mismo.

USE transactions;

CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(20) NOT NULL,
    iban VARCHAR(100) DEFAULT NULL,
    pan VARCHAR(100) DEFAULT NULL,
    pin VARCHAR(4) DEFAULT NULL,
    cvv VARCHAR(3) DEFAULT NULL,
    expiring_date VARCHAR(20) DEFAULT NULL,
    PRIMARY KEY (id)
);                                             

ALTER TABLE transaction                         # creado tabla credit_card con expiring_date VARCHAR porquè con DATE no me reconocìa el formato actual
ADD CONSTRAINT fk_transaction_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

ALTER TABLE transaction  
ADD CONSTRAINT fk_transaction_company
FOREIGN KEY (company_id)
REFERENCES company(id);                       # relacionado las tablas con foreign keys transaction --> pk credit card id y company id

# Ejercicio 2
# El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito
# con ID CcU-2938. La información que debe mostrarse para este registro es: TR323456312213576817699999. Recuerda mostrar que el cambio se realizó.

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';

# Ejercicio 3
# En la tabla "transaction" ingresa una nueva transacción con la siguiente información:
# Id 108B1D1D-5B23-A76C-55EF-C568E49A99DD, credit_card_id CcU-9999, company_id b-9999, user_id	9999
# lat 829.999, longitude -117.999, amount 111.11, declined	0

INSERT INTO credit_card (id)       
VALUES ('CcU-9999');      

INSERT INTO company (id)
VALUES ('b-9999');        

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

# Ejercicio 4
# Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.

ALTER TABLE credit_card
DROP COLUMN pan;

SELECT * FROM credit_card;

# Nivel 2
# Ejercicio 1
# Elimina de la tabla transacción el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.

DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

# Ejercicio 2
# La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas.
# Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones. Será necesaria que crees una vista 
# llamada VistaMarketing que contenga la siguiente información: Nombre de la compañía. Teléfono de contacto. País de residencia.
#  Media de compra realizado por cada compañía. Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra.

CREATE VIEW VistaMarketing AS
SELECT c.company_name, c.phone, c.country, AVG(t.amount) AS average_amount
FROM company c 
JOIN transaction t 
ON c.id = t.company_id
GROUP BY c.company_name, c.phone, c.country
ORDER BY average_amount DESC;

SELECT * FROM VistaMarketing;

# Ejercicio 3
# Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"

SELECT * FROM VistaMarketing
WHERE country = 'Germany';

# Nivel 3
# Ejercicio 1
# La próxima semana tendrás una nueva reunión con los gerentes de marketing. Un compañero de tu equipo realizó modificaciones 
# en la base de datos, pero no recuerda cómo las realizó. Te pide que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama:

ALTER TABLE user 
MODIFY COLUMN id INT;

ALTER TABLE user
CHANGE COLUMN email personal_email VARCHAR(150);

ALTER TABLE user
RENAME TO data_user;

ALTER TABLE credit_card
MODIFY COLUMN iban VARCHAR(50);

ALTER TABLE credit_card
MODIFY COLUMN cvv INT;

ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;

ALTER TABLE transaction 
MODIFY COLUMN credit_card_id VARCHAR(20);

ALTER TABLE company
DROP COLUMN website;

INSERT INTO data_user (id)
VALUES (9999);

ALTER TABLE transaction                         
ADD CONSTRAINT fk_transaction_user
FOREIGN KEY (user_id)
REFERENCES data_user(id);

# Ejercicio 2
# La empresa también le pide crear una vista llamada "InformeTecnico" que contenga la siguiente información:
# o	ID de la transacción
# o	Nombre del usuario/a
# o	Apellido del usuario/a
# o	IBAN de la tarjeta de crédito usada.
# o	Nombre de la compañía de la transacción realizada.
# o	Asegúrese de incluir información relevante de las tablas que conocerá y utilice alias para cambiar de nombre columnas según sea necesario.
# Muestra los resultados de la vista, ordena los resultados de forma descendente en función de la variable ID de transacción.

CREATE VIEW InformeTecnico AS
SELECT t.id AS transaction_id, d.name, d.surname, c.iban, co.company_name
FROM transaction t 
JOIN data_user d ON d.id = t.user_id
JOIN credit_card c ON c.id = t.credit_card_id
JOIN company co ON co.id = t.company_id
ORDER BY transaction_id DESC;

SELECT * FROM InformeTecnico;


  


















