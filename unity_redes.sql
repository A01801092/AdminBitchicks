DROP DATABASE IF EXISTS unity_redes;

-- Crear la base de datos
CREATE DATABASE unity_redes;

USE unity_redes;

CREATE TABLE admin (
    correo_admin VARCHAR(50) NOT NULL PRIMARY KEY,
    password VARCHAR(25) NOT NULL
);

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

-- Tabla LECCION con nuevo campo id_leccion como PRIMARY KEY
CREATE TABLE leccion (
    id_leccion INT PRIMARY KEY,
    nombre_leccion VARCHAR(50) NOT NULL UNIQUE,
    dificultad ENUM('Básica', 'Intermedia', 'Avanzada') DEFAULT 'Básica',
    contenido LONGTEXT
);

-- Tabla USUARIO_LECCION referenciando id_leccion
CREATE TABLE usuario_leccion (
    correo_jugador VARCHAR(50) NOT NULL,
    id_leccion INT NOT NULL,
    veces_completada INT DEFAULT 0,
    PRIMARY KEY (correo_jugador, id_leccion),
    FOREIGN KEY (correo_jugador) REFERENCES usuario(correo_jugador),
    FOREIGN KEY (id_leccion) REFERENCES leccion(id_leccion)
);

-- Tabla PREGUNTA referenciando id_leccion
CREATE TABLE pregunta (
    id_pregunta INT AUTO_INCREMENT PRIMARY KEY,
    id_leccion INT NOT NULL,
    texto_pregunta TEXT NOT NULL,
    FOREIGN KEY (id_leccion) REFERENCES leccion(id_leccion)
);

-- Tabla OPCION_RESPUESTA
CREATE TABLE opcion_respuesta (
    id_opcion INT AUTO_INCREMENT PRIMARY KEY,
    id_pregunta INT NOT NULL,
    texto_opcion TEXT NOT NULL,
    es_correcta BOOL DEFAULT FALSE,
    FOREIGN KEY (id_pregunta) REFERENCES pregunta(id_pregunta) ON DELETE CASCADE
);

-- Tabla RESPUESTA_USUARIO
CREATE TABLE respuesta_usuario (
    id_respuesta INT AUTO_INCREMENT PRIMARY KEY,
    correo_jugador VARCHAR(50) NOT NULL,
    id_pregunta INT NOT NULL,
    id_opcion_seleccionada INT NOT NULL,
    FOREIGN KEY (correo_jugador) REFERENCES usuario(correo_jugador),
    FOREIGN KEY (id_pregunta) REFERENCES pregunta(id_pregunta),
    FOREIGN KEY (id_opcion_seleccionada) REFERENCES opcion_respuesta(id_opcion)
);

INSERT INTO admin (correo_admin, password) VALUES
('jaretzy.santiago.b@gmail.com', '20051208');

INSERT INTO usuario (nombre, apellido, fecha_de_nacimiento, edad, pais, correo_jugador, password, genero, monedas, cantidadJuguete, cantidadComida, rachaDias, ultimoInicioSesion, ultimoCierreSesion, tiempoJugado, nuevoUsuario) VALUES
('Emanuel', 'Hernández', '2005-01-25', TIMESTAMPDIFF(YEAR, '2005-01-25', CURDATE()), 'México', 'emanuelhdz01@gmail.com', '123', 'Masculino', 100, 3, 5, 7, '2025-04-20 08:00:00', '2025-04-20 10:30:00', 2.5, FALSE),
('Andrea', 'Santiago', '2005-12-08', TIMESTAMPDIFF(YEAR, '2005-12-08', CURDATE()), 'México', 'andrea@gmail.com', '123', 'Femenino', 170, 4, 2, 3, '2025-04-19 14:00:00', '2025-04-19 16:20:00', 3.33, FALSE),
('Luis', 'Ramírez', '2004-09-14', TIMESTAMPDIFF(YEAR, '2004-09-14', CURDATE()), 'Chile', 'luisr@gmail.com', 'abc123', 'Masculino', 80, 2, 4, 1, '2025-04-18 09:00:00', '2025-04-18 11:00:00', 2.0, FALSE),
('Camila', 'Torres', '2003-11-02', TIMESTAMPDIFF(YEAR, '2003-11-02', CURDATE()), 'Argentina', 'camitorres@gmail.com', 'cami456', 'Femenino', 200, 1, 6, 5, '2025-04-17 10:00:00', '2025-04-17 12:30:00', 2.5, FALSE),
('Mateo', 'López', '2005-07-19', TIMESTAMPDIFF(YEAR, '2005-07-19', CURDATE()), 'Colombia', 'mateolopez@gmail.com', 'pass789', 'Masculino', 150, 5, 3, 2, '2025-04-16 11:00:00', '2025-04-16 13:00:00', 2.0, FALSE),
('Isabella', 'Gómez', '2006-04-25', TIMESTAMPDIFF(YEAR, '2006-04-25', CURDATE()), 'Perú', 'isagomez@gmail.com', 'bella321', 'Femenino', 50, 0, 1, 0, '2025-04-15 15:00:00', '2025-04-15 16:45:00', 1.75, FALSE),
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

