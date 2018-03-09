#!/bin/bash
ARG0=$1
$APP_HOME/drill/bin/drillbit.sh     ${ARG0:-'start'};
