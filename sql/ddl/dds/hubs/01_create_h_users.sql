-- Создание DDS-хаба h_users

CREATE TABLE VT261029615224__DWH.h_users
(
    hk_user_id INT NOT NULL,
    user_id INT,
    registration_dt TIMESTAMP,
    load_dt TIMESTAMP,
    load_src VARCHAR(20),
    CONSTRAINT C_PRIMARY PRIMARY KEY (hk_user_id) DISABLED
)
PARTITION BY ((h_users.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (h_users.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (h_users.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (h_users.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (h_users.load_dt)::date))::date
        ELSE (h_users.load_dt)::date
    END
);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.h_users /*+createtype(P)*/
(
    hk_user_id,
    user_id,
    registration_dt,
    load_dt,
    load_src
)
AS
SELECT
    h_users.hk_user_id,
    h_users.user_id,
    h_users.registration_dt,
    h_users.load_dt,
    h_users.load_src
FROM VT261029615224__DWH.h_users
ORDER BY h_users.load_dt
SEGMENTED BY h_users.hk_user_id ALL NODES KSAFE 1;
