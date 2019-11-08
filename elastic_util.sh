#!/bin/bash
# -*- coding: utf-8 -*-
#
# v0.1 (@jartigag, 2019-11-08)
#
# algunas queries útiles para elasticsearch (probado en v6.2.4)
#
# recomendado mover el script al PATH para tenerlo siempre a mano

ip='localhost'
port='9200'

action=$1
index_name=$2
file_or_query=$3

function query()
{
    echo -e "\033[1m\npara $1, se ejecuta:\n\n$ $2 $3\033[0m" 1>&2
    eval $2; echo #TODO?: procesar respuestas de error de la api de elastic
}

function error_exit()
{
    echo -e "\033[1muso: elastic_util.sh [acción] [argumentos]"
    echo ""
	echo -e "acciones:"
    echo ""
    echo -e "- listar
- crear nombre_indice mapping.json
- insertar nombre_indice datos.json
- eliminar nombre_indice"
    echo ""
    echo -e "- filtrar nombre_indice \"msg:error and @timestamp:[2019-11-09T00:00:00.000Z TO now]\"
- borrar nombre_indice \"@timestamp:[now-1M/M TO now-1M/M]\033[0m\""
  echo ""
  echo -e "ejemplos:"
  echo ""
  echo -e "- hacer legible un output en JSON: \nelastic_util.sh filtrar importer-miprocesado2019.10 \"campo1:100\" 2>/dev/null | python -m json.tool | less"
  echo -e "- listar los índices con el mes actual en su nombre: \nelastic_util.sh ls 2>/dev/null | grep 2019.11"
}

if [[ -n $action ]]
then

	if [[ $action == "listar" || $action == "ls" ]]
	then
       query "listar todos los índices" "curl $ip:$port/_cat/indices?v"



    elif [[ $action == "crear" ]]
    then #docs: https://www.elastic.co/guide/en/elasticsearch/reference/6.2/indices-put-mapping.html
        if [[ -n $index_name && -n $file_or_query ]]
        then
            query "crear el índice \`$index_name\` con el mapping \`$file_or_query\`" "curl -XPUT $ip:$port/$index_name; echo; curl -XPUT $ip:$port/$index_name/_mapping/_doc -H 'Content-Type: application/json' --data-binary @$file_or_query" "
#
# comentario:
#
# se debe seguir el siguiente formato en \`$file_or_query\` para declarar el tipo de cada campo de \`$index_name\`:
{
  \"properties\": {
     \"tstamp\": { \"type\": \"date\"},
     \"hostname\": { \"type\": \"keyword\"},
     \"description\": { \"type\": \"text\"},
     \"dropped_packets\": { \"type\": \"integer\"},
     \"cpu_use\": { \"type\": \"float\"}
  }
}
"
        else
            echo -e "\033[93m[!] faltan argumentos\033[0m"
            error_exit
        fi



    elif [[ $action == "insertar" ]] #WIP
    then #docs: https://www.elastic.co/guide/en/elasticsearch/reference/6.2/docs-bulk.html
        if [[ -n $index_name && -n $file_or_query ]]
        then
            query "insertar \`$file_or_query\` en \`$index_name\`" "curl -XPOST $ip:$port/$index_name/_doc/_bulk -H 'Content-Type: application/json' --data-binary @$file_or_query" "
#
# comentario:
#
# la API \"bulk\" de elastic (que permite indexar/borrar documentos en lote) requiere que \`$file_or_query\` cumpla la estructura de un \"newline delimited JSON\" (NDJSON):
{\"index\":{}}
{\"campo1\":\"valor1deldocumentoA\",\"campo2\":\"valor2deldocumentoA\"}
{\"index\":{}}
{\"campo1\":\"valor1deldocumentoB\",\"campo2\":\"valor2deldocumentoB\"}
"
        else
            echo -e "\033[93m[!] faltan argumentos\033[0m"
            error_exit
        fi



    elif [[ $action == "eliminar" ]]
	then
        if [[ -n $index_name ]]
        then
            query "eliminar el índice \`$index_name\`" "curl -XDELETE $ip:$port/$index_name"
        else
            echo -e "\033[93m[!] faltan argumentos\033[0m"
            error_exit
        fi



    elif [[ $action == "filtrar" ]]
    then #docs: https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html
        if [[ -n $index_name && -n $file_or_query ]]
        then
            query "filtrar en el índice \`$index_name\` con la \"query_string\" $file_or_query" "curl $ip:$port/$index_name/_search -H 'Content-Type: application/json' -d '
{
    \"query\":
    {
        \"query_string\": {\"query\": \"$file_or_query\"}
    }
}'"
        else
            echo -e "\033[93m[!] faltan argumentos\033[0m"
            error_exit
        fi



    elif [[ $action == "borrar" ]]
    then #docs: https://www.elastic.co/guide/en/elasticsearch/reference/6.2/docs-delete-by-query.html
        if [[ -n $index_name && -n $file_or_query ]]
        then
            query "borrar docs en el índice \`$index_name\` con la \"query_string\" $file_or_query" "curl $ip:$port/$index_name/_delete_by_query -H 'Content-Type: application/json' -d '
{
    \"query\":
    {
        \"query_string\": {\"query\": \"$file_or_query\"}
    }
}'"
        else
            echo -e "\033[93m[!] faltan argumentos\033[0m"
            error_exit
        fi
    fi
else
    error_exit
fi