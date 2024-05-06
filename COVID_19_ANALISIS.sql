SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%MEX%' AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
--WHERE location = 'MEX'
ORDER by 1,2

-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%MEX%' AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
--WHERE location = 'Mexico'
ORDER by 1,2

-- Looking at Countries with the Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS MaxInfectionPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%COL%'
GROUP BY location, population
ORDER BY MaxInfectionPercentage DESC

-- Seeing the Maximum Cases and Maximum Deaths in Mexico

SELECT location, population, MAX(total_cases) AS MaxTotalCases, MAx(total_deaths) AS MaxDeaths
FROM PortfolioProject..CovidDeaths
WHERE location = 'Mexico' AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY location, population

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS MaxDeathsPerCountry
FROM PortfolioProject..CovidDeaths
--WHERE total_deaths IS NOT NULL
GROUP BY location
ORDER BY MaxDeathsPerCountry DESC

-- Let's see the original data again to notice that in the column
-- location there is some id's that has have the name of a continent

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS MaxDeathsPerCountry
FROM PortfolioProject..CovidDeaths
--WHERE total_deaths IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MaxDeathsPerCountry DESC

-- Let's see the Highest Death Count by Continent that is contained
-- in the location column

SELECT location, MAX(CAST(total_deaths AS int)) AS MaxDeathsPerContinent
FROM PortfolioProject..CovidDeaths
--WHERE total_deaths IS NOT NULL
WHERE continent IS NULL
GROUP BY location
ORDER BY MaxDeathsPerContinent DESC

-- This is just to explain why we are chosing the function
-- WHERE total_deaths IS NOT NULL
/*
SELECT location
FROM PortfolioProject..CovidDeaths
WHERE continent is null
ORDER BY 1
*/

-- Let's see the Highest Death Count by Continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS MaxDeathsPerContinent
FROM PortfolioProject..CovidDeaths
--WHERE total_deaths IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MaxDeathsPerContinent DESC

---- Percentage of NewCases and Deaths Per Day in the World

--SELECT date, MAX(new_cases) AS NewCasesPerDay, MAX(CAST(total_deaths AS int)) AS DeathsPerDay, (SUM(CAST(total_deaths AS int)) / NULLIF(SUM(new_cases),0))*100 AS DeathPercentagePerDay
--FROM PortfolioProject..CovidDeaths
----WHERE location LIKE '%MEX%'
--WHERE continent IS NOT NULL
--GROUP BY date
--ORDER by DeathPercentagePerDay DESC

--GLOBAL NUMBERS (This code is for showing the TotalPercentage deaths
-- around the world

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%MEX%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER by 1,2

-- Let's see the dataset of vaccinations

SELECT*
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- We are going to join both tables

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM PortfolioProject..CovidDeaths d -- d is for deaths
JOIN PortfolioProject..CovidVaccinations v -- v is for vaccinations
	ON	d.date = v.date
	AND d.location = v.location
WHERE d.continent IS NOT NULL --AND d.location LIKE '%MEX%'
ORDER BY 2,3

-- See the New Vaccinatios Per Country

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,
	CONVERT(date, d.date)) AS AccumulatedVaccinations
FROM PortfolioProject..CovidDeaths d -- d is for deaths
JOIN PortfolioProject..CovidVaccinations v -- v is for vaccinations
	ON	d.date = v.date
	AND d.location = v.location
WHERE d.continent IS NOT NULL -- AND d.location LIKE '%ALB%'
ORDER BY 2,3

-- Using a CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, AccumulatedVaccinations)
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,
	CONVERT(date, d.date)) AS AccumulatedVaccinations
FROM PortfolioProject..CovidDeaths d -- d is for deaths
JOIN PortfolioProject..CovidVaccinations v -- v is for vaccinations
	ON	d.date = v.date
	AND d.location = v.location
WHERE d.continent IS NOT NULL AND d.location LIKE '%states%'
--ORDER BY 2,3
)

SELECT *, (AccumulatedVaccinations/Population)*100 AS PercentageVaccinatedPeople
FROM PopvsVac

-- Temporary Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
AccumulatedVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,
	CONVERT(date, d.date)) AS AccumulatedVaccinations
FROM PortfolioProject..CovidDeaths d -- d is for deaths
JOIN PortfolioProject..CovidVaccinations v -- v is for vaccinations
	ON	d.date = v.date
	AND d.location = v.location
-- WHERE d.continent IS NOT NULL AND d.location LIKE '%mex%'
--ORDER BY 2,3

SELECT *, (AccumulatedVaccinations/Population)*100 AS PercentageVaccinatedPeople
FROM #PercentPopulationVaccinated

-- Let's create view to store data for later visualizations

DROP VIEW IF EXISTS PercentagePopulationVaccinated

CREATE VIEW PercentagePopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,
	CONVERT(date, d.date)) AS AccumulatedVaccinations
FROM PortfolioProject..CovidDeaths d -- d is for deaths
JOIN PortfolioProject..CovidVaccinations v -- v is for vaccinations
	ON	d.date = v.date
	AND d.location = v.location
WHERE d.continent IS NOT NULL --AND d.location LIKE '%mex%'
--ORDER BY 2,3

SELECT *
FROM PercentagePopulationVaccinated