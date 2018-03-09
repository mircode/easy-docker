#!/bin/bash
URL="http://localhost:9200"
function version(){
    curl $URL
}
function health(){
    curl "$URL/_cat/health?v"
}
function nodes(){
    curl "$URL/_cat/nodes?v"
}
function indices(){
    curl "$URL/_cat/indices?v"
}
function delete(){
    curl -XDELETE "$URL/$2?pretty"
}
function create(){
    curl -XPUT "$URL/$2?pretty"
}
function add(){
    curl "$URL/$2/external/$3?pretty" -H 'Content-Type: application/json' -d$4
}
function update(){
    curl -XPOST "$URL/$2/external/$3/_update?pretty" -H 'Content-Type: application/json' -d$4
}
function query(){
   curl -XGET "$URL/$2?pretty"
}
function search(){
    curl -XGET "$URL/_search?pretty" -H 'Content-Type: application/json' -d$2
}
function help(){
	echo "usage:  es.sh [version|health|nodes|list|delete|add|update|query]"
}
function main(){
	case "$1" in 
        nodes   )   nodes   $@ ;; 
        status  )   health  $@ ;;
        list    )   indices $@ ;; 
        version )   version $@ ;; 
        create  )   create  $@ ;; 
        add     )   add     $@ ;; 
        update  )   update  $@ ;; 
        update  )   update  $@ ;;
        query   )   query   $@ ;;
        search  )   search  $@ ;;
        * ) help ;;
    esac 
}
main $@