INSERT INTO leccion (id_leccion, nombre_leccion, dificultad, contenido) VALUES
(0, 'Leccion personalizada', 'Básica', ''),
(1, 'Introducción a BlockChain', 'Básica', 'Blockchain es una tecnología revolucionaria que permite almacenar y transferir información de forma segura y sin intermediarios.\nSu estructura consiste en una cadena de bloques conectados, donde cada bloque contiene datos, un hash criptográfico, y el hash del bloque anterior.\nEsta relación entre bloques hace que sea extremadamente difícil modificar los datos sin alterar toda la cadena.\nLas principales características de una blockchain son:\n1) Descentralización: no existe un servidor central, todos los nodos tienen una copia completa,\n2) Inmutabilidad: una vez que un bloque es añadido, no se puede modificar sin romper la cadena,\n3) Transparencia: las transacciones son visibles para todos los participantes de la red.\nAdemás, el sistema se basa en la criptografía para asegurar que sólo los usuarios autorizados puedan realizar cambios válidos.\nBlockchain tiene aplicaciones más allá de las criptomonedas, como en logística, salud, identidad digital, y contratos inteligentes.\nAprender cómo funciona este sistema es fundamental para entender el futuro de las tecnologías digitales.'),
(2, 'Blockchain Intermedio', 'Intermedia', 'A nivel intermedio, es importante conocer los componentes internos de una blockchain y cómo se valida la información.\nCada bloque contiene un conjunto de transacciones, un sello de tiempo (timestamp), un nonce (número aleatorio) y un hash que enlaza con el bloque anterior.\nEl hash se genera aplicando una función criptográfica a los datos del bloque; si el contenido cambia, el hash también.\nEsto asegura la integridad de la información.\nLa validación de bloques se realiza mediante algoritmos de consenso.\nEl más conocido es Proof of Work (PoW), donde los mineros resuelven acertijos matemáticos para poder añadir nuevos bloques.\nOtro algoritmo popular es Proof of Stake (PoS), donde los validadores son elegidos en función de la cantidad de criptomonedas que tienen y están dispuestos a "apostar".\nTambién se utiliza una estructura llamada Árbol de Merkle (Merkle Tree) que permite verificar si una transacción pertenece a un bloque sin tener que revisar todo su contenido.\nEsta lección también cubre temas como bifurcaciones (forks), escalabilidad de la red y algunas limitaciones actuales de la tecnología blockchain.'),
(3, 'Blockchain Avanzado', 'Avanzada', 'En esta lección se exploran temas complejos del mundo blockchain, incluyendo su evolución hacia aplicaciones más sofisticadas como dApps (aplicaciones descentralizadas) y contratos inteligentes.\nLa blockchain de Ethereum, por ejemplo, permite programar contratos que se ejecutan automáticamente cuando se cumplen ciertas condiciones.\nSe analizan mecanismos de consenso avanzados como Delegated Proof of Stake (DPoS), Proof of Authority (PoA) y soluciones híbridas.\nTambién se estudia el concepto de Layer 2 (segunda capa), como Lightning Network o zk-Rollups, que buscan mejorar la escalabilidad de las redes.\nOtro tema importante es la interoperabilidad: cómo distintas blockchains pueden comunicarse entre sí (por ejemplo, Polkadot y Cosmos).\nAdemás, se abordan aspectos legales y éticos como la gobernanza descentralizada (DAOs), la privacidad de los datos en redes públicas y la tokenización de activos reales.\nFinalmente, se estudia cómo las blockchains privadas (como Hyperledger) son utilizadas por empresas para automatizar procesos sin perder confidencialidad.\nEsta lección es esencial para quienes deseen diseñar soluciones reales usando tecnología blockchain.'),
(4, 'Criptomonedas Básicas', 'Básica', 'Las criptomonedas son monedas digitales creadas para facilitar intercambios sin necesidad de intermediarios como bancos o gobiernos.\nLa primera y más conocida es Bitcoin, lanzada en 2009 por el misterioso Satoshi Nakamoto.\nEstas monedas se basan en blockchain, que asegura que las transacciones sean seguras, transparentes e irreversibles.\nCada criptomoneda funciona sobre su propia red o blockchain.\nEntre las criptomonedas más populares están:\n- Bitcoin (BTC): utilizada como reserva de valor y medio de intercambio,\n- Ethereum (ETH): permite ejecutar contratos inteligentes,\n- Binance Coin (BNB): útil dentro del ecosistema de Binance.\nLas criptomonedas se almacenan en billeteras digitales (wallets), que pueden ser aplicaciones móviles, dispositivos físicos o incluso papel.\nPara usarlas, se necesita una clave privada que debe mantenerse segura.\nTambién se pueden comprar y vender en plataformas llamadas exchanges.\nEl uso de criptomonedas está creciendo rápidamente y ya se aceptan como medio de pago en algunas tiendas y servicios en línea.'),
(5, 'Criptomonedas Intermedio', 'Intermedia', 'Además de comprar y vender criptomonedas, existen muchos elementos que forman parte de su ecosistema.\nEn esta lección aprenderás sobre el funcionamiento interno de las wallets, tipos de transacciones, y diferentes formas de interactuar con criptomonedas.\nLas billeteras digitales pueden ser:\n- Calientes (hot wallets): conectadas a internet, más prácticas pero menos seguras,\n- Frías (cold wallets): sin conexión, como dispositivos físicos (hardware wallets), más seguras pero menos cómodas.\nLas criptomonedas pueden enviarse directamente entre personas, sin intermediarios, lo que reduce costos y tiempos.\nSe introducen también las stablecoins, como USDT o USDC, que están diseñadas para mantener un valor estable vinculado al dólar.\nEstas monedas se usan para evitar la volatilidad típica de las criptomonedas.\nPor otro lado, existen exchanges descentralizados (DEX), que permiten el comercio sin un operador central, aumentando la privacidad.\nEste nivel te prepara para comprender cómo se integran las criptomonedas en sistemas financieros más amplios.'),
(6, 'Criptomonedas Avanzado', 'Avanzada', 'El mundo de las criptomonedas ha evolucionado más allá de simples transferencias de valor.\nHoy, existe todo un ecosistema financiero basado en blockchain llamado DeFi (Finanzas Descentralizadas).\nEn esta lección se estudian herramientas avanzadas como:\n- Staking: bloquear tus criptos para validar transacciones y obtener recompensas,\n- Yield farming: proveer liquidez a protocolos descentralizados a cambio de intereses,\n- Lending: prestar o pedir préstamos sin intermediarios, usando contratos inteligentes.\nTambién se explican los riesgos asociados: impermanent loss, ataques a protocolos, y errores en contratos inteligentes.\nSe estudian oráculos como Chainlink, que permiten a los contratos inteligentes acceder a información del mundo real.\nAdemás, se analiza la evolución regulatoria de las criptomonedas, la legalidad en distintos países, y cómo los gobiernos están respondiendo a esta nueva economía.\nFinalmente, se revisan casos de uso reales como remesas globales, microfinanzas y proyectos sociales impulsados por criptomonedas.\nEsta lección es ideal para quienes desean trabajar profesionalmente en el sector cripto o diseñar soluciones DeFi.'),
(7, 'NFTs para Principiantes', 'Básica', 'Un NFT (Token No Fungible) es un tipo especial de activo digital que representa propiedad sobre un objeto único, como una obra de arte digital, una canción, o incluso un tuit.\nA diferencia de las criptomonedas tradicionales como Bitcoin o Ethereum, que son fungibles y pueden intercambiarse entre sí, cada NFT es distinto y no se puede replicar.\nLos NFTs están registrados en una blockchain, usualmente en Ethereum, y contienen metadatos que indican quién lo creó, quién lo posee y cuál es su contenido.\nHan ganado popularidad en áreas como el arte digital, los videojuegos, los coleccionables deportivos y la música.\nPor ejemplo, artistas pueden vender obras digitales con prueba de autenticidad y recibir regalías cada vez que el NFT se revende.\nPlataformas como OpenSea y Rarible permiten crear, comprar y vender NFTs fácilmente.\nAunque es una tecnología nueva, los NFTs abren puertas a nuevas formas de monetizar contenido digital y proteger la propiedad intelectual.'),
(8, 'NFTs Intermedio', 'Intermedia', 'A medida que los NFTs evolucionan, se han convertido en mucho más que imágenes digitales coleccionables.\nEn esta etapa intermedia, se analizan conceptos como la utilidad de los NFTs (utility NFTs), la interoperabilidad entre plataformas y los contratos inteligentes que los gobiernan.\nPor ejemplo, algunos NFTs permiten acceder a eventos exclusivos, membresías, derechos de voto en proyectos, o recompensas en juegos.\nTambién se estudian los estándares de creación de NFTs como ERC-721 y ERC-1155.\nEl primero representa tokens únicos, mientras que el segundo permite representar tanto tokens únicos como múltiples (fungibles y no fungibles).\nOtra área importante es el metaverso, donde los NFTs representan terrenos virtuales, ropa para avatares o accesorios en mundos como Decentraland o The Sandbox.\nEl análisis de la escasez, la autenticidad y la comunidad detrás de un NFT es clave para determinar su valor.\nEsta lección también incluye aspectos técnicos de cómo crear un NFT, asociarlo a contenido digital y desplegarlo en una blockchain.'),
(9, 'NFTs Avanzado', 'Avanzada', 'En el nivel avanzado de NFTs se exploran las aplicaciones más innovadoras, así como los desafíos legales, técnicos y económicos que enfrenta esta tecnología.\nLos NFTs ya no solo representan arte digital, sino también identidad digital, licencias de software, contratos legales y certificados de educación.\nUn área clave es la tokenización de activos físicos, como inmuebles o autos, mediante NFTs vinculados a contratos jurídicos reales.\nTambién se abordan conceptos como NFTs dinámicos, que cambian su comportamiento según eventos externos (por ejemplo, logros en un videojuego o condiciones del clima).\nSe exploran plataformas de generación programática de NFTs, marketplaces descentralizados, y soluciones de escalabilidad como Polygon y Arbitrum.\nEn cuanto a desafíos, se estudian la congestión de red, el impacto ambiental de las blockchains PoW, el almacenamiento descentralizado (IPFS), y los problemas de derechos de autor y falsificación.\nEsta lección busca preparar al estudiante para participar activamente en el diseño de soluciones creativas y éticas con NFTs.'),
(10, 'Smart Contracts para Principiantes', 'Básica', 'Un contrato inteligente (smart contract) es un programa informático que se ejecuta automáticamente cuando se cumplen ciertas condiciones, todo dentro de una blockchain.\nEstos contratos eliminan la necesidad de intermediarios humanos o empresas para hacer cumplir un acuerdo.\nPor ejemplo, si alguien paga 1 ETH, el contrato puede transferirle un NFT de forma automática.\nEthereum fue la primera plataforma en popularizar los smart contracts, usando un lenguaje de programación llamado Solidity.\nUna vez desplegado, el código es público y no se puede modificar, lo que aporta transparencia y seguridad.\nAplicaciones comunes de los contratos inteligentes incluyen loterías automáticas, seguros descentralizados, préstamos, y la compra/venta de activos digitales.\nEste concepto es la base de muchos proyectos innovadores dentro del ecosistema blockchain.'),
(11, 'Smart Contracts Intermedio', 'Intermedia', 'A nivel intermedio, se profundiza en la estructura y codificación de los contratos inteligentes.\nSe estudia cómo escribir funciones, variables, eventos y estructuras de control en Solidity.\nTambién se introduce el uso de frameworks como Remix, Truffle y Hardhat para desarrollar, probar y desplegar contratos.\nSe analiza cómo interactúan con otras aplicaciones a través de Web3.js o Ethers.js.\nOtro tema clave es el uso de librerías seguras como OpenZeppelin y la gestión de errores con mecanismos como require(), assert() y revert().\nSe estudia también el concepto de gas: la cantidad de poder computacional que cuesta ejecutar instrucciones.\nLa optimización del uso de gas es importante para evitar tarifas elevadas.\nEsta lección sienta las bases para poder crear dApps y sistemas financieros autónomos con contratos inteligentes.'),
(12, 'Smart Contracts Avanzado', 'Avanzada', 'Aquí se exploran temas avanzados como la auditoría de seguridad de contratos, los ataques más comunes (reentrancy, front-running, integer overflow) y cómo prevenirlos.\nTambién se estudia el diseño de contratos modulares y actualizables mediante patrones como proxy.\nOtro tema importante es la integración con oráculos (como Chainlink) para acceder a datos del mundo real, y con IPFS para almacenar contenido de forma descentralizada.\nSe revisa cómo interactúan múltiples contratos entre sí en sistemas complejos como los de DeFi.\nLa interoperabilidad entre blockchains, los estándares de tokens (ERC-20, ERC-721, ERC-777) y la gobernanza descentralizada (DAOs) también forman parte de esta lección.\nEste nivel prepara al estudiante para desarrollar soluciones completas, seguras y escalables sobre blockchain.'),
(13, 'Seguridad en Crypto', 'Básica', 'La seguridad es fundamental al usar criptomonedas, ya que los errores pueden significar la pérdida total de fondos.\nUna wallet cripto funciona mediante una clave pública (tu dirección) y una clave privada (tu contraseña secreta).\nNunca debes compartir tu clave privada ni frase semilla.\nEs recomendable usar wallets de hardware (como Ledger o Trezor) para mayor protección.\nAdemás, activa siempre la verificación en dos pasos (2FA) en plataformas de intercambio.\nEvita enlaces sospechosos y no confíes en mensajes de "soporte" en redes sociales.\nEl phishing y las estafas de inversión son amenazas comunes.\nSiempre verifica que la URL del exchange sea la correcta y utiliza conexiones seguras.\nCon buenas prácticas, puedes mantener tus fondos protegidos.'),
(14, 'Seguridad en Crypto Intermedio', 'Intermedia', 'La seguridad en criptomonedas no depende solo del usuario, sino también de cómo funcionan los protocolos.\nSe estudian ataques comunes como el "man in the middle", phishing avanzado y malware diseñado para robar criptomonedas.\nTambién se introducen conceptos como almacenamiento en frío vs caliente, gestión de múltiples wallets y uso de firewalls.\nEs fundamental evaluar la reputación de plataformas y auditar contratos antes de interactuar con ellos.\nLas estafas tipo rug-pull, donde los desarrolladores desaparecen con los fondos, se evitan investigando el proyecto (whitepaper, equipo, liquidez bloqueada).\nAdemás, se recomienda monitorear tus direcciones con exploradores como Etherscan y mantener copias de seguridad cifradas de tus claves.\nEsta lección también explica cómo protegerse en redes públicas y en dispositivos móviles.'),
(15, 'Seguridad en Crypto Avanzado', 'Avanzada', 'A nivel avanzado, la seguridad en cripto se convierte en un campo altamente técnico.\nSe estudian ataques a contratos inteligentes como reentrancy, front-running, y exploits de oracle manipulation.\nTambién se analiza la arquitectura de exchanges descentralizados y los protocolos de auditoría.\nSe exploran herramientas como MythX, Slither y Oyente para analizar vulnerabilidades en el código de smart contracts.\nAdemás, se estudian técnicas de cifrado, firmas digitales y algoritmos como SHA-256 y Elliptic Curve Cryptography (ECC).\nOtro tema importante es la gestión de claves mediante bóvedas (vaults) y el uso de hardware especializado.\nFinalmente, se abordan temas de gobernanza de seguridad en DAOs, regulación legal y protección frente a amenazas de ingeniería social avanzada.\nEsta lección está orientada a desarrolladores y expertos en ciberseguridad que buscan asegurar todo el entorno cripto.');

