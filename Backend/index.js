// Importar dependencias
const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const bodyParser = require('body-parser');
const sql = require('mssql');
const dotenv = require('dotenv');
const { randomBytes } = require('crypto');

// Cargar variables de entorno
dotenv.config();

// Generar SECRET_KEY si no está en .env
const SECRET_KEY = process.env.SECRET_KEY || randomBytes(36).toString('base64');

// Configuración del servidor
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());

// Configuración de la base de datos SQL Server
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

// Middleware para validar JWT
function authenticateToken(req, res, next) {
    const token = req.headers["authorization"]?.split(" ")[1];
    if (!token) return res.sendStatus(401);

    jwt.verify(token, SECRET_KEY, (err, user) => {
        if (err) return res.sendStatus(403);
        req.user = user;
        next();
    });
}

function authorizeRole(requiredRole) {
    return (req, res, next) => {
        if (req.user.rol !== requiredRole) {
            return res.status(403).send('No tiene permisos para acceder a este recurso.');
        }
        next();
    };
}

//Encriptacion de contraseña
function encryptPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

// Rutas
app.get('/', (req, res) => {
    res.send('¡Hola, mundo!');
  });

  
// Autenticación con JWT
const crypto = require('crypto');
app.post('/login', async (req, res) => {
    const { correo, password } = req.body;
    try {
        const pool = app.get('dbPool');
        const result = await pool.request()
            .input('correo', sql.NVarChar, correo)
            .input('password', sql.NVarChar,  encryptPassword(password))
            .execute('AuthenticarUsuario');

        const user = result.recordset[0];
        if (!user) return res.sendStatus(404);        

        const token = jwt.sign({ id: user.idUsuario, correo: user.correo , rol: user.idRol }, SECRET_KEY, { expiresIn: '24h' });
        res.json({ token });
    } catch (err) {
        console.error('Error en login:', err);
        res.status(500).send('Error interno del servidor.');
    }
});

// 2.1.1 CRUD de Productos
app.post('/saveproduct', authenticateToken, authorizeRole(2), async (req, res) => {
    const { codigo, nombre, descripcion, precio, stock, foto, idEstado, idMarca } = req.body;
    if (!codigo || !nombre || !descripcion || !precio || !stock || !foto || !idEstado || !idMarca) {
        return res.status(400).send('Faltan parámetros.');
    }  
    try {          
        const pool = app.get('dbPool');
        const result = await pool.request()
        .input('codigo', sql.NVarChar, codigo)
        .input('nombre', sql.NVarChar, nombre)
        .input('descripcion', sql.NVarChar, descripcion)
        .input('precio', sql.Decimal, precio)
        .input('stock', sql.Int, stock)
        .input('foto', sql.NVarChar, foto)
        .input('idEstado', sql.Int, idEstado)
        .input('idMarca', sql.Int, idMarca)
        .input('idUsuario', sql.Int, req.user.id) 
        .execute('InsertarProducto');

        res.status(200).json({ id: result, message: 'Producto creado exitosamente.' });
    } catch (err) {
        console.error('Error al crear producto:', err);
        res.status(500).send('Error interno del servidor.');
    }
});

app.put('/updateproduct', authenticateToken, authorizeRole(2), async (req, res) => {
    const { idProducto, codigo, nombre, descripcion, precio, stock, foto, idEstado, idMarca } = req.body;

    if (!idProducto || !codigo || !nombre || !descripcion || !precio || !stock || !foto || !idEstado || !idMarca) {
        return res.status(400).send('Faltan parámetros.');
    }

    try {
        const pool = app.get('dbPool');
        const result = await pool.request()
            .input('idProducto', sql.Int, id)
            .input('codigo', sql.NVarChar, codigo)
            .input('nombre', sql.NVarChar, nombre)
            .input('descripcion', sql.NVarChar, descripcion)
            .input('precio', sql.Decimal, precio)
            .input('stock', sql.Int, stock)
            .input('foto', sql.NVarChar, foto)
            .input('idEstado', sql.Int, idEstado)
            .input('idMarca', sql.Int, idMarca)
            .input('idUsuario', sql.Int, req.user.id) 
            .execute('ActualizarProducto');

        res.status(200).json({ id: result.recordset[0], message: 'Producto actualizado exitosamente.' });
    } catch (err) {
        console.error('Error al actualizar producto:', err);
        res.status(500).send('Error interno del servidor.');
    }
});

