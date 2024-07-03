CREATE TABLE data_science_jobs (
    job_id INT PRIMARY KEY,
    job_title TEXT,
    company_name TEXT,
    post_date DATE
);
-- insert data
INSERT INTO data_science_jobs (job_id, job_title, company_name, post_date)
VALUES 
(1,'Data Scientist','Tech Innovations','January 1, 2023'),
(2,'Machine Learning Engineer','Data Driven Co','January 15, 2023'),
(3, 'AI Specialist','Future Tech','February 1, 2023')

ALTER TABLE data_science_jobs
ADD COLUMN remote BOOLEAN

SELECT *
FROM data_science_jobs
-- rename column
ALTER TABLE data_science_jobs
RENAME COLUMN post_date TO posted_on
-- set default to column
ALTER TABLE data_science_jobs
ALTER COLUMN remote SET DEFAULT FALSE;
-- delete coliumn
ALTER TABLE data_science_jobs
DROP COLUMN company_name
-- set specific row to true
ALTER TABLE data_science_jobs

UPDATE data_science_jobs
SET remote = TRUE
WHERE job_id = 2;
--verify
SELECT *
FROM data_science_jobs
-- delete table
DROP TABLE data_science_jobs;


