-- Distinct project_languages for PHP projects
-- BQ Table: php-sa-2018.ghtorrent_derived.project_languages_distinct_php
SELECT distinct pl.* -- distinct as there are exact duplicates at the same time (from race conditions in ghtorrent's queuing system)
FROM
(
  -- unique projects in the language table along with the date they were most recently update
  SELECT p.id as id,
  max(pli.created_at) as most_recent_created_at
  FROM `php-sa-2018.ghtorrent.projects_non_deleted_or_forked` as p
  INNER JOIN `php-sa-2018.ghtorrent.users_clean` as u -- limits projects to non-delete, non-fake users
  ON p.owner_id = u.id
  INNER JOIN `php-sa-2018.ghtorrent.project_languages_clean` as pli
  ON p.id = pli.project_id AND pli.language = 'php'
  GROUP BY p.id
) distinct_php_project
INNER JOIN `php-sa-2018.ghtorrent.project_languages_clean` pl
ON distinct_php_project.id = pl.project_id AND distinct_php_project.most_recent_created_at = pl.created_at
;
-- Number of rows (without distinct) 4,139,925
-- Number of row (distinct)          4,129,464

-- Percentage of projects that contain PHP
-- php-sa-2018.ghtorrent_derived.php_percentage
SELECT
t_php_bytes.project_id as project_id,
t_php_bytes.bytes as php_bytes,
t_total_bytes.bytes as total_bytes,
ROUND(t_php_bytes.bytes/t_total_bytes.bytes*100, 2) as php_percentage
FROM
(
  SELECT
  project_id,
  SUM(bytes) as bytes
  FROM `php-sa-2018.ghtorrent_derived.project_languages_distinct_php`
  GROUP BY project_id
) t_total_bytes
INNER JOIN
(
  SELECT
  project_id,
  bytes as bytes
  FROM `php-sa-2018.ghtorrent_derived.project_languages_distinct_php`
  WHERE language = 'php'
) t_php_bytes
ON t_total_bytes.project_id = t_php_bytes.project_id
WHERE t_total_bytes.bytes > 0 -- no division  by zero
-- rows 1,231,850
--  714 zero byte projects
-- SELECT
-- project_id,
-- sum(bytes) as s
-- FROM `php-sa-2018.ghtorrent_derived.project_languages_distinct_php`
-- GROUP BY project_id
-- HAVING s = 0;



-- PHP projects
---
-- More than 10KB in size with a non-zero amount of PHP
-- `php-sa-2018.ghtorrent_derived.projects_php`
SELECT
DISTINCT proj.*,
CONCAT(u.login, '/', proj.name) as repo_name
FROM `php-sa-2018.ghtorrent.projects_non_deleted_or_forked` as proj
INNER JOIN `php-sa-2018.ghtorrent_derived.php_percentage`  as perc
ON proj.id = perc.project_id
INNER JOIN `php-sa-2018.ghtorrent.users_clean` as u
ON proj.owner_id = u.id
WHERE perc.php_bytes > 0
AND perc.total_bytes > 10240;


-- PHP Projects Active in the last year
-- `php-sa-2018.ghtorrent_derived.projects_php_active`
SELECT
  DISTINCT p.*
FROM
  `php-sa-2018.ghtorrent_derived.projects_php` AS p
INNER JOIN
  `php-sa-2018.github_archive_derived.events_php_past_year` AS e
ON
  p.repo_name = e.repo_name
  AND e.type IN (
    'PushEvent',
    'WatchEvent',
    'PullRequestEvent',
    'CreateEvent',
    'ReleaseEvent'
  ) ;
-- Rows 161,896

