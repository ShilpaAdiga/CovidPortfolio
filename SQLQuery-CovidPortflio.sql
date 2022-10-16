select * from PortflioProject.dbo.Covid_deaths
where continent is not null;

--select * from PortflioProject.dbo.Covid_vaccinations;

--select the data we're going tpo use in this project
select location, date, total_cases, new_cases, total_deaths, population
from PortflioProject.dbo.Covid_deaths
where continent is not null
order by 1,2;


--looking at total cases vs total deaths ie Death percentage
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortflioProject.dbo.Covid_deaths
where continent is not null
order by 1,2;


--Looking at total cases vs population
select location, date, population,total_cases , (total_cases/population)*100 as PercentPopulationInfected
from PortflioProject.dbo.Covid_deaths
where location ='India' and  continent is not null
order by 1,2;

--looking at country with highest infection rate comared to the population
select location, population,max(total_cases) as HighestInfectionCount , max((total_cases/population))*100 as PercentPopulationInfected
from PortflioProject.dbo.Covid_deaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc;

select location, population,date, max(total_cases) as HighestInfectionCount , max((total_cases/population))*100 as PercentPopulationInfected
from PortflioProject.dbo.Covid_deaths
where continent is not null
group by location, population,date
order by PercentPopulationInfected desc;

--looking at the country with highest death count
select location, max(cast(total_deaths as INT)) as TotalDeathCount
from PortflioProject.dbo.Covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc;

--looking at the continet with  death count
select continent, max(cast(total_deaths as INT)) as TotalDeathCount
from PortflioProject.dbo.Covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc;

select location,max(cast(total_deaths as INT)) as TotalDeathCount
from PortflioProject.dbo.Covid_deaths
where continent is  null and location not in ('World','High income','Upper middle income','Lower middle income',
								'Europian Union','Low income','European Union','International')
group by location
order by TotalDeathCount desc;


--Global numbers
select   sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from PortflioProject.dbo.Covid_deaths
where continent is not null
order by 1,2;


--Dtaeth percentage in each date in the world
select   sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  (sum(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
from PortflioProject.dbo.Covid_deaths
where continent is not null
group by date
order by 1,2;


--Looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population,dea.total_cases, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated,

from PortflioProject.dbo.Covid_deaths dea
join PortflioProject.dbo.Covid_vaccinations vac
	on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3;

--total population vs vaccination using CTE
with PopvsVac (Continent, Location, Date, Population, New_vaccination,RollingPeopleVaccinated )
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortflioProject.dbo.Covid_deaths dea
join PortflioProject.dbo.Covid_vaccinations vac
	on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac;


--temp table
DROP Table if exists #PercentPeopleVaccinated;
create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortflioProject.dbo.Covid_deaths dea
join PortflioProject.dbo.Covid_vaccinations vac
	on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3)


select * , (RollingPeopleVaccinated/Population)*100
from #PercentPeopleVaccinated
order by 2,3;


--creating view to store data for visulaization later
create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortflioProject.dbo.Covid_deaths dea
join PortflioProject.dbo.Covid_vaccinations vac
	on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3)
