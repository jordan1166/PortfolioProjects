select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4


-- Select the data that I am going to use
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


-- Total cases vs Total deaths in each country
-- Show the likelihood of dying if you contract covid in a particular country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total cases vs Population
-- Show what percentage of the population has contracted covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
order by 1,2


-- Countries with the highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


-- Countries with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


-- Organize data by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2

-- Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- use CTE
with PopvsVac (continent, location, data, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- use Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ as dea
join PortfolioProject..CovidVaccinations$ as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *
from PercentPopulationVaccinated