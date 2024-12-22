// Importar dependencias
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const bodyParser = require('body-parser');
const sql = require('mssql');

// Configuración del servidor
const app = express();
const PORT = process.env.PORT || 3000;
const SECRET_KEY = "your_secret_key";

app.use(bodyParser.json());

// Rutas
app.get('/', (req, res) => {
  res.send('¡Hola, mundo!');
});

// Configuración de la base de datos SQL Server. Agregar archivo .env con credenciales
const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  options: {
      encrypt: true, // Usar en Azure
      trustServerCertificate: true // Usar si no se tiene un certificado SSL
  }
};

// Conectar a la base de datos
sql.connect(dbConfig).then(pool => {
  console.log('Conexión a la base de datos exitosa.');
  app.set('dbPool', pool);
}).catch(err => {
  console.error('Error al conectar a la base de datos:', err);
});

// Iniciar el servidor
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
