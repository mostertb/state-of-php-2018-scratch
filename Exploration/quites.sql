-- This is nonsense as it only looks at files starting with quotes
SELECT
  single,
  double,
  total_files,
  total_lines
FROM (
  SELECT
    SUM(best='single') single,
    SUM(best='double') double,
    COUNT(*) total_files,
    SUM(c) as total_lines
  FROM (
    SELECT
      IF(SUM(line='\'')>SUM(line='\"'),
        'single',
        'double') WITHIN RECORD best,
      COUNT(line) WITHIN RECORD c
    FROM (
      SELECT
        LEFT(SPLIT(content, '\n'),
          1) line
      FROM
        [php-sa-2018:github_content_derived.active_php_contents]
      HAVING
        REGEXP_MATCH(line,
          r'[ \']') )
    HAVING
      c>10 # at least 10 lines that start with space or tab
      )
   )
ORDER BY
  total_files DESC

Row 	single 	double 	total_files 	total_lines
1 	12516 	2015024 	2027540 	262888095


SELECT
      COUNT(line) WITHIN RECORD c
    FROM (
      SELECT
        LEFT(SPLIT(content, '\n'),1) line
      FROM
        [php-sa-2018:github_content_derived.active_php_contents]
      HAVING
        REGEXP_MATCH(line,
          r'[ \']') )
    HAVING
      c>10 # at least 10 lines that start with space or tab
      )
   )



