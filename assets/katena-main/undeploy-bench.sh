#!/bin/bash

sh -c 'ps aux | grep ganache-cli | grep -v grep | awk "NR==1 {print \$2}" | xargs kill'
rm ./$APP.yaml &> /dev/null
rm -r ./nodes/contracts &> /dev/null
rm -r ./.opera &> /dev/null
