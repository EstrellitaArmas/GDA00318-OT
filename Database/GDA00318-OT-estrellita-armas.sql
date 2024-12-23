CREATE DATABASE [GDA00318-OT-estrellita-armas];
GO

-- Usar la base de datos creada
USE [GDA00318-OT-estrellita-armas];
GO

-- 1. Crear las tablas

-- Tabla: Estados
CREATE TABLE Estados (
    idEstado INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(50) NOT NULL,
    descripcion NVARCHAR(50) NOT NULL,
	fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NOT NULL DEFAULT GETDATE(),
	idUsuario INT
);

-- Tabla: Roles
CREATE TABLE Roles (
    idRol INT PRIMARY KEY IDENTITY(1,1),
    descripcion NVARCHAR(50) NOT NULL
);

-- Tabla: Usuarios
CREATE TABLE Usuarios (
    idUsuario INT PRIMARY KEY IDENTITY(1,1),
    nombre_completo NVARCHAR(100) NOT NULL,
    correo NVARCHAR(100) UNIQUE NOT NULL,
    password NVARCHAR(255) NOT NULL,
    telefono NVARCHAR(15) NOT NULL,
    fecha_nacimiento DATETIME NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NOT NULL DEFAULT GETDATE(),
    idEstado INT NOT NULL,
    idRol INT NOT NULL,
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (idRol) REFERENCES Roles(idRol) ON UPDATE NO ACTION,
    CONSTRAINT FK_Usuarios_Estados FOREIGN KEY (idEstado) REFERENCES Estados(idEstado) ON UPDATE NO ACTION,
);

-- Agregar las claves foráneas después de la creación de las tablas
ALTER TABLE Estados
ADD CONSTRAINT FK_Estados_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario) ON UPDATE NO ACTION;

ALTER TABLE Usuarios
ADD CONSTRAINT FK_Usuarios_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario) ON UPDATE NO ACTION;

-- Tabla: Clientes
CREATE TABLE Clientes (
    idCliente INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(100) NOT NULL,
    razon_social NVARCHAR(245) NOT NULL,
    direccion NVARCHAR(245) NOT NULL,
    correo NVARCHAR(100) UNIQUE NOT NULL,
	password NVARCHAR(255) NOT NULL,
    telefono NVARCHAR(15),
	fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NOT NULL DEFAULT GETDATE(),
	idUsuario INT NOT NULL,
	idEstado INT NOT NULL,
    CONSTRAINT FK_Clientes_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario) ON UPDATE NO ACTION,
	CONSTRAINT FK_Clientes_Estados FOREIGN KEY (idEstado) REFERENCES Estados(idEstado) ON UPDATE NO ACTION,
);

-- Tabla: Marcas
CREATE TABLE Marcas (
    idMarca INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(100) NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NOT NULL DEFAULT GETDATE(),
	idUsuario INT NOT NULL,
	idEstado INT NOT NULL,
    CONSTRAINT FK_Marcas_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario) ON UPDATE NO ACTION,
	CONSTRAINT FK_Marcas_Estados FOREIGN KEY (idEstado) REFERENCES Estados(idEstado) ON UPDATE NO ACTION
);

-- Tabla: Productos
CREATE TABLE Productos (
    idProducto INT PRIMARY KEY IDENTITY(1,1),
    codigo NVARCHAR(100) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(255),
    precio DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL,
    foto NVARCHAR(255), -- URL de almacenamiento en la nube
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NOT NULL DEFAULT GETDATE(),
    idEstado INT NOT NULL,
    idMarca INT NOT NULL,
	idUsuario INT NOT NULL,
    CONSTRAINT FK_Productos_Estados FOREIGN KEY (idEstado) REFERENCES Estados(idEstado) ON UPDATE NO ACTION,
    CONSTRAINT FK_Productos_Marcas FOREIGN KEY (idMarca) REFERENCES Marcas(idMarca) ON UPDATE NO ACTION,
	CONSTRAINT FK_Productos_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario) ON UPDATE NO ACTION
);

-- Tabla: Categorias
CREATE TABLE Categorias (
    idCategoria INT PRIMARY KEY IDENTITY(1,1),
    nombre NVARCHAR(100) NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NOT NULL DEFAULT GETDATE(),
	idUsuario INT NOT NULL,
	idEstado INT NOT NULL,
	CONSTRAINT FK_Categorias_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario) ON UPDATE NO ACTION,
	CONSTRAINT FK_Categorias_Estados FOREIGN KEY (idEstado) REFERENCES Estados(idEstado) ON UPDATE NO ACTION,
);

