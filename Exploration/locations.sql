-- Country Location of PHP Project Owners (World)
SELECT
UPPER(u.country),
count(distinct u.login) as count
FROM `php-sa-2018.ghtorrent.users_clean` u
INNER JOIN `php-sa-2018.ghtorrent_derived.projects_php` as p
ON u.id = p.owner_id
-- WHERE u.country is not null
-- AND u.country != 'us'
GROUP BY u.country
ORDER BY count DESC;

-- Owners in Africa
SELECT
c.country,
count(distinct u.login) as count
FROM `php-sa-2018.ghtorrent.users_clean` u
INNER JOIN `php-sa-2018.ghtorrent_derived.projects_php` as p
ON u.id = p.owner_id
INNER JOIN `gdelt-bq.extra.countryinfo2` as c
ON UPPER(u.country) = c.iso
WHERE c.continent = 'AF'
GROUP BY c.country
ORDER BY count DESC;

-- Breakdown of South African Provinces
SELECT DISTINCT
u.state,
count(distinct u.login) as count
FROM `php-sa-2018.ghtorrent.users_clean` u
INNER JOIN `php-sa-2018.ghtorrent_derived.projects_php` as p
ON u.id = p.owner_id
WHERE u.country = 'za'
GROUP BY u.state
ORDER BY count DESC
;