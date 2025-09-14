-- ----------------------------------------------------------------------
-- Query 1 : Top 10 countries with maximum medals
-- Desc : 	 This query identifies the top 10 countries by total medals won
--        	 including a breakdown of Gold, Silver and bronze
-- ----------------------------------------------------------------------

with medal_count as(
	SELECT 
	    nr.region AS Country,
	    COUNT(*) AS total_medals,
	    COUNT(*) FILTER (WHERE ae.medal = 'Gold') AS gold_medals,
	    COUNT(*) FILTER (WHERE ae.medal = 'Silver') AS silver_medals,
	    COUNT(*) FILTER (WHERE ae.medal = 'Bronze') AS bronze_medals
	FROM athlete_events ae
	JOIN noc_regions nr ON ae.noc = nr.noc
	WHERE ae.medal IN ('Gold', 'Silver', 'Bronze')
	group by nr.region
)
select * from medal_count 
ORDER BY total_medals DESC
LIMIT 10;



/*
with medal_count as (
	select 
		team as Country, 
		Count(*) as total_medal,
		SUM(case
			when medal = 'Gold' then 1 else 0
		end) as gold_medals,
		SUM(case
			when medal = 'Silver' then 1 else 0
		end) as silver_medals,
		SUM(case
			when medal = 'Bronze' then 1 else 0
		end) as bronze_medals	
	from athlete_events ae
	join noc_regions nr on ae.noc = nr.noc
	where medal in ('Gold', 'Silver', 'Bronze')
	group by team 
)
select * from medal_count mc
order by total_medal desc
limit 10;
*/
--insights : 
-- The United States leads with the highest number of medals in Olympics
-- followed by France, Great Britain and Germany.
------------------------------------------------------------------------------------


------------------------------------------------------------------------------------
--QUERY 2 : Find the total number of countries participated in each Olympic Games
------------------------------------------------------------------------------------

select 
	distinct games,
	Count(distinct nr.region) as total_countries_participated
from athlete_events ae 
join noc_regions nr on ae.noc = nr.noc
group by games
order by games 



-- ----------------------------------------------------------------------
-- Query 3: Most-Successful Athletes.
-- Desc   : This query identifies the top 10 athlete with highest number of Medals 
-- ----------------------------------------------------------------------

WITH MedalWinners AS (
	select * from athlete_events ae 
	where medal in ('Gold', 'Silver', 'Bronze')
),
athleteMedals as (
	select 
		 name, team as Country, Count(*) as total_medals,
		SUM(case 
			when medal = 'Gold' then 1 else 0
		end) as gold_medal,
		SUM(case 
			when medal = 'Silver' then 1 else 0
		end) as silver_medal,
		SUM(case 
			when medal = 'Bronze' then 1 else 0
		end) as bronze_medal
	from MedalWinners
	group by name, team
)
select 
	*,
	Dense_Rank() Over(order by total_medals desc) as rank	
from athleteMedals
order by total_medals desc, gold_medal Desc 
limit 5

--INSIGHTS : 
--	Michael Fred Phelps from The United States Has won the highest number
--  Olympics Medals and majority of the them are GOLD  
------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Query 4: Top Sports by Number of Events
-- Desc   : This query identifies the sports that have had the highest number of distinct events 
-- ----------------------------------------------------------------------

SELECT
    sport,
    COUNT(DISTINCT event) AS total_distinct_events,
    MIN(year) AS first_year_contested,
    MAX(year) AS most_recent_year
FROM   athlete_events ae 
GROUP  BY sport
ORDER  BY total_distinct_events DESC
LIMIT 10

--INSIGHTS:
--	Shooting has the highest number of events, showing the diversity of this sport
----------------------------------------------------------------------------------



-------------------------------------------------------------------------
-- Query 5: Sports featured only once in the olympics 
-------------------------------------------------------------------------
with sportDetail as(
	select distinct sport, games
	from athlete_events ae 
),
sportPLayedOnce as (
	select 
	sport,
	COUNT(games) as game_played_once
from sportDetail  
group by sport
having COUNT(*) = 1
)
select sp.sport, sd.games as olympic_games 
from sportPLayedOnce sp
join sportDetail sd on sp.sport = sd.sport
order by sd.games

--INSIGHTS : 
-- The Olympic sports including Cricket, Aeronautics, Rugby etc featured only once in the olympics 
-------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------
--Query 6 : Athletes who participated in the most number of Olympic editions
-------------------------------------------------------------------------------------

select 
	name,
	team as country,
	Count(distinct year) as total_olympics_played
from athlete_events ae 
group by name, team
order by total_olympics_played desc
limit 10

