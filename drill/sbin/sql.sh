#!/bin/bash
$APP_HOME/drill/bin/sqlline -u "jdbc:drill:drillbit=localhost" "$@"
