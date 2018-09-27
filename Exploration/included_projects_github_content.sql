-- Total number of repos in github_repos
select
count(distinct repo_name)
from `bigquery-public-data.github_repos.files` ;
-- Row 	f0_
-- 1 	3,353,813

---- PHP specific
-- Number PHP repos in github_repos
SELECT
count(repo_name)
FROM `bigquery-public-data.github_repos.languages`,
UNNEST (language ) as lang_name
WHERE lang_name.name = 'PHP';
-- Row 	f0_
-- 1 	344,215

-- Total numbe rPHP projects >= 10KB
SELECT
count(php_l.repo_name)
FROM `bigquery-public-data.github_repos.languages` as php_l,
UNNEST (language ) as php_lang
INNER  JOIN
(
  -- total bytes per project
  SELECT
  repo_name,
  SUM(lang.bytes) as bytes
  FROM `bigquery-public-data.github_repos.languages`,
  UNNEST (language ) as lang
  GROUP BY repo_name
) as total
ON php_l.repo_name = total.repo_name
WHERE php_lang.name = 'PHP'
AND php_lang.bytes > 0
AND total.bytes >= 10240
;

-- Row 	f0_
-- 1 	290206

-- Distinct languages
SELECT
  DISTINCT lang.name
FROM
  `bigquery-public-data.github_repos.languages`,
  UNNEST (LANGUAGE ) AS lang
 ORDER BY lang.name;
-- 56.61 MB
-- Total 358
-- Looking for 'PHP' all caps

