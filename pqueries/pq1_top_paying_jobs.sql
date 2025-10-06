/*TOP PAYING JOBS -----------------------*/
-- What are the top-paying data analyst jobs?
-- top 10 remote roles
-- Only for specified salary (remove nulls)
SELECT *
FROM job_postings_fact
LIMIT 10;
/*----------------------------------------*/
SELECT job_id,
    job_title_short,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date::DATE
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
    AND job_location = 'Anywhere'
    AND salary_year_avg IS NOT NULL
LIMIT 10;
SELECT job_id,
    job_title_short,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date::DATE
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
    AND job_location = 'Anywhere'
    AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
/*----------------------------------------*/
-- Adding company name
SELECT job_id,
    job_title_short,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date::DATE AS posted_date,
    name AS company
FROM job_postings_fact
    LEFT JOIN company_dim USING (company_id)
WHERE job_title_short = 'Data Analyst'
    AND job_location = 'Anywhere'
    AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
/*----------------------------------------*/
-- Job search from Mali: what skills are required?
SELECT DISTINCT(job_location)
FROM job_postings_fact
ORDER BY job_location;
SELECT DISTINCT(search_location)
FROM job_postings_fact
ORDER BY search_location;
SELECT *
FROM job_postings_fact
WHERE job_location LIKE '%Mali';
SELECT *
FROM job_postings_fact
WHERE search_location = 'Mali';
/*----------------------------------------*/
SELECT *
FROM skills_dim
LIMIT 10;
SELECT *
FROM skills_job_dim
LIMIT 10;
SELECT job_title_short,
    job_location,
    job_posted_date::DATE AS posted_date,
    skills,
    type
FROM job_postings_fact
    LEFT JOIN skills_job_dim USING (job_id)
    LEFT JOIN skills_dim USING (skill_id)
WHERE search_location = 'Mali';
/*----------------------------------------*/
-- Skills details (Mali): subquery
SELECT skills,
    count(*) AS total
FROM (
        SELECT job_title_short,
            job_location,
            job_posted_date::DATE AS posted_date,
            skills,
            type
        FROM job_postings_fact
            LEFT JOIN skills_job_dim USING (job_id)
            LEFT JOIN skills_dim USING (skill_id)
        WHERE search_location = 'Mali'
    ) AS mali_skills
GROUP BY skills
ORDER BY total DESC;
-- Skills details (Mali): CTE
WITH mali_skills_cte AS (
    SELECT job_title_short,
        job_location,
        job_posted_date::DATE AS posted_date,
        skills,
        type
    FROM job_postings_fact
        LEFT JOIN skills_job_dim USING (job_id)
        LEFT JOIN skills_dim USING (skill_id)
    WHERE search_location = 'Mali'
)
SELECT skills,
    count(*) AS total
FROM mali_skills_cte
GROUP BY skills
ORDER BY total DESC;
/*
 
 
 
 
 /*TOP PAYING JOBS SKILLS -----------------------*/
WITH top_paying_jobs_cte AS (
    SELECT job_id,
        job_title_short,
        salary_year_avg,
        job_posted_date::DATE AS posted_date,
        name AS company
    FROM job_postings_fact
        LEFT JOIN company_dim USING (company_id)
    WHERE job_title_short = 'Data Analyst'
        AND job_location = 'Anywhere'
        AND salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 10
)
SELECT top_paying_jobs_cte.*,
    skills
FROM top_paying_jobs_cte
    LEFT JOIN skills_job_dim USING (job_id)
    LEFT JOIN skills_dim USING (skill_id)
WHERE skills IS NOT NULL
ORDER BY salary_year_avg DESC;
/*----------------------------------------*/
/*SKILLS COUNT FRO REMOTE JOBS------------*/
WITH top_skills_remote_cte AS (
    SELECT skill_id,
        count(*) AS total
    FROM skills_job_dim AS sjd
        LEFT JOIN job_postings_fact AS jpf USING (job_id)
    WHERE jpf.job_work_from_home = True
        AND jpf.job_title_short = 'Data Analyst'
    GROUP BY skill_id
)
SELECT skills.skill_id,
    skills as skill_name,
    total
