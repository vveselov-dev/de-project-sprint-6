-- Создание DDS-связи l_groups_dialogs

CREATE TABLE VT261029615224__DWH.l_groups_dialogs
(
    hk_l_groups_dialogs INT NOT NULL,
    hk_message_id INT NOT NULL,
    hk_group_id INT NOT NULL,
    load_dt TIMESTAMP,
    load_src VARCHAR(20),
    CONSTRAINT C_PRIMARY PRIMARY KEY (hk_l_groups_dialogs) DISABLED
)
PARTITION BY ((l_groups_dialogs.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (l_groups_dialogs.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (l_groups_dialogs.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (l_groups_dialogs.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (l_groups_dialogs.load_dt)::date))::date
        ELSE (l_groups_dialogs.load_dt)::date
    END
);

-- Внешние ключи на хабы

ALTER TABLE VT261029615224__DWH.l_groups_dialogs
ADD CONSTRAINT fk_l_groups_dialogs_message
FOREIGN KEY (hk_message_id)
REFERENCES VT261029615224__DWH.h_dialogs (hk_message_id);

ALTER TABLE VT261029615224__DWH.l_groups_dialogs
ADD CONSTRAINT fk_l_groups_dialogs_group
FOREIGN KEY (hk_group_id)
REFERENCES VT261029615224__DWH.h_groups (hk_group_id);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.l_groups_dialogs /*+createtype(P)*/
(
    hk_l_groups_dialogs,
    hk_message_id,
    hk_group_id,
    load_dt,
    load_src
)
AS
SELECT
    l_groups_dialogs.hk_l_groups_dialogs,
    l_groups_dialogs.hk_message_id,
    l_groups_dialogs.hk_group_id,
    l_groups_dialogs.load_dt,
    l_groups_dialogs.load_src
FROM VT261029615224__DWH.l_groups_dialogs
ORDER BY l_groups_dialogs.load_dt
SEGMENTED BY l_groups_dialogs.hk_l_groups_dialogs ALL NODES KSAFE 1;
