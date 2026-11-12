import os
from datetime import timedelta

import vertica_python
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago


CSV_PATH = "/data/group_log.csv"

VERTICA_CONFIG = {
    "host": "vertica.data-engineer.education-services.ru",
    "port": 5433,
    "user": "VT261029615224",
    "password": os.environ["VERTICA_PASSWORD"],
    "database": "dwh",
}

TABLE_NAME = "VT261029615224__STAGING.group_log"


def load_group_log():
    if not os.path.exists(CSV_PATH):
        raise FileNotFoundError(f"File not found: {CSV_PATH}")

    # Считаем количество записей в CSV без строки заголовка.
    with open(CSV_PATH, "r", encoding="utf-8-sig") as file:
        expected_rows = sum(1 for _ in file) - 1

    if expected_rows < 0:
        raise ValueError("CSV file is empty")

    conn = vertica_python.connect(**VERTICA_CONFIG)
    cur = conn.cursor()

    try:
        cur.execute(f"SELECT COUNT(*) FROM {TABLE_NAME}")
        existing_rows = cur.fetchone()[0]

        if existing_rows != 0:
            raise RuntimeError(
                f"Table {TABLE_NAME} is not empty: {existing_rows} rows. "
                "Clear the table before reloading."
            )

        copy_sql = f"""
            COPY {TABLE_NAME}
            FROM LOCAL '{CSV_PATH}'
            DELIMITER ','
            ENCLOSED BY '"'
            SKIP 1
            ABORT ON ERROR
        """

        cur.execute(copy_sql)

        cur.execute(f"SELECT COUNT(*) FROM {TABLE_NAME}")
        loaded_rows = cur.fetchone()[0]

        if loaded_rows != expected_rows:
            raise RuntimeError(
                f"Row count mismatch: expected {expected_rows}, "
                f"loaded {loaded_rows}"
            )

        conn.commit()
        print(f"Successfully loaded {loaded_rows} rows into {TABLE_NAME}")

    except Exception:
        conn.rollback()
        raise

    finally:
        cur.close()
        conn.close()


with DAG(
    dag_id="load_group_log_to_vertica",
    description="Load group_log.csv into Vertica STG",
    start_date=days_ago(1),
    schedule_interval=None,
    catchup=False,
    tags=["sprint-6", "stg", "vertica"],
) as dag:

    load_task = PythonOperator(
        task_id="load_group_log",
        python_callable=load_group_log,
        retries=1,
        retry_delay=timedelta(minutes=5),
    )