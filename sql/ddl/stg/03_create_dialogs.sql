-- Создание staging-таблицы dialogs

CREATE TABLE VT261029615224__STAGING.dialogs
(
    message_id INT NOT NULL,
    message_ts TIMESTAMP(6),
    message_from INT,
    message_to INT,
    message VARCHAR(1000),
    message_group INT,
    CONSTRAINT PK_dialogs PRIMARY KEY (message_id) DISABLED
)
PARTITION BY ((dialogs.message_ts)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (dialogs.message_ts)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (dialogs.message_ts)::date))::date
        WHEN "datediff"(
            'month',
            (dialogs.message_ts)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (dialogs.message_ts)::date))::date
        ELSE (dialogs.message_ts)::date
    END
);

-- Создание проекции

CREATE PROJECTION VT261029615224__STAGING.dialogs
(
    message_id,
    message_ts,
    message_from,
    message_to,
    message,
    message_group
)
AS
SELECT
    dialogs.message_id,
    dialogs.message_ts,
    dialogs.message_from,
    dialogs.message_to,
    dialogs.message,
    dialogs.message_group
FROM VT261029615224__STAGING.dialogs
ORDER BY dialogs.message_id
SEGMENTED BY HASH(dialogs.message_id) ALL NODES KSAFE 1;

