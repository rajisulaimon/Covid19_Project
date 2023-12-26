-- create a database from csv file
DROP TABLE IF EXISTS Covid
CREATE TABLE Covid as
select * FROM read_csv_auto('C:\Users\Sulaimon\OneDrive\Documents\covidDealth.csv')


-- view all data in the database order by location and date
SELECT * from main.Covid 
order by 3,4

-- select  the united state data
select location,date,total_cases,total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage,population
from covid
where location like '%States%'
order by 1,2

-- check population and case
SELECT location,date, total_cases, population, (total_cases/population)*100 as Case_Percentage,
from main.Covid 
WHERE location like '%States%' and total_cases is not NULL 
order by 1,2


-- looking for the highest infection rate and population
SELECT location,population, max(total_cases) as HigestInfections,max((total_cases/population)) *100 as PercentpopulationInfections
from covid
where continent is not NULL 
group by location, population
order by PercentpopulationInfections desc


-- Showing the country the highest deaths rate compare to population
SELECT location,max(total_deaths) as HighestDeath, round(max(total_deaths/total_cases) * 100,2) as HighestDeathPErcentage from covid 
where continent is not NULL 
group by location
order by HighestDeath desc


-- showing the continent with the highest infection rate
SELECT continent, max(total_cases) as HighestCases,round(max(total_cases/population) * 100,2) as PercentageInfectionContinent from covid
where continent is not NULL 
group by continent
order by PercentageInfectionContinent desc

-- showing the continent with the highest date rate
select continent, max(total_deaths) as HighestDeath, round(max(total_deaths/total_cases)*100,2) as HighestDeathPercentage 
from covid
where continent is not NULL 
GROUP BY continent
order by HighestDeath desc


--Glober numbers
SELECT date, sum(new_cases)as total_cases, sum(new_deaths) as total_deaths, round(sum(new_cases)/sum(new_deaths) * 100,2) as DeathPercentage from covid
where continent is not null
group by date
order by 2 desc


--select global numbers
select  sum(new_cases)as total_cases, sum(new_deaths) as total_deaths, round(sum(new_cases)/sum(new_deaths) * 100,2) as DeathPercentage from covid
where continent is not null



-- Drop vaccination table if exists
DROP TABLE IF EXISTS covidVaccine
-- create vaccination table 
CREATE TABLE covidVaccine as
select * from read_csv_auto('C:\Users\Sulaimon\Downloads\covidVaccination.csv')

--Joining data in deaths and vaccination table
SELECT * from main.covid dea join 
covidVaccine vac 
on dea.location = vac.location and dea."date" = vac.date



-- Looking at total Population and Vaccinatin using cte 
WITH popVac (Location,Date,Population,New_case,RollingCase,Vaccination,RollingVaccination)
as
(
select dea.location, dea.date, dea.population,dea.new_cases,
sum(new_cases) over (PARTITION by vac.location order by dea.location,dea.date) as RollingCase,
vac.new_vaccinations,
sum(new_vaccinations) over (PARTITION by vac.location order by dea.location,dea.date) as RollingVaccinations,
from covid dea
join covidVaccine vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2
)
--read all data in the popVac temp
select *, (RollingVaccination/population)  from popVac



-- aggregakting case and death
SELECT sum(new_cases) as total_case,sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage from covid
where continent is not null

--Drop temp table if exists
Drop TEMP TABLE IF EXISTS PopulationVaccination
-- using a temp table
Create TEMP Table PopulationVaccination(
location nvarchar(255),
Date datetime,
Population numeric,
New_case numeric,
RollingCase numeric,
Vaccination numeric,
RollingVaccination numeric
)
-- Insert the data to the temp table
Insert INTO PopulationVaccination
select dea.location, dea.date, dea.population,dea.new_cases,
sum(new_cases) over (PARTITION by vac.location order by dea.location,dea.date) as RollingCase,
vac.new_vaccinations,
sum(new_vaccinations) over (PARTITION by vac.location order by dea.location,dea.date) as RollingVaccinations,
from covid dea
join covidVaccine vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2
SELECT * from PopulationVaccination








