import express from 'express';
import path from 'path';
import mysql from 'mysql2/promise';
import session from 'express-session';
import bodyParser from 'body-parser';

let connection;

const app = express();
const port = process.env.PORT ?? 8080;
const ipAdress = process.env.C9_HOSTNAME ?? 'localhost';

app.set('view engine', 'ejs');
app.use(express.static('public'));

// Habilitar JSON en las peticiones
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.set('views', path.join(process.cwd(), 'views'));

// Middleware
app.use(express.static(path.join(process.cwd(), 'public')));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(session({
  secret: 'E679F2B24B86D6A74317265AD7E5D',
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000
  }
}));

// Conexión MySQL con mysql2/promise
let db;
(async () => {
  try {
    db = await mysql.createConnection({
      host: process.env.MYSQL_HOST,
      user: process.env.MYSQL_USER,
      password: process.env.MYSQL_PASSWORD,
      database: 'unity_redes'
    });
    console.log('Conectado a MySQL con mysql2/promise');
  } catch (err) {
    console.error('Error conectando a MySQL:', err);
    process.exit(1);
  }
})();

// Middleware de autenticación
const requireAuth = (req, res, next) => {
  if (req.session.admin) {
    next();
  } else {
    req.session.error = 'Debes iniciar sesión para acceder';
    res.redirect('/login');
  }
};

// Rutas de autenticación
app.get('/', (req, res) => {
  res.render('juego');
});

app.get('/login', (req, res) => {
  res.render('login', {
    error: req.session.error,
    success: req.session.success
  });
  req.session.error = null;
  req.session.success = null;
});

app.post('/login', async (req, res) => {
  const { correo_admin, password } = req.body;

  if (!correo_admin || !password) {
    req.session.error = 'Todos los campos son requeridos';
    return res.redirect('/login');
  }

  try {
    const [results] = await db.execute(
      'SELECT * FROM admin WHERE correo_admin = ? AND password = ?',
      [correo_admin, password]
    );

    if (results.length > 0) {
      req.session.admin = results[0];
      req.session.success = 'Bienvenida ' + results[0].correo_admin;
      return res.redirect('/index');
    } else {
      req.session.error = 'Credenciales incorrectas';
      return res.redirect('/login');
    }
  } catch (err) {
    console.error('Error en login:', err);
    req.session.error = 'Error del servidor';
    return res.redirect('/login');
  }
});

app.post('/logout', (req, res) => {
  req.session.destroy(err => {
    if (err) {
      console.error('Error al cerrar sesión:', err);
    }
    res.redirect('/');
  });
});

// Rutas protegidas
app.get('/index', requireAuth, (req, res) => {
  res.render('index', { admin: req.session.admin });
});

app.get('/lecciones', requireAuth, async (req, res) => {
  const idLeccion = 0;

  try {
    const [leccion] = await db.query(
      `SELECT id_leccion, nombre_leccion, dificultad, contenido
      FROM leccion
      WHERE id_leccion = ? LIMIT 1`, [idLeccion]
    );

    const [preguntasRaw] = await db.query(
      `SELECT p.id_pregunta, p.texto_pregunta, r.id_opcion, r.texto_opcion, r.es_correcta
      FROM pregunta p
      LEFT JOIN opcion_respuesta r ON p.id_pregunta = r.id_pregunta
      WHERE p.id_leccion = ?
      ORDER BY p.id_pregunta, r.id_opcion`, [idLeccion]
    );

    const preguntas = [];
    let currentPreguntaId = null;
    let preguntaActual = null;

    for (let row of preguntasRaw) {
      if (row.id_pregunta !== currentPreguntaId) {
        if (preguntaActual) preguntas.push(preguntaActual);
        preguntaActual = {
          texto_pregunta: row.texto_pregunta,
          opciones: []
        };
        currentPreguntaId = row.id_pregunta;
      }
      if (row.id_opcion) {
        preguntaActual.opciones.push({
          texto: row.texto_opcion,
          es_correcta: row.es_correcta
        });
      }
    }
    if (preguntaActual) preguntas.push(preguntaActual);

    while (preguntas.length < 6) {
      preguntas.push({
        texto_pregunta: '',
        opciones: [
          { texto: '', es_correcta: false },
          { texto: '', es_correcta: false },
          { texto: '', es_correcta: false }
        ]
      });
    }

    res.render('lecciones', {
      leccion: leccion[0] || { id_leccion: 0, nombre_leccion: '', dificultad: 'Básica', contenido: '' },
      preguntas,
      admin: req.session.admin,
      success: req.session.success,
      error: req.session.error
    });

    req.session.success = null;
    req.session.error = null;

  } catch (error) {
    console.error('Error en GET /lecciones:', error);
    req.session.error = 'Error al cargar el formulario';
    res.redirect('/index');
  }
});