--INSIGHTS: 
--	Ian Millar from Canada has participated in 10 olympics



------------------------------------------------------------------------------------
--Query 7: Gender Participation Trend Over the Years
------------------------------------------------------------------------------------
SELECT 
    year,
    sex,
    COUNT(DISTINCT id) AS total_athletes
FROM athlete_events
GROUP BY year, sex
ORDER BY year, sex;

--INSIGHTS
-- Female participation has started very low but has increased significantly over the years


-- ----------------------------------------------------------------------
-- Query 8: Youngest and Oldest Medal-Winning Athletes
-- ----------------------------------------------------------------------

with ranked_olympian as(
	select 
		*,
		nr.region as country,
		 Rank() Over(order by age) as youngest_rank,
		 Rank() Over(order by age desc) as oldest_rank
	from athlete_events ae 
	join noc_regions nr on nr.noc = ae.noc
	where medal in ('Gold','Silver','Bronze') and age is not NULL
)
select 
	 	name,
	 	country,
		 age,
		 games,
		 year,
		 sport, 
		 event,
		 medal
from ranked_olympian
where youngest_rank = 1 or oldest_rank = 1

--INSIGHTS
--	Dimitrios Loundras from Greece was the youngest medal winning olympian at age 10
--	John Kelly from Great Britain was the oldest medal winning olympian at age 73.



------------------------------------------------------------------------------------
--Query 9: Countries That Have Won Medals in the Most Number of different Sports
------------------------------------------------------------------------------------

WITH sport_count_per_country AS (
    SELECT
        nr.region AS country,
        ae.year,
        ae.season,
        COUNT(DISTINCT ae.sport) AS sport_count,
        COUNT(*) AS total_medals
    FROM athlete_events ae
    JOIN noc_regions nr ON ae.noc = nr.noc
    WHERE ae.medal IS NOT NULL
    GROUP BY nr.region, ae.year, ae.season
),
ranked_countries_by_season AS (
    SELECT *,
           Dense_RANK() OVER(PARTITION BY season ORDER BY sport_count DESC, total_medals DESC) AS sport_rank
    FROM sport_count_per_country
)
SELECT country, year, season, sport_count, total_medals, sport_rank
FROM ranked_countries_by_season
WHERE sport_rank <= 5
ORDER BY season, sport_rank;


------------------------------------------------------------------------------------
--Query 10: Top Athletes with the Most Medals by Sport
------------------------------------------------------------------------------------
with athlete_medal_count as(
	select 
		name, 
		sport,
		team,
		Count(*) as total_medals
	from athlete_events ae 
	where medal in ('Gold', 'Silver', 'Bronze')
	group by name, sport, team
),
ranked_athletes as(
	select 	
		*,
		Rank() over (partition by sport order by total_medals Desc) as sport_rank
	from athlete_medal_count 
)
select 
	name, 
	sport,
	team, 
	total_medals 
from ranked_athletes
where sport_rank = 1
order by total_medals desc
limit 10

--INSIGHTS 
--	Michael Fred Phelps from the United States holds the highest medal count in Swimming



------------------------------------------------------------------------------------
--QUERY 11 : Find the countries that won medals in only one sport 
--			 across all the olympics(Specialization)
------------------------------------------------------------------------------------
with countries_medal_count as (
	select 
		nr.region as country,
		sport,
		Count(*) as medal_count
	from athlete_events ae 
	join noc_regions nr on ae.noc = nr.noc
	where medal in ('Gold','Silver','Bronze')
	group by country, sport
),
country_sport_medal_count as (
	select 
		country,
		COUNT(distinct sport) as sport_count
	from countries_medal_count
	group by country
	having COUNT(distinct sport) = 1
)
SELECT
    c.country,
    cs.sport,
    cs.medal_count
FROM country_sport_medal_count c
JOIN countries_medal_count cs ON c.country = cs.country
ORDER BY cs.medal_count DESC
limit 5



------------------------------------------------------------------------------------
--QUERY 12 : Find the sports where male and female participation is relatively 
--		     balanced over the years.
-----------------------------------------------------------------------------------
with gender_participation as (
	select 
		sport,
		sex,
		COUNT(distinct name) as athlete_count
	from athlete_events ae 
	group by sport, sex
),
pivot_gender_count as (		-- pivot logic in sql means turn rows into columns
	select 
		gp.sport,
		Max(case
			when gp.sex = 'M' then gp.athlete_count else 0 
		end )as male_athletes,
		Max(case
			when gp.sex = 'F' then gp.athlete_count else 0 
		end) as female_athletes
	from gender_participation gp
	group by gp.sport
),
gender_ratio as (
	select 
		pgc.sport,
		pgc.male_athletes,
		female_athletes,
		ROUND(least(male_athletes,female_athletes)* 100.0 / greatest(male_athletes,female_athletes), 2) as gender_percentage
	from pivot_gender_count pgc
	where male_athletes is not null and female_athletes is not null
)
select
	* 
