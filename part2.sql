use md_water_services;

select
replace (employee_name,' ' , '.') -- replace the space with the full stop
from
employee;

SELECT
LOWER(REPLACE(employee_name, ' ','.')) -- make it all lowercase
FROM
employee;

SELECT
CONCAT(
LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email  -- add it all together
FROM
employee;

UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),

'@ndogowater.gov');


select
LENGTH(phone_number)
FROM
employee;

select
phone_number,
length(phone_number) as original_lenght,
length(trim(phone_number)) as trim_length from employee;

update
employee
set phone_number =trim(phone_number);

select
town_name
from employee;

select
town_name,
count(*) as employee_count
from
employee
group by
town_name
order by
employee_count desc;

select assigned_employee_id,visit_count
from visits
order by visit_count desc
limit 3;

select*
From employee
where assigned_employee_id in (30,10,46);

-- create a query that counts number of records per town
select
town_name,
  count(*)as record_per_town
  from
  location
  group by town_name
  order by record_per_town desc;
  
  select
  province_name,
  count(*) as record_per_province
  from location
  group by province_name
  order by province_name desc;
  
  -- create a result showing:province_name,town_name,an aggregated count of records for each town (consider naming this records_per_town)
  -- ensure your data is grouped by both province_name and town_name.
  -- order your results primarilly byprovince_name;
  select
  province_name,
  town_name,
  count(*) as records_per_town
  from
   location
group by province_name, town_name
order by
province_name asc,
records_per_town desc;
-- count number of records per locaction type
select
count(*) as num_sources,
location_type
from
  location
group by
  location_type
order by
  num_sources desc;
  
  select 23740 / (15910+ 23740) *100; -- present in percentage
  
  -- how many people did we survey in total?
  select sum(number_of_people_served) as total_people_surveyed
  from water_source;
  -- how many wells; taps and rivers are there?
  -- countthe distinct types of water sources and thier occurrences
  select type_of_water_source,
  count(*) as count
  from water_source
  group by type_of_water_source;
  -- how many people share particular types of water sources on avarage?
  select type_of_water_source,
  avg(number_of_people_served)
  as average_people_per_source
  from water_source
  group by type_of_water_source;
  
  -- how many people are getting water from eachtype of water source?
  select type_of_water_source,
  sum(number_of_people_served)
  as total_people_per_source_type
  from water_source
  group by type_of_water_source;
  
  -- to calculate the total number of people served by each type of water source 
  select
  type_of_water_source,
  sum(number_of_people_served) as total_people_served
  from
   water_source
group by
  type_of_water_source
order by
  total_people_served desc;
  -- converting topercentages
  select
type_of_water_source,
(sum(number_of_people_served) / 27000000) * 100 as percentage_of_total_citizens
from
water_source
group by
type_of_water_source
order by
percentage_of_total_citizens desc;

-- round off to zero desimals
select
type_of_water_source,
sum(number_of_people_served) as total_people_served_by_source,
round((sum(number_of_people_served) / 27000000) *100,0) as percentage_of_total_citizens
from
water_source
group by
type_of_water_source
order by
(sum(number_of_people_served) / 27000000) * 100 desc;

 -- Task 5: Start of a solution
-- Step 1:rank type of water source and population served 
SELECT type_of_water_source,SUM(number_of_people_served) AS people_served,
RANK () OVER(ORDER BY  SUM(number_of_people_served) DESC) AS rank_by_population
FROM md_water_services.water_source
GROUP BY type_of_water_source;

 -- Task 5: Start of a solution
-- Step 1:rank type of water source and population served 
SELECT type_of_water_source,SUM(number_of_people_served) AS people_served,
RANK () OVER(ORDER BY  SUM(number_of_people_served) DESC) AS rank_by_population
FROM md_water_services.water_source
GROUP BY type_of_water_source;select
source_id, type_of_water_source,
number_of_people_served,
RANK() over (
partition by type_of_water_source
order by number_of_people_served desc
) AS priority_rank
from
water_source
order by
priority_rank;




-- Step 2:rank  with source id, sources, number of people, and rank 
SELECT source_id, type_of_water_source, number_of_people_served, 
RANK () OVER(PARTITION BY type_of_water_source ORDER BY number_of_people_served) AS priority_rank
FROM 	water_source
WHERE type_of_water_source <> 'tap_in_home'
    AND type_of_water_source <> 'tap_in_home_broken'
    AND type_of_water_source <> 'well';  
    
select
source_id, type_of_water_source,
population_served,
dense_rank() over (order by population_served desc) 
from
water_source;

-- Step 2:  how long people have to queue on average ?
SELECT AVG(NULLIF(time_in_queue,0)) AS average_queue_time
from visits;
-- Step3: queue times aggregated across the different days of the week ?
SELECT dayname(time_of_record) AS day_of_week, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY day_of_week; 

-- Step 4  what time during the day people collect water,  order the results ?
SELECT hour(time_of_record) AS hour_of_day, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- Step 6:  to get hours more readable
SELECT TIME_FORMAT(time(time_of_record), '%H:00') AS hour_of_day, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- Step 6: to see if we only see specific day like sunday
SELECT TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record), 
CASE 
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
    END AS Sunday
FROM
    visits
WHERE
    time_in_queue != 0;

-- Step 7: specific to certain days and averaging it (we can then create a pivot table to compare results and see the times for each day by the hour)
SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Sunday,

-- Monday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Monday,

-- Tuesday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Tuesday,

-- Wednesday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Wednesday,

-- Thursday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Thursday,

-- Friday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Friday,

-- Saturday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Saturday
FROM
    visits
WHERE
    time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
    hour_of_day
ORDER BY
    hour_of_day asc;

/*We can then see the pattern, 
1. Queues are very long on a Monday morning and Monday evenings
2. Wednesday has the lowest queue times, but long queues on Wednesday evening.
3. People have to queue twice as long on Saturdays compared to the weekdays. 
4. The shortest queues are on Sundays, and this is a cultural thing. Or prioriting religion as most of the country is Christian*/-- Step 2:  how long people have to queue on average ?
SELECT AVG(NULLIF(time_in_queue,0)) AS average_queue_time
from visits;
-- Step3: queue times aggregated across the different days of the week ?
SELECT dayname(time_of_record) AS day_of_week, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY day_of_week; 

-- Step 4  what time during the day people collect water,  order the results ?
SELECT hour(time_of_record) AS hour_of_day, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- Step 6:  to get hours more readable
SELECT TIME_FORMAT(time(time_of_record), '%H:00') AS hour_of_day, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- Step 6: to see if we only see specific day like sunday
SELECT TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record), 
CASE 
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
    END AS Sunday
FROM
    visits
WHERE
    time_in_queue != 0;

-- Step 7: specific to certain days and averaging it (we can then create a pivot table to compare results and see the times for each day by the hour)
SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Sunday,

-- Monday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Monday,

-- Tuesday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Tuesday,

-- Wednesday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Wednesday,

-- Thursday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Thursday,

-- Friday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Friday,

-- Saturday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Saturday
FROM
    visits
WHERE
    time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
    hour_of_day
ORDER BY
    hour_of_day asc;

/*We can then see the pattern, 
1. Queues are very long on a Monday morning and Monday evenings
2. Wednesday has the lowest queue times, but long queues on Wednesday evening.
3. People have to queue twice as long on Saturdays compared to the weekdays. 
4. The shortest queues are on Sundays, and this is a cultural thing. Or prioriting religion as most of the country is Christian*/-- Step 2:  how long people have to queue on average ?
SELECT AVG(NULLIF(time_in_queue,0)) AS average_queue_time
from visits;
-- Step3: queue times aggregated across the different days of the week ?
SELECT dayname(time_of_record) AS day_of_week, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY day_of_week; 

-- Step 4  what time during the day people collect water,  order the results ?
SELECT hour(time_of_record) AS hour_of_day, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- Step 6:  to get hours more readable
SELECT TIME_FORMAT(time(time_of_record), '%H:00') AS hour_of_day, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- Step 6: to see if we only see specific day like sunday
SELECT TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record), 
CASE 
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
    END AS Sunday
FROM
    visits
WHERE
    time_in_queue != 0;

-- Step 7: specific to certain days and averaging it (we can then create a pivot table to compare results and see the times for each day by the hour)
SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Sunday,

-- Monday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Monday,

-- Tuesday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Tuesday,

-- Wednesday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Wednesday,

-- Thursday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Thursday,

-- Friday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Friday,

-- Saturday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Saturday
FROM
    visits
WHERE
    time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
    hour_of_day
ORDER BY
    hour_of_day asc;

/*We can then see the pattern, 
1. Queues are very long on a Monday morning and Monday evenings
2. Wednesday has the lowest queue times, but long queues on Wednesday evening.
3. People have to queue twice as long on Saturdays compared to the weekdays. 
4. The shortest queues are on Sundays, and this is a cultural thing. Or prioriting religion as most of the country is Christian*/-- Step 2:  how long people have to queue on average ?
SELECT AVG(NULLIF(time_in_queue,0)) AS average_queue_time
from visits;
-- Step3: queue times aggregated across the different days of the week ?
SELECT dayname(time_of_record) AS day_of_week, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY day_of_week; 

-- Step 4  what time during the day people collect water,  order the results ?
SELECT hour(time_of_record) AS hour_of_day, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- Step 6:  to get hours more readable
SELECT TIME_FORMAT(time(time_of_record), '%H:00') AS hour_of_day, ROUND(AVG(time_in_queue)) AS avg_queue_time
from visits
GROUP BY hour_of_day
ORDER BY hour_of_day ASC;

-- Step 6: to see if we only see specific day like sunday
SELECT TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record), 
CASE 
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
    END AS Sunday
FROM
    visits
WHERE
    time_in_queue != 0;

-- Step 7: specific to certain days and averaging it (we can then create a pivot table to compare results and see the times for each day by the hour)
SELECT
    TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Sunday,

-- Monday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Monday,

-- Tuesday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Tuesday,

-- Wednesday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Wednesday,

-- Thursday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Thursday,

-- Friday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Friday,

-- Saturday
    ROUND(AVG(
    CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
    ELSE NULL
    END),0) 
    AS Saturday
FROM
    visits
WHERE
    time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
    hour_of_day
ORDER BY
    hour_of_day asc;

/*We can then see the pattern, 
1. Queues are very long on a Monday morning and Monday evenings
2. Wednesday has the lowest queue times, but long queues on Wednesday evening.
3. People have to queue twice as long on Saturdays compared to the weekdays. 
4. The shortest queues are on Sundays, and this is a cultural thing. Or prioriting religion as most of the country is Christian*/

    
	


 
  






