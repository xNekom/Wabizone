-- Migración para cambiar el tipo de columna imagen en la tabla Product a MEDIUMBLOB
ALTER TABLE Product MODIFY COLUMN imagen MEDIUMBLOB; 