// Ruta para actualizar la lección (POST) - Versión robusta
app.post('/lecciones', requireAuth, async (req, res) => {
  const { nombre_leccion, dificultad, contenido, preguntas = [] } = req.body;
  const idLeccion = 0;

  // Validación mejorada
  if (!nombre_leccion?.trim() || !dificultad || !contenido?.trim()) {
    req.session.error = 'Todos los campos son obligatorios';
    return res.redirect('/lecciones');
  }

  try {
    // Usamos INSERT ... ON DUPLICATE KEY UPDATE para mayor resiliencia
    await db.query(
      `INSERT INTO leccion (id_leccion, nombre_leccion, dificultad, contenido)
      VALUES (?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE
        nombre_leccion = VALUES(nombre_leccion),
        dificultad = VALUES(dificultad),
        contenido = VALUES(contenido)`,
      [idLeccion, nombre_leccion.trim(), dificultad, contenido.trim()]
    );

    // Eliminar preguntas y opciones anteriores
    const [preguntasExistentes] = await db.query(
      `SELECT id_pregunta FROM pregunta WHERE id_leccion = ?`, [idLeccion]
    );

    const idsPregunta = preguntasExistentes.map(p => p.id_pregunta);
    if (idsPregunta.length > 0) {
      await db.query(`DELETE FROM opcion_respuesta WHERE id_pregunta IN (?)`, [idsPregunta]);
      await db.query(`DELETE FROM pregunta WHERE id_leccion = ?`, [idLeccion]);
    }

    // Insertar nuevas preguntas
    for (const p of preguntas) {
      const [res] = await db.query(
        `INSERT INTO pregunta (id_leccion, texto_pregunta) VALUES (?, ?)`,
        [idLeccion, p.texto?.trim()]
      );
      const idPregunta = res.insertId;

      for (let i = 0; i < 3; i++) {
        const opcion = p.opciones?.[i]?.texto?.trim();
        const esCorrecta = parseInt(p.correcta) === i;
        if (opcion) {
          await db.query(
            `INSERT INTO opcion_respuesta (id_pregunta, texto_opcion, es_correcta) VALUES (?, ?, ?)`,
            [idPregunta, opcion, esCorrecta]
          );
        }
      }
    }

    await db.commit();
    req.session.success = '¡Lección y preguntas actualizadas correctamente!';
    res.redirect('/lecciones');
  } catch (error) {
    await db.rollback();
    console.error('Error en POST /lecciones:', error);
    req.session.error = 'Error al guardar los cambios';
    res.redirect('/lecciones');
  }
});

