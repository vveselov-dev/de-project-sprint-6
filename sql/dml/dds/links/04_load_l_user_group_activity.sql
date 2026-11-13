INSERT INTO VT261029615224__DWH.l_user_group_activity
(
    hk_l_user_group_activity,
    hk_user_id,
    hk_group_id,
    load_dt,
    load_src
)
SELECT DISTINCT
    HASH(hu.hk_user_id, hg.hk_group_id) AS hk_l_user_group_activity,
    hu.hk_user_id,
    hg.hk_group_id,
    NOW() AS load_dt,
    's3' AS load_src
FROM VT261029615224__STAGING.group_log AS gl
LEFT JOIN VT261029615224__DWH.h_users AS hu
    ON gl.user_id = hu.user_id
LEFT JOIN VT261029615224__DWH.h_groups AS hg
    ON gl.group_id = hg.group_id
WHERE NOT EXISTS (
    SELECT 1
    FROM VT261029615224__DWH.l_user_group_activity AS l
    WHERE l.hk_l_user_group_activity =
        HASH(hu.hk_user_id, hg.hk_group_id)
);