-- Создание DDS-сателлита s_user_chatinfo

CREATE TABLE VT261029615224__DWH.s_user_chatinfo
(
    hk_user_id INT NOT NULL,
    chat_name VARCHAR(200),
    load_dt TIMESTAMP,
    load_src VARCHAR(20)
)
PARTITION BY ((s_user_chatinfo.load_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (s_user_chatinfo.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (s_user_chatinfo.load_dt)::date))::date
        WHEN "datediff"(
            'month',
            (s_user_chatinfo.load_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (s_user_chatinfo.load_dt)::date))::date
        ELSE (s_user_chatinfo.load_dt)::date
    END
);

-- Внешний ключ на h_users

ALTER TABLE VT261029615224__DWH.s_user_chatinfo
ADD CONSTRAINT fk_s_user_chatinfo_users
FOREIGN KEY (hk_user_id)
REFERENCES VT261029615224__DWH.h_users (hk_user_id);

-- Создание проекции

CREATE PROJECTION VT261029615224__DWH.s_user_chatinfo /*+createtype(P)*/
(
    hk_user_id,
    chat_name,
    load_dt,
    load_src
)
AS
SELECT
    s_user_chatinfo.hk_user_id,
    s_user_chatinfo.chat_name,
    s_user_chatinfo.load_dt,
    s_user_chatinfo.load_src
FROM VT261029615224__DWH.s_user_chatinfo
ORDER BY s_user_chatinfo.load_dt
SEGMENTED BY s_user_chatinfo.hk_user_id ALL NODES KSAFE 1;
