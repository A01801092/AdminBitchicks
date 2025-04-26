-- Eliminar la base de datos existente si es necesario
DROP DATABASE IF EXISTS unity_redes;

-- Crear la base de datos
CREATE DATABASE unity_redes;

USE unity_redes;

CREATE TABLE usuario (
    nombre VARCHAR(20) NOT NULL,
    apellido VARCHAR(20) NOT NULL,
    fecha_de_nacimiento DATE NOT NULL,
    edad INT,
    pais VARCHAR(20) NOT NULL,
    correo_jugador VARCHAR(50) NOT NULL PRIMARY KEY,
    password VARCHAR(25) NOT NULL,
    genero ENUM('Femenino', 'Masculino', 'Otro') DEFAULT 'Otro', -- Nuevo campo
    monedas INT NOT NULL,
    cantidadJuguete INT DEFAULT 0,
    cantidadComida INT DEFAULT 0,
    rachaDias INT DEFAULT 0,
    ultimoInicioSesion DATETIME,
    ultimoCierreSesion DATETIME,
    tiempoJugado DECIMAL(5,2) DEFAULT 0,
    nuevoUsuario BOOL DEFAULT TRUE
);

-- El resto de tu esquema permanece igual
CREATE TABLE mascota (
    id_mascota INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(10) NOT NULL,
    hambre  INT(3),
    felicidad INT(3),
    energia INT(3),
    nivel INT(2),
    correo_jugador VARCHAR(50),
    fechaUltimaAlimentacion DATETIME,
    fechaUltimoJuego DATETIME,
    FOREIGN KEY (correo_jugador) REFERENCES usuario(correo_jugador)
);

-- Tabla LECCIÓN (sin cambios)
CREATE TABLE leccion (
    nombre_leccion VARCHAR(50) NOT NULL PRIMARY KEY,
    dificultad ENUM('Básica', 'Intermedia', 'Avanzada') DEFAULT 'Básica',
    contenido LONGTEXT COMMENT
);

-- Tabla USUARIO_LECCION
CREATE TABLE usuario_leccion (
    correo_jugador VARCHAR(50) NOT NULL,
    nombre_leccion VARCHAR(50) NOT NULL,
    veces_completada INT DEFAULT 0,
    PRIMARY KEY (correo_jugador, nombre_leccion),
    FOREIGN KEY (correo_jugador) REFERENCES usuario(correo_jugador),
    FOREIGN KEY (nombre_leccion) REFERENCES leccion(nombre_leccion)
);

-- Tabla PREGUNTA (solo opción múltiple)
CREATE TABLE pregunta (
    id_pregunta INT AUTO_INCREMENT PRIMARY KEY,
    nombre_leccion VARCHAR(50) NOT NULL,
    texto_pregunta TEXT NOT NULL,
    FOREIGN KEY (nombre_leccion) REFERENCES leccion(nombre_leccion)
);

-- Tabla OPCION_RESPUESTA (obligatoria para cada pregunta)
CREATE TABLE opcion_respuesta (
    id_opcion INT AUTO_INCREMENT PRIMARY KEY,
    id_pregunta INT NOT NULL,
    texto_opcion TEXT NOT NULL,
    es_correcta BOOL DEFAULT FALSE,
    FOREIGN KEY (id_pregunta) REFERENCES pregunta(id_pregunta) ON DELETE CASCADE
);

-- Tabla RESPUESTA_USUARIO (registro específico para opción múltiple)
CREATE TABLE respuesta_usuario (
    id_respuesta INT AUTO_INCREMENT PRIMARY KEY,
    correo_jugador VARCHAR(50) NOT NULL,
    id_pregunta INT NOT NULL,
    id_opcion_seleccionada INT NOT NULL,
    FOREIGN KEY (correo_jugador) REFERENCES usuario(correo_jugador),
    FOREIGN KEY (id_pregunta) REFERENCES pregunta(id_pregunta),
    FOREIGN KEY (id_opcion_seleccionada) REFERENCES opcion_respuesta(id_opcion)
);

