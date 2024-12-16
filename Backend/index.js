const express = require('express');
const app = express();

const PORT = 3000;

// Middleware (opcional)
app.use(express.json());

// Rutas
app.get('/', (req, res) => {
  res.send('¡Hola, mundo!');
});

// Iniciar el servidor
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
