--categorize the salaries from job postings that are data analyst jobs and who have a yearly salary information. Put salary into 3 different categories if the salary_year_avg is greater than $100,000 then return ‘high salary’.if the salary_year_avg is between $60,000 and $99,999 return ‘Standard salary’. if the salary_year_avg is below $60,000 return ‘Low salary’. Also order from the highest to lowest salaries.

SELECT 
    job_id, 
    job_title,
    salary_year_avg,
    -- categorize with conditions and create new column
    CASE 
        WHEN salary_year_avg > 100000 THEN 'High salary'
        WHEN salary_year_avg BETWEEN 60000 AND 99999 THEN 'Standard salary'
        WHEN salary_year_avg < 60000 THEN 'Low salary'        
    END AS salary_category
FROM job_postings_fact
WHERE   
    salary_year_avg IS NOT NULL
    AND job_title_short = 'Data Analyst'
ORDER BY
    salary_year_avg DESC
LIMIT 10000;

--Count the number of unique companies that offer work from home (WFH) versus those requiring work to be on-site.
SELECT
    COUNT(DISTINCT CASE WHEN job_work_from_home = TRUE THEN company_id END) AS wfh_companies,
    COUNT(DISTINCT CASE WHEN job_work_from_home = FALSE THEN company_id END) AS non_wfh_companies
FROM job_postings_fact
LIMIT 1000;



-- Write a query that lists all job postings with their job_id, salary_year_avg, and two additional columns using CASE WHEN statements called: experience_level and remote_option. Use the job_postings_fact table. 
--For experience_level, categorize jobs based on keywords found in their titles (job_title) as 'Senior', 'Lead/Manager', 'Junior/Entry', or 'Not Specified'.  
--For remote_option, specify whether a job offers a remote option as either 'Yes' or 'No', based on job_work_from_home column.
-- ILIKE is not case sensitive

SELECT
    job_id,
    salary_year_avg,
    CASE
        WHEN job_title ILIKE '%Senior%' THEN 'Senior'
        WHEN job_title ILIKE '%Manager%' OR job_title ILIKE '%Lead%' THEN 'Lead/Manager'
        WHEN job_title ILIKE '%Junior%' OR job_title ILIKE '%Entry%' THEN 'Junior/Entry'
        ELSE 'Not Specified'
    END AS experience_level,
    CASE
        WHEN job_work_from_home = TRUE THEN 'Yes'
        ELSE 'No'
    END AS remote_option
FROM job_postings_fact
WHERE   
    salary_year_avg IS NOT NULL
ORDER BY
    job_id
LIMIT 1000;

