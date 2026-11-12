-- Создание staging-таблицы users

CREATE TABLE VT261029615224__STAGING.users
(
    id INT NOT NULL,
    chat_name VARCHAR(200) NOT NULL,
    registration_dt TIMESTAMP(6),
    country VARCHAR(200),
    age INT,
    CONSTRAINT PK_users PRIMARY KEY (id) DISABLED
);

-- Создание проекции

CREATE PROJECTION VT261029615224__STAGING.users /*+createtype(L)*/
(
    id,
    chat_name,
    registration_dt,
    country,
    age
)
AS
SELECT
    users.id,
    users.chat_name,
    users.registration_dt,
    users.country,
    users.age
FROM VT261029615224__STAGING.users
ORDER BY users.id
SEGMENTED BY HASH(users.id) ALL NODES KSAFE 1;

