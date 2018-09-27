-- Duplicates in the language data
SELECT count(project_id)
FROM
(
  SELECT
  project_id, count(language) as c
  FROM `php-sa-2018.ghtorrent.project_languages_clean`
  WHERE language='php'
  GROUP BY project_id
  HAVING c > 1
) a;
-- Row 	f0_
-- 1 	829003
-- Duration 3.625 sec
-- Bytes processed 739.39 MB

-- Duplicates on the same date
--  2703

-- Percentage PHP bytes in projects containing PHP
SELECT
ROUND(php_percentage, 0) as perc,
count(project_id) as count
FROM `php-sa-2018.ghtorrent_derived.php_percentage`
GROUP BY perc
ORDER BY perc ASC;

SELECT
ROUND(php_percentage, 0) as perc,
count(project_id) as count
FROM `php-sa-2018.ghtorrent_derived.php_percentage`
WHERE total_bytes >= 10240 -- at least 10KB of detected code
AND php_bytes > 0
GROUP BY perc
ORDER BY perc ASC;


-- Languages used with PHP (All)
SELECT
  l.LANGUAGE,
  COUNT(l.project_id ) AS count
FROM
  `php-sa-2018.ghtorrent_derived.project_languages_distinct_php` AS l
INNER JOIN
  `php-sa-2018.ghtorrent_derived.php_percentage` AS p
ON
  l.project_id = p.project_id
WHERE
  p.php_bytes > 0
  AND p.total_bytes >= 10240 -- at least 10KB of detected code
  -- AND p.php_percentage <= 10
  -- AND p.php_percentage >= 37 AND p.php_percentage <= 38
  AND p.php_percentage  >= 90
  AND l.LANGUAGE != 'php'
GROUP BY
  l.LANGUAGE
ORDER BY
  count DESC;

-- Languages used with PHP (Active)
SELECT
  l.LANGUAGE,
  COUNT(l.project_id ) AS count
FROM
  `php-sa-2018.ghtorrent_derived.project_languages_distinct_php` AS l
INNER JOIN
  `php-sa-2018.ghtorrent_derived.php_percentage` AS p
ON
  l.project_id = p.project_id
INNER JOIN `php-sa-2018.ghtorrent_derived.projects_php_active` as active
ON l.project_id = active.id
WHERE
  p.php_bytes > 0
  AND p.total_bytes >= 10240 -- at least 10KB of detected code
  -- AND p.php_percentage <= 10
  -- AND p.php_percentage >= 37 AND p.php_percentage <= 38
  AND p.php_percentage  >= 90
  AND l.LANGUAGE != 'php'
GROUP BY
  l.LANGUAGE
ORDER BY
  count DESC;

-- Count of unique projects that currently have PHP
SELECT count(project_id)
FROM `php-sa-2018.ghtorrent_derived.project_languages_distinct_php`
WHERE language = 'php';
-- Row 	f0_
-- 1 	1,232,564
-- Matches count of projects 1,232,564