app.get('/estadisticas', requireAuth, async (req, res) => {
  // Consultas para estadísticas
  const queries = {
    stats: `SELECT
              COUNT(*) AS total_usuarios,
              IFNULL(SUM(tiempoJugado), 0) AS total_tiempo,
              IFNULL(AVG(tiempoJugado), 0) AS promedio_tiempo,
              IFNULL(AVG(rachaDias), 0) AS promedio_racha,
              IFNULL(SUM(monedas), 0) AS total_monedas
            FROM usuario`,
    paises: `SELECT
              pais,
              IFNULL(SUM(tiempoJugado), 0) AS total_tiempo
             FROM usuario
             GROUP BY pais`,
    usuariosPorPais: `SELECT
                        pais,
                        COUNT(*) AS total_usuarios
                      FROM usuario
                      GROUP BY pais`,
    usuariosPorEdad: `SELECT
                        edad,
                        COUNT(*) AS total_usuarios
                      FROM usuario
                      GROUP BY edad
                      ORDER BY edad ASC`,
    horasPorDia: `SELECT
                    DATE(ultimoInicioSesion) AS fecha,
                    IFNULL(SUM(tiempoJugado), 0) AS horas_totales
                  FROM usuario
                  WHERE ultimoInicioSesion IS NOT NULL
                  GROUP BY DATE(ultimoInicioSesion)
                  ORDER BY fecha ASC`,
    conexionesPorHora: `SELECT
                          HOUR(ultimoInicioSesion) AS hora,
                          COUNT(*) AS total_conexiones
                        FROM usuario
                        WHERE ultimoInicioSesion IS NOT NULL
                        GROUP BY HOUR(ultimoInicioSesion)
                        ORDER BY hora ASC`,
    usuariosPorGenero: `SELECT
                          genero,
                          COUNT(*) AS total_usuarios
                        FROM usuario
                        GROUP BY genero`,
    leccionesDificiles: `SELECT
                           ul.id_leccion,
                           l.nombre_leccion,
                           l.dificultad,
                           IFNULL(AVG(ul.veces_completada), 0) AS intentos_promedio
                         FROM usuario_leccion ul
                         JOIN leccion l ON ul.id_leccion = l.id_leccion
                         GROUP BY ul.id_leccion, l.nombre_leccion, l.dificultad
                         ORDER BY intentos_promedio DESC`
  };

  try {
    // Ejecutar todas las consultas en paralelo
    const results = await Promise.all(
      Object.entries(queries).map(async ([key, sql]) => {
        try {
          const [rows] = await db.execute(sql);

          // Convertir números en las consultas que lo necesiten
          if (key === 'stats' && rows.length > 0) {
            rows[0] = {
              total_usuarios: Number(rows[0].total_usuarios) || 0,
              total_tiempo: Number(rows[0].total_tiempo) || 0,
              promedio_tiempo: Number(rows[0].promedio_tiempo) || 0,
              promedio_racha: Number(rows[0].promedio_racha) || 0,
              total_monedas: Number(rows[0].total_monedas) || 0
            };
          }

          // Convertir números en otras consultas numéricas
          if (key === 'paises') {
            rows.forEach(row => {
              row.total_tiempo = Number(row.total_tiempo) || 0;
            });
          }

          if (key === 'horasPorDia') {
            rows.forEach(row => {
              row.horas_totales = Number(row.horas_totales) || 0;
            });
          }

          if (key === 'leccionesDificiles') {
            rows.forEach(row => {
              row.intentos_promedio = Number(row.intentos_promedio) || 0;
            });
          }

          return { [key]: rows };
        } catch (err) {
          console.error(`Error en consulta ${key}:`, err);
          // Valores por defecto en caso de error
          const defaultValue = {
            stats: [{
              total_usuarios: 0,
              total_tiempo: 0,
              promedio_tiempo: 0,
              promedio_racha: 0,
              total_monedas: 0
            }],
            paises: [],
            usuariosPorPais: [],
            usuariosPorEdad: [],
            horasPorDia: [],
            conexionesPorHora: [],
            usuariosPorGenero: [],
            leccionesDificiles: []
          };
          return { [key]: defaultValue[key] || [] };
        }
      })
    );

    // Combinar resultados
    const combinedData = results.reduce((acc, result) => {
      return { ...acc, ...result };
    }, {});

    // Asegurar que stats siempre tenga valores numéricos
    combinedData.stats = combinedData.stats?.[0] || {
      total_usuarios: 0,
      total_tiempo: 0,
      promedio_tiempo: 0,
      promedio_racha: 0,
      total_monedas: 0
    };

    // Log para depuración
    console.log('Datos de estadísticas preparados:', {
      stats: combinedData.stats,
      paises: combinedData.paises?.length,
      usuariosPorEdad: combinedData.usuariosPorEdad?.length
    });

    res.render('estadisticas', {
      ...combinedData,
      admin: req.session.admin
    });
  } catch (err) {
    console.error('Error general en estadísticas:', err);
    res.status(500).render('error', {
      error: 'Error al cargar estadísticas',
      admin: req.session.admin
    });
  }
});

