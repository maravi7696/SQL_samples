SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4

-- Select the Data we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the Likelihood of Dying if you Contract COVID in the U.S.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentofDeaths
FROM PortfolioProject..CovidDeaths
WHERE location like '%states' AND continent IS NOT NULL 
ORDER BY 1,2

-- Looking at Total Cases vs the Population
-- Shows What Percentage of the Population Contracted COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states' AND continent IS NOT NULL 
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population
SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent, location, population
ORDER BY PercentPopulationInfected DESC

-- Showing the Countries with the Highest Death Count per Population
SELECT location, MAX(CONVERT(int, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING DATA DOWN BY CONTINENT
-- Showing Continents with the Highest Death Counts
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS 
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2

-- JOINING TABLES
-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingVaccinationCount 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT dea.location, MAX(vac.new_vaccinations)
AS MaxVaccinationCount
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE vac.new_vaccinations IS NOT NULL AND dea.continent IS NOT NULL
GROUP BY dea.location
ORDER BY dea.location

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentofPopulationVaccinated
CREATE TABLE #PercentofPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric
)
INSERT INTO #PercentofPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingVaccinationCount 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3

-- THE NEXT SECTION IS FOR VIEWS ONLY

--Percentage of Population that was Vaccinated
CREATE VIEW PercentofPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingVaccinationCount 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

--Percentage of Deaths in the United States
CREATE VIEW PercentofDeathsinUSA AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentofDeaths
FROM PortfolioProject..CovidDeaths
WHERE location like '%states' AND continent IS NOT NULL 

--Percentage of Population Infected in the United States
CREATE VIEW PercentPopulationInfected_USA AS
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states' AND continent IS NOT NULL 

--Percentage of Population Infected in the World
CREATE VIEW PercentPopulationInfected_Global AS
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 

--Total Death Count by Continent
CREATE VIEW TotalDeathCount AS
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent

--Max Vaccinations Per Country
CREATE VIEW MaxVaccinationPerCountry AS
SELECT dea.location, MAX(vac.new_vaccinations)
AS MaxVaccinationCount
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE vac.new_vaccinations IS NOT NULL AND dea.continent IS NOT NULL
GROUP BY dea.location
