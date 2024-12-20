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

## Data Catalog

### Dataset Overview

**Wide World Importers** (WWI) is a wholesale novelty goods importer and distributor operating from the San Francisco bay area.

As a wholesaler, WWI's customers are mostly companies who resell to individuals. WWI sells to retail customers across the United States including specialty stores, supermarkets, computing stores, tourist attraction shops, and some individuals. WWI also sells to other wholesalers via a network of agents who promote the products on WWI's behalf. While all of WWI's customers are currently based in the United States, the company is intending to push for expansion into other countries/regions.

WWI buys goods from suppliers including novelty and toy manufacturers, and other novelty wholesalers. They stock the goods in their WWI warehouse and reorder from suppliers as needed to fulfill customer orders. They also purchase large volumes of packaging materials, and sell these in smaller quantities as a convenience for the customers.

Recently WWI started to sell a variety of edible novelties such as chilly chocolates. The company previously didn't have to handle chilled items. Now, to meet food handling requirements, they must monitor the temperature in their chiller room and any of their trucks that have chiller sections.

#### Workflow for warehouse stock items

The typical flow for how items are stocked and distributed is as follows:

- WWI creates purchase orders and submits the orders to the suppliers.
- Suppliers send the items, WWI receives them and stocks them in their warehouse.
- Customers order items from WWI
- WWI fills the customer order with stock items in the warehouse, and when they don't have sufficient stock, they order the additional stock from the suppliers.
- Some customers don't want to wait for items that aren't in stock. If they order say five different stock items, and four are available, they want to receive the four items and backorder the remaining item. The item would then be sent later in a separate shipment.
- WWI invoices customers for the stock items, typically by converting the order to an invoice.
- Customers might order items that aren't in stock. These items are backordered.
- WWI delivers stock items to customers either via their own delivery vans, or via other couriers or freight methods.
- Customers pay invoices to WWI.
- Periodically, WWI pays suppliers for items that were on purchase orders. This is often sometime after they've received the goods.

#### Data warehouse and analysis workflow

While the team at WWI use SQL Server Reporting Services to generate operational reports from the WideWorldImporters database, they also need to perform analytics on their data and need to generate strategic reports. The team have created a dimensional data model in a database WideWorldImportersDW. This database is populated by an Integration Services package.

SQL Server Analysis Services is used to create analytic data models from the data in the dimensional data model. SQL Server Reporting Services is used to generate strategic reports directly from the dimensional data model, and also from the analytic model. Power BI is used to create dashboards from the same data. The dashboards are used on websites, and on phones and tablets. Note: these data models and reports aren't yet available.

#### Additional workflows

These are additional workflows.

- WWI issues credit notes when a customer doesn't receive the good for some reason, or when the goods are faulty. These are treated as negative invoices.
- WWI periodically counts the on-hand quantities of stock items to ensure that the stock quantities shown as available on their system are accurate. (The process of doing this is called a stocktake).
- Cold room temperatures. Perishable goods are stored in refrigerated rooms. Sensor data from these rooms is ingested into the database for monitoring and analytics purposes.
- Vehicle location tracking. Vehicles that transport goods for WWI include sensors that track the location. This location is again ingested into the database for monitoring and further analytics.

#### Fiscal year

The company operates with a financial year that starts on November 1.
