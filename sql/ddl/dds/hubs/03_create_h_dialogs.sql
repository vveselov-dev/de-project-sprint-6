-- Создание DDS-хаба h_dialogs

CREATE TABLE VT261029615224__DWH.h_dialogs
(
    hk_message_id INT NOT NULL,
    message_id INT,
    message_ts TIMESTAMP,
    load_dt TIMESTAMP,
    load_src VARCHAR(20),
    CONSTRAINT C_PRIMARY PRIMARY KEY (hk_message_id) DISABLED
)
PARTITION BY ((h_dialogs.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (h_dialogs.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (h_dialogs.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (h_dialogs.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (h_dialogs.load_dt)::date))::date
        ELSE (h_dialogs.load_dt)::date
    END
);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.h_dialogs /*+createtype(P)*/
(
    hk_message_id,
    message_id,
    message_ts,
    load_dt,
    load_src
)
AS
SELECT
    h_dialogs.hk_message_id,
    h_dialogs.message_id,
    h_dialogs.message_ts,
    h_dialogs.load_dt,
    h_dialogs.load_src
FROM VT261029615224__DWH.h_dialogs
ORDER BY h_dialogs.load_dt
SEGMENTED BY h_dialogs.hk_message_id ALL NODES KSAFE 1;