-- Tabla: ProductosCategorias (Relación muchos a muchos)
CREATE TABLE ProductosCategorias (
    idProducto INT NOT NULL,
    idCategoria INT NOT NULL,
    CONSTRAINT FK_ProductosCategorias_Productos FOREIGN KEY (idProducto) REFERENCES Productos(idProducto) ON UPDATE NO ACTION,
    CONSTRAINT FK_ProductosCategorias_Categorias FOREIGN KEY (idCategoria) REFERENCES Categorias(idCategoria) ON UPDATE NO ACTION,
    PRIMARY KEY (idProducto, idCategoria)
);

-- Tabla: Orden
CREATE TABLE Orden (
    idOrden INT PRIMARY KEY IDENTITY(1,1),
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_entrega DATETIME NOT NULL,
    fecha_modificacion DATETIME NOT NULL DEFAULT GETDATE(),
    direccion_entrega NVARCHAR(245) NOT NULL,
    cupon NVARCHAR(100),
    observaciones NVARCHAR(100),
    nombre NVARCHAR(100) NOT NULL,
    direccion NVARCHAR(245) NOT NULL,
    correo NVARCHAR(100) NOT NULL,
    telefono NVARCHAR(15) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    idUsuario INT NOT NULL,
    idEstado INT NOT NULL,
    CONSTRAINT FK_Orden_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario) ON UPDATE NO ACTION,
    CONSTRAINT FK_Orden_Estados FOREIGN KEY (idEstado) REFERENCES Estados(idEstado) ON UPDATE NO ACTION
);

-- Tabla: DetalleOrden
CREATE TABLE DetalleOrden (
    idDetalleOrden INT PRIMARY KEY IDENTITY(1,1),
    idOrden INT NOT NULL,
    idProducto INT NOT NULL,
    cantidad INT NOT NULL,
    descuento DECIMAL(10, 2),
    precioUnitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
	idUsuario INT NOT NULL,
    idEstado INT NOT NULL,
    CONSTRAINT FK_DetalleOrden_Usuarios FOREIGN KEY (idUsuario) REFERENCES Usuarios(idUsuario) ON UPDATE NO ACTION,
    CONSTRAINT FK_DetalleOrden_Estados FOREIGN KEY (idEstado) REFERENCES Estados(idEstado) ON UPDATE NO ACTION,
    CONSTRAINT FK_DetalleOrden_Orden FOREIGN KEY (idOrden) REFERENCES Orden(idOrden) ON UPDATE NO ACTION,
    CONSTRAINT FK_DetalleOrden_Productos FOREIGN KEY (idProducto) REFERENCES Productos(idProducto) ON UPDATE NO ACTION
);


------------------------------------------------------------------------------------------------------------------------------
-- Usar la base de datos creada
USE [GDA00318-OT-estrellita-armas];
GO

CREATE PROCEDURE InsertarUsuario
    @nombre_completo NVARCHAR(100),
    @correo NVARCHAR(100),
    @password NVARCHAR(255),
    @telefono NVARCHAR(15),
    @fecha_nacimiento DATETIME,
    @idEstado INT,
    @idRol INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar si el correo ya existe
        IF EXISTS (SELECT 1 FROM Usuarios WHERE correo = @correo)
        BEGIN
            PRINT 'Error: El correo ya está registrado.';
            RETURN;
        END;

        -- Si el correo no existe, insertar el nuevo usuario
        INSERT INTO Usuarios (nombre_completo, correo, password, telefono, fecha_nacimiento, idEstado, idRol)
		VALUES (@nombre_completo, @correo,HASHBYTES('SHA2_256', @password), @telefono, @fecha_nacimiento, @idEstado, @idRol)

        -- Confirmar éxito
        PRINT 'Usuario insertado correctamente.';
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        PRINT 'Ocurrió un error al insertar el usuario.';
        PRINT ERROR_MESSAGE(); -- Muestra el mensaje del error
    END CATCH
END;
GO

CREATE PROCEDURE ActualizarUsuario
    @idUsuario INT,
    @nombre_completo NVARCHAR(100),
    @correo NVARCHAR(100),
    @telefono NVARCHAR(15),
    @fecha_nacimiento DATETIME,
    @idEstado INT,
    @idRol INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validar si el usuario existe
        IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE idUsuario = @idUsuario)
        BEGIN
            PRINT 'Error: El usuario no existe.';
            RETURN;
        END;

        -- Validar si el correo ya está en uso por otro usuario
        IF EXISTS (SELECT 1 FROM Usuarios WHERE correo = @correo AND idUsuario <> @idUsuario)
        BEGIN
            PRINT 'Error: El correo ya está asociado a otro usuario.';
            RETURN;
        END;

        -- Actualizar los datos del usuario
        UPDATE Usuarios
		SET nombre_completo = @nombre_completo,
			correo = @correo,
			telefono = @telefono,
			fecha_nacimiento = @fecha_nacimiento,
			idEstado = @idEstado,
			idRol = @idRol,
			fecha_modificacion = GETDATE()
		WHERE idUsuario = @idUsuario

        -- Confirmar éxito
        PRINT 'Usuario actualizado correctamente.';
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        PRINT 'Ocurrió un error al actualizar el usuario.';
        PRINT ERROR_MESSAGE(); -- Mostrar mensaje del error
    END CATCH
