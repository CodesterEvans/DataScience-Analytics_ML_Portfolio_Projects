
SELECT *
FROM CovidDeaths$
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations$
--ORDER BY 3,4


--Select Data that is going to be used

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM ..CovidDeaths$
order by 1,2

-- Convert 'date' from varchar to datetime format (Hidden)
 

-- Total Cases vs Total Deaths: Likelihood of survival if infected

SELECT location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'case_lethality %'
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY location,date DESC


--Total Cases vs Population: Percent of people that have been infected

SELECT location, date, total_cases, population, (total_cases/population)*100 AS '% infected'
FROM ..CovidDeaths$
WHERE location like '%states%'
ORDER BY location, date DESC


-- Percent of Population that is or has been Infected

SELECT location, population, MAX(total_cases) AS InfectionCount, MAX(total_cases/population)*100 AS 'percent_infected'
FROM ..CovidDeaths$
GROUP BY location, population
ORDER BY percent_infected DESC


-- Highest Total Death Count by Country

SELECT location, MAX(cast(total_deaths AS int)) AS death_total
FROM ..CovidDeaths$
WHERE continent is not NULL
GROUP BY location
ORDER BY death_total DESC

-- Highest Death Rate by Country

SELECT location,population, MAX(total_deaths) as death_total, MAX(total_cases) AS Infection_Count, (MAX(total_deaths)/MAX(total_cases))*100 AS Death_Rate_Percentage
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY Death_Rate_Percentage DESC

-- Death Count by Continent

SELECT continent, MAX(cast(total_deaths AS int)) AS death_total
FROM ..CovidDeaths$
WHERE continent is not NULL
GROUP BY continent
ORDER BY death_total DESC

-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS 'case_lethality %'
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY total_cases


-- Total Vaccinations vs Population

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, --SUM(convert(int,vac.new_vaccinations))	SUM(convert(int,vac.new_vaccinations))/dea.population AS 'people_vaccinated'
SUM(convert(int,vac.new_vaccinations)) OVER(PARTITION by dea.location ORDER BY dea.location,dea.date) as rolling_vaccination_count
FROM ..CovidDeaths$ AS dea
JOIN ..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--GROUP BY dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
ORDER BY 2,3

--CTE

With VacvsPop (continent, location, date, population, new_vaccinations, RollingVaccinationCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location,dea.date) as RollingVaccinationCount
FROM ..CovidDeaths$ AS dea
JOIN ..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingVaccinationCount/population)*100
FROM VacvsPop



-- Temp Table 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, --SUM(convert(int,vac.new_vaccinations))	SUM(convert(int,vac.new_vaccinations))/dea.population AS 'people_vaccinated'
SUM(convert(int,vac.new_vaccinations)) OVER(PARTITION by dea.location ORDER BY dea.location,dea.date) as RollingVaccinationCount
FROM ..CovidDeaths$ AS dea
JOIN ..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingVaccinationCount/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated


-- VIEW 

CREATE VIEW PercentPopulationVaccinated AS

SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, --SUM(convert(int,vac.new_vaccinations))	SUM(convert(int,vac.new_vaccinations))/dea.population AS 'people_vaccinated'
SUM(convert(int,vac.new_vaccinations)) OVER(PARTITION by dea.location ORDER BY dea.location,dea.date) as RollingVaccinationCount
FROM ..CovidDeaths$ AS dea
JOIN ..CovidVaccinations$ AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM #PercentPopulationVaccinated

--Extras 



-- Death Rate by Continent

SELECT location, MAX(total_cases) AS infection_count, MAX(total_deaths) AS death_total, (MAX(total_deaths)/MAX(total_cases))*100 AS Death_Rate_Percentage
FROM .CovidDeaths$
WHERE continent is null  and location not LIKE '%income%'
GROUP BY location
ORDER BY Death_Rate_Percentage DES


-- 


-- % of population vaccinated
--SELECT cd.location, cd.date, cd.population,people_fully_vaccinated, (cast(people_fully_vaccinated as int)/population)*100 AS 'fully vax %'
--FROM ..CovidVaccinations$ AS cv
--INNER JOIN ..CovidDeaths$ AS cd
--	ON cv.location=cd.location
--WHERE cv.location like '%states%' and cv.people_fully_vaccinated >0
--ORDER BY date