FROM top_skills_remote_cte
    INNER JOIN skills_dim AS skills USING (skill_id)
ORDER BY total DESC
LIMIT 10;
/*----------------------------------------
 
 
 DATA ANALYST JOB SKILLS
 /*----------------------------------------*/
-- using all jobs postings inlcuding non-remote
SELECT *
FROM job_postings_fact
    INNER JOIN skills_job_dim USING (job_id)
    INNER JOIN skills_dim USING (skill_id)
LIMIT 10;
SELECT skills,
    COUNT(*) AS total
FROM job_postings_fact
    INNER JOIN skills_job_dim USING (job_id)
    INNER JOIN skills_dim USING (skill_id)
GROUP BY skills
ORDER BY total DESC
LIMIT 10;
-- Adding job title filter
SELECT skills,
    COUNT(*) AS total
FROM job_postings_fact
    INNER JOIN skills_job_dim USING (job_id)
    INNER JOIN skills_dim USING (skill_id)
WHERE job_title_short = 'Data Analyst'
GROUP BY skills
ORDER BY total DESC
LIMIT 10;
-- Adding job title filter, just remote jobs
SELECT skills,
    COUNT(*) AS total
FROM job_postings_fact
    INNER JOIN skills_job_dim USING (job_id)
    INNER JOIN skills_dim USING (skill_id)
WHERE job_title_short = 'Data Analyst'
    AND job_work_from_home = True
GROUP BY skills
ORDER BY total DESC
LIMIT 10;
/*----------------------------------------
 
 
 TOP SKILLS BASED ON SALARY FOR SPECIFIC ROLE
 /*----------------------------------------*/
SELECT skills,
    ROUND(AVG(salary_year_avg), 2) AS salary
FROM job_postings_fact
    INNER JOIN skills_job_dim USING (job_id)
    INNER JOIN skills_dim USING (skill_id)
WHERE job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
GROUP BY skills
ORDER BY salary DESC
LIMIT 10;
-- For just remote jobs:
SELECT skills,
    ROUND(AVG(salary_year_avg), 1) AS salary
FROM job_postings_fact
    INNER JOIN skills_job_dim USING (job_id)
    INNER JOIN skills_dim USING (skill_id)
WHERE job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True
GROUP BY skills
ORDER BY salary DESC
LIMIT 25;
-- Query result exported to clipboard and pasted into copilot prompt for analysis:
-- Quick Takeaways:
-- - Big data + ML orchestration = highest pay (PySpark, DataRobot, Airflow)
-- - DevOps and cloud-native tools are strong earners
-- - Programming languages like Swift and Golang beat traditional ones in salary
-- - Database and BI tools are solid but not top-tier in pay
/*----------------------------------------*/
/* MOST OPTIMAL SKILLS TO LEARN ------------*/
-- High demand and high pay
-- using CTEs and focusing on remote jobs.
/*----------------------------------------*/
-- top skills by count
SELECT skills,
    COUNT(*) AS total
FROM job_postings_fact
    INNER JOIN skills_job_dim USING (job_id)
    INNER JOIN skills_dim USING (skill_id)
GROUP BY skills
LIMIT 10;
-- TOP skills by avg salary
SELECT skill_id,
    skills,
    ROUND(AVG(salary_year_avg), 2) AS salary
FROM job_postings_fact
    INNER JOIN skills_job_dim USING (job_id)
    INNER JOIN skills_dim USING (skill_id)