app.get('/usuarios', requireAuth, async (req, res) => {
  const orden = req.query.orden || 'nombre';
  const direccion = req.query.dir || 'asc';

  const ordenamientosValidos = {
    'nombre': 'nombre', 'apellido': 'apellido', 'edad': 'edad',
    'genero': 'genero', 'pais': 'pais', 'tiempo': 'tiempoJugado',
    'racha': 'rachaDias', 'fecha': 'ultimoInicioSesion'
  };

  let query = 'SELECT * FROM usuario';
  if (ordenamientosValidos[orden]) {
    query += ` ORDER BY ${ordenamientosValidos[orden]} ${direccion === 'desc' ? 'DESC' : 'ASC'}`;
  }

  try {
    const [resultados] = await db.execute(query);
    res.render('usuarios', { usuarios: resultados, admin: req.session.admin });
  } catch (err) {
    console.error('Error en usuarios:', err);
    return res.status(500).render('error', { error: 'Error al cargar usuarios' });
  }
});

app.get('/leccion', requireAuth, async (req, res) => {
  const orden = req.query.orden || 'nombre';
  const direccion = req.query.dir || 'asc';

  const ordenamientosValidos = {
    'id_leccion': 'id_leccion', 'nombre_leccion': 'nombre_leccion', 'dificultad': 'dificultad'
  };

  let query = 'SELECT * FROM leccion';
  if (ordenamientosValidos[orden]) {
    query += ` ORDER BY ${ordenamientosValidos[orden]} ${direccion === 'desc' ? 'DESC' : 'ASC'}`;
  }

  try {
    const [resultados] = await db.execute(query);
    res.render('leccion', { leccion: resultados, admin: req.session.admin });
  } catch (err) {
    console.error('Error en lecciones:', err);
    return res.status(500).render('error', { error: 'Error al cargar lecciones' });
  }
});

app.get('/pregunta', requireAuth, async (req, res) => {
  const orden = req.query.orden || 'nombre';
  const direccion = req.query.dir || 'asc';

  const ordenamientosValidos = {
    'id_pregunta': 'id_pregunta', 'id_leccion': 'id_leccion', 'texto_pregunta': 'texto_pregunta'
  };

  let query = 'SELECT * FROM pregunta';
  if (ordenamientosValidos[orden]) {
    query += ` ORDER BY ${ordenamientosValidos[orden]} ${direccion === 'desc' ? 'DESC' : 'ASC'}`;
  }

  try {
    const [resultados] = await db.execute(query);
    res.render('pregunta', { pregunta: resultados, admin: req.session.admin });
  } catch (err) {
    console.error('Error en preguntas:', err);
    return res.status(500).render('error', { error: 'Error al cargar preguntas' });
  }
});

// Ruta de créditos (pública)
app.get('/creditos', (req, res) => {
  res.render('creditos', { admin: req.session.admin });
});

// Ruta para mostrar formulario (GET)
app.get('/agregar', requireAuth, (req, res) => {
  res.render('agregar', {
    admin: req.session.admin,
    success: req.session.success,
    error: req.session.error
  });

  // Limpiar mensajes
  req.session.success = null;
  req.session.error = null;
});

// Ruta para procesar formulario (POST)
app.post('/agregar', requireAuth, async (req, res) => {
  const { correo_admin, password } = req.body;

  // Validaciones
  if (!correo_admin || !password) {
    req.session.error = 'Todos los campos son obligatorios';
    return res.redirect('/agregar');
  }

  if (password.length < 8) {
    req.session.error = 'La contraseña debe tener al menos 8 caracteres';
    return res.redirect('/agregar');
  }

  try {
    // Insertar nueva administradora
    await db.execute(
      'INSERT INTO admin (correo_admin, password) VALUES (?, ?)',
      [correo_admin, password]
    );

    req.session.success = '¡Administradora agregada exitosamente!';
    return res.redirect('/agregar');

  } catch (err) {
    console.error('Error al agregar administradora:', err);
    req.session.error = 'Error interno al procesar la solicitud';
    return res.redirect('/agregar');
  }
});



