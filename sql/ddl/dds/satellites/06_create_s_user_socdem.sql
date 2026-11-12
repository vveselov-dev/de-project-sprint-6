-- Создание DDS-сателлита s_user_socdem

CREATE TABLE VT261029615224__DWH.s_user_socdem
(
    hk_user_id INT NOT NULL,
    country VARCHAR(200),
    age INT,
    load_dt TIMESTAMP,
    load_src VARCHAR(20)
)
PARTITION BY ((s_user_socdem.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (s_user_socdem.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (s_user_socdem.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (s_user_socdem.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (s_user_socdem.load_dt)::date))::date
        ELSE (s_user_socdem.load_dt)::date
    END
);

-- Внешний ключ на h_users

ALTER TABLE VT261029615224__DWH.s_user_socdem
ADD CONSTRAINT fk_s_user_socdem_users
FOREIGN KEY (hk_user_id)
REFERENCES VT261029615224__DWH.h_users (hk_user_id);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.s_user_socdem /*+createtype(P)*/
(
    hk_user_id,
    country,
    age,
    load_dt,
    load_src
)
AS
SELECT
    s_user_socdem.hk_user_id,
    s_user_socdem.country,
    s_user_socdem.age,
    s_user_socdem.load_dt,
    s_user_socdem.load_src
FROM VT261029615224__DWH.s_user_socdem
ORDER BY s_user_socdem.load_dt
SEGMENTED BY s_user_socdem.hk_user_id ALL NODES KSAFE 1;
