-- Создание staging-таблицы groups

CREATE TABLE VT261029615224__STAGING.groups
(
    id INT NOT NULL,
    admin_id INT,
    group_name VARCHAR(100),
    registration_dt TIMESTAMP(6),
    is_private BOOLEAN,
    CONSTRAINT PK_groups PRIMARY KEY (id) DISABLED
)
PARTITION BY ((groups.registration_dt)::date)
GROUP BY (
    CASE
        WHEN "datediff"(
            'year',
            (groups.registration_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 2
        THEN (date_trunc('year', (groups.registration_dt)::date))::date
        WHEN "datediff"(
            'month',
            (groups.registration_dt)::date,
            ((now())::timestamptz(6))::date
        ) >= 3
        THEN (date_trunc('month', (groups.registration_dt)::date))::date
        ELSE (groups.registration_dt)::date
    END
);

-- Внешний ключ на staging.users

ALTER TABLE VT261029615224__STAGING.groups
ADD CONSTRAINT FK_groups_admin
FOREIGN KEY (admin_id)
REFERENCES VT261029615224__STAGING.users (id);

-- Создание проекции

CREATE PROJECTION VT261029615224__STAGING.groups
(
    id,
    admin_id,
    group_name,
    registration_dt,
    is_private
)
AS
SELECT
    groups.id,
    groups.admin_id,
    groups.group_name,
    groups.registration_dt,
    groups.is_private
FROM VT261029615224__STAGING.groups
ORDER BY
    groups.id,
    groups.admin_id
SEGMENTED BY HASH(groups.id) ALL NODES KSAFE 1;

