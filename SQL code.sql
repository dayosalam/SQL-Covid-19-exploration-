SELECT  *
FROM CovidDeaths$
WHERE continent IS NOT NULL 
Order by 3,4


SELECT  *
FROM CovidVaccination$
Order by 3,4

-- Select Data that I am going to use 

SELECT  location, date, new_cases, total_cases, total_deaths,population
FROM CovidDeaths$
Order by 1,2

--Total Cases vs Total Deaths AS percentage of Death

SELECT  
	location, date,  total_cases, total_deaths,
	((total_deaths/total_cases)*100) AS PercentageDeath
FROM 
	CovidDeaths$
WHERE
	location = 'NIgeria' or location = 'Canada' 
Order by 1,2

--Looking at Total cases vs Population
--Percentage of population that got covid

SELECT  
	location, date,  total_cases, population,
	(total_cases/population)*100 AS PopulationInfected
FROM 
	CovidDeaths$
WHERE 
	location like '%NIgeria'
Order by 1,2

--Country with Highest cases compared to population
SELECT  
	location,  max(total_cases) AS HighestCaseCountry, 
	population, max((total_cases/population)*100) AS PercentagePopulationInfected
FROM 
	CovidDeaths$
GROUP by location, population
Order by PercentagePopulationInfected DESC


--Country HighestDeath per Population

SELECT  location,  max(CAST(total_deaths AS INT)) AS HighestDeathCountry
FROM CovidDeaths$
WHERE continent IS NOT NULL 
GROUP by location
ORDER by HighestDeathCountry DESC

--BY CONTINIENT 

SELECT continent location,  max(CAST(total_deaths AS INT)) AS HighestDeathContinent
FROM CovidDeaths$
WHERE continent IS NOT NULL 
GROUP by continent
ORDER by HighestDeathContinent DESC

-- Showing continent with highest death count

SELECT continent location,  max(CAST(total_deaths AS INT)) AS HighestDeathCountry
FROM CovidDeaths$
WHERE continent IS NOT NULL 
GROUP by continent
ORDER by HighestDeathCountry DESC





-- Global numbers

SELECT  date, SUM(new_cases) AS total_new_cases, SUM(CAST(new_deaths as int)) AS total_new_deaths,
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths$
--WHERE location = 'NIgeria' or location = 'Canada' 
WHERE continent is not null
GROUP BY date
ORDER by 1,2


--Total Population vs Vaccinations(Percentage of population vaccinated)

SELECT 
	dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY 
	dea.location ORDER BY dea.location, dea.date) 
	AS total_vaccinations_country
FROM
	Portfolio..CovidDeaths$ dea
	JOIN 
	Portfolio..CovidVaccination$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3
	

	--Using CTE to temporary store the result in 

WITH PopVsVac (Continent, location, Date, Population,new_vaccinations ,total_vaccinations_country) AS
(
	SELECT 
	dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) 
	AS total_vaccinations_country
FROM
	Portfolio..CovidDeaths$ dea
	JOIN 
	Portfolio..CovidVaccination$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 

--ORDER BY 2,3
)

-- Using result stored in CTE table to get percentage of population vaccinated
SELECT *, (total_vaccinations_country/Population)*100 AS population_vaccinated_percentage
FROM
	PopVsVac


-- Creating a TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinated numeric,
	Total_vaccinations_country numeric
)
--Inserting values into the TEMP table
INSERT INTO #PercentPopulationVaccinated
	SELECT 
	dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) 
	AS total_vaccinations_country
FROM
	Portfolio..CovidDeaths$ dea
	JOIN 
	Portfolio..CovidVaccination$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (Total_vaccinations_country/Population)*100
FROM #PercentPopulationVaccinated



--Creating view to store data for later visualization

CREATE VIEW PercentPopulatedVaccinated AS
		SELECT 
	dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) 
	AS total_vaccinations_country
FROM
	Portfolio..CovidDeaths$ dea
	JOIN 
	Portfolio..CovidVaccination$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *
FROM PercentPopulatedVaccinated