// Unity
app.post("/unity/registrar", async function (req, res){
    let connection;
    console.log("req.body (registrar):", req.body)

    const { nombre_jugador, apellido_jugador, fecha_nacimiento, pais_jugador, correo_jugador, password } = req.body;

    try {
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: 'unity_redes'
        });

        const callProcedure = `CALL RegistrarUsuario(?, ?, ?, ?, ?, ?)`;
        await connection.execute(callProcedure, [
            nombre_jugador,
            apellido_jugador,
            fecha_nacimiento,
            pais_jugador,
            correo_jugador,
            password
        ]);

        res.json({ mensaje: "Usuario registrado exitosamente" });

    } catch (err) {
        console.error("Error al registrar el usuario:", err);
        res.status(500).send("Error al registrar el usuario");
    } finally {
        if (connection) await connection.end();
    }
});

app.post("/unity/descargaDatos", async function (req, res) {
    const { correo_jugador } = req.body;
    let connection;

    try {
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: 'unity_redes'
        });

        // Llamada al procedimiento almacenado
        const [rows] = await connection.query(
            "CALL ObtenerDatosUsuario(?)",
            [correo_jugador]
        );

        // El resultado está en rows[0] porque CALL retorna un array de arrays
        if (rows[0].length > 0) {
            const { monedas, cantidadJuguete, cantidadComida, rachaDias, nuevoUsuario } = rows[0][0];
            res.json({
                monedas,
                cantidadJuguete,
                cantidadComida,
                rachaDias,
                nuevoUsuario
            });
        } else {
            res.status(404).json({ error: "Usuario no encontrado" });
        }
    } catch (err) {
        console.error("Error en descargaDatos:", err);
        res.status(500).json({ error: "Error interno del servidor" });
    } finally {
        if (connection) await connection.end();
    }
});

app.post("/unity/mascota", async (req, res) => {
  const { correo_jugador } = req.body;

  let connection;

  try {
    connection = await mysql.createConnection({
      host: process.env.MYSQL_HOST,
      user: process.env.MYSQL_USER,
      password: process.env.MYSQL_PASSWORD,
      database: "unity_redes",
    });

    // Llamar al procedimiento almacenado
    const [result] = await connection.query(
      "CALL ObtenerDatosMascotaConCalculo(?)",
      [correo_jugador]
    );

    const mascotaData = result[0][0]; // Primer conjunto de resultados, primer registro

    if (!mascotaData) {
      return res.status(404).json({ error: "Mascota no encontrada para el usuario" });
    }

    // Devolver la información al cliente (Unity)
    res.json({
      nombre: mascotaData.nombre,
      hambre: mascotaData.hambre,
      felicidad: mascotaData.felicidad,
      energia: mascotaData.energia,
      nivel: mascotaData.nivel
    });

  } catch (err) {
    console.error("Error al obtener datos de la mascota:", err);
    res.status(500).json({ error: "Error interno del servidor" });
  } finally {
    if (connection) await connection.end();
  }
});

app.post("/unity/validar", async function (req, res) {
  let connection;
  const { correo_jugador, password } = req.body;

  try {
    connection = await mysql.createConnection({
      host: process.env.MYSQL_HOST,
      user: process.env.MYSQL_USER,
      password: process.env.MYSQL_PASSWORD,
      database: 'unity_redes'
    });

    // Llama al procedimiento que valida y actualiza
    const [result] = await connection.query(
      "CALL ValidarCredencialesYActualizarInicio(?, ?)",
      [correo_jugador, password]
    );

    const respuesta = result[0][0]; // Primer conjunto de resultados, primer objeto
    res.json(respuesta);

  } catch (error) {
    console.error("Error en la validación del usuario:", error);
    res.status(500).json({ respuesta: "Error" });
  } finally {
    if (connection) await connection.end();
  }
});