END;
GO

CREATE PROCEDURE CambiarContrasenaUsuario
    @correo NVARCHAR(100),          -- Correo del usuario
    @nuevaPassword NVARCHAR(255)    -- Nueva contraseña
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar si el correo existe
    IF NOT EXISTS (SELECT 1 FROM Usuarios WHERE correo = @correo)
    BEGIN
        PRINT 'Error: El correo no existe .';
        RETURN;
    END;

    -- Actualizar la contraseña del usuario
    UPDATE Usuarios
    SET password = HASHBYTES('SHA2_256', @nuevaPassword),
        fecha_modificacion = GETDATE()
    WHERE correo = @correo;

    PRINT 'La contraseña se actualizó correctamente.';
END;
GO

CREATE PROCEDURE AuthenticarUsuario
    @correo NVARCHAR(100),
    @password NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Variable para almacenar la contraseña hasheada de la base de datos
    DECLARE @passwordHashed NVARCHAR(255);
    
    -- Buscar el usuario por correo
    SELECT @passwordHashed = password
    FROM Usuarios
    WHERE correo = @correo;

    -- Verificar si el correo existe
    IF @passwordHashed IS NULL
    BEGIN
        -- Si no existe el usuario, devolver error 404
        RAISERROR('Usuario no encontrado', 16, 1);
        RETURN;
    END
    
    -- Generar el hash de la contraseña proporcionada usando SHA2_256
    DECLARE @hashedPassword NVARCHAR(255);
    SET @hashedPassword =  HASHBYTES('SHA2_256', @password);

    -- Comparar la contraseña proporcionada con la almacenada
    IF @hashedPassword != @passwordHashed
    BEGIN
        -- Si las contraseñas no coinciden, devolver error 403
        RAISERROR('Contraseña incorrecta', 16, 1);
        RETURN;
    END

    -- Si la validación fue exitosa, devolver los detalles del usuario
    SELECT idUsuario, nombre_completo, correo, telefono, fecha_nacimiento, fecha_creacion, fecha_modificacion, idEstado, idRol
    FROM Usuarios
    WHERE correo = @correo;
END;
GO

CREATE PROCEDURE InsertarProducto
    @codigo NVARCHAR(100),
    @nombre NVARCHAR(100),
    @descripcion NVARCHAR(255),
    @precio DECIMAL(10, 2),
    @stock INT,
    @foto NVARCHAR(255),
    @idEstado INT,
    @idMarca INT,
	@idUsuario INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Productos WHERE codigo = @codigo)
    BEGIN
        PRINT 'Error: El código del producto ya existe.'
        RETURN
    END

    INSERT INTO Productos (codigo, nombre, descripcion, precio, stock, foto, idEstado, idMarca,idUsuario)
    VALUES (@codigo, @nombre, @descripcion, @precio, @stock, @foto, @idEstado, @idMarca,@idUsuario)

	-- Obtenemos el ID del producto insertado
    DECLARE @idProducto INT = SCOPE_IDENTITY();

    -- Seleccionamos el producto insertado
    SELECT 
        p.idProducto, p.codigo, p.nombre, p.descripcion, p.precio, p.stock, p.foto, p.idEstado, p.idMarca, p.idUsuario
    FROM Productos p
    WHERE p.idProducto = @idProducto;
	
END
GO


CREATE PROCEDURE ActualizarProducto
    @idProducto INT,
    @codigo NVARCHAR(100),
    @nombre NVARCHAR(100),
    @descripcion NVARCHAR(255),
    @precio DECIMAL(10, 2),
    @stock INT,
    @foto NVARCHAR(255),
    @idEstado INT,
    @idMarca INT,
	@idUsuario INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Productos WHERE codigo = @codigo AND idProducto <> @idProducto)
    BEGIN
        PRINT 'Error: El código del producto ya existe para otro producto.'
        RETURN
    END

    UPDATE Productos
    SET codigo = @codigo,
        nombre = @nombre,
        descripcion = @descripcion,
        precio = @precio,
        stock = @stock,
        foto = @foto,
        idEstado = @idEstado,
        idMarca = @idMarca,
		idUsuario = @idUsuario,
		fecha_modificacion = GETDATE()
    WHERE idProducto = @idProducto

	 -- Seleccionamos el producto insertado
    SELECT 
        p.idProducto, p.codigo, p.nombre, p.descripcion, p.precio, p.stock, p.foto, p.idEstado, p.idMarca, p.idUsuario
    FROM Productos p
    WHERE p.idProducto = @idProducto;
	
END
GO


