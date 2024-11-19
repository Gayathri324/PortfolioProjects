Select *
from PortfolioProject..covidDeath


---- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covidDeath
order by 1,2


---- Looking at Total cases vs Total Deaths
---- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/nullif(total_cases,0))*100 as DeathPercentage
from PortfolioProject..covidDeath
Where location like '%Kingdom%'
order by 1,2

---- Looking at Total cases vs Population
---- Show what percentage of population got covid

Select location, date, total_cases,population, (total_deaths/population)*100 as DeathPercentage
from PortfolioProject..covidDeath
Where location like '%Kingdom%'
order by 1,2

---- Looking at Countries with Highest Infection Rate compared to Population

Select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..covidDeath
--Where location like '%Kingdom%'
Group by location, population
Order by PercentagePopulationInfected desc

--- Showing Highest Death Count per Population

Select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeath
--Where location like '%Kingdom%'
Where continent is null
Group by location
Order by TotalDeathCount desc

---- LET'S BREAK THINGS DOWN BY CONTINENT

---- Showing continents with the Highest Death count per Population

Select continent ,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeath
--Where location like '%Kingdom%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

---- GLOBAL NUMBERS


Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/nullif(SUM(new_cases),0)*100 DeathPercentage
from PortfolioProject..covidDeath
Where continent is not null
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, SUM(convert(float, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  PortfolioProject..covidDeath dea
join PortfolioProject..covidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With popvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(convert(float, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  PortfolioProject..covidDeath dea
join PortfolioProject..covidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
)
 
Select *, (RollingPeopleVaccinated/nullif(population,0))*100
from popvsVac


--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(convert(float, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  PortfolioProject..covidDeath dea
join PortfolioProject..covidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/nullif(population,0))*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, 
SUM(convert(float, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  PortfolioProject..covidDeath dea
join PortfolioProject..covidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated

