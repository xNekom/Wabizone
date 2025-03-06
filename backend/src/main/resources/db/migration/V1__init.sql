-- Initial database schema creation

-- User table
CREATE TABLE IF NOT EXISTS User (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    imagen MEDIUMBLOB,
    rol VARCHAR(50) DEFAULT 'USER'
);

-- Product table
CREATE TABLE IF NOT EXISTS Product (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    custom_id VARCHAR(50) UNIQUE,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT,
    stock INT DEFAULT 0,
    precio DOUBLE NOT NULL,
    imagen MEDIUMBLOB
);

-- Add other tables as needed based on your application requirements