CREATE PROCEDURE InactivarProducto
    @idProducto INT,
    @idEstado INT,
	@idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Actualizar el estado del producto para inactivarlo
    UPDATE Productos
    SET idEstado = @idEstado,	
		idUsuario = @idUsuario,
		fecha_modificacion = GETDATE()
    WHERE idProducto = @idProducto;
END;
GO

CREATE PROCEDURE InsertarCliente
    @nombre NVARCHAR(100),
    @razon_social NVARCHAR(245),
    @direccion NVARCHAR(245),
    @correo NVARCHAR(100),
	@password NVARCHAR(255),
    @telefono NVARCHAR(15),
	@idUsuario INT,
	@idEstado INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Clientes WHERE correo = @correo)
    BEGIN
        PRINT 'Error: El correo ya existe en la tabla Clientes.'
        RETURN
    END

    INSERT INTO Clientes (nombre, razon_social, direccion, correo, password, telefono,idUsuario,idEstado)
    VALUES (@nombre, @razon_social, @direccion, @correo, HASHBYTES('SHA2_256', @password), @telefono,@idUsuario,@idEstado)
END
GO


CREATE PROCEDURE ActualizarCliente
    @idCliente INT,
    @nombre NVARCHAR(100),
    @razon_social NVARCHAR(245),
    @direccion NVARCHAR(245),
    @correo NVARCHAR(100),
    @telefono NVARCHAR(15),
	@idUsuario INT,
	@idEstado INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Clientes WHERE correo = @correo AND idCliente <> @idCliente)
    BEGIN
        PRINT 'Error: El correo ya existe en la tabla Clientes para otro cliente.'
        RETURN
    END

    UPDATE Clientes
    SET nombre = @nombre,
        razon_social = @razon_social,
        direccion = @direccion,
        correo = @correo,
        telefono = @telefono,
		idUsuario = @idUsuario,
		idEstado = @idEstado,
		fecha_modificacion = GETDATE()
    WHERE idCliente = @idCliente
END
GO

CREATE PROCEDURE CambiarContrasenaCliente
    @correo NVARCHAR(100),          -- Correo del usuario
    @passwordActual NVARCHAR(255),  -- Contraseña actual
    @nuevaPassword NVARCHAR(255)    -- Nueva contraseña
AS
BEGIN
    SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM Clientes WHERE correo = @correo)
    BEGIN
        PRINT 'Error: El correo no existe.'
        RETURN
    END

    -- Actualizar la contraseña del usuario
    UPDATE Clientes
    SET password = HASHBYTES('SHA2_256', @nuevaPassword),
        fecha_modificacion = GETDATE()
    WHERE correo = @correo;

    PRINT 'La contraseña se actualizó correctamente.';
END;
GO

CREATE PROCEDURE InsertarEstado
    @nombre NVARCHAR(50),
    @descripcion NVARCHAR(50)
AS
BEGIN
    INSERT INTO Estados (nombre, descripcion)
    VALUES (@nombre, @descripcion)
END
GO

CREATE PROCEDURE ActualizarEstado
    @idEstado INT,
    @nombre NVARCHAR(50),
    @descripcion NVARCHAR(50),
	@idUsuario INT
AS
BEGIN
    UPDATE Estados
    SET nombre = @nombre,
        descripcion = @descripcion,
		idUsuario = @idUsuario,
		fecha_modificacion = GETDATE()
    WHERE idEstado = @idEstado
END
GO


CREATE PROCEDURE InsertarMarca
    @nombre NVARCHAR(100),
	@idUsuario INT,
	@idEstado INT
AS
BEGIN
    INSERT INTO Marcas (nombre,idUsuario,idEstado)
    VALUES (@nombre,@idUsuario,@idEstado)
END
GO

CREATE PROCEDURE ActualizarMarca
    @idMarca INT,
    @nombre NVARCHAR(100),
	@idUsuario INT,
	@idEstado INT
AS
BEGIN
    UPDATE Marcas
    SET nombre = @nombre,
	    idUsuario = @idUsuario,
		idEstado = @idEstado,
        fecha_modificacion = GETDATE()
    WHERE idMarca = @idMarca
END
GO

CREATE PROCEDURE InsertarCategoria
    @nombre NVARCHAR(100),
	@idUsuario INT,
	@idEstado INT
AS
BEGIN
    INSERT INTO Categorias (nombre,idUsuario,idEstado)
    VALUES (@nombre,@idUsuario,@idEstado)

	-- Obtenemos el ID del producto insertado
    DECLARE @idCategoria INT = SCOPE_IDENTITY();

    -- Seleccionamos el producto insertado
    SELECT c.idCategoria
      ,c.nombre
      ,c.fecha_creacion
      ,c.fecha_modificacion
      ,c.idUsuario
      ,c.idEstado
	  FROM Categorias c 
	  WHERE c.idCategoria = @idCategoria

