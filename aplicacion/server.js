const express = require('express');
const { sql, config } = require('./db/conexion');

const app = express();

const path = require('path');
app.use(express.static('public'));

app.use(express.json());


// Función para ejecutar procedimientos almacenados ABM
async function ejecutarSpParque(nombreSp, parametros) {
  const pool = await sql.connect(config);
  const request = pool.request();

  for (const parametro of parametros) {
    request.input(parametro.nombre, parametro.tipo, parametro.valor);
  }

  return request.execute(nombreSp);
}

/*---------------------------------------------------------------------------------------
---------- ENPOINTS ABM PARQUE ----------------------------------------------------------
---------------------------------------------------------------------------------------*/

// GET parques
app.get('/parques', async (req, res) => {
  try {
    await sql.connect(config);
    const result = await sql.query('SELECT * FROM parques.parque');
    res.json(result.recordset);
  }
    catch (err) {
    console.error('Error al obtener parques:', err);
    res.status(500).json({ error: 'Error al obtener parques' });
  }
});

// POST parque
app.post('/parques', async (req, res) => {
  try {
    const {
      nombre,
      direccion,
      latitud,
      longitud,
      superficie_km2,
      id_localidad,
      id_tipo_parque,
    } = req.body;

    await ejecutarSpParque('parques.sp_parque_alta', [
      { nombre: 'nombre', tipo: sql.VarChar(150), valor: nombre },
      { nombre: 'direccion', tipo: sql.VarChar(200), valor: direccion },
      { nombre: 'latitud', tipo: sql.Decimal(9, 6), valor: latitud },
      { nombre: 'longitud', tipo: sql.Decimal(9, 6), valor: longitud },
      { nombre: 'superficie_km2', tipo: sql.Decimal(10, 2), valor: superficie_km2 },
      { nombre: 'id_localidad', tipo: sql.Int, valor: id_localidad },
      { nombre: 'id_tipo_parque', tipo: sql.Int, valor: id_tipo_parque },
    ]);

    res.status(201).json({ message: 'Parque creado correctamente' });
  } catch (err) {
    console.error('Error al crear parque:', err);
    res.status(400).json({ error: err.message });
  }
});

// PUT parque
app.put('/parques/:id_parque', async (req, res) => {
  try {
    const idParque = parseInt(req.params.id_parque, 10);
    const {
      nombre,
      direccion,
      latitud,
      longitud,
      superficie_km2,
      id_localidad,
      id_tipo_parque,
    } = req.body;

    await ejecutarSpParque('parques.sp_parque_modificacion', [
      { nombre: 'id_parque', tipo: sql.Int, valor: idParque },
      { nombre: 'nombre', tipo: sql.VarChar(150), valor: nombre },
      { nombre: 'direccion', tipo: sql.VarChar(200), valor: direccion },
      { nombre: 'latitud', tipo: sql.Decimal(9, 6), valor: latitud },
      { nombre: 'longitud', tipo: sql.Decimal(9, 6), valor: longitud },
      { nombre: 'superficie_km2', tipo: sql.Decimal(10, 2), valor: superficie_km2 },
      { nombre: 'id_localidad', tipo: sql.Int, valor: id_localidad },
      { nombre: 'id_tipo_parque', tipo: sql.Int, valor: id_tipo_parque },
    ]);

    res.json({ message: 'Parque actualizado correctamente' });
  } catch (err) {
    console.error('Error al actualizar parque:', err);
    res.status(400).json({ error: err.message });
  }
});

// DELETE parque
app.delete('/parques/:id_parque', async (req, res) => {
  try {
    const idParque = parseInt(req.params.id_parque, 10);

    await ejecutarSpParque('parques.sp_parque_baja', [
      { nombre: 'id_parque', tipo: sql.Int, valor: idParque },
    ]);

    res.json({ message: 'Parque eliminado correctamente' });
  } catch (err) {
    console.error('Error al eliminar parque:', err);
    res.status(400).json({ error: err.message });
  }
});

/*---------------------------------------------------------------------------------------
---------- RUTAS ------------------------------------------------------------------------
---------------------------------------------------------------------------------------*/

// Página principal
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Página parques
app.get('/parque', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'parque.html'));
});

/*---------------------------------------------------------------------------------------
---------- LEVANTAR SERVIDOR ------------------------------------------------------------
---------------------------------------------------------------------------------------*/
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Servidor escuchando en http://localhost:${PORT}`);
});