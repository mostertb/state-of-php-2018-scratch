SELECT
count(id)
FROM `php-sa-2018.github_content_derived.active_php_contents`
WHERE content like '%<=>%';


SELECT
count(id)
FROM `php-sa-2018.github_content_derived.active_php_contents`
WHERE content like '% yield %';


SELECT
count(check.has)
FROM
(
  SELECT
  CASE
   WHEN REGEXP_CONTAINS(content, r"\(.*,\s*\)\s*;")
   THEN 1
   ELSE 0
  END as has
  FROM `php-sa-2018.github_content_derived.active_php_contents`
) check
WHERE check.has = 1;

110556


SELECT
count(check.has)
FROM
(
  SELECT
  CASE
   WHEN REGEXP_CONTAINS(content, r"array\(.*,\s*\)\s*;") THEN 1
   ELSE 0
  END as has
  FROM `php-sa-2018.github_content_derived.active_php_contents`
) check
WHERE check.has = 1;
56525

