

152188 composer.json in root accross all heads

-- Which branch are composer files on
SELECT
f.ref,
count(f.path) as count
FROM `bigquery-public-data.github_repos.files` as f
WHERE f.path = 'composer.json'
group by f.ref
ORDER BY count DESC;
--
-- Row 	ref 	count
-- 1 	refs/heads/master 	144044
-- 2 	refs/heads/develop 	3289
-- 3 	refs/heads/dev 	416
-- 4 	refs/heads/staging 	227
-- 5 	refs/heads/1.0 	170
-- 6 	refs/heads/development 	169
-- 7 	refs/heads/5.1 	154
-- 8 	refs/heads/gh-pages 	153
-- 9 	refs/heads/2.0 	139
-- 10 	refs/heads/1.x 	138


-- Credit: Brent Shaffer  - PHP Advocate e@Google
CREATE TEMPORARY FUNCTION parseComposer(json STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS """
  var result = []
  try {
    var json = JSON.parse(json)
    for (key in json.require) {
      result.push(key)
    }
    delete json;
  } catch(e) {
  }
  return result;
  """;

SELECT
  package_name,
  COUNT(package_name) AS count
FROM
(
  SELECT
    parseComposer(c.content) AS package_name
  FROM
    `bigquery-public-data.github_repos.contents` c
  JOIN (
    SELECT
      id
    FROM
      `bigquery-public-data.github_repos.files`
    WHERE
      path = "composer.json" ) f
  ON
    f.id = c.id
) packages,
  UNNEST(package_name) AS package_name
WHERE
  package_name IS NOT NULL
GROUP BY
  package_name
ORDER BY
  count DESC
;


-- Breakdown by vendor
SELECT
REPLACE(REGEXP_EXTRACT(package_name, r"^.+\/"), '/', '') as vendor,
SUM(count) as total
FROM `php-sa-2018.github_content_derived.composer_package_count`
GROUP BY vendor
ORDER BY total desc


-- Breakdown by framework
SELECT
*
FROM `php-sa-2018.github_content_derived.composer_package_count`
WHERE package_name IN(
-- 'laravel/laravel',
'symfony/symfony',
'codeigniter/framework',
'yiisoft/yii2',
'phalcon/cphalcon',
'cakephp/cakephp',
'zendframework/zendframework',
'slim/slim',
-- 'laravel/lumen',
'laravel/lumen-framework',
'silex/silex',
'laravel/framework'
)
ORDER BY count desc
-- 'laravel/laravel',
'symfony/symfony',
'codeigniter/framework',
'yiisoft/yii2',
'phalcon/cphalcon',
'cakephp/cakephp',
'zendframework/zendframework',
'slim/slim',
-- 'laravel/lumen',
'laravel/lumen-framework',
'silex/silex',
'laravel/framework'


-- php extensions
-- `php-sa-2018.github_content_derived.composer_php_requirement`
SELECT
package_name,
count
FROM `php-sa-2018.github_content_derived.composer_package_count`
WHERE package_name like 'ext-%'
AND package_name not like '%/%'
ORDER BY count DESC


-- PHP Version requirements
-- `php-sa-2018.github_content_derived.composer_php_requirement`
CREATE TEMPORARY FUNCTION parseComposer(json STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS """
  var result = []
  try {
    var json = JSON.parse(json)
    for (key in json.require) {
      if(key === 'php'){
        result.push(json.require[key])
      }
    }
    delete json;
  } catch(e) {
  }
  return result;
  """;

SELECT
  version,
  COUNT(version) AS count
FROM
(
  SELECT
    parseComposer(c.content) AS version
  FROM
    `bigquery-public-data.github_repos.contents` c
  JOIN (
    SELECT
      id
    FROM
      `bigquery-public-data.github_repos.files`
    WHERE
      path = "composer.json" ) f
  ON
    f.id = c.id
) packages,
  UNNEST(version) AS version
WHERE
  version IS NOT NULL
GROUP BY
  version
ORDER BY
  count DESC


-- Naive sum
SELECT
CASE
  WHEN version LIKE '%5.1%' THEN '5.1'
  WHEN version LIKE '%5.2%' THEN '5.2'
  WHEN version LIKE '%5.3%' THEN '5.3'
  WHEN version LIKE '%5.4%' THEN '5.4'
  WHEN version LIKE '%5.5%' THEN '5.5'
  WHEN version LIKE '%5.6%' THEN '5.6'
  WHEN version LIKE '%7.0%' THEN '7.0'
  WHEN version LIKE '%7.1%' THEN '7.1'
  WHEN version LIKE '%7.2%' THEN '7.2'
  ELSE ''
END as clean_version,
SUM(count) as total
FROM `php-sa-2018.github_content_derived.composer_php_requirement`
GROUP BY clean_version
ORDER BY clean_version ASC

-- Only Major version 7
SELECT SUM(count)
FROM `php-sa-2018.github_content_derived.composer_php_requirement`
WHERE version LIKE '%7%'
AND version NOT LIKE '%7.%'
AND version NOT LIKE '%.7%'
AND version NOT LIKE '%5._._7%'
AND version NOT LIKE '%<7%'
-- Row 	f0_
-- 1 	402


-- Dev packages
CREATE TEMPORARY FUNCTION parseComposer(json STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS """
  var result = []
  try {
    var json = JSON.parse(json)
    for (key in json['require-dev']) {
      result.push(key)
    }
    delete json;
  } catch(e) {
  }
  return result;
  """;

SELECT
  package_name,
  COUNT(package_name) AS count
FROM
(
  SELECT
    parseComposer(c.content) AS package_name
  FROM
    `bigquery-public-data.github_repos.contents` c
  JOIN (
    SELECT
      id
    FROM
      `bigquery-public-data.github_repos.files`
    WHERE
      path = "composer.json" ) f
  ON
    f.id = c.id
) packages,
  UNNEST(package_name) AS package_name
WHERE
  package_name IS NOT NULL
GROUP BY
  package_name
ORDER BY
  count DESC
;



