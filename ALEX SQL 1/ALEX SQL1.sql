 /*Covid 19 Data Exploration */
SELECT  *
FROM  covid_deaths cd 
WHERE  continent IS NOT NULL  
ORDER BY location, [date]; 


-- Select Data that we are going to be starting with
SELECT location, [date] ,total_cases ,new_cases total_deaths ,population 
FROM covid_deaths cd 
WHERE continent IS NOT NULL 
ORDER BY location , [date]; 

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location , [date], total_cases , total_deaths, (CAST(total_deaths as float)/CAST (total_cases as float))*100 as 'percentage' 
FROM covid_deaths cd 
WHERE  location LIKE  '%states%'
AND  continent IS NOT NULL  
ORDER BY  location , [date] 


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location , [date] , population , total_cases,  (total_cases/population)*100 as 'infected_population_percentage'
FROM covid_deaths cd 
--Where location like '%states%'
ORDER BY location , [date] 


-- Countries with Highest Infection Rate compared to Population

SELECT  location , population , MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
FROM covid_deaths cd 
--Where location like '%states%'
GROUP BY  Location, Population
ORDER BY  PercentPopulationInfected DESC 


-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM covid_deaths cd 
--Where location like '%states%'
WHERE  continent IS NOT NULL  
GROUP BY  location
ORDER BY  TotalDeathCount DESC 



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT  continent, MAX(cast(total_deaths  as int)) as TotalDeathCount
FROM covid_deaths cd 
--Where location like '%states%'
WHERE  continent IS NOT NULL  
GROUP BY  continent
ORDER  BY TotalDeathCount DESC 



-- GLOBAL NUMBERS

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM covid_deaths cd 
--Where location like '%states%'
where continent is not null 
--Group By date
order by total_cases, total_deaths 



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT  cd.continent, cd.location, cd.[date] , cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.[date] ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM  covid_deaths cd 
JOIN covid_vaccine cv on cd.location = cv.location and cd.[date]  = cv.[date] 
WHERE  cd.continent IS NOT NULL
ORDER BY cd.location, cd.[date] 


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac as (SELECT  cd.continent, cd.location, cd.[date] , cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.[date] ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM  covid_deaths cd 
JOIN covid_vaccine cv on cd.location = cv.location and cd.[date]  = cv.[date] 
WHERE  cd.continent IS NOT NULL
--ORDER BY cd.location, cd.[date]
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT  cd.continent, cd.location, cd.[date] , cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.[date] ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM  covid_deaths cd 
JOIN covid_vaccine cv on cd.location = cv.location and cd.[date]  = cv.[date]


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT  cd.continent, cd.location, cd.[date] , cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.[date] ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM  covid_deaths cd 
JOIN covid_vaccine cv on cd.location = cv.location and cd.[date]  = cv.[date] 
WHERE  cd.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated