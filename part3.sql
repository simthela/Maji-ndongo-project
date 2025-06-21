select*
from
auditor_report;
select location_id, true_water_source_score
from
auditor_report;
-- we join the visits table to the auditor_report table.make sure to grap subjective_quality_score, record_id and location_id.
select
auditor_report.location_id as audit_location,
auditor_report.true_water_source_score,
visits.location_id as visit_location,
visits.record_id
from auditor_report
join
visits on auditor_report.location_id =visits.location_id;

/*our next step is to retrieve the corresponding scores from the water_quality_table.we are particulary interested in the subjective_quality_score,
to do this,we'll join the visits table and the water_quality table using the record_id as conneting key*/
select
auditor_report.location_id as audit_location,
auditor_report.true_water_source_score,
visits.location_id as visit_location,
visits.record_id,
water_quality.subjective_quality_score
from
auditor_report
join
visits
on auditor_report.location_id = visits.location_id
join
water_quality
on visits.record_id = water_quality.record_id;

/*- since it is a duplicate,we can drop one of
the location_id columns.let's leave leave record_id and rename the score to surveyor_score and auditor_score to make it clear score
we're looking at in the results set.*/
select
auditor_report.location_id as audit_location,
visits.record_id,
water_quality.subjective_quality_score as surveyor_score,
auditor_report.true_water_source_score as auditor_score
from
auditor_report
join
visits
on auditor_report.location_id = visits.location_id
join
water_quality
on visits.record_id =water_quality.record_id;

/*since were joining 1620 rows of data,we want to keep track of number of rows we get each time we run a query.
we can force sql to give us all of the results, using
LIMIT 10000*/
select
auditor_report.location_id as audit_location,
visits.record_id,
water_quality.subjective_quality_score,
auditor_report.true_water_source_score as auditor_score
from
auditor_report
join
visits
on auditor_report.location_id = visits.location_id
join
water_quality
on visits.record_id = water_quality.record_id
where
visits.visit_count =1
limit 10000;

select
auditor_report.location_id as audit_location,
auditor_report.type_of_water_source as auditor_source,
water_source.type_of_water_source as survey_source
from
auditor_report
join
visits
on auditor_report.location_id = visits.location_id
join
water_quality
on visits.record_id = water_quality.record_id
join
water_source
on water_quality.record_id = water_source.source_id
where
visits.visit_count = 1
limit 10000;

-- Linking water source to employees

CREATE VIEW incorrect_records AS
WITH
	Incorrect_records AS (
						SELECT
								auditor_report.location_id AS location,
								visits.record_id,
								employee.employee_name AS employee_name,
								auditor_report.true_water_source_score AS Audit_score,
								water_quality.subjective_quality_score AS Empoloyee_score,
								auditor_report.statements AS Statement
FROM
auditor_report
JOIN
visits 
ON auditor_report.location_id = visits.location_id
JOIN
water_quality
ON visits.record_id = water_quality.record_id
JOIN 
employee
ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE water_quality.subjective_quality_score != auditor_report.true_water_source_score AND visits.visit_count
= 1 /* AND auditor_report.statements LIKE '%%cash%%' */ -- Where auditor reported the word 'cash' om the statement of the residents--
LIMIT 10000
)
SELECT
 *
 FROM
 Incorrect_records;
 
 /* Number of times an employee made mistakes */
CREATE VIEW error_count AS
SELECT 
employee_name,
COUNT(employee_name) AS number_of_mistakes
FROM
incorrect_records
GROUP BY
employee_name;

/* Average number of mistakes committed by employees*/
CREATE VIEW avg_error_count_per_empl AS
SELECT
AVG(number_of_mistakes) 
FROM
error_count;

/* Finding employees who made more mistakes than average*/
CREATE VIEW suspect_list AS
WITH suspect_list AS (
SELECT
employee_name,
number_of_mistakes
FROM
error_count
WHERE
number_of_mistakes > (SELECT
                            AVG(number_of_mistakes) 
							FROM
							error_count))
SELECT * FROM suspect_list;
 
 /* Paying close attention to the suspected employees */
 SELECT
 employee_name,
 location,
Statement
 FROM
 incorrect_records
 WHERE employee_name IN (SELECT 
								employee_name
								FROM
								suspect_list);
                                





