SELECT *
FROM project1.dbo.CovidDeaths$


SELECT *
FROM project1.dbo.CovidVaccinations$

--select data that we are going to use
SELECT location, date, population, total_cases, total_deaths 
From project1.dbo.CovidDeaths$
ORDER BY 3 

--Looking at total cases vs total deaths
Select location,date,population,total_cases,total_deaths,(total_deaths/total_cases) as DeathsvsCases
From project1.dbo.CovidDeaths$
where location='Unites States'
order by 2

--Looking at Total Cases vs Population
Select location,date,population,total_cases,total_deaths,(total_cases/population) as cases_percentage
From project1.dbo.CovidDeaths$
where location='United States'
order by 2

--Looking at Total deaths vs Population
Select location,date,population,total_cases,total_deaths,(total_deaths/population) as deaths_percentage
From project1.dbo.CovidDeaths$
where location='United States'
order by 2

--Looking for the countries with highest infection rate compared to population
Select location,max(total_cases) as M_cases, population,(Max(total_cases)/population)*100 as cases_percentage
From project1.dbo.CovidDeaths$
group by population,location
order by cases_percentage desc

--Looking for countries with highest death rate compared to population
Select location,max(total_deaths) as M_deaths, population,(Max(total_deaths)/population)*100 as deaths_percentage
From project1.dbo.CovidDeaths$
where continent is not null
group by population,location
order by deaths_percentage desc

--looking for total deaths in each continent
Select continent,max(cast(total_deaths as int)) as deaths,sum(population) as population_continent, max(cast(total_deaths as int))/sum(population) as percentage
From project1.dbo.CovidDeaths$
where continent is  not null
group by continent
order by 4 desc

--looking total deaths and cases for each day in entire world.
select date, sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100) as percentage
from project1.dbo.CovidDeaths$
where continent is not null
group by date
order by date desc

--Joining two tables with location and date based
Select * 
From project1.dbo.CovidDeaths$ as deaths
join project1.dbo.CovidVaccinations$ as vaccin
on deaths.location = vaccin.location
and deaths.date = vaccin.date
order by deaths.date desc

--Looking for total cases and totalvaccinations with respective to date
Select deaths.Location,deaths.population,deaths.total_cases,vaccin.total_vaccinations
From project1.dbo.CovidDeaths$ as deaths
join project1.dbo.CovidVaccinations$ as vaccin
on deaths.location = vaccin.location
and deaths.date = vaccin.date
where deaths.continent is not null
order by deaths.date desc

--Looking for total cases and total vaccinations eith respective to location
Select deaths.Location,deaths.population,max(deaths.total_cases) as Cases,max(vaccin.total_vaccinations) as Vaccinations
From project1.dbo.CovidDeaths$ as deaths
join project1.dbo.CovidVaccinations$ as vaccin
on deaths.location = vaccin.location
where deaths.continent is not null
group by deaths.location, deaths.population

--Looking for percentage of vacinnations taken based on population and cases in each location
Select deaths.Location,deaths.population,max(deaths.total_cases) as Cases,max(vaccin.total_vaccinations) as Vaccinations,
max(vaccin.total_vaccinations)/max(deaths.total_cases) as vaccin_to_cases,max(vaccin.total_vaccinations)/deaths.population as vaccin_to_population 
From project1.dbo.CovidDeaths$ as deaths
join project1.dbo.CovidVaccinations$ as vaccin
on deaths.location = vaccin.location
where deaths.continent is not null
group by deaths.location, deaths.population
order by 6 desc

--Looking for percentage of vaccinnations based on date
Select deaths.location, deaths.date, deaths.total_cases, vaccin.new_vaccinations,vaccin.total_vaccinations
From project1.dbo.CovidDeaths$ as deaths
join project1.dbo.CovidVaccinations$ as vaccin
on deaths.location = vaccin.location and
deaths.date = vaccin.date
where deaths.location='india'


--Looking at total vaccinations
Select deaths.continent,deaths.location,deaths.date,deaths.population,vaccin.new_vaccinations,
SUM(CONVERT(int,vaccin.new_vaccinations)) OVER (Partition by deaths.location
order by deaths.location, deaths.date) as vaccinations
From project1.dbo.CovidDeaths$ as deaths
join project1.dbo.CovidVaccinations$ as vaccin
on deaths.location = vaccin.location and
deaths.date = vaccin.date
where deaths.continent is not null
order by 2,3

--Create CTE

with CTE_Table(continent,location,date,population,new_vacc,vacc) as (
Select deaths.continent,deaths.location,deaths.date,deaths.population,vaccin.new_vaccinations,
SUM(CONVERT(int,vaccin.new_vaccinations)) OVER (Partition by deaths.location
order by deaths.location, deaths.date) as vaccinations
From project1.dbo.CovidDeaths$ as deaths
join project1.dbo.CovidVaccinations$ as vaccin
on deaths.location = vaccin.location and
deaths.date = vaccin.date
where deaths.continent is not null
)
Select location,vacc from CTE_Table

--Looking to create temporary table
Drop table IF EXISTS #stat_table
Create table #stat_table( continent varchar(20), location varchar(200), population int)

Insert into #stat_table
Select deaths.continent,deaths.location,deaths.date,deaths.population
From project1.dbo.CovidDeaths$ as deaths
join project1.dbo.CovidVaccinations$ as vaccin
on deaths.location = vaccin.location and
deaths.date = vaccin.date
--where deaths.continent is not null
Select * from #stat_table


--Looking to create view to store required set of table
CREATE VIEW stat as 
Select deaths.continent,deaths.location,deaths.date,deaths.population,vaccin.new_vaccinations,
SUM(CONVERT(int,vaccin.new_vaccinations)) OVER (Partition by deaths.location
order by deaths.location, deaths.date) as vaccinations
From project1.dbo.CovidDeaths$ as deaths
join project1.dbo.CovidVaccinations$ as vaccin
on deaths.location = vaccin.location and
deaths.date = vaccin.date
where deaths.continent is not null

select * from stat

 























