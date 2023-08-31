/* https://d-i-motion.com/lessons/sql-week-1/ */

/* Problem 1 */
select * 
from cd.facilities
where membercost != 0

/* Problem 2 */
select *
from cd.facilities
where name like '%Tennis%'

/* Problem 3 */
select *
from cd.facilities
where facid in (1,5)

/* Problem 4 */
select * 
from lyft_drivers
where yearly_salary <= '30000' or yearly_salary >= '70000'

/* Problem 5 */
select count(nominee)
from oscar_nominees
where nominee = 'Abigail Breslin'