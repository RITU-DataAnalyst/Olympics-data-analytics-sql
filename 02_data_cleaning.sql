-- ======================================================================
-- FILE       : 02_data_cleaning.sql
-- PROJECT    : Olympics Data Analysis Case Study
-- PURPOSE    : Initial data audit, profiling, and validation checks
-- CREATED ON : 19-05-2025
-- ======================================================================

-- ----------------------------------------------------------------------
-- STEP 1 : Total Row Count in Both Tables
-- Desc : To verify that the data was imported successfully.
-- ----------------------------------------------------------------------

select 
	'athlete_events' as table_name,
	Count(*) as total_row_count
from athlete_events ae 
union ALL
select 
	'noc_regions',
	Count(*) 
from noc_regions nr 


-- ----------------------------------------------------------------------
-- STEP 2 : DISTINCT Count of Athletes, Events and countries, sports, year
-- Desc : This query will calculate the number of unique athletes, 
--        countries, sporting events, sports, and olympic years represented
--        in the dataset.
--        This helps understand the dataset's diversity.
-- ----------------------------------------------------------------------

select 
	 Count(distinct name) as athletes_count,
	 Count(distinct team) as countries_count,
	 Count(distinct event) as event_count,
	 Count(distinct sport) as total_sports,
	 Count(distinct year) as olympic_year_count
from athlete_events ae 


-- ----------------------------------------------------------------------
-- STEP 3 : NULL counts in key columns
-- Desc   : This query will count the NULL value in age, height and 
--          weight columns that helps to identify the data quality issues. 
-- ----------------------------------------------------------------------

select 
	SUM(case 
		when age is null then 1 else 0
	end) as null_age,
	SUM(case 
		when height is null then 1 else 0
	end) as null_height,
	SUM(case 
		when weight is null then 1 else 0
	end) as null_weight
from athlete_events ae 


-- ----------------------------------------------------------------------
-- STEP 4 : Duplicate records for the same player,event,medal
-- Desc   : This query will check-is there any player who appear in 
--          the same event in the same year twice(rarest of the rare)
-- ----------------------------------------------------------------------

WITH ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY id, name, sex, age, height, weight, team,
                        noc, games, year, season, city, sport, event, medal
           ORDER BY id
         ) AS rn
  FROM athlete_events
)
SELECT *
FROM ranked
where rn > 1


-- ----------------------------------------------------------------------
-- STEP 5 : Check Gender Trend
-- Desc   : Check How many male or female athletes participated in Olympics each year       
-- ----------------------------------------------------------------------

select
	year,
	SUM(case 
			when sex = 'M' then 1 else 0
	end
	) as total_male,
	SUM(case 
			when sex = 'F' then 1 else 0
	end
	) as total_female
from athlete_events ae 
group by year
order by year


-- ----------------------------------------------------------------------
-- STEP 5 : Age,Height and weight Distribution Statistics
-- Desc   : Calculate the minimum, maximum, and average age, weight and height 
--          of athletes to identify any out of range or weird values.
-- ----------------------------------------------------------------------

select
	MIN(age) as min_age,
	MAX(age) as max_age,
	ROUND(AVG(age) :: numeric,0) as avg_age,
	MIN(height) as min_height,
	MAX(height) as max_height,
	ROUND(AVG(height) :: numeric,0) as avg_height,
	MIN(weight) as min_weight,
	MAX(weight) as max_weight,
	ROUND(AVG(weight) :: numeric,0) as avg_weight
from athlete_events ae 
where age is not null and height is not null and weight is not null 


-- ----------------------------------------------------------------------
-- STEP 6 : Check all noc codes
-- Desc   : Country Codes in athlete_events table that don’t exist 
--          in noc_regions table (should be 0)
-- ----------------------------------------------------------------------

select ae.noc, Count(*) as missing_code
from athlete_events ae  
join noc_regions nr on ae.noc = nr.noc
where nr.noc is null
group by ae.noc
order by missing_code 

















