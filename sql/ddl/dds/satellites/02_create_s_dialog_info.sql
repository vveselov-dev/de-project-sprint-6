-- Создание DDS-сателлита s_dialog_info

CREATE TABLE VT261029615224__DWH.s_dialog_info
(
    hk_message_id INT NOT NULL,
    message VARCHAR(1000),
    message_from INT,
    message_to INT,
    load_dt TIMESTAMP,
    load_src VARCHAR(20)
)
PARTITION BY ((s_dialog_info.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (s_dialog_info.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (s_dialog_info.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (s_dialog_info.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (s_dialog_info.load_dt)::date))::date
        ELSE (s_dialog_info.load_dt)::date
    END
);

-- Внешний ключ на h_dialogs

ALTER TABLE VT261029615224__DWH.s_dialog_info
ADD CONSTRAINT fk_s_dialog_info_dialogs
FOREIGN KEY (hk_message_id)
REFERENCES VT261029615224__DWH.h_dialogs (hk_message_id);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.s_dialog_info /*+createtype(P)*/
(
    hk_message_id,
    message,
    message_from,
    message_to,
    load_dt,
    load_src
)
AS
SELECT
    s_dialog_info.hk_message_id,
    s_dialog_info.message,
    s_dialog_info.message_from,
    s_dialog_info.message_to,
    s_dialog_info.load_dt,
    s_dialog_info.load_src
FROM VT261029615224__DWH.s_dialog_info
ORDER BY s_dialog_info.load_dt
SEGMENTED BY s_dialog_info.hk_message_id ALL NODES KSAFE 1;
