const sql = require('mssql');

// Configuración de conexión
const config = {
  user: '', // usuario SQL Server
  password: '', // contraseña de su conexión
  server: 'localhost', // 'localhost' o 'NOMBRE_PC\\SQLEXPRESS' -> fijarse con SELECT @@SERVERNAME en SQL Server
  database: 'BD_Parques_Nacionales',
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

module.exports = { sql, config };