WHERE salary_year_avg IS NOT NULL
GROUP BY skills
ORDER BY salary DESC
LIMIT 10;
-- Building CTEs:
-- order by count (total)
WITH skills_cte AS (
    SELECT skills_dim.skill_id,
        skills_dim.skills,
        COUNT(*) AS total
    FROM job_postings_fact
        INNER JOIN skills_job_dim USING (job_id)
        INNER JOIN skills_dim USING (skill_id)
    WHERE job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True
    GROUP BY skills_dim.skill_id
),
salary_cte AS (
    SELECT skills_job_dim.skill_id,
        ROUND(AVG(salary_year_avg), 2) AS salary
    FROM job_postings_fact
        INNER JOIN skills_job_dim USING (job_id)
        INNER JOIN skills_dim USING (skill_id)
    WHERE job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True
    GROUP BY skills_job_dim.skill_id
)
SELECT skills_cte.skill_id,
    skills_cte.skills,
    total,
    salary
FROM skills_cte
    INNER JOIN salary_cte ON skills_cte.skill_id = salary_cte.skill_id
ORDER BY total DESC,
    salary DESC
LIMIT 50;
-- Order by salary
WITH skills_cte AS (
    SELECT skills_dim.skill_id,
        skills_dim.skills,
        COUNT(*) AS total
    FROM job_postings_fact
        INNER JOIN skills_job_dim USING (job_id)
        INNER JOIN skills_dim USING (skill_id)
    WHERE job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True
    GROUP BY skills_dim.skill_id
),
salary_cte AS (
    SELECT skills_job_dim.skill_id,
        ROUND(AVG(salary_year_avg), 2) AS salary
    FROM job_postings_fact
        INNER JOIN skills_job_dim USING (job_id)
        INNER JOIN skills_dim USING (skill_id)
    WHERE job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True
    GROUP BY skills_job_dim.skill_id
)
SELECT skills_cte.skill_id,
    skills_cte.skills,
    total,
    salary
FROM skills_cte
    INNER JOIN salary_cte ON skills_cte.skill_id = salary_cte.skill_id
ORDER BY salary DESC,
    total DESC
LIMIT 50;
-- minimum limit for demand
WITH skills_cte AS (
    SELECT skills_dim.skill_id,
        skills_dim.skills,
        COUNT(*) AS total
    FROM job_postings_fact
        INNER JOIN skills_job_dim USING (job_id)
        INNER JOIN skills_dim USING (skill_id)
    WHERE job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True
    GROUP BY skills_dim.skill_id
),
salary_cte AS (
    SELECT skills_job_dim.skill_id,
        ROUND(AVG(salary_year_avg), 2) AS salary
    FROM job_postings_fact
        INNER JOIN skills_job_dim USING (job_id)
        INNER JOIN skills_dim USING (skill_id)
    WHERE job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True
    GROUP BY skills_job_dim.skill_id
)
SELECT skills_cte.skill_id,
    skills_cte.skills,
    total,
    salary
FROM skills_cte
    INNER JOIN salary_cte ON skills_cte.skill_id = salary_cte.skill_id
WHERE total > 10
ORDER BY salary DESC,
    total DESC
LIMIT 50;
-- rewriting for more concise code:
SELECT skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.skill_id) AS total,
    ROUND(AVG(salary_year_avg), 2) AS salary
FROM job_postings_fact
    INNER JOIN skills_job_dim USING (job_id)
    INNER JOIN skills_dim USING (skill_id)
WHERE job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True -- Need to use HAVING for filtering
    -- AND WHERE total > 10
GROUP BY skills_dim.skill_id
HAVING COUNT(skills_job_dim.skill_id) > 10
ORDER BY salary DESC,
    total DESC
LIMIT 10;
SELECT skills_dim.skill_id,
    skills_dim.skills,
    COUNT(*) AS total,
    ROUND(AVG(salary_year_avg), 2) AS salary
FROM job_postings_fact
    INNER JOIN skills_job_dim USING (job_id)
    INNER JOIN skills_dim USING (skill_id)
WHERE job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True
GROUP BY skills_dim.skill_id
HAVING COUNT(*) > 10
ORDER BY salary DESC,
    total DESC
LIMIT 10;