END
GO

CREATE PROCEDURE ActualizarCategoria
    @idCategoria INT,
    @nombre NVARCHAR(100),
	@idUsuario INT,
	@idEstado INT
AS
BEGIN
    UPDATE Categorias
    SET nombre = @nombre,
		idUsuario = @idUsuario,
		idEstado = @idEstado,
        fecha_modificacion = GETDATE()
    WHERE idCategoria = @idCategoria

	-- Devolvemos la categoria actualizada
    SELECT c.idCategoria
      ,c.nombre
      ,c.fecha_creacion
      ,c.fecha_modificacion
      ,c.idUsuario
      ,c.idEstado
	  FROM Categorias c 
	  WHERE c.idCategoria = @idCategoria

END
GO

CREATE PROCEDURE InsertarOrdenConDetalles
    @fecha_entrega DATETIME,
    @direccion_entrega NVARCHAR(245),
    @cupon NVARCHAR(100),
    @observaciones NVARCHAR(100),
    @nombre NVARCHAR(100),
    @direccion NVARCHAR(245),
    @correo NVARCHAR(100),
    @telefono NVARCHAR(15),
    @total DECIMAL(10, 2),
    @idUsuario INT,
    @idEstado INT,
    @detalles NVARCHAR(MAX) -- JSON con los detalles de la orden
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insertar la orden principal
        DECLARE @idOrden INT;

        INSERT INTO Orden (fecha_entrega, direccion_entrega, cupon, observaciones, nombre, direccion, correo, telefono, total, idUsuario, idEstado)
        VALUES (@fecha_entrega, @direccion_entrega, @cupon, @observaciones, @nombre, @direccion, @correo, @telefono, @total, @idUsuario, @idEstado);

        -- Obtener el idOrden generado
        SET @idOrden = SCOPE_IDENTITY();

        -- Insertar los detalles de la orden
        INSERT INTO DetalleOrden (idOrden, idProducto, cantidad, descuento, precioUnitario, subtotal, idUsuario, idEstado)
        SELECT 
            @idOrden AS idOrden,
            JSON_VALUE(detalle.value, '$.idProducto') AS idProducto,
            JSON_VALUE(detalle.value, '$.cantidad') AS cantidad,
            JSON_VALUE(detalle.value, '$.descuento') AS descuento,
            JSON_VALUE(detalle.value, '$.precioUnitario') AS precioUnitario,
            JSON_VALUE(detalle.value, '$.subtotal') AS subtotal,
            JSON_VALUE(detalle.value, '$.idUsuario') AS idUsuario,
            JSON_VALUE(detalle.value, '$.idEstado') AS idEstado
        FROM OPENJSON(@detalles) AS detalle;

        -- Confirmar la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Revertir la transacción en caso de error
        ROLLBACK TRANSACTION;

        -- Lanza el error para el manejo externo
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE ActualizarOrdenConDetalles
    @idOrden INT,
    @fecha_entrega DATETIME,
    @direccion_entrega NVARCHAR(245),
    @cupon NVARCHAR(100),
    @observaciones NVARCHAR(100),
    @nombre NVARCHAR(100),
    @direccion NVARCHAR(245),
    @correo NVARCHAR(100),
    @telefono NVARCHAR(15),
    @total DECIMAL(10, 2),
    @idUsuario INT,
    @idEstado INT,
    @detalles NVARCHAR(MAX) -- JSON con los detalles de la orden
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que el idOrden exista
        IF NOT EXISTS (SELECT 1 FROM Orden WHERE idOrden = @idOrden)
        BEGIN
            THROW 50001, 'El idOrden no existe en la tabla Orden.', 1;
        END

        -- Actualizar la orden principal
        UPDATE Orden
        SET fecha_entrega = @fecha_entrega,
            direccion_entrega = @direccion_entrega,
            cupon = @cupon,
            observaciones = @observaciones,
            nombre = @nombre,
            direccion = @direccion,
            correo = @correo,
            telefono = @telefono,
            total = @total,
            idUsuario = @idUsuario,
            idEstado = @idEstado
        WHERE idOrden = @idOrden;

        -- Actualizar el estado de los detalles existentes de la orden
        UPDATE DetalleOrden
        SET idEstado = @idEstado
        WHERE idOrden = @idOrden;

        -- Insertar los nuevos detalles de la orden
        INSERT INTO DetalleOrden (idOrden, idProducto, cantidad, descuento, precioUnitario, subtotal, idUsuario, idEstado)
        SELECT 
            @idOrden AS idOrden,
            JSON_VALUE(detalle.value, '$.idProducto') AS idProducto,
            JSON_VALUE(detalle.value, '$.cantidad') AS cantidad,
            JSON_VALUE(detalle.value, '$.descuento') AS descuento,
            JSON_VALUE(detalle.value, '$.precioUnitario') AS precioUnitario,
            JSON_VALUE(detalle.value, '$.subtotal') AS subtotal,
            JSON_VALUE(detalle.value, '$.idUsuario') AS idUsuario,
            JSON_VALUE(detalle.value, '$.idEstado') AS idEstado
        FROM OPENJSON(@detalles) AS detalle;

        -- Confirmar la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Revertir la transacción en caso de error
        ROLLBACK TRANSACTION;

        -- Lanza el error para el manejo externo
        THROW;
    END CATCH
