CREATE TABLE VT261029615224__DWH.s_auth_history
(
    hk_l_user_group_activity INT NOT NULL,
    user_id_from INT,
    event VARCHAR(10) NOT NULL,
    event_dt TIMESTAMP(6) NOT NULL,
    load_dt TIMESTAMP(6) NOT NULL,
    load_src VARCHAR(20) NOT NULL,

    CONSTRAINT fk_s_auth_history_l_user_group_activity
        FOREIGN KEY (hk_l_user_group_activity)
        REFERENCES VT261029615224__DWH.l_user_group_activity
            (hk_l_user_group_activity)
)
PARTITION BY load_dt::DATE
GROUP BY CALENDAR_HIERARCHY_DAY(load_dt::DATE, 2, 2);

CREATE PROJECTION VT261029615224__DWH.s_auth_history
(
    hk_l_user_group_activity,
    user_id_from,
    event,
    event_dt,
    load_dt,
    load_src
)
AS
SELECT
    hk_l_user_group_activity,
    user_id_from,
    event,
    event_dt,
    load_dt,
    load_src
FROM VT261029615224__DWH.s_auth_history
ORDER BY
    hk_l_user_group_activity,
    event_dt
SEGMENTED BY HASH(hk_l_user_group_activity) ALL NODES KSAFE 1;