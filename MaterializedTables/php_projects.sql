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


-- Distinct projects_non_deleted_or_forked for PHP








-- All PHP Projects
SELECT p.*
FROM `php-sa-2018.ghtorrent.projects_non_deleted_or_forked` as p
INNER JOIN `php-sa-2018.ghtorrent.users_clean` as u -- limits projects to non-delete, non-fake users
ON p.owner_id = u.id
INNER JOIN `php-sa-2018.ghtorrent.project_languages_clean` as pl
ON p.id = pl.project_id AND pl.language = 'php'
GROUP BY p.id; -- language table contains duplicates


SELECT p.*
FROM `php-sa-2018.ghtorrent.projects_non_deleted_or_forked` as p
INNER JOIN `php-sa-2018.ghtorrent.users_clean` as u -- limits projects to non-delete, non-fake users
ON p.owner_id = u.id
INNER JOIN `php-sa-2018.ghtorrent.project_languages_clean` as pl
ON p.id = pl.project_id AND pl.language = 'php'
GROUP BY p.id; -- language table contains duplicates