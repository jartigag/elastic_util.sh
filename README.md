# elastic_util.sh

```
uso: elastic_util.sh [acción] [argumentos]

acciones:

- listar
- crear nombre_indice mapping.json
- insertar nombre_indice datos.json
- mapping nombre_indice
- eliminar nombre_indice

- filtrar nombre_indice "msg:error and @timestamp:[2019-11-09T00:00:00.000Z TO now]"
- borrar nombre_indice "@timestamp:[now-1M/M TO now-1M/M]"

ejemplos:

- hacer legible un output en JSON:
elastic_util.sh filtrar importer-miprocesado2019.10 "campo1:100" 2>/dev/null | python -m json.tool | less
- listar los índices con el mes actual en su nombre:
elastic_util.sh ls | grep 2019.11
```
