-- Создание DDS-связи l_user_message

CREATE TABLE VT261029615224__DWH.l_user_message
(
    hk_l_user_message INT NOT NULL,
    hk_user_id INT NOT NULL,
    hk_message_id INT NOT NULL,
    load_dt TIMESTAMP,
    load_src VARCHAR(20),
    CONSTRAINT C_PRIMARY PRIMARY KEY (hk_l_user_message) DISABLED
)
PARTITION BY ((l_user_message.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (l_user_message.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (l_user_message.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (l_user_message.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (l_user_message.load_dt)::date))::date
        ELSE (l_user_message.load_dt)::date
    END
);

-- Внешние ключи на хабы

ALTER TABLE VT261029615224__DWH.l_user_message
ADD CONSTRAINT fk_l_user_message_user
FOREIGN KEY (hk_user_id)
REFERENCES VT261029615224__DWH.h_users (hk_user_id);

ALTER TABLE VT261029615224__DWH.l_user_message
ADD CONSTRAINT fk_l_user_message_message
FOREIGN KEY (hk_message_id)
REFERENCES VT261029615224__DWH.h_dialogs (hk_message_id);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.l_user_message /*+createtype(P)*/
(
    hk_l_user_message,
    hk_user_id,
    hk_message_id,
    load_dt,
    load_src
)
AS
SELECT
    l_user_message.hk_l_user_message,
    l_user_message.hk_user_id,
    l_user_message.hk_message_id,
    l_user_message.load_dt,
    l_user_message.load_src
FROM VT261029615224__DWH.l_user_message
ORDER BY l_user_message.load_dt
SEGMENTED BY l_user_message.hk_user_id ALL NODES KSAFE 1;
