
-- Repo names for PHP projects
-- `php-sa-2018.github_content_derived.repo_names_php`
SELECT
DISTINCT repo_name
FROM `bigquery-public-data.github_repos.languages`,
UNNEST (language ) as lang_name
WHERE lang_name.name = 'PHP';
-- 344,215 records


-- Github content repos that match ghtorrent 'active' php repos
-- `php-sa-2018.github_content_derived.repo_names_php_active`
SELECT
DISTINCT c.*
FROM `php-sa-2018.github_content_derived.repo_names_php` as c
INNER JOIN `php-sa-2018.ghtorrent_derived.projects_php_active` as a
ON c.repo_name = a.repo_name



-- Files in active php projects
-- `php-sa-2018.github_content_derived.active_php_files`
SELECT
DISTINCT
f.id,
f.repo_name,
f.path
FROM `bigquery-public-data.github_repos.files` as f
INNER JOIN `php-sa-2018.github_content_derived.repo_names_php_active` as a
ON f.repo_name = a.repo_name
WHERE f.path like '%.php'
AND f.path NOT like '%/vendor/%'
AND f.path NOT like 'vendor/%'
AND f.ref ='refs/heads/master'
Rows 2,896,713

-- Active PHP contents
-- `php-sa-2018.github_content_derived.active_php_contents`
SELECT
c.*
FROM `bigquery-public-data.github_repos.contents` as c
INNER JOIN `php-sa-2018.github_content_derived.active_php_files` as f
ON c.id = f.id
16.66 GB