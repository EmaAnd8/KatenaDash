#!/bin/bash

# Create or clear the results file
results_file="deployment_results.txt"
echo "Deployment Results:" > $results_file

for APP in file_to_run;
do
    echo "deploying ${APP}..."
    #rm -r ./.opera &> /dev/null
    cp ./benchmark/$APP.yaml .
    rm -r ./nodes/contracts &> /dev/null
    mkdir ./nodes/contracts &> /dev/null
    cp ./nodes/temp_ABI/* ./nodes/contracts
    opera deploy -r -i input.yml ./$APP.yaml -v > deploy.log
    status=$?
    if [ $status -eq 0 ]
    then
        echo "${APP} deployed successfully"
        echo "${APP} deployed successfully" >> $results_file
        # Extract important results from deploy.log and append to results file
        echo "Important results from ${APP} deployment:" >> $results_file
        grep -E "contract|address|transaction|Deploying|Deployment|Executing|complete" deploy.log | grep -v -E "sas_address|address_parameters|bytecode" >> $results_file
    else
        echo "Deployment of ${APP} failed" >> $results_file
        grep -w "stderr" deploy.log | tail -1 >> $results_file
        rm ./nodes/temp_ABI/*
        exit 2
    fi
    echo -e "\ndeploy finished" >> deploy.log
    rm ./$APP.yaml &> /dev/null
    rm -r ./nodes/contracts &> /dev/null
done;

rm ./nodes/temp_ABI/*
rm accounts.json
rm accounts-pretty.json
