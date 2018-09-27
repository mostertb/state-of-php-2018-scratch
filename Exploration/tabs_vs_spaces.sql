-- Based on https://medium.com/@hoffa/400-000-github-repositories-1-billion-files-14-terabytes-of-code-spaces-or-tabs-7cfe0b5dd7fd
SELECT
  tabs,
  spaces,
  total_files,
  total_lines
FROM (
  SELECT
    SUM(best='tab') tabs,
    SUM(best='space') spaces,
    COUNT(*) total_files,
    SUM(c) as total_lines
  FROM (
    SELECT
      IF(SUM(line=' ')>SUM(line='\t'),
        'space',
        'tab') WITHIN RECORD best,
      COUNT(line) WITHIN RECORD c
    FROM (
      SELECT
        LEFT(SPLIT(content, '\n'),
          1) line
      FROM
        [php-sa-2018:github_content_derived.active_php_contents]
      HAVING
        REGEXP_MATCH(line,
          r'[ \t]') )
    HAVING
      c>10 # at least 10 lines that start with space or tab
      )
   )
ORDER BY
  total_files DESC

LIMIT
  100

Row 	tabs 	spaces 	total_files 	total_lines 	lratio
1 	649,150 	1,748,235 	2,397,385 	413,175,973 	0.990697203262821