END
GO


CREATE PROCEDURE InsertarRol
    @descripcion NVARCHAR(50)
AS
BEGIN
    INSERT INTO Roles (descripcion)
    VALUES (@descripcion)
END
GO

CREATE PROCEDURE ActualizarRol
    @idRol INT,
    @descripcion NVARCHAR(50)
AS
BEGIN
    UPDATE Roles
    SET descripcion = @descripcion
    WHERE idRol = @idRol
END
GO


-----------------------------------------------------------------------------------------------------------------------------


USE [GDA00318-OT-estrellita-armas];
GO


EXEC InsertarRol 'Administrador';
EXEC InsertarRol 'Operador';
EXEC InsertarRol 'Cliente';


EXEC InsertarEstado 'Activo', 'El estado indica que está disponible';
EXEC InsertarEstado 'Inactivo', 'El estado indica que está deshabilitado';
EXEC InsertarEstado 'Pendiente', 'Estado en espera de acción';
EXEC InsertarEstado 'En proceso', 'Se está ejecutando la acción';
EXEC InsertarEstado 'Completado', 'La acción fue finalizada';
EXEC InsertarEstado 'Cancelado', 'La acción fue detenida';
EXEC InsertarEstado 'Rechazado', 'Solicitud rechazada';
EXEC InsertarEstado 'Aprobado', 'Solicitud aprobada';
EXEC InsertarEstado 'En revisión', 'Pendiente de aprobación/revisión';
EXEC InsertarEstado 'Suspendido', 'Acción suspendida temporalmente';
EXEC InsertarEstado 'Finalizado', 'Proceso terminado exitosamente';
EXEC InsertarEstado 'Disponible', 'Elemento disponible para uso';
EXEC InsertarEstado 'No disponible', 'Elemento no está disponible';
EXEC InsertarEstado 'Reservado', 'Elemento reservado';
EXEC InsertarEstado 'Confirmado', 'Acción confirmada';
EXEC InsertarEstado 'Expirado', 'Elemento fuera de tiempo';
EXEC InsertarEstado 'Pagado', 'Orden o servicio pagado';
EXEC InsertarEstado 'No pagado', 'Orden o servicio pendiente de pago';
EXEC InsertarEstado 'Devuelto', 'Producto o servicio regresado';
EXEC InsertarEstado 'En tránsito', 'Elemento en camino';


EXEC InsertarUsuario 'Juan Pérez', 'juan.perez@example.com', 'securePass123', '41112222', '1990-03-15', 1, 1;  -- ADMINISTRADOR
EXEC InsertarUsuario 'María López', 'maria.lopez@example.com', 'password123', '42223333', '1985-07-20', 1, 2; -- OPERADOR 
EXEC InsertarUsuario 'Carlos Ramírez', 'carlos.ramirez@example.com', 'mypassword!', '43334444', '1992-12-01', 1, 2;  
EXEC InsertarUsuario 'Ana González', 'ana.gonzalez@example.com', 'StrongPass2024', '44445555', '1988-05-10', 1, 2;
EXEC InsertarUsuario 'Luis Torres', 'luis.torres@example.com', 'Torres@456', '4468666', '1993-01-25', 1, 2;
EXEC InsertarUsuario 'Sofía Rivera', 'sofia.rivera@example.com', 'Rivera123!', '46667777', '1990-08-30', 1, 2;
EXEC InsertarUsuario 'Pedro Sánchez', 'pedro.sanchez@example.com', 'SafePass321', '47778888', '1987-03-14', 1, 2;
EXEC InsertarUsuario 'Lucía Martínez', 'lucia.martinez@example.com', 'LuciaPass!', '48889999', '1995-11-22', 2, 2;
EXEC InsertarUsuario 'Diego Hernández', 'diego.hernandez@example.com', 'Hernandez2024', '49990000', '1989-06-05', 1, 2;
EXEC InsertarUsuario 'Laura Vega', 'laura.vega@example.com', 'Vega@456', '40001111', '1991-10-18', 2, 2;
EXEC InsertarUsuario 'Manuel Ortiz', 'manuel.ortiz@example.com', 'OrtizSecure!', '41112223', '1986-09-09', 1, 2;
EXEC InsertarUsuario 'Isabel Romero', 'isabel.romero@example.com', 'RomeroPass!', '42223334', '1994-12-25', 2, 2;
EXEC InsertarUsuario 'Clara Castillo', 'clara.castillo@example.com', 'Castillo123!', '43334445', '1990-07-07', 2,2;
EXEC InsertarUsuario 'Pablo Flores', 'pablo.flores@example.com', 'Flores#2024', '44445556', '1989-05-03', 1, 2;
EXEC InsertarUsuario 'Enrique Navarro', 'enrique.navarro@example.com', 'Navarro@456', '446667', '199204-12', 1, 2;
EXEC InsertarUsuario 'Carolina Rojas', 'carolina.rojas@example.com', 'Rojas#123', '46667778', '1987-08-29', 2, 2;
EXEC InsertarUsuario 'Jorge Ramos', 'jorge.ramos@example.com', 'Ramos2024!', '47778889', '1986-11-01', 1, 2;
EXEC InsertarUsuario 'Paula Díaz', 'paula.diaz@example.com', 'Paula@2024', '48889990', '1995-01-17', 2, 2;
EXEC InsertarUsuario 'Alberto Méndez', 'alberto.mendez@example.com', 'Mendez@456', '49990001', '1993-03-10', 1, 2 ;
EXEC InsertarUsuario 'Rosa García', 'rosa.garcia@example.com', 'Garcia#Secure!', '40001112', '1994-12-21', 2, 2;

