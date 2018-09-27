-- Total number of repos in ghtorrent
SELECT
count(distinct id)
FROM ghtorrent.projects;
-- +--------------------+
-- | count(distinct id) |
-- +--------------------+
-- |           98,452,740 |
-- +--------------------+
-- 1 row in set (2 min 14.76 sec)

-- Commits in GHTorrent
-- root@compute:~/phpsa2018/mysql-2018-09-01# time wc -l commits.csv
-- 1,083,445,192 commits.csv
--
-- real	8m0.419s
-- user	0m29.912s
-- sys	1m19.524s


-- Total number of 'undeleted' repos in ghtorrent
SELECT
count(distinct p.id)
FROM ghtorrent.projects as p
INNER JOIN ghtorrent.users as u
ON p.owner_id = u.id
WHERE p.deleted=0
AND p.url IS NOT NULL
AND p.name IS NOT NULL
-- AND forked_from IS NULL
AND u.deleted=0
AND u.fake=0
;

-- +--------------------+ without user limitation
-- | count(distinct id) |
-- +--------------------+
-- |           92,437,149 |
-- +--------------------+

-- 1 row in set (2 min 24.33 sec)

-- +----------------------+
-- | count(distinct p.id) |
-- +----------------------+
-- |             89,356,055 |
-- +----------------------+
-- 1 row in set (12 min 14.93 sec)



-- Total number of 'undeleted', 'non-forked' repos in ghtorrent
SELECT
count(distinct p.id)
FROM ghtorrent.projects as p
INNER JOIN ghtorrent.users as u
ON p.owner_id = u.id
WHERE p.deleted=0
AND p.url IS NOT NULL
AND p.name IS NOT NULL
AND p.forked_from IS NULL
AND u.deleted=0
AND u.fake=0
;

-- Total number of non-forked, non-deleted projects with more than 10KB non-vendor/non-generated code
SELECT
  COUNT(distinct distinct_project.id) -- distinct as there are exact duplicates at the same time (from race conditions
                                      -- in  ghtorrent's queuing system)
FROM
(
  -- unique projects in the language table along with the date they were most recently update (as there is a full set of
  -- records each time data is refreshed)
  SELECT p.id as id,
  max(pli.created_at) as most_recent_created_at
  FROM `php-sa-2018.ghtorrent.projects_non_deleted_or_forked` as p
  INNER JOIN `php-sa-2018.ghtorrent.users_clean` as u
  ON p.owner_id = u.id
  INNER JOIN `php-sa-2018.ghtorrent.project_languages_clean` as pli
  ON p.id = pli.project_id
  GROUP BY p.id
) distinct_project
INNER JOIN
(
  -- sum of bytes per project per update
  SELECT pli.project_id as id,
  pli.created_at as created_at,
  SUM(pli.bytes) as total_bytes
  FROM `php-sa-2018.ghtorrent.projects_non_deleted_or_forked` as p
  INNER JOIN `php-sa-2018.ghtorrent.users_clean` as u
  ON p.owner_id = u.id
  INNER JOIN `php-sa-2018.ghtorrent.project_languages_clean` as pli
  ON p.id = pli.project_id
  GROUP BY pli.project_id, pli.created_at
) as project_byte_sum
ON distinct_project.id = project_byte_sum.id AND distinct_project.most_recent_created_at = project_byte_sum.created_at
WHERE project_byte_sum.total_bytes > 10240
;
-- Duration 53.024 sec
-- Bytes processed 2.13 GB
-- Rows 7,892,367

-- +--------------------+
-- | count(distinct id) |
-- +--------------------+
-- |           57,921,775 |
-- +--------------------+
-- 1 row in set (3 min 54.76 sec)

-- Number PHP 'undeleted' repos in ghtorrent
SELECT count(DISTINCT pl.project_id)
FROM ghtorrent.project_languages as pl
INNER JOIN ghtorrent.projects as p
ON pl.project_id = p.id
INNER JOIN ghtorrent.users as u
ON p.owner_id = u.id
WHERE p.deleted=0
AND p.url IS NOT NULL
AND p.name IS NOT NULL
-- AND p.forked_from IS NULL
AND u.deleted=0
AND u.fake=0
AND pl.language ='php';

-- +-------------------------------+
-- | count(DISTINCT pl.project_id) |
-- +-------------------------------+
-- |                       2,486,699 |
-- +-------------------------------+
-- 1 row in set (4 min 39.03 sec)

-- Number PHP  'undeleted', 'non-forked' repos in ghtorrent
SELECT count(DISTINCT pl.project_id)
FROM ghtorrent.project_languages as pl
INNER JOIN ghtorrent.projects as p
ON pl.project_id = p.id
INNER JOIN ghtorrent.users as u
ON p.owner_id = u.id
WHERE p.deleted=0
AND p.url IS NOT NULL
AND p.name IS NOT NULL
AND p.forked_from IS NULL
AND u.deleted=0
AND u.fake=0
AND pl.language ='php';

-- +-------------------------------+
-- | count(DISTINCT pl.project_id) |
-- +-------------------------------+
-- |                     1,232,564 |
-- +-------------------------------+
-- 1 row in set (1 min 22.24 sec)

-- Number PHP 'undeleted', 'non-forked' repos in ghtorrent larger than 10KB with non-zero PHP Bytes
SELECT
  COUNT(project_id)
FROM
  `php-sa-2018.ghtorrent_derived.php_percentage`
WHERE
  php_bytes > 0
  AND total_bytes > 10240;
-- Row 	f0_
-- 1 	939895

SELECT
COUNT (distinct all_notable_projects.repo_name)
FROM
(
  SELECT
    distinct distinct_project.repo_name as repo_name -- distinct due to duplicates at the same created_at
  FROM
  (
    -- unique projects in the language table along with the date they were most recently update (as there is a full set of
    -- records each time data is refreshed)
    SELECT p.id as id,
    CONCAT(u.login, '/', p.name) as repo_name,
    max(pli.created_at) as most_recent_created_at
    FROM `php-sa-2018.ghtorrent.projects_non_deleted_or_forked` as p
    INNER JOIN `php-sa-2018.ghtorrent.users_clean` as u
    ON p.owner_id = u.id
    INNER JOIN `php-sa-2018.ghtorrent.project_languages_clean` as pli
    ON p.id = pli.project_id
    GROUP BY p.id,repo_name
  ) distinct_project
  INNER JOIN
  (
    -- sum of bytes per project per update
    SELECT pli.project_id as id,
    pli.created_at as created_at,
    SUM(pli.bytes) as total_bytes
    FROM `php-sa-2018.ghtorrent.projects_non_deleted_or_forked` as p
    INNER JOIN `php-sa-2018.ghtorrent.users_clean` as u
    ON p.owner_id = u.id
    INNER JOIN `php-sa-2018.ghtorrent.project_languages_clean` as pli
    ON p.id = pli.project_id
    GROUP BY pli.project_id, pli.created_at
  ) as project_byte_sum
  ON distinct_project.id = project_byte_sum.id AND distinct_project.most_recent_created_at = project_byte_sum.created_at
  WHERE project_byte_sum.total_bytes > 10240
) all_notable_projects
INNER JOIN `githubarchive.month.201*`  as a
ON a.repo.name = all_notable_projects.repo_name
WHERE _TABLE_SUFFIX IN (
'709', '710', '711', '712',
'801','802','803','804','805','806','807','808'
)
AND a.type IN (
    'PushEvent',
    'WatchEvent',
    'PullRequestEvent',
    'CreateEvent',
    'ReleaseEvent'
)
;
-- Row 	f0_
-- 1 	1,654,039
-- Duration 32.275 sec
-- Bytes processed 19.85 GB



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

SELECT
a.id,
a.type as type,
a.repo.id as ga_repo_id,
a.repo.name as repo_name,
a.actor.id as ga_actor_id,
a.actor.login as actor_login,
a.created_at as created_at
FROM `githubarchive.month.201*` a
INNER JOIN `php-sa-2018.ghtorrent_derived.projects_php` as p
ON a.repo.name = p.repo_name
WHERE _TABLE_SUFFIX IN (
'709', '710', '711', '712',
'801','802','803','804','805','806','807','808'
)