from gender_ratio
order by gender_percentage desc
limit 15

--INSIGHTS
--	Table Tennis is the most gender balanced sport



------------------------------------------------------------------------------------
--QUERY 13 : Countries that have improved the most over the last 3 olympic editions
------------------------------------------------------------------------------------
with recent_years as(
	select 
		distinct year 
	from athlete_events ae 
	where medal in ('Gold', 'Silver', 'Bronze')
	order by ae.year desc
	limit 3
),
medal_count as( 
select 
	team,
	year,
	Count(*) as total_medals
from athlete_events ae
where medal in ('Gold', 'Silver', 'Bronze')
group by team, year
),
filtered_medals as (
	select 
		mc.team,
		mc.year,
		mc.total_medals
	from medal_count as mc
	join recent_years ry on mc.year = ry.year
), 
medal_trend as(
	select 
		mc.team as country,
		MAX(case
			when mc.year = (select MIN(year) from recent_years) then mc.total_medals else 0
		end) as earliest,
		MAX(case
			when mc.year = (select MAX(year) from recent_years) then mc.total_medals else 0
		end) as latest
	from filtered_medals mc
	group by mc.team
),
improvement as(			--Some countries may not have won any medals in one of the years
	SELECT 					
        country,
        coalesce(latest,0) AS medals_in_latest,
        coalesce(earliest,0) AS medals_in_earliest,
        coalesce(latest,0) - coalesce(earliest,0) AS net_improvement
    FROM medal_trend
)
select 
	* 
from improvement
where medals_in_latest > medals_in_earliest
order by net_improvement desc
limit 20

--INSIGHTS
-- Germany showed the greatest improvement in the total medal count in the
-- last 3 olympics editions



------------------------------------------------------------------------------------
--QUERY 14 : Countries with the Highest Medal Efficiency (Medals per Athlete per Game)
------------------------------------------------------------------------------------

with athlete_count as (
	select 
		noc,
		games,
		Count(distinct id) as total_athletes
	from athlete_events ae 
	group by noc, games
),
medal_Count as (
	select
		noc,
		games,
		Count(medal) as medal_count
	from athlete_events ae 
	where medal in ('Gold', 'Silver', 'Bronze')
	group by noc, games
),
efficiency as (
	select
		ac.noc, 
		ac.games,
		nr.region as Country,
		total_athletes ,
		medal_count ,
		ROUND(medal_count :: numeric / total_athletes , 2) as medal_per_athlete
	from athlete_count ac
	join medal_count mc on ac.noc = mc.noc and ac.games = mc.games
	join noc_regions nr on ac.noc = nr.noc
	WHERE ac.total_athletes >= 10 -- filter to meaningful delegations
),
ranked_efficiency as ( 
	select 
		*,
		RANK() Over(order by medal_per_athlete Desc) as rank_by_efficiency
	from efficiency
)
select
	rank_by_efficiency,
	country,
	games,
	total_athletes ,
	medal_count ,
	medal_per_athlete 
from ranked_efficiency
where rank_by_efficiency <= 10



------------------------------------------------------------------------------------
-- QUERY 15 : Find the athletes who won medals in multiple sports(Most versatile athletes)
------------------------------------------------------------------------------------

with athletes_with_medals as (
	select 
		id,
		name, 
		sport,
		Count(distinct medal) as medal_count
	from athlete_events ae 
	where medal in ('Gold', 'Silver', 'Bronze')
	group by id, name, sport
),
athlete_sport_count as (
	select 
		id,
		name,
		Count(distinct sport) as sports_medaled_in 
	from athletes_with_medals awm
	group by id, name
),
versatile_athletes as (
	select 
		id,
		name, 
		sports_medaled_in 
	from athlete_sport_count
	where sports_medaled_in > 1
),
detailed_sports as (
	select
		awm.id,
		awm.name,
		String_AGG(distinct awm.sport, ',') as sports	
	from athletes_with_medals awm
	join versatile_athletes va on awm.id = va.id
	group by awm.id, awm.name
)
select
	va.name,
	ds.sports,
	va.sports_medaled_in
from versatile_athletes va
join detailed_sports ds on va.id = ds.id
order by va.sports_medaled_in Desc
limit 10












