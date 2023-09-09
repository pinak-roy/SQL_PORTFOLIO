/* Find the longest ongoing project for each department. */
select p.name, (p.end_date-p.start_date) as time_idff
from departments d
join employees e on d.id = e.department_id
join projects p on e.department_id = p.department_id
group by p.name, time_idff
order by time_idff desc
limit 1

/* Find all employees who are not managers. */
select e.name, e.job_title
from departments d
join employees e on d.id = e.department_id
join projects p on e.department_id = p.department_id
where e.job_title not like '%Manager%'


/* Find all employees who have been hired after the start of a project in their department. */
select e.name
from departments d
join employees e on d.id = e.department_id
join projects p on e.department_id = p.department_id
where e.hire_date > p.start_date


/* Rank employees within each department based on their hire date (earliest hire gets the highest rank).*/
select e.name,d.name, rank() over(partition by e.department_id order by e.hire_date) as ranking
from departments d
join employees e on d.id = e.department_id
join projects p on e.department_id = p.department_id

/* Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.*/
select name, department_id, hire_date,
  (hire_date - lead(hire_date) over (partiton by department_id order by hire_date)) as duration
from employees
order by department_id, hire_date
