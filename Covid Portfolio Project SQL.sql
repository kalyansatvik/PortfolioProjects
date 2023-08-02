
Select location, date, total_cases, new_cases, total_deaths, 
population
From CovidDeaths
Order By 1,2

--ALTER TABLE CovidDeaths
--ALTER COLUMN total_cases float;

--ALTER TABLE CovidDeaths
--ALTER COLUMN total_deaths float;

-- total cases vs total deaths
Select location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where Location Like '%states%'
Order By 1,2

-- total cases vs population
Select location, date, population, total_cases, 
(total_cases/population)*100 as InfectionPercentage
From CovidDeaths
Where Location Like '%states%'
Order By 1,2

-- Looking at Highest infection rate compared to population
Select location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, 
MAX((total_cases/population)*100) as PopulationInfectedPercentage
From CovidDeaths
--Where Location Like '%states%'
Group By location, population
Order By PopulationInfectedPercentage desc

-- Looking at Highest Death count per population
Select location, population, MAX(total_deaths) as HighestDeathCount, 
MAX((total_deaths/population)*100) as PopulationDeathPercentage
From CovidDeaths
--Where Location Like '%states%'
Where continent is Not Null -- to get rid of continent level data in countries
Group By location, population
Order By PopulationDeathPercentage desc

-- Looking at Total cases Vs Total Deaths by date
Select date, SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths
from CovidDeaths
Group By date
Order by date desc

-- Looking at overall Total cases Vs Total Deaths and DeathPercentage
Select SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths,
(SUM(cast( new_deaths As int))/SUM(new_cases)) * 100 as OverallDeathPercentage
from CovidDeaths

-- Looking at the total population vs Total vaccination
Select dea.population, vac.total_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date

-- Use CTE Population Vs total vaccinations

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

-- run the CTE with WITH and SELECT statements together
/*
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	It is used to get total cases accumulated by location and date wise
*/

/*Arithmetic overflow error converting expression to data type int. 
Warning: Null value is eliminated by an aggregate or other SET operation.
Fix this issue by converting the column with bigint data type - CAST(vac.new_vaccinations as bigint)*/

-- TEMP Table
DROP Table if Exists #PercentagePeopleVaccinated
Create Table #PercentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3 --order by is not allowed

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePeopleVaccinated

-- CREATE VIEW - It is permanent table which will be used in visualizations
-- View will be present in PortfolioProject --> Views
Create View PercentagePeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2,3 --order by is not allowed

Select * from PercentagePeopleVaccinated























