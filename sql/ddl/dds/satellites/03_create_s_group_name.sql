-- Создание DDS-сателлита s_group_name

CREATE TABLE VT261029615224__DWH.s_group_name
(
    hk_group_id INT NOT NULL,
    group_name VARCHAR(100),
    load_dt TIMESTAMP,
    load_src VARCHAR(20)
)
PARTITION BY ((s_group_name.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (s_group_name.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (s_group_name.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (s_group_name.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (s_group_name.load_dt)::date))::date
        ELSE (s_group_name.load_dt)::date
    END
);

-- Внешний ключ на h_groups

ALTER TABLE VT261029615224__DWH.s_group_name
ADD CONSTRAINT fk_s_group_name_groups
FOREIGN KEY (hk_group_id)
REFERENCES VT261029615224__DWH.h_groups (hk_group_id);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.s_group_name /*+createtype(P)*/
(
    hk_group_id,
    group_name,
    load_dt,
    load_src
)
AS
SELECT
    s_group_name.hk_group_id,
    s_group_name.group_name,
    s_group_name.load_dt,
    s_group_name.load_src
FROM VT261029615224__DWH.s_group_name
ORDER BY s_group_name.load_dt
SEGMENTED BY s_group_name.hk_group_id ALL NODES KSAFE 1;
