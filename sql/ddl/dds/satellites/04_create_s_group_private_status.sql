-- Создание DDS-сателлита s_group_private_status

CREATE TABLE VT261029615224__DWH.s_group_private_status
(
    hk_group_id INT NOT NULL,
    is_private BOOLEAN,
    load_dt TIMESTAMP,
    load_src VARCHAR(20)
)
PARTITION BY ((s_group_private_status.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (s_group_private_status.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (s_group_private_status.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (s_group_private_status.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (s_group_private_status.load_dt)::date))::date
        ELSE (s_group_private_status.load_dt)::date
    END
);

-- Внешний ключ на h_groups

ALTER TABLE VT261029615224__DWH.s_group_private_status
ADD CONSTRAINT fk_s_group_private_status_groups
FOREIGN KEY (hk_group_id)
REFERENCES VT261029615224__DWH.h_groups (hk_group_id);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.s_group_private_status /*+createtype(P)*/
(
    hk_group_id,
    is_private,
    load_dt,
    load_src
)
AS
SELECT
    s_group_private_status.hk_group_id,
    s_group_private_status.is_private,
    s_group_private_status.load_dt,
    s_group_private_status.load_src
FROM VT261029615224__DWH.s_group_private_status
ORDER BY s_group_private_status.load_dt
SEGMENTED BY s_group_private_status.hk_group_id ALL NODES KSAFE 1;
