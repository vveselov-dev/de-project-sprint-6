# Data Engineering Project: Social Network Analytics DWH

## Overview

This project focuses on building a Data Warehouse (DWH) for a social network analytics use case.

The main objective is to ingest raw data from an S3 data lake, load it into a staging layer, transform it into a Data Vault-based warehouse model, and prepare analytical queries to evaluate user engagement in groups.

The project demonstrates key Data Engineering concepts, including ETL pipeline development, data modeling, SQL transformations, workflow orchestration, and analytical data processing.

## Architecture

The data pipeline consists of the following stages:

1. **Data Extraction** — downloading source CSV files from an S3 bucket.
2. **Staging Layer (STG)** — loading raw data into Vertica without changing its original structure.
3. **Data Warehouse (DDS)** — transforming source data into a Data Vault model consisting of Hubs, Links, and Satellites.
4. **Analytics Layer** — preparing SQL queries and CTEs to calculate user engagement metrics.

### Data Flow

```text
          Amazon S3
              |
              v
       CSV Source Files
              |
              v
       Apache Airflow
       (Data Extraction)
              |
              v
       Vertica STAGING
              |
              v
       Vertica DWH (DDS)
       +------------------+
       | Hubs             |
       | Links            |
       | Satellites       |
       +------------------+
              |
              v
       SQL Analytics
              |
              v
       Group Engagement
          Metrics
```

## Technology Stack

| Technology | Purpose |
|---|---|
| Python | Data extraction and ETL logic |
| Apache Airflow | Workflow orchestration |
| Docker & Docker Compose | Local development environment |
| Vertica | Data Warehouse |
| SQL | Data transformations, modeling, and analytics |
| Amazon S3 | Source data storage |
| Metabase | BI and data exploration environment |

## Data Warehouse Design

The warehouse follows the **Data Vault 2.0 modeling approach**, separating business entities, relationships, and descriptive or historical attributes.

### Hubs

Hubs represent core business entities:

- `h_users` — users
- `h_groups` — groups
- `h_dialogs` — messages

### Links

Links represent relationships between business entities:

- `l_admins` — relationships between groups and administrators
- `l_groups_dialogs` — relationships between groups and messages
- `l_user_message` — relationships between users and messages
- `l_user_group_activity` — relationships between users and groups

### Satellites

Satellites store descriptive attributes and historical information:

- `s_admins` — administrator information
- `s_dialog_info` — message attributes
- `s_group_name` — group names
- `s_group_private_status` — group privacy status
- `s_user_chatinfo` — user chat information
- `s_user_socdem` — user demographic information
- `s_auth_history` — user activity history within groups

## Data Pipeline

The extraction and loading process is orchestrated using Apache Airflow.

The pipeline includes:

- Downloading CSV datasets from Amazon S3.
- Loading source data into Vertica staging tables.
- Creating and maintaining Data Warehouse structures.
- Migrating data from staging tables into Hubs, Links, and Satellites.
- Validating loaded data using SQL queries.

The `group_log` dataset contains user activity events such as `add`, `leave`, and `create`. These events are stored in the `s_auth_history` satellite and linked to user-group relationships through `l_user_group_activity`.

## Analytics

The final stage focuses on measuring user engagement in social network groups.

The analytical queries use Common Table Expressions (CTEs) to calculate:

- The number of unique users who have posted at least one message in each group.
- The number of unique users who joined each group.
- The conversion rate from group membership to active participation.

The main metric is **Group Conversion**:

```text
Group Conversion =
    Users Who Posted at Least One Message
    --------------------------------------
           Users Who Joined the Group
```

The analysis focuses on the ten oldest groups and ranks them by their conversion rate.

## Repository Structure

```text
.
├── dags/
│   ├── download_s3_files.py
│   └── load_group_log_to_vertica.py
│
├── data/                   # Local source data (not committed)
│
├── sql/
│   ├── ddl/
│   │   └── dds/
│   │       ├── hubs/
│   │       ├── links/
│   │       └── satellites/
│   │
│   ├── dml/
│   │   └── dds/
│   │       ├── links/
│   │       └── satellites/
│   │
│   └── analytics/
│       └── 01_analyze_group_conversion.sql
│
├── plugins/                # Metabase plugins
├── docker-compose.yml
├── .env                    # Local environment variables (not committed)
└── README.md
```

## Running the Project

### Prerequisites

- Docker Desktop
- Docker Compose
- Access to the source S3 bucket
- Vertica database credentials

### Configuration

Create a `.env` file in the project root and provide the required credentials:

```env
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
VERTICA_PASSWORD=your_vertica_password
```

Do not commit `.env` or any other files containing credentials.

### Start the Environment

```bash
docker compose up -d
```

Airflow UI:

`http://localhost:3001/`

Metabase UI:

`http://localhost:3335/`

Run the Airflow DAGs to download source data and load it into Vertica. Execute the SQL scripts in the appropriate order to create the warehouse structures, migrate the data, and run analytical queries.

## Key Results

- Loaded **889,733** user activity events into the staging layer.
- Created a Data Vault warehouse model with Hubs, Links, and Satellites.
- Built a user-group relationship model containing **569,426** unique user-group links.
- Migrated **889,733** activity events into the `s_auth_history` satellite.
- Prepared analytical SQL queries to calculate group engagement and conversion rates.

---

**Project type:** Data Engineering / Data Warehousing  
**Focus areas:** ETL, Data Vault 2.0, SQL, Apache Airflow, Vertica, Docker