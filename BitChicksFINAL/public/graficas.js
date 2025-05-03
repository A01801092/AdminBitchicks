import { Chart } from 'https://cdn.jsdelivr.net/npm/chart.js@4.4.2/+esm';

document.addEventListener('DOMContentLoaded', function() {
  // Obtener datos del elemento HTML
  const datosElement = document.getElementById('datos-graficos');

  // Parsear todos los datos
  const stats = {
    total_usuarios: datosElement.dataset.totalUsuarios,
    promedio_racha: datosElement.dataset.promedioRacha,
    total_tiempo: datosElement.dataset.totalTiempo,
    promedio_tiempo: datosElement.dataset.promedioTiempo
  };

  const paises = JSON.parse(datosElement.dataset.paises);
  const usuariosPorEdad = JSON.parse(datosElement.dataset.edades);
  const horasPorDia = JSON.parse(datosElement.dataset.horas);
  const usuariosPorPais = JSON.parse(datosElement.dataset.usuariosPais);
  const preguntasDificiles = JSON.parse(datosElement.dataset.preguntas || '[]');

  // --- Gráfico de barras: Horas por país ---
  const ctxPaises = document.getElementById('graficoPaises').getContext('2d');
  new Chart(ctxPaises, {
    type: 'bar',
    data: {
      labels: paises.map(p => p.pais),
      datasets: [{
        label: 'Horas jugadas',
        data: paises.map(p => parseFloat(p.total_tiempo)),
        backgroundColor: '#F50087',
        borderColor: '#F50087',
        borderWidth: 1
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: (ctx) => `${ctx.raw} horas jugadas`
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          title: { display: true, text: 'Horas jugadas' }
        },
        x: {
          title: { display: true, text: 'Países' }
        }
      }
    }
  });

  // --- Gráfico de barras: Usuarios por edad ---
  const ctxEdades = document.getElementById('graficoEdades').getContext('2d');
  new Chart(ctxEdades, {
    type: 'bar',
    data: {
      labels: usuariosPorEdad.map(e => e.edad),
      datasets: [{
        label: 'Usuarios registrados',
        data: usuariosPorEdad.map(e => e.total_usuarios),
        backgroundColor: '#F50087',
        borderColor: '#F50087',
        borderWidth: 1
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            label: (ctx) => `${ctx.raw} usuario${ctx.raw !== 1 ? 's' : ''} de ${ctx.label} años`
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          ticks: { precision: 0 },
          title: { display: true, text: 'Número de usuarios' }
        },
        x: {
          title: { display: true, text: 'Edad' }
        }
      }
    }
  });

  // --- Gráfico de pastel: Usuarios por país ---
  const ctxPastel = document.getElementById('graficoUsuariosPais').getContext('2d');
  new Chart(ctxPastel, {
    type: 'pie',
    data: {
      labels: usuariosPorPais.map(p => p.pais),
      datasets: [{
        data: usuariosPorPais.map(p => p.total_usuarios),
        backgroundColor: [
          '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF',
          '#FF9F40', '#8AC24A', '#FF6B6B', '#47B8E0', '#7B68EE'
        ],
        borderWidth: 1
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: { position: 'right' },
        tooltip: {
          callbacks: {
            label: (ctx) => {
              const total = ctx.dataset.data.reduce((a, b) => a + b, 0);
              const percentage = Math.round((ctx.raw / total) * 100);
              return `${ctx.label}: ${ctx.raw} (${percentage}%)`;
            }
          }
        }
      }
    }
  });

  // --- Gráfico de líneas: Horas por día ---
  const ctxLineas = document.getElementById('graficoHorasPorDia').getContext('2d');
  new Chart(ctxLineas, {
    type: 'line',
    data: {
      labels: horasPorDia.map(d => new Date(d.fecha).toLocaleDateString('es-MX')),
      datasets: [{
        label: 'Horas jugadas',
        data: horasPorDia.map(d => d.horas_totales),
        borderColor: '#F50087',
        backgroundColor: 'rgba(255, 99, 132, 0.1)',
        borderWidth: 2,
        fill: true,
        tension: 0.3
      }]
    },
    options: {
      responsive: true,
      plugins: {
        legend: { display: false },
        tooltip: {
          callbacks: {
            title: (ctx) => ctx[0].label,
            label: (ctx) => `${ctx.raw.toFixed(2)} horas jugadas`
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          title: { display: true, text: 'Horas totales' }
        },
        x: {
          title: { display: true, text: 'Fecha' },
          ticks: { maxRotation: 45, minRotation: 45 }
        }
      }
    }
  });

  // --- Gráfico de barras horizontales: Preguntas difíciles ---
  if (preguntasDificiles.length > 0) {
    const ctxPreguntas = document.getElementById('graficoPreguntasDificiles').getContext('2d');
    const labels = preguntasDificiles.map(item => {
      const leccion = item.nombre_leccion?.substring(0, 15) || 'Lección';
      const pregunta = item.texto_pregunta?.substring(0, 30) || 'Pregunta';
      return `${leccion}: ${pregunta}...`;
    });

    new Chart(ctxPreguntas, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Porcentaje de error',
          data: preguntasDificiles.map(item => item.porcentaje_error),
          backgroundColor: '#FF6384',
          borderColor: '#cc4c6c',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        indexAxis: 'y',
        plugins: {
          tooltip: {
            callbacks: {
              label: function(context) {
                const preguntaCompleta = preguntasDificiles[context.dataIndex].texto_pregunta;
                const leccion = preguntasDificiles[context.dataIndex].nombre_leccion;
                return [
                  `Lección: ${leccion}`,
                  `Pregunta: ${preguntaCompleta}`,
                  `Error: ${context.raw}%`
                ];
              }
            }
          }
        },
        scales: {
          x: {
            beginAtZero: true,
            max: 100,
            title: { display: true, text: 'Porcentaje de respuestas incorrectas' }
          }
        }
      }
    });
  }
});