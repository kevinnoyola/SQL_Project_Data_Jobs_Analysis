--Identify companies with the most diverse (unique) job titles. Use a CTE to count the number of unique job titles per company, then select companies with the highest diversity in job titles.


-- Define a CTE named title_diversity to calculate unique job titles per company
WITH title_diversity AS (
    SELECT
        company_id,
        COUNT(DISTINCT job_title) AS unique_titles
    FROM job_postings_fact
    GROUP BY company_id
)

-- Get company name and count of how many unique titles each company has
SELECT
    company_dim.name,
    title_diversity.unique_titles
FROM title_diversity
    INNER JOIN company_dim ON title_diversity.company_id = company_dim.company_id
ORDER BY
    unique_titles DESC
LIMIT 10;

--compare individual salaries with national averages
--Create Common Table Expression (CTE) named avg_salaries
--Calculate the average yearly salary (AVG(salary_year_avg)) for each country (job_country)
--From the job_postings_fact table,
--Grouping the results by job_country.
--In the main query:
--Select:
--the job_id, job_title, and company name (companies.name) to get the basic job posting information.
--Retrieve the salary (salary_year_avg) for each job posting and label it as salary_rate.
--Categorize each salary as 'Above Average' or 'Below Average' by comparing the individual salary rate to the average salary of the corresponding country obtained from the avg_salaries CTE (job_postings.salary_year_avg > avg_salaries.avg_salary)
--Extract the month from the job posting date (job_posted_date) to include in your results as posting_month.
--INNER JOIN the job_postings_fact table with the company_dim table to link each job posting with the respective company name.
--INNER JOIN the avg_salaries CTE to bring in the average salary data for comparison.
--Order the results by the posting_month in descending order to sort the job postings starting with the most recent.
--gets average job salary for each country
WITH avg_salaries AS (
    SELECT
        job_country,
        AVG(salary_year_avg) AS avg_salary
    FROM job_postings_fact
    GROUP BY job_country
)

SELECT
    job_postings.job_id,
    job_postings.job_title,
    job_postings.salary_year_avg AS salary_rate,
-- categorize salary as above or below country salary
    CASE
        WHEN job_postings.salary_year_avg > avg_salaries.avg_salary
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS salary_category,

    --get month and year of date
    EXTRACT (MONTH FROM job_postings.job_posted_date) AS posting_month
FROM
    job_postings_fact as job_postings
INNER JOIN 
    company_dim as companies ON job_postings.company_id = companies.company_id
INNER JOIN
    avg_salaries ON job_postings.job_country = avg_salaries.job_country
ORDER BY
    posting_month DESC
LIMIT 1000;


--Calculate the number of unique skills required by each company.
--Use two CTEs. The first should focus on counting the unique skills required by each company. The second CTE should aim to find the highest average salary offered by these companies.

-- Counts the distinct skills required for each company's job posting
WITH required_skills AS (
    SELECT
    companies.company_id,
    COUNT (DISTINCT skills_to_job.skill_id) AS unique_skills_required
    FROM
        company_dim AS companies
    LEFT JOIN job_postings_fact AS job_postings ON companies.company_id = job_postings.company_id
    LEFT JOIN skills_job_dim AS skills_to_job ON job_postings.job_id = skills_to_job.job_id
    GROUP BY
        companies.company_id
),

-- Gets the highest average yearly salary from the jobs that require at least one skills 
max_salary AS (
    SELECT 
        job_postings.company_id,
        MAX (job_postings.salary_year_avg) AS highest_average_salary
    FROM
        job_postings_fact AS job_postings
    WHERE
        job_postings.job_id IN (SELECT job_id FROM skills_job_dim)
    GROUP BY
        job_postings.company_id
)

-- Joins 2 CTEs with table to get query
SELECT
    companies.name,
    required_skills.unique_skills_required AS unique_skills_required,
    max_salary.highest_average_salary 
FROM
    company_dim AS companies
LEFT JOIN required_skills ON companies.company_id = required_skills.company_id
LEFT JOIN max_salary ON companies.company_id = max_salary.company_id
WHERE 
    max_salary.highest_average_salary IS NOT NULL
ORDER BY
    highest_average_salary DESC
LIMIT 100;
