# GDA00318-OT
DesafioWEB360-EstrellitaGuadalupeArmasMonroy

# Documentación de Endpoints

## Introducción
Este documento describe los endpoints disponibles en la API, incluyendo ejemplos de uso y los roles que tienen acceso a cada uno.

---

## Autenticación y Usuarios

### Login
- **Endpoint:** `POST /login`
- **Descripción:** Autentica a un usuario y genera un token JWT válido por 24 horas.
- **Acceso:** Todos los usuarios registrados.

#### Ejemplo de solicitud:
```json
{
    "correo": "usuario@example.com",
    "password": "contraseña123"
}
```

#### Ejemplo de respuesta:
```json
{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### Insertar Usuario
- **Endpoint:** `POST /insertarUsuario`
- **Descripción:** Crea un nuevo usuario en el sistema.
- **Acceso:** Operadores (rol 2).

#### Ejemplo de solicitud:
```json
{
    "nombre_completo": "Juan Perez",
    "correo": "juan@example.com",
    "password": "miContraseña",
    "telefono": "1234567890",
    "fecha_nacimiento": "1990-01-01",
    "idEstado": 1,
    "idRol": 3
}
```

#### Ejemplo de respuesta:
```json
{
    "id": 45,
    "message": "Usuario insertado correctamente."
}
```

---

### Actualizar Usuario
- **Endpoint:** `PUT /actualizarUsuario`
- **Descripción:** Actualiza la información de un usuario existente.
- **Acceso:** Operadores (rol 2).

#### Ejemplo de solicitud:
```json
{
    "idUsuario": 45,
    "nombre_completo": "Juan Perez Actualizado",
    "correo": "juan_updated@example.com",
    "telefono": "0987654321",
    "fecha_nacimiento": "1990-01-01",
    "idEstado": 1,
    "idRol": 3
}
```

#### Ejemplo de respuesta:
```json
{
    "id": 45,
    "message": "Usuario actualizado correctamente."
}
```

---

### Cambiar Contraseña
- **Endpoint:** `PUT /cambiarContrasena`
- **Descripción:** Cambia la contraseña de un usuario.
- **Acceso:** Clientes (rol 3).

#### Ejemplo de solicitud:
```json
{
    "correo": "usuario@example.com",
    "nuevaPassword": "nuevaContraseña"
}
```

#### Ejemplo de respuesta:
```json
{
    "message": "Contraseña actualizada correctamente."
}
```

---

## Productos

### Guardar Producto
- **Endpoint:** `POST /saveproduct`
- **Descripción:** Agrega un nuevo producto al sistema.
- **Acceso:** Operadores (rol 2).

#### Ejemplo de solicitud:
```json
{
    "codigo": "PROD001",
    "nombre": "Producto 1",
    "descripcion": "Descripción del producto",
    "precio": 100.50,
    "stock": 20,
    "foto": "url_foto.jpg",
    "idEstado": 1,
    "idMarca": 3
}
```

#### Ejemplo de respuesta:
```json
{
    "id": 101,
    "message": "Producto creado exitosamente."
}
```

---

### Actualizar Producto
- **Endpoint:** `PUT /updateproduct`
- **Descripción:** Actualiza la información de un producto existente.
- **Acceso:** Operadores (rol 2).

#### Ejemplo de solicitud:
```json
{
    "idProducto": 101,
    "codigo": "PROD001",
    "nombre": "Producto 1 Actualizado",
    "descripcion": "Nueva descripción",
    "precio": 120.00,
    "stock": 15,
    "foto": "nueva_url_foto.jpg",
    "idEstado": 1,
    "idMarca": 3
}
```

#### Ejemplo de respuesta:
```json
{
    "id": 101,
    "message": "Producto actualizado exitosamente."
}
```

---

### Listar Productos
- **Endpoint:** `GET /products`
- **Descripción:** Devuelve una lista de productos disponibles.
- **Acceso:** Operadores (rol 2).

#### Ejemplo de respuesta:
```json
[
    {
        "idProducto": 101,
        "codigo": "PROD001",
        "nombre": "Producto 1",
        "descripcion": "Descripción del producto",
        "precio": 120.00,
        "stock": 15,
        "foto": "url_foto.jpg",
        "idEstado": 1,
        "idMarca": 3
    },
    {
        "idProducto": 102,
        "codigo": "PROD002",
        "nombre": "Producto 2",
        "descripcion": "Descripción del producto 2",
        "precio": 90.00,
        "stock": 50,
        "foto": "url_foto2.jpg",
        "idEstado": 1,
        "idMarca": 4
    }
]
```

---

## Categorías

### Insertar Categoría
- **Endpoint:** `POST /insertar-categoria`
- **Descripción:** Agrega una nueva categoría al sistema.
- **Acceso:** Operadores (rol 2).

#### Ejemplo de solicitud:
```json
{
    "nombre": "Categoría 1",
    "idEstado": 1
}
```

#### Ejemplo de respuesta:
```json
{
    "id": 10,
    "message": "Categoría insertada con éxito."
}
```

---

### Actualizar Categoría
- **Endpoint:** `PUT /actualizar-categoria`
- **Descripción:** Actualiza la información de una categoría existente.
- **Acceso:** Operadores (rol 2).

#### Ejemplo de solicitud:
```json
{
    "idCategoria": 10,
    "nombre": "Categoría 1 Actualizada",
    "idEstado": 1
}
```

#### Ejemplo de respuesta:
```json
{
    "id": 10,
    "message": "Categoría actualizada con éxito."
}
```

---

### Listar Categorías
- **Endpoint:** `GET /categorias`
- **Descripción:** Devuelve una lista de categorías disponibles.
- **Acceso:** Operadores (rol 2).

#### Ejemplo de respuesta:
```json
[
    {
        "idCategoria": 10,
        "nombre": "Categoría 1",
        "idEstado": 1
    },
    {
        "idCategoria": 11,
        "nombre": "Categoría 2",
        "idEstado": 1
    }
]
```

---

## Ordenes

### Insertar Orden
- **Endpoint:** `POST /orden`
- **Descripción:** Crea una nueva orden con sus detalles.
- **Acceso:** Clientes (rol 3).

#### Ejemplo de solicitud:
```json
{
    "fecha_entrega": "2024-12-31",
    "direccion_entrega": "Calle 123, Ciudad",
    "cupon": "DESCUENTO10",
    "observaciones": "Sin picante",
    "nombre": "Juan Perez",
    "direccion": "Calle 123, Ciudad",
    "correo": "juan@example.com",
    "telefono": "1234567890",
    "total": 150.75,
    "idEstado": 1,
    "detalles": [
        {
            "idProducto": 101,
            "cantidad": 2,
            "precio": 50.25
        },
        {
            "idProducto": 102,
            "cantidad": 1,
            "precio": 50.25
        }
    ]
}
```

#### Ejemplo de respuesta:
```json
{
    "message": "Orden creada exitosamente."
}
```

---

### Actualizar Orden
- **Endpoint:** `PUT /actualizar-orden`
- **Descripción:** Actualiza los datos de una orden existente.
- **Acceso:** Clientes (rol 3).

#### Ejemplo de solicitud:
```json
{
    "idOrden": 1,
    "fecha_entrega": "2025-01-01",
    "direccion_entrega": "Calle Actualizada 456, Ciudad",
    "cupon": "DESCUENTO20",
    "observaciones": "Sin sal",
    "nombre": "Juan Actualizado",
    "direccion": "Calle Actualizada 456, Ciudad",
    "correo": "juan_updated@example.com",
    "telefono": "0987654321",
    "total": 200.00,
    "idEstado": 1,
    "detalles": [
        {
            "idProducto": 101,
            "cantidad": 3,
            "precio": 60.00
        }
    ]
}
```

#### Ejemplo de respuesta:
```json
{
    "message": "Orden actualizada exitosamente."
}
```

---

