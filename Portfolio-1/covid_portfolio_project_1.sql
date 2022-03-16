-- Select data that we are going to be using from coviddeaths table
Select location, date, total_cases,new_cases,total_deaths,population
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2;

-- Looking at the total cases vs total deaths 
Select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100  as death_percentage 
from PortfolioProject..coviddeaths
where location like '%zealand%' and continent is not null
order by 1,2;

-- Looking at the total cases vs population
-- Shows what % of the population got Covid
Select location, date,total_cases,population, (total_cases/population)*100  as percent_population_infected
from PortfolioProject..coviddeaths
where location like '%zealand%' and continent is not null
order by 1,2;

-- Looking at countries with highest infection rate compared to population
Select location, MAX(total_cases) as highest_infection_count,population, (MAX(total_cases)/population)*100  as percent_population_infected 
from PortfolioProject..coviddeaths
where continent is not null
group by location, population
order by percent_population_infected desc;

--Looking at the deaths count per population by country
Select location,MAX(CAST(total_deaths as Int)) as total_death_count
from PortfolioProject..coviddeaths
where continent is not null
group by location
order by total_death_count desc;

-- Let's break things down by continent

-- Showing the continents with the highest death count
Select continent,MAX(CAST(total_deaths as Int)) as total_death_count
from PortfolioProject..coviddeaths
where continent is not null
group by continent
order by total_death_count desc;

-- GLOBAL NUMBERS

Select  date,SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100  as death_percentage_globally 
from PortfolioProject..coviddeaths
where continent is not null
group by date
order by 1,2;

-- Joining tables
-- total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..covidvaccinations vac
join PortfolioProject..coviddeaths dea 
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3;

-- Use CTE
with popvsvac  (continent, location, date, population, new_vaccinations,rolling_people_vaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..covidvaccinations vac
join PortfolioProject..coviddeaths dea 
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

)
select *, (rolling_people_vaccinated/population)*100 as vaccination_rate
from popvsvac
order by 2, 3;

-- temp table
drop table if exists #percent_population_vaccinated;
Create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
data datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
Insert into #percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..covidvaccinations vac
join PortfolioProject..coviddeaths dea 
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null;

select *, (rolling_people_vaccinated/population)*100 as vaccination_rate
from #percent_population_vaccinated
order by 2, 3;


-- Creating Views for later data viz
create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..covidvaccinations vac
join PortfolioProject..coviddeaths dea 
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null;


select * 
from percent_population_vaccinated