-- INSERTS PREGUNTAS (usando id_leccion correspondiente)
INSERT INTO pregunta(id_leccion, texto_pregunta) VALUES

-- Preguntas block chain basico
(1, '¿Qué es una blockchain?'),
(1, '¿Cuál es el principal beneficio de la descentralización en blockchain?'),
(1, '¿Qué tecnología permite verificar las transacciones en una blockchain?'),
(1, '¿Qué significa que los datos en blockchain son inmutables?'),
(1, '¿Quién controla la red en una blockchain pública?'),
(1, '¿Qué es un bloque dentro de la blockchain?'),
(1, '¿Cuál es una característica clave de la transparencia en blockchain?'),
(1, '¿Qué función cumple el consenso en blockchain?'),

-- Preguntas block chain Intermedio
(2, '¿Qué es una red de prueba (testnet) en blockchain?'),
(2, '¿Qué rol cumple la minería en las blockchains basadas en Proof of Work?'),
(2, '¿Qué ventaja tiene Proof of Stake sobre Proof of Work?'),
(2, '¿Qué es un fork en una blockchain?'),
(2, '¿Cuál es el objetivo principal de los nodos en una blockchain?'),
(2, '¿Qué significa que una blockchain sea permissionless?'),
(2, '¿Cuál es el propósito de un contrato inteligente?'),
(2, '¿Qué implica la escalabilidad en el contexto blockchain?'),

-- Preguntas block chain avanzado
(3, '¿Qué es una bifurcación (fork) en blockchain?'),
(3, '¿Qué diferencia a una bifurcación suave (soft fork) de una dura (hard fork)?'),
(3, '¿Cuál es el objetivo del mecanismo de consenso?'),
(3, '¿Qué es la prueba de participación (Proof of Stake)?'),
(3, '¿Qué papel juegan los nodos completos en blockchain?'),
(3, '¿Qué representa la escalabilidad en una red blockchain?'),
(3, '¿Cuál es una desventaja del mecanismo Proof of Work?'),
(3, '¿Qué solución se propone para mejorar la escalabilidad de Ethereum?'),

