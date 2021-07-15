/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

--------------------------------------------------------------------------------------------------------------------------


select *
from coviddeaths_csv 
where continent is not null 
order by 3, 4

select location , total_cases , new_cases , total_deaths , population 
from coviddeaths_csv 
order by 1 ,2

--------------------------------------------------------------------------------------------------------------------------


/*Looking at Total Cases vs Total Deaths*/

select location , `date` ,total_cases , total_deaths , 
	(total_cases/population)*100 as death_percentage
from coviddeaths_csv 
where location = 'Afghanistan'
order by 1 ,2

--------------------------------------------------------------------------------------------------------------------------


/*Looking at Total Cases vs Population*/

select location , `date` , population ,total_cases , total_deaths , (total_cases/population)*100 as death_percentage
from coviddeaths_csv 
where location = 'Africa'
order by 1 ,2

--------------------------------------------------------------------------------------------------------------------------


/*Looking at Countries with Highest Infection rate compared to Population*/

select location , population , max(total_cases) , 
		max(total_cases/population)*100 as percent_population_infected
from coviddeaths_csv 
group by location, population 
order by percent_population_infected desc 

--------------------------------------------------------------------------------------------------------------------------


/*Showing Countries with Highest Death Count per Population*/

select location , sum(total_deaths) as total_death_count
from coviddeaths_csv 
where continent  is not null 
group by location 
order by total_death_count desc 

--------------------------------------------------------------------------------------------------------------------------


/*BREAKING THINGS DOWN BY CONTINENT

Showing contintents with the highest death count per population*/

Select continent, MAX(cast(Total_deaths as int)) as total_death_count
From coviddeaths_csv
Where continent is not null 
Group by continent
order by total_death_count desc

--------------------------------------------------------------------------------------------------------------------------


/*GLOBAL NUMBERS*/

select `date` , sum(new_cases) as total_cases , sum(new_deaths) total_deaths ,
	sum(new_deaths)/sum(new_cases)*100 as new_death_percentage
from coviddeaths_csv 
where continent is not null  
group by `date` 

--------------------------------------------------------------------------------------------------------------------------


/*Looking at Total Population vs Vaccination*/

select cd.continent , cd.location , cd.`date` , cd.population, cv.new_vaccinations 
from coviddeaths_csv cd 
join covidvacinations_csv cv
	on cd.location = cv.location 
		and cd.`date` = cv.`date` 
where cv.new_vaccinations is not null 

--------------------------------------------------------------------------------------------------------------------------


/*Using CTE*/

with PopsVsVacc (Continent, Location, Date, New_Vaccination, RollingPeopleVaccinated)
as 
(
select cd.continent , cd.location , cd.`date` , cv.new_vaccinations, 
	sum(cast (cv.new_vaccinations as int)) OVER
	(partition by cd.location order by cd.location, cd.`date`) 
	as rolling_people_vaccinated,
	(rolling_people_vaccinated/population)*100 
from coviddeaths_csv cd 
join covidvacinations_csv cv
	on cd.location = cv.location 
	and cd.`date` = cv.`date` 
where cv.new_vaccinations is not null
)

select *, (RollingPeopleVaccinated/Population)*100 as vaccination_percentage
from PopsVsVacc

--------------------------------------------------------------------------------------------------------------------------


/*TEMP TABLE*/

drop table if exists percentage_population_vaccinated
create temporary table percentage_population_vaccinated
(
Continent varchar(255), 
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into percentage_population_vaccinated
select cd.continent , cd.location , cd.`date` , cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER(partition by cv.location order by cv.location ,cv.`date` desc)
	as rolling_people_vaccinated
from coviddeaths_csv cd 
join covidvacinations_csv cv
	on cd.location = cv.location 
	and cd.`date` = cv.`date` 
where cv.new_vaccinations is not null

select *, (RollingPeopleVaccinated/Population)*100 as vaccination_percentage
from percentage_population_vaccinated

--------------------------------------------------------------------------------------------------------------------------


/*Creating View to store data for later visualization*/

create view percentage_population_vaccinated as
select cd.continent , cd.location , cd.`date` , cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER(partition by cv.location order by cv.location ,cv.`date` desc)
	as rolling_people_vaccinated
from coviddeaths_csv cd 
join covidvacinations_csv cv
	on cd.location = cv.location 
	and cd.`date` = cv.`date` 
where cv.new_vaccinations is not null

--------------------------------------------------------------------------------------------------------------------------

