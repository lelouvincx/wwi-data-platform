# Project WideWorldImporters Data Platform

This is my side project building a data platform with dataset WideWorldImporters. Using prefect, dbt, bigquery, holistics.

## Roadmap

- [ ] Design architecture
- [x] Initialize Postgres with dataset
  - [x] Database catalog
- [ ] Setup GCP BigQuery
- [ ] Build Prefect Flow to push data from Postgres to BigQuery in raw layer
- [ ] Build dbt project to transform data in raw layer to later layers
- [ ] Register Holistics account and build dashboard
- [ ] Continuous Integration with Github Actions

## Local development guide

### Prequisites

- Python version >= 3.11 (3.11.10 recommended)
- Docker with docker compose (at least 4 core and 4GB of RAM). [Installation guide](https://docs.docker.com/engine/install/)
- uv 0.5.9 for python project management. [Installation guide](https://docs.astral.sh/uv/getting-started/installation/)
- GCP Account. You can use free tier account. [Signup here](https://cloud.google.com/)

### Install codebase

1. Clone the repository & go to the project location (/wwi-data-platform)

2. Install python dependencies

```bash
uv sync --all-packages
```

3. Build docker images

```bash
docker build -t data-generator:localdev -f .docker/build/app/Dockerfile .
```

5. Start docker services

```bash
make up
```

6. Visit [Makefile](./Makefile) to short-binding commands

### Restore the database

1. Download dump file at https://github.com/Azure/azure-postgresql/blob/master/samples/databases/wide-world-importers/wide_world_importers_pg.dump
2. Spawn up the postgres container, notice that there's 5 users: admin, azure_pg_admin, azure_superuser, greglow, data_engineer (detail in file `./deployment/data/init_db.sh`)
3. Shell to postgresql

Copy dump file to container

```bash
docker cp ./wide_world_importers_pg.dump database:/backups/wide_world_importers_pg.dump
```

4. Restore (inside postgres container)

```bash
docker exec database /bin/bash -c "pg_restore -h localhost -p 5432 -U postgres -W -v -Fc -d wideworldimporters < /backups/wide_world_importers_pg.dump"
```

Then enter postgres's password and take a coffee.