-- Preguntas cripto momedas basicas
(4, '¿Qué es una criptomoneda?'),
(4, '¿Cuál fue la primera criptomoneda?'),
(4, '¿Qué función cumple Ethereum además de ser criptomoneda?'),
(4, '¿Qué característica principal tienen las criptomonedas?'),
(4, '¿Qué es un wallet o billetera digital?'),
(4, '¿Cuál es la función de Binance Coin (BNB)?'),
(4, '¿Por qué las criptomonedas son consideradas descentralizadas?'),
(4, '¿Qué se necesita para realizar una transacción con criptomonedas?'),

-- Preguntas critpo monedas medio
(5, '¿Qué es la volatilidad en criptomonedas?'),
(5, '¿Qué es un exchange?'),
(5, '¿Cuál es el objetivo del análisis técnico en criptomonedas?'),
(5, '¿Qué son las altcoins?'),
(5, '¿Qué significa stablecoin?'),
(5, '¿Qué es el market cap o capitalización de mercado?'),
(5, '¿Por qué es importante la liquidez de una criptomoneda?'),
(5, '¿Qué función cumple un whitepaper en una cripto?'),

-- Preguntas crypto monedas avanzado
(6, '¿Qué es una DAO en el contexto de criptomonedas?'),
(6, '¿Qué implica el staking en blockchain?'),
(6, '¿Qué es un token de gobernanza?'),
(6, '¿Qué representa la interoperabilidad entre blockchains?'),
(6, '¿Qué significa "tokenomics"?'),
(6, '¿Qué son las soluciones Layer 2?'),
(6, '¿Qué ventaja tienen las blockchains con contratos inteligentes?'),
(6, '¿Qué riesgo puede implicar el uso de DApps no auditadas?'),

-- Preguntas NFT basico
(7, '¿Qué significa NFT?'),
(7, '¿Qué hace único a un NFT?'),
(7, '¿Cuál es una plataforma popular para comprar NFTs?'),
(7, '¿Qué blockchain es más usada para NFTs?'),
(7, '¿Qué puede representar un NFT?'),
(7, '¿Qué diferencia hay entre un NFT y una criptomoneda?'),
(7, '¿Cómo se prueba la propiedad de un NFT?'),
(7, '¿Qué rol tiene la metadata en un NFT?'),

-- Preguntas NFT intermedio
(8, '¿Qué es un NFT de utilidad?'),
(8, '¿Qué es una whitelist en proyectos NFT?'),
(8, '¿Qué papel juega la comunidad en un proyecto NFT?'),
(8, '¿Qué es la “roadmap” de un proyecto NFT?'),
(8, '¿Qué significa hacer staking con NFTs?'),
(8, '¿Qué es un NFT dinámico?'),
(8, '¿Qué función cumple el arte en un NFT?'),
(8, '¿Qué es el “reveal” en una colección NFT?'),

-- Pregunta NFT avanzado
(9, '¿Qué es el minting de un NFT?'),
(9, '¿Qué es una colección de NFTs?'),
(9, '¿Qué ventaja ofrecen los NFTs en videojuegos?'),
(9, '¿Qué es un contrato inteligente en NFTs?'),
(9, '¿Qué es la escasez digital?'),
(9, '¿Qué es un "floor price" en una colección?'),
(9, '¿Qué tipo de derechos puede otorgar un NFT?'),
(9, '¿Qué riesgo puede haber en la inversión en NFTs?'),

-- Contratos inteligentes basico
(10, '¿Qué es un contrato inteligente?'),
(10, '¿Qué blockchain es conocida por permitir contratos inteligentes?'),
(10, '¿Qué lenguaje se usa comúnmente para programar smart contracts en Ethereum?'),
(10, '¿Qué ventaja tienen los contratos inteligentes sobre los contratos tradicionales?'),
(10, '¿Qué sucede cuando se cumplen las condiciones de un smart contract?'),
(10, '¿Qué es un "oracle" en contratos inteligentes?'),
(10, '¿Pueden modificarse los smart contracts una vez desplegados?'),
(10, '¿Qué riesgo tienen los contratos inteligentes mal codificados?'),

-- Lección 11: Contratos inteligentes medio
(11, '¿Qué función tiene require() en Solidity?'),
(11, '¿Cuál de los siguientes entornos permite desarrollar y desplegar contratos directamente en el navegador?'),
(11, '¿Qué biblioteca es recomendada para implementar contratos seguros y reutilizables?'),
(11, '¿Qué herramienta se utiliza para interactuar con contratos inteligentes desde JavaScript?'),
(11, '¿Qué ocurre si un contrato consume más gas del límite establecido?'),
(11, '¿Qué instrucción se utiliza para revertir manualmente una transacción y devolver el gas no utilizado?'),
(11, '¿Qué componente define los datos públicos almacenados en un contrato?'),
(11, '¿Cuál de estas estructuras permite ejecutar código basado en condiciones?'),

-- Lección 12: Contratos inteligentes avanzado
(12, '¿Qué ataque permite que un contrato llame repetidamente a otro antes de que finalice una transacción?'),
(12, '¿Qué patrón permite actualizar un contrato sin cambiar su dirección?'),
(12, '¿Cuál es el propósito principal de un oráculo en blockchain?'),
(12, '¿Qué estándar de token permite representar activos únicos?'),
(12, '¿Qué protocolo permite almacenar contenido de forma descentralizada?'),
(12, '¿Cuál es un objetivo clave al auditar un contrato inteligente?'),
(12, '¿Qué biblioteca facilita la integración de contratos con JavaScript?'),
(12, '¿Qué organización permite la gobernanza descentralizada de proyectos?'),

-- Lección 13: Seguridad en cripto básica
(13, '¿Qué es una clave privada en una wallet?'),
(13, '¿Qué tipo de wallet se recomienda por su seguridad?'),
(13, '¿Qué práctica es clave para evitar ataques de phishing?'),
(13, '¿Qué es 2FA?'),
(13, '¿Qué debes evitar en redes sociales?'),
(13, '¿Qué pasa si compartes tu frase semilla?'),
(13, '¿Cuál es la función de una clave pública?'),
(13, '¿Qué conexión se recomienda para acceder a un exchange?'),

-- Lección 14: Seguridad en cripto intermedio
(14, '¿Qué es un ataque "man in the middle"?'),
(14, '¿Qué diferencia principal hay entre almacenamiento en frío y caliente?'),
(14, '¿Qué herramienta se usa para monitorear transacciones en la blockchain?'),
(14, '¿Qué precaución ayuda a evitar un rug-pull?'),
(14, '¿Qué se recomienda para proteger claves privadas?'),
(14, '¿Qué es un firewall en el contexto cripto?'),
(14, '¿Por qué es importante auditar un contrato inteligente?'),
(14, '¿Qué tipo de malware puede robar tus criptomonedas?'),

-- Lección 15: Seguridad en cripto avanzado
(15, '¿Qué herramienta sirve para detectar errores en contratos inteligentes?'),
(15, '¿Qué algoritmo usa Bitcoin para hashing?'),
(15, '¿Qué ataque se basa en modificar los datos que proporciona un oráculo?'),
(15, '¿Qué permite la criptografía de curva elíptica (ECC)?'),
(15, '¿Qué es una vault en seguridad cripto?'),
(15, '¿Qué ataque ocurre cuando se adelanta una transacción con conocimiento previo?'),
(15, '¿Qué es MythX?'),
(15, '¿Qué estudia la gobernanza en DAOs?');

