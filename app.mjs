import express from 'express';
import path from 'path';
import mysql from 'mysql';
import session from 'express-session';
import bodyParser from 'body-parser';

const app = express();
const port = process.env.PORT ?? 8080;
const ip_address = process.env.C9_HOSTNAME ?? 'localhost';

// Configuración de EJS
app.set('view engine', 'ejs');
app.set('views', path.join(process.cwd(), 'views'));

// Middleware
app.use(express.static(path.join(process.cwd(), 'public')));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(session({
  secret: 'tu_clave_secreta_aleatoria',
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000
  }
}));

// Conexión MySQL
const db = mysql.createConnection({
  host: process.env.MYSQL_HOST,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: 'unity_redes'
});

db.connect((err) => {
  if (err) {
    console.error('Error conectando a MySQL:', err);
    process.exit(1);
  }
  console.log('Conectado a MySQL');
});

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

app.post('/login', (req, res) => {
  const { correo_admin, password } = req.body;

  if (!correo_admin || !password) {
    req.session.error = 'Todos los campos son requeridos';
    return res.redirect('/login');
  }

  db.query(
    'SELECT * FROM admin WHERE correo_admin = ? AND password = ?',
    [correo_admin, password],
    (err, results) => {
      if (err) {
        console.error('Error en login:', err);
        req.session.error = 'Error del servidor';
        return res.redirect('/login');
      }

      if (results.length > 0) {
        req.session.admin = results[0];
        req.session.success = 'Bienvenida ' + results[0].correo_admin;
        return res.redirect('/index');
      } else {
        req.session.error = 'Credenciales incorrectas';
        return res.redirect('/login');
      }
    }
  );
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

// Ruta para mostrar el formulario (GET)
app.get('/lecciones', requireAuth, (req, res) => {
  const idLeccion = 0; // Siempre mostramos la lección 0

  db.query('SELECT * FROM leccion WHERE id_leccion = ?', [idLeccion], (err, results) => {
    if (err) {
      console.error('Error al obtener lección:', err);
      req.session.error = 'Error al cargar la lección';
      return res.redirect('/index');
    }

    if (results.length === 0) {
      req.session.error = 'Lección no encontrada';
      return res.redirect('/index');
    }

    res.render('lecciones', {
      leccion: results[0],
      admin: req.session.admin,
      success: req.session.success,
      error: req.session.error
    });

    // Limpiar los mensajes después de mostrarlos
    req.session.success = null;
    req.session.error = null;
  });
});
// Ruta para actualizar la lección (POST)
app.post('/lecciones', requireAuth, (req, res) => {
  const { nombre_leccion, dificultad, contenido } = req.body;
  const idLeccion = 0;

  if (!nombre_leccion || !dificultad || !contenido) {
    req.session.error = 'Todos los campos son obligatorios';
    return res.redirect('/lecciones');
  }

  db.query(
    'UPDATE leccion SET nombre_leccion = ?, dificultad = ?, contenido = ? WHERE id_leccion = ?',
    [nombre_leccion, dificultad, contenido, idLeccion],
    (err, results) => {
      if (err) {
        console.error('Error al actualizar lección:', err);
        req.session.error = 'Error al actualizar la lección';
        return res.redirect('/lecciones');
      }

      req.session.success = 'Lección actualizada correctamente';
      res.redirect('/lecciones');
    }
  );
});

app.get('/estadisticas', requireAuth, (req, res) => {
  // Consultas anidadas para estadísticas con manejo de NULL
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

  // Ejecutar todas las consultas en paralelo con manejo de errores
  const executeQueries = Object.entries(queries).map(([key, sql]) => {
    return new Promise((resolve) => {
      db.query(sql, (err, results) => {
        if (err) {
          console.error(`Error en consulta ${key}:`, err);
          // Devuelve valores por defecto en caso de error
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
          resolve({ [key]: defaultValue[key] || [] });
        } else {
          resolve({ [key]: results });
        }
      });
    });
  });

  Promise.all(executeQueries)
    .then(results => {
      // Combinar resultados y asegurar valores por defecto
      const combinedData = results.reduce((acc, result) => {
        return { ...acc, ...result };
      }, {});

      // Asegurar que stats siempre tenga valores
      combinedData.stats = combinedData.stats?.[0] || {
        total_usuarios: 0,
        total_tiempo: 0,
        promedio_tiempo: 0,
        promedio_racha: 0,
        total_monedas: 0
      };

      // Convertir valores NULL a 0
      combinedData.stats.promedio_racha = combinedData.stats.promedio_racha || 0;
      combinedData.stats.promedio_tiempo = combinedData.stats.promedio_tiempo || 0;

      res.render('estadisticas', {
        ...combinedData,
        admin: req.session.admin
      });
    })
    .catch(err => {
      console.error('Error general en estadísticas:', err);
      res.status(500).render('error', {
        error: 'Error al cargar estadísticas',
        admin: req.session.admin
      });
    });
});

app.get('/usuarios', requireAuth, (req, res) => {
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

  db.query(query, (err, resultados) => {
    if (err) {
      console.error('Error en usuarios:', err);
      return res.status(500).render('error', { error: 'Error al cargar usuarios' });
    }
    res.render('usuarios', { usuarios: resultados, admin: req.session.admin });
  });
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
    await db.query(
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
  console.log(`Servidor escuchando en: http://${ip_address}:${port}`);
});