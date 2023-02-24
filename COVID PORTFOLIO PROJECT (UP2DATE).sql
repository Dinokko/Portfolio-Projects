SELECT * FROM PORTFOLIOPROJECT..CovidDeaths
ORDER BY 3,4

--SELECT * FROM PORTFOLIOPROJECT..CovidVaccinations
--ORDER BY 3,4

SELECT Location, Date, total_cases, new_cases, total_deaths, population 
FROM PORTFOLIOPROJECT..CovidDeaths
ORDER BY 1, 2

-- Total Cases vs Total Deaths

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS death_percentage
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE location = 'Canada'
WHERE continent is not null
ORDER BY 1, 2

-- Total Cases vs Population

SELECT Location, Date, total_cases, population, (total_cases/population)* 100 AS population_percentage
FROM PORTFOLIOPROJECT..CovidDeaths
WHERE location = 'Canada'
WHERE continent is not null
ORDER BY 1, 2

-- Countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 AS population_percentage
FROM PORTFOLIOPROJECT..CovidDeaths
--WHERE location = 'Canada'
GROUP BY location, population
ORDER BY population_percentage desc

-- Countries with highest death rate compared to population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PORTFOLIOPROJECT..CovidDeaths
--WHERE location = 'Canada'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Break down by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PORTFOLIOPROJECT..CovidDeaths
--WHERE location = 'Canada' AND location <> 'High income' AND location <> 'Low income' AND location <> 'Lower middle income' AND location <> 'Upper middle income'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--  Showing contients with highest death count per population 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PORTFOLIOPROJECT..CovidDeaths
--WHERE location = 'Canada'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT SUM(total_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 AS death_percentage
FROM PORTFOLIOPROJECT..CovidDeaths
--WHERE location = 'Canada'
where continent is not null
--Group by date
ORDER BY 1, 2

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_vaccinated,
-- (total_vaccinated/population)* 100
FROM PORTFOLIOPROJECT..Coviddeaths dea
JOIN PORTFOLIOPROJECT..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2, 3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, total_vaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_vaccinated
--, (total_vaccinated/population)* 100
FROM PORTFOLIOPROJECT..Coviddeaths dea
JOIN PORTFOLIOPROJECT..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- ORDER BY 2, 3
)
SELECT *, (total_vaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_vaccinated
--, (total_vaccinated/population)* 100
FROM PORTFOLIOPROJECT..Coviddeaths dea
JOIN PORTFOLIOPROJECT..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- ORDER BY 2, 3

SELECT *, (total_vaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- VIEW 

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_vaccinated
--, (total_vaccinated/population)* 100
FROM PORTFOLIOPROJECT..Coviddeaths dea
JOIN PORTFOLIOPROJECT..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- ORDER BY 2, 3

SELECT * FROM PercentPopulationVaccinated