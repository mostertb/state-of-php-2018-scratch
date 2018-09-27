-- Lines containing Stack Overflow
SELECT
  line
FROM (
  SELECT
    SPLIT(content, '\n') AS line
  FROM
    `php-sa-2018.github_content_derived.active_php_contents` ) lines,
  UNNEST(line) AS line
WHERE
  line LIKE '%stackoverflow%'
  OR line LIKE '%stack overflow%'

Rows 4694


-- Files containing Stack Overflow
SELECT
count(id)
FROM `php-sa-2018.github_content_derived.active_php_contents`
WHERE content like '%stackoverflow%'
OR content like '%stack overflow%'

-- Row 	f0_
-- 1 	3892


