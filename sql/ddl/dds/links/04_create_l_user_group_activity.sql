CREATE TABLE VT261029615224__DWH.l_user_group_activity
(
    hk_l_user_group_activity INT NOT NULL,
    hk_user_id INT NOT NULL,
    hk_group_id INT NOT NULL,
    load_dt TIMESTAMP(6) NOT NULL,
    load_src VARCHAR(20) NOT NULL,

    CONSTRAINT fk_l_user_group_activity_h_users
        FOREIGN KEY (hk_user_id)
        REFERENCES VT261029615224__DWH.h_users (hk_user_id),

    CONSTRAINT fk_l_user_group_activity_h_groups
        FOREIGN KEY (hk_group_id)
        REFERENCES VT261029615224__DWH.h_groups (hk_group_id)
)
PARTITION BY load_dt::DATE
GROUP BY CALENDAR_HIERARCHY_DAY(load_dt::DATE, 2, 2);

CREATE PROJECTION VT261029615224__DWH.l_user_group_activity
(
    hk_l_user_group_activity,
    hk_user_id,
    hk_group_id,
    load_dt,
    load_src
)
AS
SELECT
    hk_l_user_group_activity,
    hk_user_id,
    hk_group_id,
    load_dt,
    load_src
FROM VT261029615224__DWH.l_user_group_activity
ORDER BY
    load_dt
SEGMENTED BY HASH(hk_l_user_group_activity) ALL NODES KSAFE 1;