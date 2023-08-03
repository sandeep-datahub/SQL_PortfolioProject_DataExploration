SELECT *
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2


-- LOOKING at Total Cases vs Total Deaths
-- Shows the likelihood of death if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like 'India' AND continent is not null
ORDER BY 1, 2

-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, 
MAX(total_cases) as HighestInfectionCount, 
ROUND(MAX((total_cases/population)*100),2) AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY 3 DESC

-- Showing countries with the highest death count per Location

SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY 2 DESC

--LET'S BREAK THINGS DOWN BY CONTINENT; The data comprises of mixed up entries in location and continent.

--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT

SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY 2 DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as INT)) as TotalDeaths, 
SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage 
FROM CovidDeaths
WHERE continent is not null


--LOOKING AT Total Population vs Vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER(PARTITION BY cd.location ORDER BY cd.date) 
as RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location=cv.location 
	and cd.date=cv.date
WHERE cd.continent is not null
ORDER BY 2,3

-- USING CTE
WITH popvsvac as (
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER(PARTITION BY cd.location ORDER BY cd.date) 
as RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location=cv.location 
	and cd.date=cv.date
WHERE cd.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 FROM popvsvac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), date datetime, population numeric, new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER(PARTITION BY cd.location ORDER BY cd.date) 
as RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location=cv.location 
	and cd.date=cv.date
--WHERE cd.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS int)) OVER(PARTITION BY cd.location ORDER BY cd.date) 
as RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location=cv.location 
	and cd.date=cv.date
WHERE cd.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated