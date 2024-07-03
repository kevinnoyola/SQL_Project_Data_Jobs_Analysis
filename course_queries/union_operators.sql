--Create a unified query that categorizes job postings into two groups: those with salary information (salary_year_avg or salary_hour_avg is not null) and those without it. 

-- Select job postings with salary information
(
    SELECT
        job_id,
        job_title,
        'With Salary Info' AS salary_info --custom field indicating salary info presence
    FROM
        job_postings_fact
    WHERE
        salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL
)
UNION ALL
-- select job postings without salary info
(
    SELECT
        job_id,
        job_title,
        'Without Salary Info' AS salary_info
    FROM 
        job_postings_fact
    WHERE
        salary_year_avg IS NULL AND salary_hour_avg IS null
)
ORDER BY
    salary_info DESC, 
    job_id;


--Retrieve the job id, job title short, job location, job via, skill and skill type for each job posting from the first quarter (January to March).
--Only include postings with an average yearly salary greater than $70,000.

--create tables for each month
CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH from job_posted_date) = 1;
CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH from job_posted_date) = 2;
CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT (MONTH from job_posted_date) = 3;


--now you can run below query
SELECT
    job_postings_q1.job_id,
    job_postings_q1.job_title_short,
    job_postings_q1.job_location,
    job_postings_q1.job_via,
    job_postings_q1.salary_year_avg,
    skills_dim.skills,
    skills_dim.type
FROM
-- get job postings from first quarter
(
    SELECT * 
    FROM january_jobs
    UNION ALL
    SELECT * 
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) AS job_postings_q1
LEFT JOIN skills_job_dim ON job_postings_q1.job_id = skills_job_dim.job_id
LEFT JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_postings_q1.salary_year_avg > 70000
ORDER BY
    job_postings_q1.job_id;



--Analyze the monthly demand for skills by counting the number of job postings for each skill in the first quarter (January to March)

--CTE for combining job postings from Q1
WITH combined_job_postings AS (
    SELECT 
        job_id, 
        job_posted_date
    FROM january_jobs
    UNION ALL 
    SELECT 
        job_id, 
        job_posted_date
    FROM february_jobs
    UNION ALL
    SELECT 
        job_id, 
        job_posted_date
    FROM march_jobs
),

-- CTE for calculating monthly skill demand based on combined postings
monthly_skill_demand AS (
    SELECT
        skills_dim.skills,
        EXTRACT (YEAR FROM combined_job_postings.job_posted_date) AS year,
        EXTRACT (MONTH FROM combined_job_postings.job_posted_date) AS month,
        COUNT(combined_job_postings.job_id) AS postings_count
    FROM
        combined_job_postings
            INNER JOIN skills_job_dim ON combined_job_postings.job_id = skills_job_dim.job_id
            INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    GROUP BY
        skills_dim.skills, year, month
)

-- main query to display demand for each skill during Q1

SELECT
    skills,
    year,
    month,
    postings_count
FROM 
    monthly_skill_demand
ORDER BY
    skills, year, month;