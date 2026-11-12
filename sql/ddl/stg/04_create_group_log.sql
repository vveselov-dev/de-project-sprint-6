-- Создание staging-таблицы group_log

CREATE TABLE VT261029615224__STAGING.group_log
(
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    user_id_from INT,
    event VARCHAR(10) NOT NULL,
    datetime TIMESTAMP(6) NOT NULL
);

CREATE PROJECTION VT261029615224__STAGING.group_log
(
    group_id,
    user_id,
    user_id_from,
    event,
    datetime
)
AS
SELECT
    group_id,
    user_id,
    user_id_from,
    event,
    datetime
FROM VT261029615224__STAGING.group_log
ORDER BY
    group_id,
    user_id,
    datetime
SEGMENTED BY HASH(group_id) ALL NODES KSAFE 1;

