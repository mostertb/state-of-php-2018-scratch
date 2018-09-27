-- Types of events for PHP project over the past year
-- saved to sheet
SELECT
type,
count(id) as count
FROM `php-sa-2018.github_archive_derived.events_php_past_year`
GROUP BY type
ORDER BY count DESC
