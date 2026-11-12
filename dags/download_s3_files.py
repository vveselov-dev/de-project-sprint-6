
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

from datetime import datetime
import pendulum
import boto3
import os


AWS_ACCESS_KEY_ID = os.environ['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']


def fetch_s3_file(bucket: str, key: str):
    session = boto3.session.Session()

    s3_client = session.client(
        service_name='s3',
        endpoint_url='https://storage.yandexcloud.net',
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    )

    s3_client.download_file(
        Bucket=bucket,
        Key=key,
        Filename=f'/data/{key}'
    )


bash_command_tmpl = """
{% for file in params.files %}
    echo "========== {{ file }} =========="
    head -n 10 {{ file }}
{% endfor %}
"""


with DAG(
    dag_id='sprint6_dag_get_data',
    schedule_interval=None,
    start_date=pendulum.parse('2022-07-13'),
    catchup=False
) as dag:

    bucket_files = [
        'users.csv',
        'groups.csv',
        'dialogs.csv',
        'group_log.csv'
    ]

    task1 = PythonOperator(
        task_id='fetch_users',
        python_callable=fetch_s3_file,
        op_kwargs={'bucket': 'sprint6', 'key': 'users.csv'},
    )

    task2 = PythonOperator(
        task_id='fetch_groups',
        python_callable=fetch_s3_file,
        op_kwargs={'bucket': 'sprint6', 'key': 'groups.csv'},
    )

    task3 = PythonOperator(
        task_id='fetch_dialogs',
        python_callable=fetch_s3_file,
        op_kwargs={'bucket': 'sprint6', 'key': 'dialogs.csv'},
    )

    task4 = PythonOperator(
        task_id='fetch_group_log',
        python_callable=fetch_s3_file,
        op_kwargs={'bucket': 'sprint6', 'key': 'group_log.csv'},
    )

    print_10_lines_of_each = BashOperator(
        task_id='print_10_lines_of_each',
        bash_command=bash_command_tmpl,
        params={'files': [f'/data/{f}' for f in bucket_files]}
    )

    [task1, task2, task3, task4] >> print_10_lines_of_each