INSERT INTO usuario (nombre, apellido, fecha_de_nacimiento, edad, pais, correo_jugador, password, genero, monedas, cantidadJuguete, cantidadComida, rachaDias, ultimoInicioSesion, ultimoCierreSesion, tiempoJugado, nuevoUsuario) VALUES
('Emanuel', 'Hernández', '2005-01-25', TIMESTAMPDIFF(YEAR, '2005-01-25', CURDATE()), 'México', 'emanuelhdz01@gmail.com', '123', 'Masculino', 100, 3, 5, 7, '2025-04-20 08:00:00', '2025-04-20 10:30:00', 2.5, TRUE),
('Andrea', 'Santiago', '2005-12-08', TIMESTAMPDIFF(YEAR, '2005-12-08', CURDATE()), 'México', 'andrea@gmail.com', '123', 'Femenino', 170, 4, 2, 3, '2025-04-19 14:00:00', '2025-04-19 16:20:00', 3.33, TRUE),
('Luis', 'Ramírez', '2004-09-14', TIMESTAMPDIFF(YEAR, '2004-09-14', CURDATE()), 'Chile', 'luisr@gmail.com', 'abc123', 'Masculino', 80, 2, 4, 1, '2025-04-18 09:00:00', '2025-04-18 11:00:00', 2.0, TRUE),
('Camila', 'Torres', '2003-11-02', TIMESTAMPDIFF(YEAR, '2003-11-02', CURDATE()), 'Argentina', 'camitorres@gmail.com', 'cami456', 'Femenino', 200, 1, 6, 5, '2025-04-17 10:00:00', '2025-04-17 12:30:00', 2.5, FALSE),
('Mateo', 'López', '2005-07-19', TIMESTAMPDIFF(YEAR, '2005-07-19', CURDATE()), 'Colombia', 'mateolopez@gmail.com', 'pass789', 'Masculino', 150, 5, 3, 2, '2025-04-16 11:00:00', '2025-04-16 13:00:00', 2.0, TRUE),
('Isabella', 'Gómez', '2006-04-25', TIMESTAMPDIFF(YEAR, '2006-04-25', CURDATE()), 'Perú', 'isagomez@gmail.com', 'bella321', 'Femenino', 50, 0, 1, 0, '2025-04-15 15:00:00', '2025-04-15 16:45:00', 1.75, TRUE),
('Diego', 'Fernández', '2002-06-10', TIMESTAMPDIFF(YEAR, '2002-06-10', CURDATE()), 'México', 'diegof@gmail.com', 'dfpass', 'Otro', 95, 3, 2, 4, '2025-04-14 16:00:00', '2025-04-14 18:00:00', 2.0, FALSE);

-- Insertar mascotas (igual que antes)
INSERT INTO mascota (nombre, hambre, felicidad, energia, nivel, correo_jugador, fechaUltimaAlimentacion, fechaUltimoJuego) VALUES
('Firu', 10, 90, 70, 5, 'emanuelhdz01@gmail.com', '2025-04-19 09:00:00', '2025-04-19 12:00:00'),
('Luna', 100, 100, 100, 4, 'andrea@gmail.com', '2025-04-19 14:00:00', '2025-04-19 16:20:00'),
('Rocky', 75, 70, 50, 3, 'luisr@gmail.com', '2025-04-18 09:30:00', '2025-04-18 11:30:00'),
('Milo', 50, 95, 80, 6, 'camitorres@gmail.com', '2025-04-17 10:30:00', '2025-04-17 12:30:00'),
('Simba', 90, 60, 65, 2, 'mateolopez@gmail.com', '2025-04-16 11:15:00', '2025-04-16 13:15:00'),
('Nala', 65, 75, 70, 3, 'isagomez@gmail.com', '2025-04-15 15:30:00', '2025-04-15 16:50:00'),
('Toby', 70, 88, 72, 4, 'diegof@gmail.com', '2025-04-14 16:30:00', '2025-04-14 18:30:00');

-- Lecciones sobre Crypto, Blockchain y NFTs
INSERT INTO leccion (nombre_leccion, dificultad, contenido) VALUES
('Introducción a Blockchain', 'Básica', 'Blockchain es una tecnología de registro distribuido descentralizado. Sus características clave son: 1) Descentralización - no hay control central, 2) Inmutabilidad - los datos no se pueden alterar, 3) Transparencia - todas las transacciones son visibles.'),
('Criptomonedas Básicas', 'Básica', 'Las criptomonedas son activos digitales para intercambio. Las principales son: Bitcoin (BTC) - la primera cripto, Ethereum (ETH) - para contratos inteligentes, Binance Coin (BNB) - token de Binance.'),
('NFTs para Principiantes', 'Intermedia', 'NFTs son tokens no fungibles que representan propiedad de items únicos. Usos comunes: arte digital, coleccionables, propiedad intelectual y tickets para eventos.'),
('Smart Contracts', 'Avanzada', 'Smart contracts son programas en blockchain que ejecutan acuerdos automáticamente. Ventajas: eliminan intermediarios, son transparentes y se ejecutan solos.'),
('Seguridad en Crypto', 'Intermedia', 'Protege tus cripto con: hardware wallets, autenticación de dos factores (2FA) y verificando URLs. Peligros: phishing, scams y wallets falsas.');

-- Preguntas y respuestas
INSERT INTO pregunta (nombre_leccion, texto_pregunta) VALUES
('Introducción a Blockchain', '¿Qué característica principal define a una blockchain?'),
('Introducción a Blockchain', '¿Qué significa que una blockchain es inmutable?'),
('NFTs para Principiantes', '¿Qué significa NFT?'),
('NFTs para Principiantes', '¿Qué tipo de archivos pueden ser NFTs?'),
('Criptomonedas Básicas', '¿Cuál fue la primera criptomoneda?'),
('Smart Contracts', '¿Dónde se ejecutan los smart contracts?');