app.post('/guardarSesion', async function(req, res) {
    let connection;
    const {
        correo_jugador,
        moneda_jugador,
        comida_jugador,
        juguetes_jugador,
        felicidad_jugador,
        energia_jugador,
        hambre_jugador,
        nivel,
        racha_dias
    } = req.body;

    try {
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: "unity_redes"
        });

        console.log("Correo recibido:", correo_jugador);
        console.log("Body recibido:", req.body);

        await connection.query(
            "CALL GuardarSesionCompleta(?, ?, ?, ?, ?, ?, ?, ?, ?)",
            [
                correo_jugador,
                moneda_jugador,
                comida_jugador,
                juguetes_jugador,
                racha_dias,
                hambre_jugador,
                felicidad_jugador,
                energia_jugador,
                nivel
            ]
        );

        res.status(200).json({ mensaje: "Sesión guardada correctamente." });
    } catch (error) {
        console.error("Error al guardar sesión:", error);
        res.status(500).json({ mensaje: "Error al guardar sesión en la base de datos." });
    } finally {
        if (connection) await connection.end();
    }
});

app.post('/fechasMascota', async function(req, res) {
    let connection;
    const { correo_jugador, tipo } = req.body;

    try {
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: "unity_redes"
        });

        const [result] = await connection.query(
            `CALL ActualizarFechaMascota(?, ?)`,
            [correo_jugador, tipo]
        );

        res.status(200).json({ mensaje: "Fecha de mascota actualizada correctamente." });

    } catch (error) {
        console.error("Error al llamar al procedimiento:", error);
        res.status(500).json({ mensaje: "Error al actualizar la fecha en la tabla mascota." });
    }
});

app.get('/dbJugadores', async (req,res) => {
    let connection;
    try {
      // Create a connection to the database
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: 'unity_redes'
        });

        const [rows] = await connection.execute('select * from usuario');
        res.render('dbJugadores', { rows});

    } catch (err) {
        res.status(500).send('Error al acceder a la base de datos');

    } finally {
        // Close the database connection
        if (connection) {
            await connection.end();
        }
    }
} );

app.get('/dbMascotas', async (req,res) => {
    let connection;
    try {
      // Create a connection to the database
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: 'unity_redes'
        });

        const [rows] = await connection.execute('select * from mascota');
        res.render('dbMascotas', { rows});

    } catch (err) {
        res.status(500).send('Error al acceder a la base de datos');

    } finally {
        // Close the database connection
        if (connection) {
            await connection.end();
        }
    }
});

app.get('/dbLecciones', async (req,res) => {
    let connection;
    try {
      // Create a connection to the database
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: 'unity_redes'
        });

        const [rows] = await connection.execute('select * from leccion');
        res.render('dbLecciones', { rows});

    } catch (err) {
        res.status(500).send('Error al acceder a la base de datos');

    } finally {
        // Close the database connection
        if (connection) {
            await connection.end();
        }
    }
});

app.get('/dbPreguntas', async (req,res) => {
    let connection;
    try {
      // Create a connection to the database
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: 'unity_redes'
        });

        const [rows] = await connection.execute('select * from pregunta');
        res.render('dbPreguntas', { rows});

    } catch (err) {
        res.status(500).send('Error al acceder a la base de datos');

    } finally {
        // Close the database connection
        if (connection) {
            await connection.end();
        }
    }
});

app.get('/dbUsuarioLeccion', async (req,res) => {
    let connection;
    try {
      // Create a connection to the database
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: 'unity_redes'
        });

        const [rows] = await connection.execute('select * from usuario_leccion');
        res.render('dbUsuarioLeccion', { rows});

    } catch (err) {
        res.status(500).send('Error al acceder a la base de datos');

    } finally {
        // Close the database connection
        if (connection) {
            await connection.end();
        }
    }
});


app.get('/dbRespuestas', async (req,res) => {
    let connection;
    try {
      // Create a connection to the database
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: 'unity_redes'
        });

        const [rows] = await connection.execute('select * from opcion_respuesta');
        res.render('dbRespuestas', { rows});

    } catch (err) {
        res.status(500).send('Error al acceder a la base de datos');

    } finally {
        // Close the database connection
        if (connection) {
            await connection.end();
        }
    }
});

