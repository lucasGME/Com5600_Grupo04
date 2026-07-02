document.addEventListener('DOMContentLoaded', () => {
    cargarParques();
    altaParque();
    modificarParque();
    eliminarParque();
});


/*---------------------------------------------------------------------------------------
---------- Usar ABM de Parques Nacionales -----------------------------------------------
---------------------------------------------------------------------------------------*/

function cargarParques() {
    fetch('http://localhost:3000/parques')
        .then(res => res.json())
        .then(data => {
            const lista = document.getElementById('lista-parques');

            lista.innerHTML = '';

            data.forEach(parque => {
                const li = document.createElement('li');

                li.innerHTML = `
        <div class="card-parque">
            <h3>${parque.nombre}</h3>
            <p>ID Parque: ${parque.id_parque}</p>
            <p>Dirección: ${parque.direccion}</p>
            <p>Latitud: ${parque.latitud}</p>
            <p>Longitud: ${parque.longitud}</p>
            <p>Superficie (km²): ${parque.superficie_km2}</p>
            <p>ID Localidad: ${parque.id_localidad}</p>
            <p>ID Tipo Parque: ${parque.id_tipo_parque}</p>
        </div>
        `;
                lista.appendChild(li);
            });
        })
        .catch(err => console.error('Error:', err));
}

function altaParque() {
    const form = document.getElementById('formulario-parque-alta');
    form.addEventListener('submit', (e) => {
        e.preventDefault();

        const data = {
            nombre: document.getElementById('nombre_alta').value,
            direccion: document.getElementById('direccion_alta').value,
            latitud: parseFloat(document.getElementById('latitud_alta').value),
            longitud: parseFloat(document.getElementById('longitud_alta').value),
            superficie_km2: parseFloat(document.getElementById('superficie_alta').value),
            id_localidad: parseInt(document.getElementById('id_localidad_alta').value),
            id_tipo_parque: parseInt(document.getElementById('id_tipo_parque_alta').value),
        };


        fetch('http://localhost:3000/parques', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        })
            .then(async res => {
                const resultado = await res.json();

                if (!res.ok) {
                    throw new Error(resultado.error || 'Error al crear parque');
                }

                return resultado;
            })
            .then(() => {
                alert('Parque creado ✅');
                form.reset();
                cargarParques();
            })
            .catch(err => {
                console.error(err);
                alert('❌ Error: \n' + err.message);
            });
    });
}

function modificarParque() {
    const form = document.getElementById('formulario-parque-modificar');

    form.addEventListener('submit', async (e) => {
        e.preventDefault();

        const id = document.getElementById('id_parque_modificar').value;

        const data = {
            nombre: document.getElementById('nombre_modificar').value,
            direccion: document.getElementById('direccion_modificar').value,
            latitud: parseFloat(document.getElementById('latitud_modificar').value),
            longitud: parseFloat(document.getElementById('longitud_modificar').value),
            superficie_km2: parseFloat(document.getElementById('superficie_modificar').value),
            id_localidad: parseInt(document.getElementById('id_localidad_modificar').value),
            id_tipo_parque: parseInt(document.getElementById('id_tipo_parque_modificar').value),
        };

        try {
            const res = await fetch(`http://localhost:3000/parques/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            const result = await res.json();

            if (!res.ok) {
                throw new Error(result.error);
            }

            alert('✅ Parque modificado');
            form.reset();
            cargarParques();

        } catch (err) {
            console.error(err);
            alert('❌ Error: \n' + err.message);
        }
    });
}

function eliminarParque() {
  const form = document.getElementById('formulario-parque-eliminar');

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const id = document.getElementById('id_parque_eliminar').value;

    if (!confirm(`¿Seguro que querés eliminar el parque con ID ${id}?`)) {
      return;
    }

    try {
      const res = await fetch(`http://localhost:3000/parques/${id}`, {
        method: 'DELETE'
      });

      const result = await res.json();

      if (!res.ok) {
        throw new Error(result.error || 'Error al eliminar');
      }

      alert('✅ Parque eliminado');
      form.reset();
      cargarParques();

    } catch (err) {
      console.error(err);
      alert('❌ Error: \n' + err.message);
    }
  });
}
