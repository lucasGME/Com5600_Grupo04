# Com5600_Grupo04 - Aplicación sencilla de Node.js con SQL Server
# Guía de Instalación

Esta guía describe los pasos necesarios para instalar las dependencias, configurar la conexión a base de datos y ejecutar la aplicación en un entorno local.

---

## 📋 Prerrequisitos

Antes de comenzar, verificar que **Node.js** y **npm** estén instalados en el equipo.

### Verificar versión de Node.js

```bash
node --version
```

### Verificar versión de npm

```bash
npm --version
```

---

## 📥 Instalación de Node.js

Si Node.js no se encuentra instalado, descargar e instalar la versión recomendada desde el sitio oficial:

🔗 https://nodejs.org/es/download

Una vez finalizada la instalación, volver a ejecutar los comandos anteriores para confirmar que la instalación fue exitosa.

---

## 🗄️ Configuración de SQL Server

La aplicación requiere acceso a una instancia de **SQL Server**.

### Verificar configuración de red

Asegurarse de que:

- El servicio de SQL Server se encuentre en ejecución.
- El protocolo **TCP/IP** esté habilitado.
- El puerto **1433** se encuentre habilitado y accesible.

> ⚠️ Sin esta configuración la aplicación no podrá conectarse a la base de datos.

---

## 📦 Instalación de Dependencias

Ubicarse en la carpeta raíz de la aplicación y ejecutar:

```bash
npm install
```

Este comando instalará todas las dependencias necesarias definidas en el proyecto.

---

## ⚙️ Configuración de la Conexión a Base de Datos

Modificar el archivo:

```text
aplicacion/db/conexion.js
```

Actualizar los parámetros de conexión según el entorno:

```javascript
// Configuración de conexión
const config = {
  user: '', // usuario SQL Server
  password: '', // contraseña de su conexión
  server: 'localhost', 
  database: 'BD_Parques_Nacionales',
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};
```

> 🔒 Utilizar las credenciales correspondientes al entorno donde se desplegará la aplicación.

---

## ▶️ Ejecución de la Aplicación

Ubicarse en la carpeta raíz de la aplicación y ejecutar:

```bash
node server.js
```

Si el servidor inicia correctamente, se mostrará un mensaje indicando que la aplicación está en ejecución.

---

## 🌐 Acceso a la Aplicación

Abrir el navegador y acceder a:

```text
http://localhost:3000
```

### Flujo completo

1. Verificar instalación de Node.js y npm.
2. Instalar Node.js si es necesario.
3. Verificar que SQL Server tenga habilitado TCP/IP por el puerto 1433.
4. Ejecutar `npm install`.
5. Configurar `aplicacion/db/conexion.js`.
6. Ejecutar `node server.js`.
7. Acceder a `http://localhost:3000`.