INSERT INTO opcion_respuesta (id_pregunta, texto_opcion, es_correcta) VALUES
-- BlockChain Basico respuestas
(1, 'Una base de datos central controlada por gobiernos', FALSE),
(1, 'Una red descentralizada que registra datos inmutables', TRUE),
(1, 'Un sistema de archivos locales compartidos', FALSE),

(2, 'Permite distribuir el poder entre los participantes', TRUE),
(2, 'Permite que una sola entidad administre la red', FALSE),
(2, 'Evita compartir información entre usuarios', FALSE),

(3, 'Reconocimiento facial', FALSE),
(3, 'Algoritmos de consenso como Proof of Work', TRUE),
(3, 'Archivos PDF cifrados', FALSE),

(4, 'Que los bloques pueden eliminarse fácilmente', FALSE),
(4, 'Que los datos no pueden modificarse una vez registrados', TRUE),
(4, 'Que los datos son almacenados en papel', FALSE),

(5, 'Los bancos centrales', FALSE),
(5, 'La comunidad de nodos distribuida', TRUE),
(5, 'El servidor principal de la red', FALSE),

(6, 'Una red social especializada en criptomonedas', FALSE),
(6, 'Una unidad que contiene información de transacciones', TRUE),
(6, 'Un archivo multimedia digital', FALSE),

(7, 'Oculta todos los movimientos económicos', FALSE),
(7, 'Permite a cualquiera auditar las transacciones', TRUE),
(7, 'Impide que se compartan los datos', FALSE),

(8, 'Acelera la creación de bloques nuevos', FALSE),
(8, 'Ayuda a los nodos a acordar qué bloques son válidos', TRUE),
(8, 'Evita que se conecten nuevos usuarios', FALSE),

-- BlockChain Intermedio respuestas
(9, 'Una red usada por gobiernos', FALSE),
(9, 'Una red utilizada para hacer pruebas sin usar criptomonedas reales', TRUE),
(9, 'Una red para minar más rápido', FALSE),

(10, 'Verificar y añadir nuevas transacciones a la blockchain', TRUE),
(10, 'Eliminar bloques obsoletos', FALSE),
(10, 'Hackear la red para obtener recompensas', FALSE),

(11, 'Requiere hardware más caro', FALSE),
(11, 'Consume menos energía al no necesitar resolver problemas matemáticos complejos', TRUE),
(11, 'Depende solo de los bancos', FALSE),

(12, 'Un tipo de transacción rápida', FALSE),
(12, 'Una bifurcación en el código o reglas de una blockchain', TRUE),
(12, 'Un error de la red', FALSE),

(13, 'Crear nuevas criptomonedas', FALSE),
(13, 'Almacenar bloques antiguos', FALSE),
(13, 'Validar y distribuir la información en la red', TRUE),

(14, 'Solo puede ser usada por empresas', FALSE),
(14, 'Cualquiera puede participar sin permiso de una autoridad central', TRUE),
(14, 'Necesita aprobación del gobierno', FALSE),

(15, 'Ejecutar condiciones programadas automáticamente', TRUE),
(15, 'Limpiar la red de bloques corruptos', FALSE),
(15, 'Crear nuevas wallets', FALSE),

(16, 'La capacidad de una red de procesar un gran volumen de transacciones', TRUE),
(16, 'La habilidad de conectarse a otras blockchains', FALSE),
(16, 'La cantidad de nodos disponibles', FALSE),

-- Block chain avanzado respuestas
(17, 'Una mejora automática del software', FALSE),
(17, 'Una división de la cadena de bloques en dos versiones', TRUE),
(17, 'Un ataque DDoS a la red', FALSE),

(18, 'Una soft fork cambia el algoritmo de consenso', FALSE),
(18, 'Una soft fork es compatible con versiones anteriores, una hard fork no', TRUE),
(18, 'No hay diferencia entre ambas', FALSE),

(19, 'Aumentar el precio de los tokens', FALSE),
(19, 'Asegurar que todos los nodos estén de acuerdo en el estado de la red', TRUE),
(19, 'Limitar la velocidad de las transacciones', FALSE),

(20, 'Es una forma de almacenar criptomonedas', FALSE),
(20, 'Es un mecanismo donde los validadores son elegidos según sus tokens', TRUE),
(20, 'Es una técnica de marketing', FALSE),

(21, 'Transmiten spam en la red', FALSE),
(21, 'Almacenan toda la blockchain y validan transacciones', TRUE),
(21, 'Solo minan bloques', FALSE),

(22, 'La facilidad con la que se hackea la red', FALSE),
(22, 'La capacidad de manejar más transacciones por segundo', TRUE),
(22, 'El precio por usar la red', FALSE),

(23, 'Es muy ecológico', FALSE),
(23, 'Consume mucha energía', TRUE),
(23, 'No necesita hardware especializado', FALSE),

(24, 'Cambiar a Proof of Work', FALSE),
(24, 'Implementar Ethereum 2.0 con Proof of Stake y sharding', TRUE),
(24, 'Eliminar los contratos inteligentes', FALSE),

-- Respuestas criptomonedas basicas
(25, 'Dinero físico usado en internet', FALSE),
(25, 'Activo digital que funciona como medio de intercambio', TRUE),
(25, 'Un archivo PDF encriptado', FALSE),

(26, 'Ethereum', FALSE),
(26, 'Bitcoin', TRUE),
(26, 'Litecoin', FALSE),

(27, 'Sirve únicamente para pagar bienes', FALSE),
(27, 'Permite ejecutar contratos inteligentes', TRUE),
(27, 'Es solo una versión mejorada de Bitcoin', FALSE),

(28, 'Está controlada por un banco central', FALSE),
(28, 'Funciona sin necesidad de un ente central', TRUE),
(28, 'Depende de una única empresa', FALSE),

(29, 'Una cuenta bancaria', FALSE),
(29, 'Una aplicación que almacena claves para gestionar criptomonedas', TRUE),
(29, 'Un documento legal', FALSE),

(30, 'Es una copia de Bitcoin', FALSE),
(30, 'Se usa dentro del ecosistema de Binance', TRUE),
(30, 'Es un juego NFT', FALSE),

(31, 'Porque están reguladas por gobiernos', FALSE),
(31, 'Porque no dependen de una autoridad central', TRUE),
(31, 'Porque se imprimen como el dinero fiat', FALSE),

(32, 'Una tarjeta de crédito', FALSE),
(32, 'Una dirección de wallet y acceso a internet', TRUE),
(32, 'Un número telefónico vinculado', FALSE),

-- Respuestas cripto monedas intermedio
(33, 'La estabilidad del precio en el tiempo', FALSE),
(33, 'La rapidez con la que cambia el precio de una criptomoneda', TRUE),
(33, 'El volumen de compra diaria', FALSE),

(34, 'Un software de minería', FALSE),
(34, 'Plataforma para comprar, vender o intercambiar criptomonedas', TRUE),
(34, 'Un tipo de wallet', FALSE),

(35, 'Predecir movimientos de precio con base en patrones históricos', TRUE),
(35, 'Crear nuevas criptomonedas', FALSE),
(35, 'Traducir monedas a distintos idiomas', FALSE),

(36, 'Monedas físicas en circulación', FALSE),
(36, 'Todas las criptos que no son Bitcoin', TRUE),
(36, 'Criptos que valen menos de un dólar', FALSE),