EXEC InsertarCliente 'Juan Pérez', 'JP Consulting S.A.', 'Calle 123', 'juan.perez@example.com', 'aB1cD2eF3G', '41234567', 1, 1;
EXEC InsertarCliente 'Ana López', 'AL Designs', 'Av. Principal 456', 'ana.lopez@example.com', '1aB2cD3eF4', '42345678', 1, 1;
EXEC InsertarCliente 'Carlos Ramírez', 'CR Distribuciones', 'Calle Secundaria 789', 'carlos.ramirez@example.com', '5gH6iJ7kL8', '43456789', 1, 1;
EXEC InsertarCliente 'María González', 'MG Marketing', 'Boulevard Norte 101', 'maria.gonzalez@example.com', '9iJ0kL1mN2', '44567890', 1, 1;
EXEC InsertarCliente 'Luis Torres', 'LT Ingeniería', 'Calle Sur 202', 'luis.torres@example.com', 'O3pQ4rS5tU', '45678901', 1, 1;
EXEC InsertarCliente 'Lucía Martínez', 'LM Software', 'Av. Oeste 303', 'lucia.martinez@example.com', 'V6wX7yZ8uK', '46789012', 1, 1;
EXEC InsertarCliente 'Pedro Sánchez', 'PS Construcciones', 'Calle Este 404', 'pedro.sanchez@example.com', 'L9zA0bC1dE', '47890123', 1, 1;
EXEC InsertarCliente 'Sofía Rivera', 'SR Eventos', 'Av. Central 505', 'sofia.rivera@example.com', 'F2gH3iJ4kL', '48901234', 1, 1;
EXEC InsertarCliente 'Diego Hernández', 'DH Logística', 'Boulevard Sur 606', 'diego.hernandez@example.com', 'M5nO6pQ7rS', '49012345', 1, 1;
EXEC InsertarCliente 'Clara Castillo', 'CC Textiles', 'Calle 707', 'clara.castillo@example.com', 'D8sT9uV0wX', '40123456', 1, 1;
EXEC InsertarCliente 'Pablo Flores', 'PF Electrónica', 'Av. 808', 'pablo.flores@example.com', 'Y1nZ2vA3bC', '41234567', 1, 1;
EXEC InsertarCliente 'Laura Vega', 'LV Consultores', 'Boulevard 909', 'laura.vega@example.com', 'B4gF5hG6iH', '42345678', 1, 1;
EXEC InsertarCliente 'Jorge Ramos', 'JR Publicidad', 'Calle 1010', 'jorge.ramos@example.com', 'K7lM8nP9qR', '43456789', 1, 1;
EXEC InsertarCliente 'Paula Díaz', 'PD Soluciones', 'Av. 1111', 'paula.diaz@example.com', 'S1wT2uV3xL', '44567890', 1, 1;
EXEC InsertarCliente 'Manuel Ortiz', 'MO Transportes', 'Boulevard 1212', 'manuel.ortiz@example.com', 'J9tQ0yR1zN', '45678901', 1, 1;
EXEC InsertarCliente 'Isabel Romero', 'IR Alimentos', 'Calle 1313', 'isabel.romero@example.com', 'E2vS3wF4gH', '46789012', 1, 1;
EXEC InsertarCliente 'Alberto Méndez', 'AM Tecnologías', 'Av. 1414', 'alberto.mendez@example.com', 'I5lJ6mK7nO', '47890123', 1, 1;
EXEC InsertarCliente 'Rosa García', 'RG Emprendimientos', 'Boulevard 1515', 'rosa.garcia@example.com', 'P8oQ9rS0tU', '48901234', 1, 1;
EXEC InsertarCliente 'Enrique Navarro', 'EN Servicios', 'Calle 1616', 'enrique.navarro@example.com', 'B1vC2wX3yN', '49012345', 1, 1;
EXEC InsertarCliente 'Carolina Rojas', 'CR Producciones', 'Av. 1717', 'carolina.rojas@example.com', 'T4sU5vW6yK', '40123456', 1, 1;


