/****** Covid data expoloration project  ******/
SELECT 
  * 
FROM 
  PORTFOLIOPROJECT1..[covid deaths] 
WHERE 
  continent IS NOT NULL 
ORDER BY 
  3, 
  4 


SELECT 
  location, 
  total_cases, 
  date, 
  new_cases, 
  total_deaths, 
  population 
FROM 
  PORTFOLIOPROJECT1..[covid deaths] 
WHERE 
  continent IS NOT NULL 
ORDER BY 
  1, 
  2 
  
  -- Total cases vs total deaths


SELECT 
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  (total_deaths / total_cases)* 100 AS DeathPercentage 
FROM 
  PORTFOLIOPROJECT1..[covid deaths] 
WHERE 
  continent IS NOT NULL --AND location = 'United kingdom'
ORDER BY 
  1, 
  2 
  
  -- Looking at total cases VS Population


SELECT 
  location, 
  date, 
  total_cases, 
  population, 
  (total_cases / population)* 100 AS InfectionPercentage 
FROM 
  PORTFOLIOPROJECT1..[covid deaths] 
WHERE 
  continent IS NOT NULL -- AND location = 'United kingdom'
ORDER BY 
  1, 
  2 
  
  -- Countries with the highest Infection rates compared  to the population


Select 
  Location, 
  Population, 
  MAX(total_cases) as HighestInfectionCount, 
  Max(
    (total_cases / population)
  )* 100 as PercentPopulationInfected 
From 
  PortfolioProject..CovidDeaths --Where location like '%states%'
Group by 
  Location, 
  Population 
order by 
  PercentPopulationInfected desc 
  
  -- Countries with Highest Death Count per Population


SELECT 
  location, 
  MAX(
    CAST (total_deaths AS INT)
  ) AS TotalDeathCount 
FROM 
  PORTFOLIOPROJECT1..[covid deaths] 
WHERE 
  continent IS NOT NULL -- AND location = 'United kingdom'
GROUP BY 
  location 
ORDER BY 
  TotalDeathCount DESC 
  
  -- Continents with Highest Death Count per Population


SELECT 
  continent, 
  MAX(
    CAST (total_deaths AS INT)
  ) AS TotalDeathCount 
FROM 
  PORTFOLIOPROJECT1..[covid deaths] 
WHERE 
  continent IS NOT NULL 
GROUP BY 
  continent 
ORDER BY 
  TotalDeathCount DESC 
  
  -- Global numbers -Partioned by date


SELECT 
  date, 
  SUM(new_cases) AS Total_Cases, 
  SUM(
    CAST(new_deaths AS INT)
  ) AS Total_Deaths, 
  (
    SUM(
      CAST(new_deaths AS INT)
    )/ SUM(new_cases)
  ) * 100 AS Death_Percentage 
FROM 
  PORTFOLIOPROJECT1..[covid deaths] 
WHERE 
  continent IS NOT NULL --AND location = 'United kingdom'
GROUP BY 
  date 
ORDER BY 
  1, 
  2 
  
  -- Global numbers- Worldwide Total cases, Total deaths, and death percentage


SELECT 
  SUM(new_cases) AS Total_Cases, 
  SUM(
    CAST(new_deaths AS INT)
  ) AS Total_Deaths, 
  (
    SUM(
      CAST(new_deaths AS INT)
    )/ SUM(new_cases)
  ) * 100 AS Death_Percentage 
FROM 
  PORTFOLIOPROJECT1..[covid deaths] 
WHERE 
  continent IS NOT NULL --AND location = 'United kingdom'
ORDER BY 
  1, 
  2 
  
  --Total population VS Vaccination


SELECT 
  death.continent, 
  death.location, 
  death.date, 
  death.population, 
  new_vaccinations, 
  SUM(
    CAST(vacc.new_vaccinations AS BIGINT)
  ) OVER (
    PARTITION BY death.location 
    ORDER BY 
      death.date, 
      death.location
  ) AS RollingPeopleVacc 
FROM 
  PORTFOLIOPROJECT1..[covid deaths] death 
  JOIN PORTFOLIOPROJECT1..[covid vaccinationations] vacc ON death.location = vacc.location 
  AND death.date = vacc.date 
WHERE 
  death.continent IS NOT NULL 
ORDER BY 
  2, 
  3 
  
  -- USE CTE
  
  
  WITH popVSvacc (
    continent, location, population, date, 
    new_vaccinations, RollingPeopleVacc
  ) AS (
    SELECT 
      death.continent, 
      death.location, 
      death.date, 
      death.population, 
      new_vaccinations, 
      SUM(
        CAST(vacc.new_vaccinations AS BIGINT)
      ) OVER (
        PARTITION BY death.location 
        ORDER BY 
          death.date, 
          death.location
      ) AS RollingPeopleVacc 
    FROM 
      PORTFOLIOPROJECT1..[covid deaths] death 
      JOIN PORTFOLIOPROJECT1..[covid vaccinationations] vacc ON death.location = vacc.location 
      AND death.date = vacc.date 
    WHERE 
      death.continent IS NOT NULL
  ) 
SELECT 
  *, 
  (RollingPeopleVacc / population)* 100 
FROM 
  popVSvacc 
  
  -- TEMP TABLE

DROP 
  TABLE IF EXISTS #PercentPopulationVaccinated
  CREATE TABLE #PercentPopulationVaccinated
  (
    Continent nvarchar(255), 
    Location nvarchar(255), 
    Date datetime, 
    Population numeric, 
    New_Vaccination numeric, 
    RollingPeopleVacc numeric, 
    ) INSERT INTO #PercentPopulationVaccinated
SELECT 
  death.continent, 
  death.location, 
  death.date, 
  death.population, 
  new_vaccinations, 
  SUM(
    CAST(vacc.new_vaccinations AS BIGINT)
  ) OVER (
    PARTITION BY death.location 
    ORDER BY 
      death.date, 
      death.location
  ) AS RollingPeopleVacc 
FROM 
  PORTFOLIOPROJECT1..[covid deaths] death 
  JOIN PORTFOLIOPROJECT1..[covid vaccinationations] vacc ON death.location = vacc.location 
  AND death.date = vacc.date 
WHERE 
  death.continent IS NOT NULL 
ORDER BY 
  2, 
  3 
SELECT 
  *, 
  (RollingPeopleVacc / population)* 100 
FROM 
  #PercentPopulationVaccinated
 
 
 -- Creating a view for later tablue viz
  
  
  CREATE VIEW PercentPopulationVaccinated AS 
SELECT 
  death.continent, 
  death.location, 
  death.date, 
  death.population, 
  new_vaccinations, 
  SUM(
    CAST(vacc.new_vaccinations AS BIGINT)
  ) OVER (
    PARTITION BY death.location 
    ORDER BY 
      death.date, 
      death.location
  ) AS RollingPeopleVacc 
FROM 
  PORTFOLIOPROJECT1..[covid deaths] death 
  JOIN PORTFOLIOPROJECT1..[covid vaccinationations] vacc ON death.location = vacc.location 
  AND death.date = vacc.date 
WHERE 
  death.continent IS NOT NULL 
  --ORDER BY 2,3