(37, 'Cripto con precio volátil', FALSE),
(37, 'Cripto cuyo valor está vinculado a un activo estable', TRUE),
(37, 'Una moneda que cambia de nombre frecuentemente', FALSE),

(38, 'La cantidad de monedas en el mercado secundario', FALSE),
(38, 'Valor total de todas las monedas en circulación', TRUE),
(38, 'El costo para minar una criptomoneda', FALSE),

(39, 'Para limitar la compra de activos', FALSE),
(39, 'Porque permite comprar o vender fácilmente sin afectar el precio', TRUE),
(39, 'Porque evita la inflación', FALSE),

(40, 'Es un documento para pagar impuestos', FALSE),
(40, 'Documento técnico que explica el proyecto cripto', TRUE),
(40, 'Una reseña de usuarios en internet', FALSE),

-- cripto monedas avanznadas

(41, 'Una aplicación de mensajería', FALSE),
(41, 'Organización autónoma descentralizada que toma decisiones sin jerarquías centrales', TRUE),
(41, 'Un tipo de wallet avanzada', FALSE),

(42, 'Una forma de gastar tokens', FALSE),
(42, 'Bloquear tokens como forma de apoyar la red y obtener recompensas', TRUE),
(42, 'Eliminar tokens permanentemente', FALSE),

(43, 'Permite elegir el color de los tokens', FALSE),
(43, 'Otorga derecho a votar decisiones en un proyecto cripto', TRUE),
(43, 'Es una función de seguridad', FALSE),

(44, 'Transferir dinero a bancos', FALSE),
(44, 'Capacidad de comunicación entre diferentes blockchains', TRUE),
(44, 'Multiplicar monedas en un wallet', FALSE),

(45, 'Un conjunto de reglas sobre minería', FALSE),
(45, 'Modelo económico que define el uso y distribución de un token', TRUE),
(45, 'Un sistema de rastreo de wallets', FALSE),

(46, 'Aplicaciones para trading', FALSE),
(46, 'Soluciones que mejoran la velocidad y escalabilidad de blockchains existentes', TRUE),
(46, 'Extensiones de navegador', FALSE),

(47, 'Ofrecen mayor transparencia y automatización', TRUE),
(47, 'Permiten hacer transacciones sin internet', FALSE),
(47, 'Solo sirven para juegos', FALSE),

(48, 'Son totalmente seguros por defecto', FALSE),
(48, 'Pueden tener vulnerabilidades que afecten fondos del usuario', TRUE),
(48, 'Funcionan únicamente con Bitcoin', FALSE),

-- respuestas nft principiantes
(49, 'Non-Fungible Token', TRUE),
(49, 'New Financial Tool', FALSE),
(49, 'Non-Financial Technology', FALSE),

(50, 'Su valor en dinero', FALSE),
(50, 'Su unicidad y no intercambiabilidad', TRUE),
(50, 'Que solo se pueden minar una vez al año', FALSE),

(51, 'Coinbase', FALSE),
(51, 'OpenSea', TRUE),
(51, 'MetaMask', FALSE),

(52, 'Ethereum', TRUE),
(52, 'Bitcoin', FALSE),
(52, 'Litecoin', FALSE),

(53, 'Solo arte digital', FALSE),
(53, 'Arte, música, objetos de videojuegos, etc.', TRUE),
(53, 'Documentos bancarios', FALSE),

(54, 'Ambos son únicos', FALSE),
(54, 'El NFT es único, la cripto es intercambiable', TRUE),
(54, 'El NFT solo se usa en videojuegos', FALSE),

(55, 'A través de un hash', FALSE),
(55, 'Por su registro en la blockchain', TRUE),
(55, 'Con un contrato firmado en papel', FALSE),

(56, 'Controlar el precio del NFT', FALSE),
(56, 'Describir atributos del NFT como nombre o imagen', TRUE),
(56, 'Establecer reglas para intercambios físicos', FALSE),

-- respuestas nft intermedios
(57, 'NFT usado únicamente como imagen de perfil', FALSE),
(57, 'NFT que proporciona acceso a beneficios o servicios exclusivos', TRUE),
(57, 'NFT que cambia de dueño automáticamente', FALSE),

(58, 'Lista negra de usuarios que no pueden comprar', FALSE),
(58, 'Lista de acceso anticipado a la compra de NFTs', TRUE),
(58, 'Direcciones bloqueadas de la blockchain', FALSE),

(59, 'Solo se encarga del marketing', FALSE),
(59, 'Influye en el éxito y valor del proyecto', TRUE),
(59, 'No tiene importancia real', FALSE),

(60, 'Documento legal del NFT', FALSE),
(60, 'Plan de desarrollo del proyecto en el tiempo', TRUE),
(60, 'Contrato de compra del NFT', FALSE),

(61, 'Eliminar un NFT de circulación', FALSE),
(61, 'Bloquear un NFT a cambio de recompensas', TRUE),
(61, 'Transferir un NFT automáticamente', FALSE),

(62, 'NFT que evoluciona o cambia con el tiempo o condiciones', TRUE),
(62, 'NFT con múltiples dueños', FALSE),
(62, 'NFT con valor fijo para siempre', FALSE),

(63, 'Solo es decorativo', FALSE),
(63, 'Aporta identidad visual y valor percibido al NFT', TRUE),
(63, 'No influye en el mercado', FALSE),

(64, 'Es la destrucción de los NFTs sin usar', FALSE),
(64, 'Es cuando los NFTs ocultos son mostrados al comprador', TRUE),
(64, 'Es cuando los NFT se hacen públicos por primera vez', FALSE),

-- Respuesas NFT avanzados
(65, 'Eliminar un NFT de la blockchain', FALSE),
(65, 'Proceso de crear y registrar un NFT en la blockchain', TRUE),
(65, 'Hacer copias de un NFT', FALSE),

(66, 'Una única obra NFT', FALSE),
(66, 'Grupo de NFTs relacionados, lanzados bajo un mismo proyecto', TRUE),
(66, 'Un archivo físico asociado a un NFT', FALSE),

(67, 'Desbloqueo de tarjetas de crédito', FALSE),
(67, 'Propiedad de activos dentro del juego', TRUE),
(67, 'Creación de personajes automáticos', FALSE),

(68, 'Documento legal asociado al NFT', FALSE),
(68, 'Programa que define cómo se comporta un NFT en la blockchain', TRUE),
(68, 'Licencia de usuario del arte digital', FALSE),

(69, 'Cantidad infinita de copias', FALSE),
(69, 'Limitación intencional de la cantidad disponible', TRUE),
(69, 'Disponibilidad global', FALSE),

(70, 'Precio mínimo al que se pueden vender todos los NFTs', FALSE),
(70, 'Precio mínimo al que se ofrece un NFT en el mercado secundario', TRUE),
(70, 'Costo de creación de un NFT', FALSE),

(71, 'Derechos de propiedad física del objeto', FALSE),
(71, 'Derechos digitales como acceso exclusivo o voto en decisiones', TRUE),
(71, 'Licencias de minería', FALSE),

(72, 'Garantía de aumento de valor', FALSE),
(72, 'Pérdida de valor o fraude si no se verifica su autenticidad', TRUE),
(72, 'Obligación legal de compra', FALSE),

-- Contratos inteligentes basicos
(73, 'Documento legal digitalizado', FALSE),
(73, 'Programa autoejecutable que se activa cuando se cumplen condiciones', TRUE),
(73, 'Un archivo PDF encriptado', FALSE),

