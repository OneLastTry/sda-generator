#!/bin/bash
# batchSize will define how many patients will be generated before restarting the process
# recommend number not larger than 10000
batchSize=10000

clear
printf "\n--------------------------------------------------------------------------------"
printf "\nWelcome to HealthShare SDA3 Generator"
printf "\n--------------------------------------------------------------------------------"
printf "\nThe SDA3 files are generated based on Synthea CCDA files."
printf "\nFor more:"
printf "\n- https://github.com/OneLastTry/sda-generator"
printf "\n- https://github.com/synthetichealth/synthea"
printf "\nNote that the total number of files will exceed the number of generated patients"
printf "\n--------------------------------------------------------------------------------"
printf "\nInform how many (alive) patients you wish to generate: "
read total
re='^[0-9]+$'
if ! [[ $total =~ $re ]] ; then
   printf ">>>>> ERROR: Not a number"
   exit 1
fi
printf "Do you really with to generate $total patients? (Y/N): "
read proceed
if [ ! $proceed == 'Y' ]; then
    printf "\n\nABORTED!\n\n"
    exit 1
fi
batch=$(((total/batchSize)+1))
printf "\nStarting ... "
start=$(date)
function progress()
{
    clear
    printf "\n--------------------------------------------------------------------------------"
    printf "\nWelcome to HealthShare SDA3 Generator"
    printf "\n--------------------------------------------------------------------------------"
    printf "\nGenerating $total patients ... in progress"
    printf "\nGenerated patients $current of $total"
    printf "\nGenerated files $fileTotal"
    printf "\Start: $start"
    printf "\n--------------------------------------------------------------------------------\n"
}

function finish()
{
    end=$(date)
    clear
    printf "\n--------------------------------------------------------------------------------"
    printf "\nWelcome to HealthShare SDA3 Generator"
    printf "\n--------------------------------------------------------------------------------"
    printf "\nGenerating $total patients ... done"
    printf "\nGenerated files $fileTotal"
    printf "\Start: $start"
    printf "\End: $end"
    printf "\n--------------------------------------------------------------------------------"
    printf "\nCompleted\n"
}

function start() 
{
    docker-compose up -d &> /dev/null
    docker run -d --rm -v $PWD/output:/output hsdemo-loader/synthea:base /synthea/bin/synthea \
        --exporter.ccda.export=true \
        --exporter.fhir.export=false \
        --exporter.hospital.fhir.export=false \
        --exporter.split_records=true \
        --exporter.split_records.duplicate_data=true -p $batchSize &> output/synthea.log
    sleep 10
}

function stop() 
{
    docker-compose down &> /dev/null
}

function monitor() 
{
    monitor=1
    tail -n 1 output/synthea.log >> output/created.log
    while [ $monitor == 1 ]
    do
        left=$(ls -1A output/ccda | wc -l)
        fileTotal=$(ls -1A output/sda3 | wc -l)
        fileTotal=$((fileTotal-1))
        if [ $left == 0 ]; then
            sleep 30
            progress
            monitor=0
        else
            progress
            sleep 5
        fi
    done
}

function run()
{
    current=0
    while [ ! $current == $total ]
    do
        if [ $((current+batchSize)) -gt $total ]; then
            batchSize=$((total-current))
            current=$total
            process
        else 
            current=$((current+batchSize))
            process
        fi
    done
    finish
}

function process()
{
    start
    monitor
    stop

}

run