app.get('/products', authenticateToken, async (req, res) => {
    try {
        const pool = app.get('dbPool');
        const result = await pool.request().query('SELECT * FROM Productos;');
        res.json(result.recordset);
    } catch (err) {
        console.error('Error al obtener productos:', err);
        res.status(500).send('Error interno del servidor.');
    }
});


// Endpoint para insertar una categoría
app.post('/insertar-categoria',authenticateToken, authorizeRole(2), async (req, res) => {
    const { nombre, idEstado } = req.body;
  
    if (!nombre || !idEstado) {
      return res.status(400).send('Faltan parámetros.');
    }
  
    try {
        const pool = app.get('dbPool');
        const result = await pool.request()
            .input('nombre', sql.NVarChar, nombre)
            .input('idEstado', sql.Int, idEstado)
            .input('idUsuario', sql.Int, req.user.id) 
            .execute('InsertarCategoria');

        res.status(200).json({ id: result.recordset[0], message: 'Categoría insertada con éxito.' });
    } catch (error) {
      console.error(error);
      res.status(500).send('Error al insertar la categoría.');
    }
});
  
  // Endpoint para actualizar una categoría
app.put('/actualizar-categoria', authenticateToken, authorizeRole(2), async (req, res) => {
    const { idCategoria, nombre, idEstado } = req.body;
  
    if (!idCategoria || !nombre || !idEstado) {
      return res.status(400).send('Faltan parámetros.');
    }
    try {
        const pool = app.get('dbPool');
        const result = await pool.request()
            .input('idCategoria', sql.Int, idCategoria)
            .input('nombre', sql.NVarChar, nombre)
            .input('idEstado', sql.Int, idEstado)
            .input('idUsuario', sql.Int, req.user.id) 
            .execute('ActualizarCategoria');

            res.status(200).json({ id: result.recordset[0], message: 'Categoría actualizada con éxito.' });
      } catch (error) {
        console.error(error);
        res.status(500).send('Error al actualizar la categoría.');
      }
});

app.get('/categorias', authenticateToken, async (req, res) => {
    try {
        const pool = app.get('dbPool');
        const result = await pool.request().query('SELECT * FROM Categorias;');
        res.json(result.recordset);
    } catch (err) {
        console.error('Error al obtener categorias:', err);
        res.status(500).send('Error interno del servidor.');
    }
});


app.post('/insertarUsuario',  authenticateToken, authorizeRole(2), async (req, res) => {
    const { nombre_completo, correo, password, telefono, fecha_nacimiento, idEstado, idRol } = req.body;
  
    try {
      const pool = await sql.connect(dbConfig);
      const result = await pool.request()
        .input('nombre_completo', sql.NVarChar, nombre_completo)
        .input('correo', sql.NVarChar, correo)
        .input('password', sql.NVarChar, encryptPassword(password))
        .input('telefono', sql.NVarChar, telefono)
        .input('fecha_nacimiento', sql.DateTime, fecha_nacimiento)
        .input('idEstado', sql.Int, idEstado)
        .input('idRol', sql.Int, idRol)
        .execute('InsertarUsuario');
      
        res.status(200).json({ id: result.recordset[0], message: 'Usuario insertado correctamente.' });
    } catch (err) {
      res.status(500).send({ error: 'Error al insertar el usuario.', details: err.message });
    }
  });
  