(74, 'Ripple', FALSE),
(74, 'Ethereum', TRUE),
(74, 'Bitcoin Cash', FALSE),

(75, 'Python', FALSE),
(75, 'Solidity', TRUE),
(75, 'C++', FALSE),

(76, 'Mayor coste legal', FALSE),
(76, 'Ejecución automática sin intermediarios', TRUE),
(76, 'Menor privacidad', FALSE),

(77, 'Se detienen para validación manual', FALSE),
(77, 'Se ejecuta automáticamente la acción programada', TRUE),
(77, 'Envían un correo de aviso', FALSE),

(78, 'Empresa que guarda copias de contratos', FALSE),
(78, 'Fuente externa de datos que alimenta un contrato inteligente', TRUE),
(78, 'App para firmar contratos', FALSE),

(79, 'Sí, siempre pueden cambiarse', FALSE),
(79, 'No, son inmutables salvo que se diseñen actualizables', TRUE),
(79, 'Solo los puede cambiar el creador sin condiciones', FALSE),

(80, 'No pasa nada', FALSE),
(80, 'Pueden provocar pérdidas económicas y ser explotados', TRUE),
(80, 'Solo afectan la velocidad de la blockchain', FALSE),

-- Contratos inteligentes intermedio

(81, 'Wallet conectada a internet permanentemente', FALSE),
(81, 'Wallet desconectada de internet, más segura', TRUE),
(81, 'Wallet en redes sociales', FALSE),

(82, 'Método legítimo para recuperar claves', FALSE),
(82, 'Suplantación para robar información o activos', TRUE),
(82, 'Técnica para minar', FALSE),

(83, 'Una sola contraseña', FALSE),
(83, 'Método de verificación adicional mediante código externo', TRUE),
(83, 'Un tipo de wallet física', FALSE),

(84, 'Mayor velocidad de conexión', FALSE),
(84, 'Mayor riesgo de hackeo y robo de datos', TRUE),
(84, 'Acceso sin contraseña', FALSE),

(85, 'La dirección pública', FALSE),
(85, 'Frase de respaldo que permite recuperar una wallet', TRUE),
(85, 'Un número de transacción', FALSE),

(86, 'Venta gradual para obtener liquidez', FALSE),
(86, 'Manipulación del precio para vender en alto y dejar pérdidas a otros', TRUE),
(86, 'Actualización de software en exchanges', FALSE),

(87, 'Dejar la gestión a una plataforma central', FALSE),
(87, 'Guardar tus llaves privadas sin intermediarios', TRUE),
(87, 'Compartir tus claves por seguridad', FALSE),

(88, 'Contrato sin código fuente', FALSE),
(88, 'Contrato con código oculto para robar o vulnerar', TRUE),
(88, 'Contrato auditado por la comunidad', FALSE),

-- Contatos intelifentes avanzados
(89, 'Overflow', FALSE),
(89, 'Reentrancy', TRUE),
(89, 'Oráculo falso', FALSE),

(90, 'Delegated Storage', FALSE),
(90, 'Proxy pattern', TRUE),
(90, 'Gas Optimization', FALSE),

(91, 'Verificar identidad del minero', FALSE),
(91, 'Proveer datos del mundo real a contratos', TRUE),
(91, 'Eliminar fees de gas', FALSE),

(92, 'ERC-20', FALSE),
(92, 'ERC-721', TRUE),
(92, 'ERC-1155 para tokens fungibles', FALSE),

(93, 'HTTP', FALSE),
(93, 'IPFS', TRUE),
(93, 'FTP', FALSE),

(94, 'Aumentar la velocidad de ejecución', FALSE),
(94, 'Detectar vulnerabilidades', TRUE),
(94, 'Crear tokens más rápido', FALSE),

(95, 'Node.js', FALSE),
(95, 'Ethers.js', TRUE),
(95, 'Bootstrap.js', FALSE),

(96, 'DAO', TRUE),
(96, 'Proof of Work', FALSE),
(96, 'NFTs', FALSE),

-- seguridad crypto basica
(97, 'Una contraseña temporal', FALSE),
(97, 'El acceso único a tus fondos', TRUE),
(97, 'Un número de cuenta bancaria', FALSE),

(98, 'Hot wallet', FALSE),
(98, 'Cold wallet', TRUE),
(98, 'Multisig wallet online', FALSE),

(99, 'Actualizar el navegador', FALSE),
(99, 'Verificar siempre URLs', TRUE),
(99, 'Abrir todos los enlaces recibidos', FALSE),

(100, 'Doble validación con código y autenticador', TRUE),
(100, 'Revisión manual de IPs', FALSE),
(100, 'Desconexión automática', FALSE),

(101, 'Publicar dirección pública', FALSE),
(101, 'Compartir datos sensibles', TRUE),
(101, 'Comentar sobre el mercado', FALSE),

(102, 'Te protege frente a ataques', FALSE),
(102, 'Pueden robar tus fondos', TRUE),
(102, 'Te permite recuperar tokens', FALSE),

(103, 'Verificar la identidad del usuario', FALSE),
(103, 'Recibir transacciones', TRUE),
(103, 'Asegurar el contrato', FALSE),

(104, 'Red pública abierta', FALSE),
(104, 'Red segura y VPN', TRUE),
(104, 'Uso de proxies sin cifrado', FALSE),

-- seguridad cripto intermedia
(105, 'Hackeo del servidor central', FALSE),
(105, 'Interceptar y modificar comunicaciones', TRUE),
(105, 'Cambio de clave privada', FALSE),

(106, 'Conectividad constante', FALSE),
(106, 'El frío no está conectado a internet', TRUE),
(106, 'Mayor uso de CPU', FALSE),

(107, 'VPN', FALSE),
(107, 'Explorador de bloques', TRUE),
(107, 'Smart contract IDE', FALSE),

(108, 'Estudiar los whitepapers', FALSE),
(108, 'Revisar el código y auditorías del proyecto', TRUE),
(108, 'Hacer staking', FALSE),

(109, 'Guardar en la nube', FALSE),
(109, 'Uso de hardware wallets', TRUE),
(109, 'Subir a GitHub', FALSE),

(110, 'Sistema de minería', FALSE),
(110, 'Barreras que protegen de accesos no autorizados', TRUE),
(110, 'Compilador de código', FALSE),

(111, 'Optimizar el contrato', FALSE),
(111, 'Para prevenir fallos y exploits', TRUE),
(111, 'Enviar tokens rápidamente', FALSE),

(112, 'Rootkit', FALSE),
(112, 'Keylogger', TRUE),
(112, 'Debugger', FALSE),

-- seguridad cripto avanzado
(113, 'Metamask', FALSE),
(113, 'Slither', TRUE),
(113, 'OpenSea', FALSE),

(114, 'AES-128', FALSE),
(114, 'SHA-256', TRUE),
(114, 'MD5', FALSE),

(115, 'Cross-site scripting', FALSE),
(115, 'Oracle manipulation', TRUE),
(115, 'Backdoor en el contrato', FALSE),

(116, 'Controlar precios', FALSE),
(116, 'Firmas digitales seguras', TRUE),
(116, 'Minar nuevos bloques', FALSE),

(117, 'Un contrato con errores', FALSE),
(117, 'Almacenamiento seguro de fondos', TRUE),
(117, 'Una dirección pública', FALSE),

(118, 'Sybil attack', FALSE),
(118, 'Front-running', TRUE),
(118, 'Replay attack', FALSE),

(119, 'Editor de Solidity', FALSE),
(119, 'Herramienta de análisis de seguridad para Solidity', TRUE),
(119, 'Compilador de JavaScript', FALSE),

