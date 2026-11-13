WITH oldest_groups AS (
    SELECT
        hk_group_id
    FROM VT261029615224__DWH.h_groups
    ORDER BY registration_dt
    LIMIT 10
),

user_group_messages AS (
    SELECT
        lgd.hk_group_id,
        COUNT(DISTINCT lum.hk_user_id) AS cnt_users_in_group_with_messages
    FROM VT261029615224__DWH.l_user_message AS lum
    INNER JOIN VT261029615224__DWH.l_groups_dialogs AS lgd
        ON lum.hk_message_id = lgd.hk_message_id
    INNER JOIN oldest_groups AS og
        ON lgd.hk_group_id = og.hk_group_id
    GROUP BY
        lgd.hk_group_id
),

user_group_log AS (
    SELECT
        luga.hk_group_id,
        COUNT(DISTINCT luga.hk_user_id) AS cnt_added_users
    FROM VT261029615224__DWH.l_user_group_activity AS luga
    INNER JOIN VT261029615224__DWH.s_auth_history AS sah
        ON luga.hk_l_user_group_activity = sah.hk_l_user_group_activity
    INNER JOIN oldest_groups AS og
        ON luga.hk_group_id = og.hk_group_id
    WHERE sah.event = 'add'
    GROUP BY
        luga.hk_group_id
)

SELECT
    og.hk_group_id,
    COALESCE(ugl.cnt_added_users, 0) AS cnt_added_users,
    COALESCE(
        ugm.cnt_users_in_group_with_messages, 0
    ) AS cnt_users_in_group_with_messages,
    CAST(
        COALESCE(ugm.cnt_users_in_group_with_messages, 0)
        AS NUMERIC(18, 6)
    ) / NULLIF(ugl.cnt_added_users, 0) AS group_conversion
FROM oldest_groups AS og
LEFT JOIN user_group_log AS ugl
    ON og.hk_group_id = ugl.hk_group_id
LEFT JOIN user_group_messages AS ugm
    ON og.hk_group_id = ugm.hk_group_id
ORDER BY group_conversion DESC;