import express from 'express';
import path from 'path';
import mysql from 'mysql';

const app = express();
const port = process.env.PORT ?? 8080;
const ip_address = process.env.C9_HOSTNAME ?? 'localhost';

// Configuración de EJS
app.set('view engine', 'ejs');
app.set('views', path.join(process.cwd(), 'views'));

// Archivos estáticos
app.use(express.static(path.join(process.cwd(), 'public')));

// Datos para la conexión a la base de datos MySQL
const db = mysql.createConnection({
  host: process.env.MYSQL_HOST,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: 'unity_redes'
});

// Conexión a la base de datos
db.connect((err) => {
  if (err) throw err;
  console.log('Conectado a MySQL');
});

// Ruta de inicio
app.get('/', (req, res) => {
  res.render('index');
});

// Ruta de estadísticas
app.get('/estadisticas', (req, res) => {
  // Estadísticas generales de todos los usuarios
  db.query(`
    SELECT
      COUNT(*) AS total_usuarios,
      SUM(tiempoJugado) AS total_tiempo,
      AVG(tiempoJugado) AS promedio_tiempo,
      AVG(rachaDias) AS promedio_racha,
      SUM(monedas) AS total_monedas
    FROM usuario
  `, (err, resultados) => {
    if (err) throw err;

    // Estadísticas por país para gráfico de barras
    db.query(`
      SELECT pais, SUM(tiempoJugado) AS total_tiempo
      FROM usuario
      GROUP BY pais
    `, (err2, paisResultados) => {
      if (err2) throw err2;

      // Conteo de usuarios por país para gráfico de pastel
      db.query(`
        SELECT pais, COUNT(*) AS total_usuarios
        FROM usuario
        GROUP BY pais
      `, (err3, usuariosPorPais) => {
        if (err3) throw err3;

        // Distribución por edades para gráfico de barras
        db.query(`
          SELECT
            edad,
            COUNT(*) AS total_usuarios
          FROM usuario
          GROUP BY edad
          ORDER BY edad ASC
        `, (err4, usuariosPorEdad) => {
          if (err4) throw err4;

          // Conteo de tiempo jugado por día para el gráfico de línea
          db.query(`
            SELECT
              DATE(ultimoInicioSesion) AS fecha,
              SUM(tiempoJugado) AS horas_totales
            FROM usuario
            WHERE ultimoInicioSesion IS NOT NULL
            GROUP BY DATE(ultimoInicioSesion)
            ORDER BY fecha ASC
          `, (err5, horasPorDia) => {
            if (err5) throw err5;

            // Conteo del total de conexiones por hora para el gráfico de línea
            db.query(`
              SELECT
                HOUR(ultimoInicioSesion) AS hora,
                COUNT(*) AS total_conexiones
              FROM usuario
              WHERE ultimoInicioSesion IS NOT NULL
              GROUP BY HOUR(ultimoInicioSesion)
              ORDER BY hora ASC
            `, (err6, conexionesPorHora) => {
              if (err6) throw err6;

              //Distribución por género para gráfico de pastel
              db.query(`
                SELECT
                  genero,
                  COUNT(*) AS total_usuarios
                FROM usuario
                GROUP BY genero
              `, (err7, usuariosPorGenero) => {
                if (err7) throw err7;

                // Promedio de los intentos para cada lección para el gráfico de barras laterales
                db.query(`
                  SELECT
                    ul.nombre_leccion,
                    l.dificultad,
                    AVG(ul.veces_completada) AS intentos_promedio
                  FROM usuario_leccion ul
                  JOIN leccion l ON ul.nombre_leccion = l.nombre_leccion
                  GROUP BY ul.nombre_leccion, l.dificultad
                  ORDER BY intentos_promedio DESC
                `, (err8, leccionesDificiles) => {
                  if (err8) throw err8;

                  // Manda los datos en formato JSON a estadísticas para ser graficados
                  res.render('estadisticas', {
                    stats: resultados[0],
                    paises: paisResultados,
                    usuariosPorPais: usuariosPorPais,
                    usuariosPorEdad: usuariosPorEdad,
                    horasPorDia: horasPorDia,
                    conexionesPorHora: conexionesPorHora,
                    usuariosPorGenero: usuariosPorGenero,
                    leccionesDificiles: leccionesDificiles
                  });
                });
              });
            });
          });
        });
      });
    });
  });
});

// Ruta de usuarios
app.get('/usuarios', (req, res) => {
  // Datos para el ordenamiento de la tabla (asc-dsc)
  const orden = req.query.orden || 'nombre';
  const direccion = req.query.dir || 'asc';

  // Query para obetener todos los datos de la tabla usuario
  let query = 'SELECT * FROM usuario';

  const ordenamientosValidos = {
    'nombre': 'nombre',
    'apellido': 'apellido',
    'edad': 'edad',
    'genero': 'genero',
    'pais': 'pais',
    'tiempo': 'tiempoJugado',
    'racha': 'rachaDias',
    'fecha': 'ultimoInicioSesion'
  };

  // Implementa en el query el ordenamiento que se le requiere de la variable deseada
  if (ordenamientosValidos[orden]) {
    query += ` ORDER BY ${ordenamientosValidos[orden]} ${direccion === 'desc' ? 'DESC' : 'ASC'}`;
  }
  db.query(query, (err, resultados) => {
    if (err) throw err;

    // Manda los datos a Usuario en formato JSON para que pueda ponerse en la tabla
    res.render('usuarios', { usuarios: resultados });
  });
});

// Ruta para la página de créditos
app.get('/creditos', (req, res) => {
  res.render('creditos');
});

// Página de recurso no encontrado (estatus 404)
app.use((req, res) => {
  const url = req.originalUrl;
  res.status(404).render('404', { url });
});

// Iniciar servidor
app.listen(port, () => {
  console.log(`Servidor escuchando en: http://${ip_address}:${port}`);
});