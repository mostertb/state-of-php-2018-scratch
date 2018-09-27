-- Events for PHP projects in the past year
-- php-sa-2018.github_archive_derived.events_php_past_year`
SELECT
a.id,
a.type as type,
a.repo.id as ga_repo_id,
a.repo.name as repo_name,
a.actor.id as ga_actor_id,
a.actor.login as actor_login,
a.created_at as created_at
FROM `githubarchive.month.201*` a
INNER JOIN `php-sa-2018.ghtorrent_derived.projects_php` as p
ON a.repo.name = p.repo_name
WHERE _TABLE_SUFFIX IN (
'709', '710', '711', '712',
'801','802','803','804','805','806','807','808'
)

