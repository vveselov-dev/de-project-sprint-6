-- Создание DDS-сателлита s_admins

CREATE TABLE VT261029615224__DWH.s_admins
(
    hk_admin_id INT NOT NULL,
    is_admin BOOLEAN,
    admin_from TIMESTAMP,
    load_dt TIMESTAMP,
    load_src VARCHAR(20)
)
PARTITION BY ((s_admins.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (s_admins.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (s_admins.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (s_admins.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (s_admins.load_dt)::date))::date
        ELSE (s_admins.load_dt)::date
    END
);

-- Внешний ключ на l_admins

ALTER TABLE VT261029615224__DWH.s_admins
ADD CONSTRAINT fk_s_admins_l_admins
FOREIGN KEY (hk_admin_id)
REFERENCES VT261029615224__DWH.l_admins (hk_l_admin_id);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.s_admins /*+createtype(P)*/
(
    hk_admin_id,
    is_admin,
    admin_from,
    load_dt,
    load_src
)
AS
SELECT
    s_admins.hk_admin_id,
    s_admins.is_admin,
    s_admins.admin_from,
    s_admins.load_dt,
    s_admins.load_src
FROM VT261029615224__DWH.s_admins
ORDER BY s_admins.load_dt
SEGMENTED BY s_admins.hk_admin_id ALL NODES KSAFE 1;
