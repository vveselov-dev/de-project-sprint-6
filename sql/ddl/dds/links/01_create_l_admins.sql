-- Создание DDS-связи l_admins

CREATE TABLE VT261029615224__DWH.l_admins
(
    hk_l_admin_id INT NOT NULL,
    hk_user_id INT NOT NULL,
    hk_group_id INT NOT NULL,
    load_dt TIMESTAMP,
    load_src VARCHAR(20),
    CONSTRAINT C_PRIMARY PRIMARY KEY (hk_l_admin_id) DISABLED
)
PARTITION BY ((l_admins.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (l_admins.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (l_admins.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (l_admins.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (l_admins.load_dt)::date))::date
        ELSE (l_admins.load_dt)::date
    END
);

-- Внешние ключи на хабы

ALTER TABLE VT261029615224__DWH.l_admins
ADD CONSTRAINT fk_l_admins_user
FOREIGN KEY (hk_user_id)
REFERENCES VT261029615224__DWH.h_users (hk_user_id);

ALTER TABLE VT261029615224__DWH.l_admins
ADD CONSTRAINT fk_l_admins_group
FOREIGN KEY (hk_group_id)
REFERENCES VT261029615224__DWH.h_groups (hk_group_id);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.l_admins /*+createtype(P)*/
(
    hk_l_admin_id,
    hk_user_id,
    hk_group_id,
    load_dt,
    load_src
)
AS
SELECT
    l_admins.hk_l_admin_id,
    l_admins.hk_user_id,
    l_admins.hk_group_id,
    l_admins.load_dt,
    l_admins.load_src
FROM VT261029615224__DWH.l_admins
ORDER BY l_admins.load_dt
SEGMENTED BY l_admins.hk_l_admin_id ALL NODES KSAFE 1;
