select * 
from portfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from portfolioProject..CovidVaccinations
--order by 3,4

--select Data taht we are going to  use 

select location, date, total_cases,new_cases,total_deaths, population 
from portfolioProject..CovidDeaths
order by 1,2

--loking at total cases vs total deaths

select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from portfolioProject..CovidDeaths 
where location like '%france%' 
order by 1,2

--looking at total cases vs Population 
select Location , date, total_cases,Population, (total_cases/population)*100 AS gensaveccovid 
from portfolioProject..CovidDeaths
where location like '%france%'  
and  continent is not null 
order by 1,2

-- country with hight infection compares to the population. 
select Location ,Population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 AS percentpopulationinfected 
from portfolioProject..CovidDeaths
--where location like '%maroc%'
group by location, Population
order by percentpopulationinfected desc



--lets break things down by contient 


-- montrer les pays avecc le plus haux taux de mort par population 
select continent , MAX(cast(total_deaths as int)) as Totaldemort
from portfolioProject..CovidDeaths
--where location like '%france%'
where continent is not null
group by continent
order by Totaldemort desc


--showing the continents with the highest death count per population 

select location, MAX(cast(total_deaths as int)) as Totaldemort
from portfolioProject..CovidDeaths
--where location like '%france%'
where continent is not null
group by location
order by Totaldemort desc


--global Numbers 

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as deathPercentage 
from portfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
--groupe by date
order by 1,2


--for the vacination cases 

select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations
From portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null 
order by 1,2


--loking at total population vs vaccinations 

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS rolling_people_vaccinated, 
	
FROM 
    portfolioProject..CovidDeaths dea
JOIN 
    portfolioProject..CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL 
ORDER BY 
    dea.location, 
    dea.date;



--USE CTE 

with PopvsVac (continent, location, date, population,new_vaccination, rollingpeoplevaccinated)
as 
--loking at total population vs vaccinations 
(
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS rollingpeoplevaccinated
FROM 
    portfolioProject..CovidDeaths dea
JOIN 
    portfolioProject..CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL 
--ORDER BY 1,2
)
select * ,(rollingpeoplevaccinated/Population)*100
From PopvsVac 






--temp table 
-- Suppression de la table temporaire si elle existe
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

-- Création de la table temporaire avec les bons types de données
CREATE TABLE #PercentPopulationVaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATE,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rolling_people_vaccinated NUMERIC
);

-- Insertion des données avec calcul du cumul
INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.date
    ) AS rolling_people_vaccinated
FROM 
    portfolioProject..CovidDeaths dea 
JOIN 
    portfolioProject..CovidVaccinations vac 
    ON dea.location = vac.location
    AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL;

-- Sélection finale avec calcul du pourcentage
SELECT 
    continent,
    location,
    date,
    population,
    new_vaccinations,
    rolling_people_vaccinated,
    (rolling_people_vaccinated * 1.0 / population) * 100 AS vaccination_percentage
FROM 
    #PercentPopulationVaccinated
ORDER BY 
    location, 
    date;

--Creating View to store data fro later visualisations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(CONVERT(int,vac.new_vaccinations)) Over (partition by dea.location Order by dea.location, dea.Date)as RollingPeopleVaccinated
FROM 
    portfolioProject..CovidDeaths dea
JOIN 
    portfolioProject..CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL 
--ORDER BY 1,2


Select *
From PercentPopulationVaccinated