(120, 'El marketing del proyecto', FALSE),
(120, 'Cómo se toman decisiones en organizaciones descentralizadas', TRUE),
(120, 'El minado de tokens', FALSE);

INSERT INTO usuario_leccion (correo_jugador, id_leccion, veces_completada) VALUES
('emanuelhdz01@gmail.com', 1, 1),
('emanuelhdz01@gmail.com', 2, 1),
('andrea@gmail.com', 3, 2),
('luisr@gmail.com', 4, 1),
('camitorres@gmail.com', 5, 1);

-- Respuestas de usuarios
INSERT INTO respuesta_usuario (correo_jugador, id_pregunta, id_opcion_seleccionada) VALUES
('emanuelhdz01@gmail.com', 1, 2),
('emanuelhdz01@gmail.com', 2, 5),
('andrea@gmail.com', 3, 8),
('andrea@gmail.com', 4, 11),
('luisr@gmail.com', 5, 14),
('camitorres@gmail.com', 6, 17);

-- Objetos base datos
DELIMITER $$
CREATE PROCEDURE CalcularDuracionSesion(IN correo_input VARCHAR(100))
BEGIN
    DECLARE horas_actuales DECIMAL(5,2);
    DECLARE minutos_jugados INT;
    DECLARE nuevas_horas DECIMAL(5,2);

    -- Calcular diferencia en minutos
    SELECT TIMESTAMPDIFF(MINUTE, ultimoInicioSesion, ultimoCierreSesion)
        INTO minutos_jugados
        FROM usuario
        WHERE correo_jugador = correo_input;

    -- Obtener horas jugadas actuales
    SELECT tiempoJugado INTO horas_actuales
        FROM usuario
        WHERE correo_jugador = correo_input;

    -- Calcular nuevas horas con redondeo a 2 decimales
    SET nuevas_horas = ROUND(minutos_jugados / 60, 2);

    -- Actualizar el total sumando las nuevas
    UPDATE usuario
    SET tiempoJugado = ROUND(horas_actuales + nuevas_horas, 2)
    WHERE correo_jugador = correo_input;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE RegistrarUsuario (
    IN p_nombre VARCHAR(20),
    IN p_apellido VARCHAR(20),
    IN p_fecha_nacimiento DATE,
    IN p_pais VARCHAR(20),
    IN p_correo_jugador VARCHAR(50),
    IN p_password VARCHAR(25)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al registrar el usuario';
    END;

    START TRANSACTION;

    INSERT INTO usuario (
        nombre, apellido, fecha_de_nacimiento, pais,
        correo_jugador, password, monedas
    ) VALUES (
        p_nombre, p_apellido, p_fecha_nacimiento, p_pais,
        p_correo_jugador, p_password, 20
    );

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$
CREATE PROCEDURE ObtenerDatosMascotaConCalculo(
  IN p_correo_jugador VARCHAR(100)
)
BEGIN
  DECLARE v_nombre VARCHAR(100);
  DECLARE v_hambre INT;
  DECLARE v_felicidad INT;
  DECLARE v_energia INT;
  DECLARE v_nivel INT;
  DECLARE v_fechaUltimaAlimentacion DATETIME;
  DECLARE v_fechaUltimoJuego DATETIME;
  DECLARE v_ultimoInicioSesion DATETIME;
  DECLARE v_nuevaHambre INT;
  DECLARE v_nuevaFelicidad INT;
  DECLARE v_horasSinComer INT;
  DECLARE v_horasSinJugar INT;

  -- Obtener los datos originales
  SELECT m.nombre, m.hambre, m.felicidad, m.energia, m.nivel,
         m.fechaUltimaAlimentacion, m.fechaUltimoJuego, u.ultimoInicioSesion
  INTO v_nombre, v_hambre, v_felicidad, v_energia, v_nivel,
       v_fechaUltimaAlimentacion, v_fechaUltimoJuego, v_ultimoInicioSesion
  FROM mascota m
  JOIN usuario u ON m.correo_jugador = u.correo_jugador
  WHERE m.correo_jugador = p_correo_jugador;

  -- Calcular diferencia en horas
  SET v_horasSinComer = TIMESTAMPDIFF(HOUR, v_fechaUltimaAlimentacion, v_ultimoInicioSesion);
  SET v_horasSinJugar = TIMESTAMPDIFF(HOUR, v_fechaUltimoJuego, v_ultimoInicioSesion);

  -- Aplicar decremento sin bajar de 0
  SET v_nuevaHambre = GREATEST(0, v_hambre - v_horasSinComer);
  SET v_nuevaFelicidad = GREATEST(0, v_felicidad - v_horasSinJugar);

  -- Retornar los valores
  SELECT v_nombre AS nombre, v_nuevaHambre AS hambre, v_nuevaFelicidad AS felicidad,
         v_energia AS energia, v_nivel AS nivel;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE ValidarCredencialesYActualizarInicio(
  IN p_correo VARCHAR(100),
  IN p_password VARCHAR(100)
)
BEGIN
  DECLARE existe_usuario INT;

  -- Verifica si existe el usuario con esa contraseña
  SELECT COUNT(*) INTO existe_usuario
  FROM usuario
  WHERE correo_jugador = p_correo AND password = p_password;

  -- Si existe, actualiza la fecha de inicio y retorna 'Correcto'
  IF existe_usuario = 1 THEN
    UPDATE usuario SET ultimoInicioSesion = NOW()
    WHERE correo_jugador = p_correo;

    SELECT 'Correcto' AS respuesta;
  ELSE
    SELECT 'Incorrecto' AS respuesta;
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE ObtenerDatosUsuario(
    IN p_correo VARCHAR(100)
)
BEGIN
    SELECT monedas, cantidadJuguete, cantidadComida, rachaDias
    FROM usuario
    WHERE correo_jugador = p_correo;
END$$

DELIMITER ;

DELIMITER $$
CREATE PROCEDURE GuardarSesionCompleta(
    IN p_correo_jugador VARCHAR(100),
    IN p_monedas INT,
    IN p_comida INT,
    IN p_juguetes INT,
    IN p_racha INT,
    IN p_hambre INT,
    IN p_felicidad INT,
    IN p_energia INT,
    IN p_nivel INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- Actualizar tabla usuario
    UPDATE usuario
    SET monedas = p_monedas,
        cantidadComida = p_comida,
        cantidadJuguete = p_juguetes,
        rachaDias = p_racha,
        ultimoCierreSesion = NOW()
    WHERE correo_jugador = p_correo_jugador;

    -- Actualizar tabla mascota
    UPDATE mascota
    SET hambre = p_hambre,
        felicidad = p_felicidad,
        energia = p_energia,
        nivel = p_nivel
    WHERE correo_jugador = p_correo_jugador;

    -- Llamar a procedimiento existente para calcular duración
    CALL CalcularDuracionSesion(p_correo_jugador);

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE ActualizarFechaMascota(
    IN correo VARCHAR(100),
    IN tipo CHAR(1)
)
BEGIN
    DECLARE campoFecha VARCHAR(50);

    -- Validación del tipo
    IF tipo = 'A' THEN
        SET campoFecha = 'fechaUltimaAlimentacion';
    ELSEIF tipo = 'J' THEN
        SET campoFecha = 'fechaUltimoJuego';
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo inválido. Usa A o J.';
    END IF;

    -- Variable de sesión para usar en EXECUTE
    SET @correo = correo;

    -- SQL dinámico
    SET @sql = CONCAT('UPDATE mascota SET ', campoFecha, ' = NOW() WHERE correo_jugador = ?');
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING @correo;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

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