# SDA Generator

This is a small tool that leverages [InterSystems IRIS for Health](https://hub.docker.com/_/intersystems-iris-for-health) to generate SDA based on [Synthea](https://github.com/synthetichealth/synthea) CCDA.

## Install

Clone the repo `git clone https://github.com/OneLastTry/sda-generator.git` and then execute from the main directory `docker-compose build`.

## Execution

Once the build is complete, from the main directory, start your iris container:

- **start container:** `docker-compose up -d`

After the container, from the main directory, start the generation process by executing the command below.
Note that **p** is the number of patient, hence the example below generates 5 patients `-p 5`.
Do not run for more than 10K patients, if you need a large sample see the last section of this file.

```bash
docker run --rm -v $PWD/output:/output hsdemo-loader/synthea:base /synthea/bin/synthea --exporter.ccda.export=true --exporter.fhir.export=false --exporter.hospital.fhir.export=false -p 5
```

All your generated CCDA files will be saved inside **./ouput/sda3**

Once you are done simply discard the container running `docker-compose down`

## Helpul links

- [Install Docker](https://docs.docker.com/get-docker/)
- [Install docker-compose](https://docs.docker.com/compose/install/)

## Directory Structure

```bash
├── Dockerfile
├── Dockerfile.Synthea
├── LICENSE
├── README.md
├── code
│   └── src
│       ├── XF
│       │   ├── CCDA
│       │   │   └── FileInbound.cls
│       │   ├── Installer.cls
│       │   └── SDA3
│       │       └── FileOutbound.cls
│       └── XFPKG
│           └── FoundationProduction.cls
├── create-a-lot.sh
├── docker-compose.yml
├── output
│   └── sda3
├── scripts
│   └── build.sh
└── sda-generator.code-workspace

9 directories, 12 files
```

## Bonus

You can run below script on a unix environment to generate very large set of patients (10K+)

```bash
./create-a-lot.sh
```