app.post('/unity/descargarLeccion', async function (req, res) {
    const { eleccion } = req.body; // Este es el "tipo" que Unity envía como eleccion
    let connection;

    try {
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: 'unity_redes'
        });

        const [rows] = await connection.query(
            `SELECT nombre_leccion, contenido FROM leccion WHERE id_leccion = ?`,
            [eleccion]
        );

        if (rows.length > 0) {
            const { nombre_leccion, contenido } = rows[0];
            res.json({
                nombre_leccion,
                contenido
            });
        } else {
            res.status(404).json({ error: "Lección no encontrada" });
        }
    } catch (err) {
        console.error("Error en descargarLeccion:", err);
        res.status(500).json({ error: "Error interno del servidor" });
    } finally {
        if (connection) await connection.end();
    }
});

app.post('/unity/descargarPreguntasRespuestas', async function (req, res) {
    const { eleccion } = req.body;
    let connection;

    try {
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: 'unity_redes'
        });

        const [preguntas] = await connection.execute(
            "SELECT id_pregunta, texto_pregunta FROM pregunta WHERE id_leccion = ? ORDER BY RAND() LIMIT 6",
            [eleccion]
        );

        const resultado = {};

        for (let i = 0; i < preguntas.length; i++) {
            const pregunta = preguntas[i];

            // Obtener todas las respuestas de esa pregunta
            const [todasRespuestas] = await connection.execute(
                "SELECT texto_opcion, es_correcta FROM opcion_respuesta WHERE id_pregunta = ?",
                [pregunta.id_pregunta]
            );

            // Filtrar correctas e incorrectas
            const correctas = todasRespuestas.filter(r => r.es_correcta === 1);
            const incorrectas = todasRespuestas.filter(r => r.es_correcta === 0);

            // Asegurar que haya al menos una correcta y una incorrecta
            if (correctas.length === 0 || incorrectas.length === 0) {
                console.warn(`Pregunta ${pregunta.id_pregunta} no tiene suficientes respuestas válidas.`);
                continue;
            }

            // Elegir una respuesta correcta al azar
            const correcta = correctas[Math.floor(Math.random() * correctas.length)];
            // Elegir una incorrecta al azar
            const incorrecta = incorrectas[Math.floor(Math.random() * incorrectas.length)];

            // Mezclar orden
            const opciones = [
                { texto: correcta.texto_opcion, esCorrecta: true },
                { texto: incorrecta.texto_opcion, esCorrecta: false }
            ];
            opciones.sort(() => Math.random() - 0.5);

            // Añadir al resultado
            resultado[`pregunta${i+1}`] = pregunta.texto_pregunta;
            resultado[`incisoA${i+1}`] = opciones[0].texto;
            resultado[`esCorrectaA${i+1}`] = opciones[0].esCorrecta;
            resultado[`incisoB${i+1}`] = opciones[1].texto;
            resultado[`esCorrectaB${i+1}`] = opciones[1].esCorrecta;
        }

        res.json(resultado);
    } catch (error) {
        console.error('Error al obtener preguntas:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    } finally {
        if (connection) {
            await connection.end();
        }
    }
});

app.post('/unity/mandarDatosLeccion', async function (req, res) {
    const { correo, tema } = req.body;
    let connection;

    try {
        connection = await mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: 'unity_redes'
        });

        const id_leccion = tema; // Ya es el ID directamente

        const [updateResult] = await connection.execute(
            'UPDATE usuario_leccion SET veces_completada = veces_completada + 1 WHERE correo_jugador = ? AND id_leccion = ?',
            [correo, id_leccion]
        );

        if (updateResult.affectedRows === 0) {
            await connection.execute(
                'INSERT INTO usuario_leccion (correo_jugador, id_leccion, veces_completada) VALUES (?, ?, 1)',
                [correo, id_leccion]
            );
        }

        res.json({ mensaje: 'Progreso guardado correctamente' });
    } catch (error) {
        console.error('Error al guardar progreso:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
    } finally {
        if (connection) {
            await connection.end();
        }
    }
});


// Manejo de errores
app.use((err, req, res, next) => {
  console.error('Error:', err.stack);
  res.status(500).render('error', { error: err.message });
});

app.use((req, res) => {
  res.status(404).render('404', {
    url: req.originalUrl,
    admin: req.session.admin
  });
});

// Iniciar servidor
app.listen(port, () => {
  console.log(`Servidor esperando en: http://${ipAdress}:${port}`);
});