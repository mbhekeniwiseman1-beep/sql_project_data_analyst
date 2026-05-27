/*
Question: What are the top-paying data analyst jobs?
- Identify the top 10 highest-paying Data Analyst roles that are available remotely
- Focuses on job postings with specified salaries ( remove nulls)
- Why? Highest the top-paying opportunities for Data Analysts, offering insights into employement
*/

select
	top 10 
	job_id,
	job_title,
	job_location,
	job_schedule_type,
	salary_year_avg,
	job_posted_date,
	name as company_name
from 
	job_postings_fact
left join company_dim on job_postings_fact.company_id = company_dim.company_id
where job_title_short = 'Data Analyst' and
	  job_location = 'anywhere' and
	  salary_year_avg is not null
order by salary_year_avg desc

/* 
Question: What are the skills required for these top-paying roles?
- Use the top 10 highest paying Data Analyst jobs from first query
- Add the specific skills required for these roles
- why? it provides a detailed look at which high paying jobs demand certain skills,
- helping job seekers understand which skills to develop that align with top salaries
*/

with top_paying_jobs as (
select
	top 10 
	job_id,
	job_title,
	salary_year_avg,
	name as company_name
from 
	job_postings_fact
left join company_dim on job_postings_fact.company_id = company_dim.company_id
where job_title_short = 'Data Analyst' and
	  job_location = 'anywhere' and
	  salary_year_avg is not null
order by salary_year_avg desc
)
select 
	top_paying_jobs.*,
	skills
from top_paying_jobs
inner join skills_job_dim on top_paying_jobs.job_id = skills_job_dim.job_id
inner join skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
order by salary_year_avg desc

/*
Question: What are the most in-demand skills for my role?
- Join job postings to inner join table similar to query
- identify the top 5 in-demand skills for a data analyst
- Focus on all job postings
- why? Retrieves the top 5 skills with the highest demand in the job market,
providing insights into the most valuable skills for job seekers
*/

select 
top 5 
skills,
count(skills_job_dim.job_id) as demand_count
from job_postings_fact
inner join skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
inner join skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
where job_title_short = 'Data Analyst' AND job_work_from_home = 'true'
group by skills
order by demand_count desc

/*
Question: What are the top skills based on salary for my role?
*/

select 
top 25
skills,
round(avg(salary_year_avg),0) as avg_sal
from job_postings_fact
inner join skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
inner join skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
where job_title_short = 'Data Analyst' AND job_work_from_home = 'true'
group by skills
order by avg_sal desc

/* 
Question: What are the most optimal skills to learn
	- Identify skills in high demand and associated with high avg salaries for Data Analyst roles
	- Concentrates on remote positions with specified salaries
	- why? Targets skills that offer job security (high demand) and financial benefits (high salaries),
	offering strategic insights for career development in data analysis
*/
with skills_demand AS (
    select
        skills_dim.skill_id,
        skills_dim.skills,
        count(skills_job_dim.job_id) AS demand_count
    from job_postings_fact
    inner join skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    inner join skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    where job_title_short = 'Data Analyst' 
        and salary_year_avg IS NOT NULL
        and job_work_from_home = 'true'
    group by skills_dim.skill_id, skills_dim.skills  
), average_salary AS (
  select 
        skills_job_dim.skill_id,
        round(AVG(salary_year_avg), 0) AS avg_sal
    FROM job_postings_fact
    inner join skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    inner join skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    where job_title_short = 'Data Analyst' 
        and salary_year_avg IS NOT NULL
        and job_work_from_home = 'true'
    group by skills_job_dim.skill_id
)
select
    skills_demand.skill_id,       
    skills_demand.skills,
    demand_count,
    avg_sal                        
from skills_demand                 
INNER JOIN average_salary ON skills_demand.skill_id = average_salary.skill_id
order by demand_count desc, avg_sal desc;
