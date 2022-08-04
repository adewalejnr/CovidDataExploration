SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select data to be used

SELECT Location, date,  total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at the total cases vs total deaths to determine the likelihood of deathing if one contracts covid in Nigeria

SELECT Location, date,  total_cases, total_deaths, (total_deaths/total_cases)*100 AS Percentage_Death
FROM PortfolioProject..CovidDeaths
WHERE location like'%Nigeria%'
ORDER BY 1,2;

-- Looking at the population vs total cases to determine the percentage of population that has got covid in Nigeria

SELECT Location, date,  population, total_cases, (total_cases/population)*100 AS Population_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like'%Nigeria%'
ORDER BY 1,2;

--Under 1% of the total population has got Covid from 2020 till now

-- Looking at the Highest Infection Rate vs Population by country

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulation_percentage
FROM PortfolioProject..CovidDeaths
Group BY location, population
ORDER BY InfectedPopulation_percentage DESC;

-- Faeroe Islands has the highest infection Rate with 65% of the population infected and it's closely followed by Cyprus and Gibraltar 
-- with 62% and 60% respectively as of 27/07/2022


-- Looking at the Highest Death Count per Population and country

SELECT Location, population, MAX(cast(Total_Deaths as int)) AS HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group BY Location, population
ORDER BY HighestDeathCount DESC;

-- The United States has the highest death count with 1,028,819 as of 27/07/2022


--Drilling down by Continent

-- Looking at the Continent with the Highest Death Count per Population

SELECT continent, MAX(cast(Total_Deaths as int)) AS HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group BY continent
ORDER BY HighestDeathCount DESC;


--LOOKING AT THE GLOBAL NUMBERS

SELECT date, SUM(New_cases) as total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentageGlobally
From PortfolioProject..CovidDeaths
Where continent is not null
Group BY date
ORDER BY 1,2 DESC;

-- Looking at the total cases and total death across the world
SELECT SUM(New_cases) as total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentageGlobally
From PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 1,2 DESC;


-- Joining the Vaccination table together with the Deaths table

SELECT *
From PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.Date
ORDER BY 1,2 DESC;

-- Looking at the Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
From PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.Date
Where dea.continent is not null
ORDER BY 2,3 DESC;


SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS int))  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.Date
Where dea.continent is not null
ORDER BY 2,3 DESC;



-- Using CTE

WITH PopuVsVacci (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS int))  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.Date
Where dea.continent is not null
--ORDER BY 2,3 DESC
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS Vaccination_Percentage
FROM PopuVsVacci



--Using a TEMP Table


DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS int))  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.Date
Where dea.continent is not null
--ORDER BY 2,3 DESC

SELECT *, (RollingPeopleVaccinated/population)*100 AS Vaccination_Percentage
FROM #PercentPopulationVaccinated


--Creating a view to stare date for visualization later

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, Vac.new_vaccinations
, SUM(CAST(Vac.new_vaccinations AS int))  OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccinations Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.Date
Where dea.continent is not null
--ORDER BY 2,3 DESC


Create View HighestDeathCountByContinent as
SELECT continent, MAX(cast(Total_Deaths as int)) AS HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group BY continent
--ORDER BY HighestDeathCount DESC;