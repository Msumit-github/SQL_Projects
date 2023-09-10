select *
From [Portfolio Project]..['Covid Deaths']
order by 3,4

-- select *
-- from [Portfolio Project]..['Covid Vaccination']
-- order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..['Covid Deaths']
order by 1,2

-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..['Covid Deaths']
order by 1,2

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..['Covid Deaths']
Where location = 'India'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of people got covid

select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentageOverPopulation
from [Portfolio Project]..['Covid Deaths']
Where location = 'India'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/Population))*100 as PercentPopulationInfected
from [Portfolio Project]..['Covid Deaths']
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with highest death count
select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..['Covid Deaths']
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's look at things by Continent

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..['Covid Deaths']
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..['Covid Deaths']
where continent is not null
Group by date
order by 1,2

Select *
From [Portfolio Project]..['Covid Vaccination']

Select *
From [Portfolio Project]..['Covid Deaths'] as dea
Join [Portfolio Project]..['Covid Vaccination'] as vac
    On dea.location = vac.location
    and dea.date = vac.date

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project]..['Covid Deaths'] as dea
Join [Portfolio Project]..['Covid Vaccination'] as vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..['Covid Deaths'] as dea
Join [Portfolio Project]..['Covid Vaccination'] as vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..['Covid Deaths'] as dea
Join [Portfolio Project]..['Covid Vaccination'] as vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp Table

Create Table #Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..['Covid Deaths'] as dea
Join [Portfolio Project]..['Covid Vaccination'] as vac
    On dea.location = vac.location
    and dea.date = vac.date

select *, (RollingPeopleVaccinated/population)*100
From #Population_Vaccinated

-- Creating View to store data for later visualisations 

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) Over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..['Covid Deaths'] as dea
Join [Portfolio Project]..['Covid Vaccination'] as vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated