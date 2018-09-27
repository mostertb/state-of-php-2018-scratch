-- The most recent GHTorrent data in BigQuery is from April (https://bigquery.cloud.google.com/dataset/ghtorrent-bq:ght_2018_04_01?)
-- For more recent data, I downloaded the September 2018 MySQL GHTorrent dump (http://ghtorrent-downloads.ewi.tudelft.nl/mysql/mysql-2018-09-01.tar.gz),
-- imported it into a local data base and then exported the CSV data we are interested in, to import into BigQuery


-- sed -i 's/0000-00-00 00:00:00/\\N/g' ghtorrent_project_test.cs

-- gzip -k ghtorrent_project_non_deleted_or_forked.csv

-- 1) project_non_deleted_or_forked
--- Exclude `description` field due to 4GB BQ import limit

SELECT
`id`, `url`, `owner_id`, `name`, `language`, `created_at`, `updated_at`
INTO OUTFILE '/data/ghtorrent_project_non_deleted_or_forked.csv'
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY x'01'
OPTIONALLY ENCLOSED BY ''
FROM ghtorrent.projects
WHERE deleted=0
AND url IS NOT NULL
AND `name` IS NOT NULL
AND forked_from IS NULL;
-- Query OK, 92,437,149 rows affected (4 min 26.76 sec)
-- bq load --source_format=CSV --field_delimiter=^A --null_marker="\N" --quote="" --allow_quoted_newlines php-sa-2018:ghtorrent.projects_non_deleted_or_forked gs://php-sa-2018-ghtorrent/ghtorrent_project_non_deleted_or_forked.csv.gz /data/ghtorrent_project_non_deleted_or_forked_schema.json

-- location omitted due to dirty data that fails csv import
SELECT
`id`, `login`, `company`, `created_at`, `type`,`long`, `lat`, `country_code`, `state`, `city`
INTO OUTFILE '/data/ghtorrent_users_clean.csv'
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY x'01'
OPTIONALLY ENCLOSED BY x'02'
FROM ghtorrent.users
WHERE deleted=0
AND fake=0
;
-- Query OK, 19,719,196 rows affected (47.99 sec)
-- bq load --source_format=CSV --field_delimiter=^A --null_marker="\N" --quote="^B" --allow_quoted_newlines php-sa-2018:ghtorrent.users_clean gs://php-sa-2018-ghtorrent/ghtorrent_users_clean.csv /data/ghtorrent_users_clean_schema.json


--  project languages
SELECT pl.project_id, pl.language, pl.bytes, pl.created_at
INTO OUTFILE '/data/ghtorrent_project_languages_clean.csv'
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY x'01'
OPTIONALLY ENCLOSED BY x'02'
FROM ghtorrent.project_languages as pl
INNER JOIN ghtorrent.projects as p
ON pl.project_id = p.id
WHERE p.deleted=0
AND p.url IS NOT NULL
AND p.name IS NOT NULL
AND p.forked_from IS NULL;

-- Query OK, 50267317 rows affected (20 min 40.01 sec)
-- bq load --source_format=CSV --field_delimiter=^A --null_marker="\N" --quote="^B" --allow_quoted_newlines php-sa-2018:ghtorrent.project_languages_clean gs://php-sa-2018-ghtorrent/ghtorrent_project_languages_clean.csv /data/ghtorrent_project_languages_clean_schema.json


-- project_watchers
SELECT w.repo_id, w.user_id, w.created_at
INTO OUTFILE '/data/ghtorrent_watchers_clean.csv'
CHARACTER SET UTF8MB4
FIELDS TERMINATED BY x'01'
OPTIONALLY ENCLOSED BY x'02'
FROM ghtorrent.watchers as w
INNER JOIN ghtorrent.projects as p
ON w.repo_id = p.id
INNER JOIN ghtorrent.users as u
ON w.user_id = u.id
WHERE p.deleted=0
AND p.url IS NOT NULL
AND p.name IS NOT NULL
AND p.forked_from IS NULL
AND u.deleted=0
AND u.fake=0;
-- Query OK, 105485251 rows affected (15 min 33.67 sec)
-- bq load --source_format=CSV --field_delimiter=^A --null_marker="\N" --quote="" --allow_quoted_newlines --time_partitioning_field=created_at php-sa-2018:ghtorrent.watchers_clean gs://php-sa-2018-ghtorrent/ghtorrent_watchers_clean.csv.gz /data/ghtorrent_watchers_clean_schema.json