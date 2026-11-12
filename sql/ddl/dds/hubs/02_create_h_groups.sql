-- Создание DDS-хаба h_groups

CREATE TABLE VT261029615224__DWH.h_groups
(
    hk_group_id INT NOT NULL,
    group_id INT,
    registration_dt TIMESTAMP,
    load_dt TIMESTAMP,
    load_src VARCHAR(20),
    CONSTRAINT C_PRIMARY PRIMARY KEY (hk_group_id) DISABLED
)
PARTITION BY ((h_groups.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (h_groups.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (h_groups.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (h_groups.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (h_groups.load_dt)::date))::date
        ELSE (h_groups.load_dt)::date
    END
);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.h_groups /*+createtype(P)*/
(
    hk_group_id,
    group_id,
    registration_dt,
    load_dt,
    load_src
)
AS
SELECT
    h_groups.hk_group_id,
    h_groups.group_id,
    h_groups.registration_dt,
    h_groups.load_dt,
    h_groups.load_src
FROM VT261029615224__DWH.h_groups
ORDER BY h_groups.load_dt
SEGMENTED BY h_groups.hk_group_id ALL NODES KSAFE 1;
