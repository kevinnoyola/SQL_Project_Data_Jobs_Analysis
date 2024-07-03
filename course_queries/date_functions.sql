-- extract month form date and convert to standard timezone then to EST and also you can see how many job postings occur in each month
SELECT
    EXTRACT (MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS month,
    count(*) AS postings_count
    
FROM job_postings_fact
GROUP BY    
    month
ORDER BY    
    month
LIMIT 100;

--Find companies (include company name) that have posted jobs offering health insurance, where these postings were made in the second quarter of 2023. Use date extraction to filter by quarter. And order by the job postings count from highest to lowest.

SELECT 
    company_dim.name,
    COUNT (job_postings_fact.job_id) AS postings_count
FROM job_postings_fact
INNER JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE   
    job_postings_fact.job_health_insurance = TRUE
    AND EXTRACT (QUARTER FROM job_postings_fact.job_posted_date) = 2
GROUP BY
    company_dim.name
HAVING  
    COUNT (job_postings_fact.job_id) > 0
ORDER BY    
    postings_count DESC;