-- Opciones de respuesta
INSERT INTO opcion_respuesta (id_pregunta, texto_opcion, es_correcta) VALUES
(1, 'Es controlada por un banco central', FALSE),
(1, 'Es una base de datos descentralizada', TRUE),
(1, 'Requiere permisos especiales para leer', FALSE),
(2, 'Que puede ser editada por cualquiera', FALSE),
(2, 'Que los datos no pueden ser alterados', TRUE),
(2, 'Que es muy rápida', FALSE),
(3, 'New Financial Technology', FALSE),
(3, 'Non-Fungible Token', TRUE),
(3, 'Network File Transfer', FALSE),
(4, 'Solo imágenes JPEG', FALSE),
(4, 'Cualquier archivo digital', TRUE),
(4, 'Exclusivamente videos', FALSE),
(5, 'Ethereum', FALSE),
(5, 'Bitcoin', TRUE),
(5, 'Dogecoin', FALSE),
(6, 'En servidores privados', FALSE),
(6, 'En la blockchain', TRUE),
(6, 'En la nube', FALSE);

-- Progreso de usuarios
INSERT INTO usuario_leccion (correo_jugador, nombre_leccion, veces_completada) VALUES
('emanuelhdz01@gmail.com', 'Introducción a Blockchain', 2),
('andrea@gmail.com', 'NFTs para Principiantes', 1),
('luisr@gmail.com', 'Criptomonedas Básicas', 3),
('camitorres@gmail.com', 'Seguridad en Crypto', 1),
('mateolopez@gmail.com', 'Smart Contracts', 2);

-- Respuestas de usuarios
INSERT INTO respuesta_usuario (correo_jugador, id_pregunta, id_opcion_seleccionada) VALUES
('emanuelhdz01@gmail.com', 1, 2),
('emanuelhdz01@gmail.com', 2, 5),
('andrea@gmail.com', 3, 8),
('andrea@gmail.com', 4, 11),
('luisr@gmail.com', 5, 14),
('camitorres@gmail.com', 6, 17);

-- Procedimiento para calcular duración de sesión (igual que antes)
DELIMITER $$

CREATE PROCEDURE CalcularDuracionSesion(IN correo_input VARCHAR(100))
BEGIN
    DECLARE horas_actuales DECIMAL(5,2);
    DECLARE minutos_jugados INT;
    DECLARE nuevas_horas DECIMAL(5,2);

    SELECT TIMESTAMPDIFF(MINUTE, ultimoInicioSesion, ultimoCierreSesion)
        INTO minutos_jugados
        FROM usuario
        WHERE correo_jugador = correo_input;

    SELECT tiempoJugado INTO horas_actuales
        FROM usuario
        WHERE correo_jugador = correo_input;

    SET nuevas_horas = ROUND(minutos_jugados / 60, 2);

    UPDATE usuario
    SET tiempoJugado = ROUND(horas_actuales + nuevas_horas, 2)
    WHERE correo_jugador = correo_input;
END$$

-- Trigger para inserts/updates
DELIMITER $$
CREATE TRIGGER calcular_edad_trigger
BEFORE INSERT ON usuario
FOR EACH ROW
BEGIN
    SET NEW.edad = TIMESTAMPDIFF(YEAR, NEW.fecha_de_nacimiento, CURDATE());
END$$

CREATE TRIGGER actualizar_edad_trigger
BEFORE UPDATE ON usuario
FOR EACH ROW
BEGIN
    SET NEW.edad = TIMESTAMPDIFF(YEAR, NEW.fecha_de_nacimiento, CURDATE());
END$$
DELIMITER ;

-- Evento diario
DELIMITER $$
CREATE EVENT actualizar_edades_diario
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    UPDATE usuario SET edad = TIMESTAMPDIFF(YEAR, fecha_de_nacimiento, CURDATE());
END$$
DELIMITER ;

DELIMITER $$

-- Registrar una respuesta de opción múltiple
CREATE PROCEDURE RegistrarRespuestaMultiple(
    IN p_correo VARCHAR(50),
    IN p_id_pregunta INT,
    IN p_id_opcion INT
)
BEGIN
    DECLARE v_es_correcta BOOL;
    DECLARE v_nombre_leccion VARCHAR(50);

    -- Verificar si la opción es correcta
    SELECT es_correcta INTO v_es_correcta
    FROM opcion_respuesta
    WHERE id_opcion = p_id_opcion;

    -- Obtener la lección asociada
    SELECT nombre_leccion INTO v_nombre_leccion
    FROM pregunta WHERE id_pregunta = p_id_pregunta;

    -- Registrar la respuesta
    INSERT INTO respuesta_usuario (
        correo_jugador,
        id_pregunta,
        id_opcion_seleccionada
    ) VALUES (
        p_correo,
        p_id_pregunta,
        p_id_opcion
    );

    -- Actualizar conteo de lecciones completadas si es correcta
    IF v_es_correcta THEN
        INSERT INTO usuario_leccion (
            correo_jugador,
            nombre_leccion,
            veces_completada
        ) VALUES (
            p_correo,
            v_nombre_leccion,
            1
        ) ON DUPLICATE KEY UPDATE
            veces_completada = veces_completada + 1;
    END IF;
END$$

DELIMITER ;