-- Migración para cambiar el tipo de columna imagen a MEDIUMBLOB
ALTER TABLE User MODIFY COLUMN imagen MEDIUMBLOB; 