app.put('/actualizarUsuario',  authenticateToken, authorizeRole(2), async (req, res) => {
    const { idUsuario, nombre_completo, correo, telefono, fecha_nacimiento, idEstado, idRol } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
        .input('idUsuario', sql.Int, idUsuario)
        .input('nombre_completo', sql.NVarChar, nombre_completo)
        .input('correo', sql.NVarChar, correo)
        .input('telefono', sql.NVarChar, telefono)
        .input('fecha_nacimiento', sql.DateTime, fecha_nacimiento)
        .input('idEstado', sql.Int, idEstado)
        .input('idRol', sql.Int, idRol)
        .execute('ActualizarUsuario');
        res.status(200).json({ id: result.recordset[0], message: 'Usuario actualizado correctamente.' });
    } catch (err) {
        res.status(500).send({ error: 'Error al actualizar el usuario.', details: err.message });
    }
});
  
app.put('/cambiarContrasena',  authenticateToken, async (req, res) => {
    const { correo, nuevaPassword } = req.body;
  
    try {
      const pool = await sql.connect(dbConfig);
      await pool.request()
        .input('correo', sql.NVarChar, correo)
        .input('nuevaPassword', sql.NVarChar, encryptPassword(nuevaPassword))
        .execute('CambiarContrasenaUsuario');
      res.send({ message: 'Contraseña actualizada correctamente.' });
    } catch (err) {
      res.status(500).send({ error: 'Error al actualizar la contraseña.', details: err.message });
    }
});

// Endpoint para insertar una nueva orden con detalles
app.post('/orden', authenticateToken, async (req, res) => {
    const {
        fecha_entrega,
        direccion_entrega,
        cupon,
        observaciones,
        nombre,
        direccion,
        correo,
        telefono,
        total,
        idEstado,
        detalles,
    } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('fecha_entrega', sql.DateTime, fecha_entrega)
            .input('direccion_entrega', sql.NVarChar(245), direccion_entrega)
            .input('cupon', sql.NVarChar(100), cupon)
            .input('observaciones', sql.NVarChar(100), observaciones)
            .input('nombre', sql.NVarChar(100), nombre)
            .input('direccion', sql.NVarChar(245), direccion)
            .input('correo', sql.NVarChar(100), correo)
            .input('telefono', sql.NVarChar(15), telefono)
            .input('total', sql.Decimal(10, 2), total)
            .input('idUsuario', sql.Int, req.user.id)
            .input('idEstado', sql.Int, idEstado)
            .input('detalles', sql.NVarChar(sql.MAX), JSON.stringify(detalles))
            .execute('InsertarOrdenConDetalles');

        res.status(201).json({ message: 'Orden creada exitosamente' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error al crear la orden' });
    }
});

// Endpoint para actualizar una orden existente con detalles
app.put('/actualizar-orden', authenticateToken, authorizeRole(2), async (req, res) => {
    const {
        idOrden,
        fecha_entrega,
        direccion_entrega,
        cupon,
        observaciones,
        nombre,
        direccion,
        correo,
        telefono,
        total,
        idEstado,
        detalles,
    } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('idOrden', sql.Int, idOrden)
            .input('fecha_entrega', sql.DateTime, fecha_entrega)
            .input('direccion_entrega', sql.NVarChar(245), direccion_entrega)
            .input('cupon', sql.NVarChar(100), cupon)
            .input('observaciones', sql.NVarChar(100), observaciones)
            .input('nombre', sql.NVarChar(100), nombre)
            .input('direccion', sql.NVarChar(245), direccion)
            .input('correo', sql.NVarChar(100), correo)
            .input('telefono', sql.NVarChar(15), telefono)
            .input('total', sql.Decimal(10, 2), total)
            .input('idUsuario', sql.Int, req.user.id)
            .input('idEstado', sql.Int, idEstado)
            .input('detalles', sql.NVarChar(sql.MAX), JSON.stringify(detalles))
            .execute('ActualizarOrdenConDetalles');

        res.status(200).json({ message: 'Orden actualizada exitosamente' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error al actualizar la orden' });
    }
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`Servidor escuchando en http://localhost:${PORT}`);
});