EXEC InsertarMarca 'Lenovo',1, 1;
EXEC InsertarMarca 'Logitech',1, 1;
EXEC InsertarMarca 'Razer',1, 1;
EXEC InsertarMarca 'Samsung',1, 1;
EXEC InsertarMarca 'Sony',1, 1;
EXEC InsertarMarca 'Epson',1, 1;
EXEC InsertarMarca 'TP-Link',1, 1;
EXEC InsertarMarca 'Canon',1, 1;
EXEC InsertarMarca 'Western Digital',1, 1;
EXEC InsertarMarca 'Kingston',1, 1;
EXEC InsertarMarca 'Corsair',1, 1;

EXEC InsertarCategoria 'Categoría 1',1, 1;
EXEC InsertarCategoria 'Categoría 2',1, 1;

EXEC InsertarProducto 'P101', 'Laptop Lenovo', 'Laptop para oficina', 899.99, 25, 'http://img.laptop1.com', 1, 1,1;
EXEC InsertarProducto 'P102', 'Mouse Logitech', 'Mouse inalámbrico', 49.99, 100, 'http://img.mouse1.com', 1, 2,1;
EXEC InsertarProducto 'P103', 'Teclado Mecánico', 'Teclado gamer RGB', 120.00, 50, 'http://img.keyboard1.com', 1, 1,1;
EXEC InsertarProducto 'P104', 'Monitor Samsung', 'Monitor 27 pulgadas', 299.00, 30, 'http://img.monitor1.com', 1, 3,1;
EXEC InsertarProducto 'P105', 'Audífonos Sony', 'Audífonos inalámbricos', 159.99, 40, 'http://img.headphones1.com', 1, 2,1;
EXEC InsertarProducto 'P106', 'Impresora Epson', 'Impresora multifunción', 199.00, 20, 'http://img.printer1.com', 1, 4,1;
EXEC InsertarProducto 'P107', 'Router TP-Link', 'Router Wi-Fi 6', 79.99, 60, 'http://img.router1.com', 1, 3,1;
EXEC InsertarProducto 'P108', 'Cámara Canon', 'Cámara profesional', 1200.00, 10, 'http://img.camera1.com', 1, 1,1;
EXEC InsertarProducto 'P109', 'Disco Duro WD', 'Disco externo 1TB', 89.99, 70, 'http://img.hdd1.com', 1, 2,1;
EXEC InsertarProducto 'P110', 'Memoria USB', 'USB 64GB Kingston', 15.00, 200, 'http://img.usb1.com', 1, 1,1;
EXEC InsertarProducto 'P111', 'Tablet Samsung', 'Tablet Galaxy Tab', 499.00, 15, 'http://img.tablet1.com', 1, 4,1;
EXEC InsertarProducto 'P112', 'Cargador Rápido', 'Cargador para móviles', 25.00, 150, 'http://img.charger1.com', 1, 2,1;
EXEC InsertarProducto 'P113', 'Smartwatch', 'Reloj inteligente', 249.99, 20, 'http://img.watch1.com', 1, 3,1;
EXEC InsertarProducto 'P114', 'Bocina JBL', 'Bocina Bluetooth', 99.99, 50, 'http://img.speaker1.com', 1, 2,1;
EXEC InsertarProducto 'P115', 'Control PS5', 'Control inalámbrico', 69.99, 100, 'http://img.controller1.com', 1, 4,1;
EXEC InsertarProducto 'P116', 'Silla Gamer', 'Silla ergonómica', 329.00, 5, 'http://img.chair1.com', 1, 3,1;
EXEC InsertarProducto 'P117', 'MicroSD 128GB', 'Memoria para móviles', 35.00, 180, 'http://img.microsd1.com', 1, 2,1;
EXEC InsertarProducto 'P118', 'Switch Cisco', 'Switch de red 24 puertos', 499.99, 8, 'http://img.switch1.com', 1, 1,1;
EXEC InsertarProducto 'P119', 'Cable HDMI', 'Cable 4K 2 metros', 12.99, 300, 'http://img.hdmi1.com', 1, 2,1;
EXEC InsertarProducto 'P120', 'Fuente Corsair', 'Fuente 750W modular', 129.00, 30, 'http://img.psu1.com', 1, 4,1;


