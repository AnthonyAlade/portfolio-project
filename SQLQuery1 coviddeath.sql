select *
from [portfolio project].[dbo].[CovidDeaths$]
order by location,date

select * 
from [portfolio project].[dbo].[CovidVaccinations$]
order by location,date

select location, date, total_cases,new_cases,total_deaths, population
from  [portfolio project].[dbo].[CovidDeaths$]
order by location, date
 
 -- looking at total cases vs total deaths
 -- shows likelyhood of dying if infected in your country
select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 death_percentage
from  [portfolio project].[dbo].[CovidDeaths$]
where location like '%nigeria%'
order by location, date

--looking at total cases vs populaion
--shows percentage that has covid
select location, date, total_cases,population ,( total_cases/population)* 100 percentageinfected
from  [portfolio project].[dbo].[CovidDeaths$]
where location like '%nigeria%'
order by location, date

--looking at countries with hghest infection rate compared to population
select location, max(total_cases) as maxinfected,population ,( max(total_cases)/population)* 100 maxpercentageinfected
from  [portfolio project].[dbo].[CovidDeaths$]
--where location like '%nigeria%'
group by location,population
order by maxpercentageinfected desc

--shows country with highest death count per country

select location, max(cast(total_deaths as int))as totaldeathcount
from  [portfolio project].[dbo].[CovidDeaths$]
where continent is not null
group by location
order by totaldeathcount desc

--Lets break things down by continent
-- showing continents with highest death count

select continent, max(cast(total_deaths as int))as totaldeathcount
from  [portfolio project].[dbo].[CovidDeaths$]
where continent is not null
group by continent
order by totaldeathcount desc

--Global Numbers

select  sum(new_cases) totalcases, sum(cast(new_deaths as int)) totaldeaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 deathpercentage
from  [portfolio project].[dbo].[CovidDeaths$]
where continent is not null
--group by date
order by sum(new_cases)



--Looking at the total population vs vaccination

--using CTE

with population_vs_vaccination(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select cd.continent,cd.location,cd.date, cd.population,
cv.new_vaccinations,sum(cast (cv.new_vaccinations as int)) 
over (partition by cd.location order by cd.date) as rollingpeoplevaccinated
from [portfolio project].[dbo].[CovidDeaths$] as CD
join [portfolio project].[dbo].[CovidVaccinations$] as CV
on CD.location = CV.location
AND CD.date = CV.date
where cd.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from population_vs_vaccination

--TEMP TABLE
drop table if exists #Percentpopulationvaccinated
CREATE TABLE #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingpeoplevaccinated numeric
)

insert into #Percentpopulationvaccinated
select cd.continent,cd.location,cd.date, cd.population,
cv.new_vaccinations,sum(cast (cv.new_vaccinations as int)) 
over (partition by cd.location order by cd.date) as rollingpeoplevaccinated
from [portfolio project].[dbo].[CovidDeaths$] as CD
join [portfolio project].[dbo].[CovidVaccinations$] as CV
on CD.location = CV.location
AND CD.date = CV.date
--where cd.continent is not null
--order by 2,3


--creating view to store data for later visualisations

create view percentpopulationvaccinated as
select cd.continent,cd.location,cd.date, cd.population,
cv.new_vaccinations,sum(cast (cv.new_vaccinations as int)) 
over (partition by cd.location order by cd.date) as rollingpeoplevaccinated
from [portfolio project].[dbo].[CovidDeaths$] as CD
join [portfolio project].[dbo].[CovidVaccinations$] as CV
on CD.location = CV.location
AND CD.date = CV.date
where cd.continent is not null
--order by 2,3

