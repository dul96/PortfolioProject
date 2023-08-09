select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_presentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--looking at total cases vs population
--shows what presentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as cases_presentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1, 2

--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as infection_presentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by infection_presentage desc

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by highest_death_count desc

--let's break things down by continent
--showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as highest_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by highest_death_count desc

--global numbers
select date, SUM(new_cases) as total_case, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as new_death_presentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--lookig at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Using CTC
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
select *, (rolling_people_vaccinated/population)*100
from PopvsVac

--Temp Table
drop table if exists #PresentPopulationVaccinated
create table #PresentPopulationVaccinated(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #PresentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (rolling_people_vaccinated/population)*100
from #PresentPopulationVaccinated

--creating view to store data for later visualizations
create view PresentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PresentPopulationVaccinated