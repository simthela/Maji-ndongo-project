use md_water_services;

-- start by joining location to visits
select
location.province_name,
location.town_name,
visits.visit_count,
location.location_id
from location
join visits
on location.location_id =visits.location_id;

-- how can we join the water_source table on the key shared between water_source and visits
select
location.province_name,
location.town_name,
visits.visit_count,
location.location_id,
water_source.number_of_people_served
from location
join visits
on location.location_id = visits.location_id
join water_source
on visits.source_id = water_source.source_id;



SELECT
	location.province_name,
    location.town_name,
    visits.visit_count,
    water_source.type_of_water_source,
    location.location_id,
    water_source.number_of_people_served
FROM location
JOIN visits
ON location.location_id = visits.location_id
JOIN water_source
ON visits.source_id = water_source.source_id
WHERE visits.location_id = 'AkHa00103';


/* For one location, there are multiple AkHa00103 records for the same location.
If we aggregate, we will include
these rows, so our results will be incorrect. To fix this, we can just select rows where visits.visit_count = 1.*/
SELECT
	location.province_name,
    location.town_name,
    visits.visit_count,
    water_source.type_of_water_source,
    location.location_id,
    water_source.number_of_people_served
FROM location
JOIN visits
ON location.location_id = visits.location_id
JOIN water_source
ON visits.source_id = water_source.source_id
WHERE visits.visit_count = 1;

-- Add the location_type column from location and time_in_queue from visits to our results set
SELECT
	location.province_name,
    location.town_name,
    location.location_type,
    visits.time_in_queue,
    visits.visit_count,
    water_source.type_of_water_source,
    location.location_id,
    water_source.number_of_people_served
FROM location
JOIN visits
ON location.location_id = visits.location_id
JOIN water_source
ON visits.source_id = water_source.source_id
WHERE visits.visit_count = 1;

-- This table assembles data from different tables into one to simplify analysis
SELECT
water_source.type_of_water_source,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;

-- Create a view for the combined_analysis Table
CREATE VIEW combined_analysis_table AS
-- This view assembles data from different tables into one to simplify analysis
SELECT
water_source.type_of_water_source AS source_type,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served AS people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;


-- The last analysis
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN
province_totals pt ON ct.province_name = pt.province_name
GROUP BY
ct.province_name
ORDER BY
ct.province_name;

WITH town_totals AS (         -- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN  -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

-- Create a temporary table to store the data from the query
DROP TEMPORARY TABLE town_aggregated_water_access;
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS
(-- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
total_ppl_serv,
ROUND((SUM(CASE WHEN source_type = 'river'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
ROUND((SUM(CASE WHEN source_type = 'shared_tap'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
ROUND((SUM(CASE WHEN source_type = 'well'
THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
ct.province_name,
ct.town_name
ORDER BY
ct.town_name;

SELECT * 
FROM town_aggregated_water_access
WHERE town_name != 'Rural'
ORDER BY shared_tap DESC;

SELECT * 
FROM town_aggregated_water_access
ORDER BY province_name, tap_in_home, tap_in_home_broken DESC;

SELECT * 
FROM combined_analysis_table
WHERE source_type='well';


SELECT location.province_name, (sum(water_source.number_of_people_served)*100 / 27628140)
FROM visits
JOIN location
ON visits.location_id = location.location_id
JOIN water_source
ON water_source.source_id = visits.source_id
WHERE type_of_water_source IN ('tap_in_home', 'tap_in_home_broken')
GROUP BY province_name;


SELECT province_name, sum(people_served), (sum(people_served)*100 /27628140) as pct
FROM combined_analysis_table
WHERE source_type IN ('tap_in_home', 'tap_in_home_broken')
GROUP BY province_name;

SELECT sum(number_of_people_served) 
FROM water_source;


SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) *
100,0) AS Pct_broken_taps
FROM
town_aggregated_water_access
ORDER BY Pct_broken_taps DESC;


/* A Practical Plan */

CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
/* Project_id −− Unique key for sources in case we visit the same
source more than once in the future.
*/
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
/* source_id −− Each of the sources we want to improve should exist,
and should refer to the source table. This ensures data integrity.
*/
Address VARCHAR(50), -- Street address
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50), -- What the engineers should do at that place
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
/* Source_status −− We want to limit the type of information engineers can give us, so we
limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
*/
Date_of_completion DATE, -- Engineers will add this the day the source has been upgraded
Comments TEXT -- Engineers can leave comments. We use a TEXT type that has no limit on char length
);


-- Project_progress_query
SELECT
location.address,
location.town_name,
location.province_name,
water_source.type_of_water_source,
well_pollution.results,
(CASE 
	WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install R0 filter'
    WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
    WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
    WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN CONCAT("Install ", FLOOR(visits.time_in_queue/30), " taps nearby")
    WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
    ELSE NULL
    END
) AS improvements
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND ( -- AND one of the following (OR) options must be true as well.
well_pollution.results != 'Clean'
OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
)
limit 100000;

SELECT * 
FROM project_progress;

INSERT INTO project_progress (source_id, address, town, province, source_type, improvement)
SELECT
visits.source_id,
location.address,
location.town_name,
location.province_name,
water_source.type_of_water_source,
(CASE 
	WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install R0 filter'
    WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
    WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
    WHEN water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 THEN CONCAT("Install ", FLOOR(visits.time_in_queue/30), " taps nearby")
    WHEN water_source.type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
    ELSE NULL
    END
) AS improvements
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1 -- This must always be true
AND ( -- AND one of the following (OR) options must be true as well.
well_pollution.results != 'Clean'
OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
OR (water_source.type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
)
LIMIT 100000;

SELECT *
FROM project_progress
LIMIT 100;


                                



