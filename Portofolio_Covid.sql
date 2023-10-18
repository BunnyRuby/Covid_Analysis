Select *
From PortfolioProject.dbo.CovidDeaths
Order by 3, 4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--Order by 3, 4


-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

SELECT *
INTO PortfolioProject..CovidDeaths_tc_nn
FROM PortfolioProject..CovidDeaths
WHERE total_cases is not null

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths_tc_nn
order by 1, 2

-- Looking at total cases vs total deaths
-- Shows likelihood of you contract covid in your country
Select Location, date, total_cases, total_deaths, (CONVERT(DECIMAL(18, 2), total_deaths) / CONVERT(DECIMAL(18, 2), total_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths_tc_nn
where location like '%states%'
order by 1, 2



-- Looking at total cases vs population
-- Shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths_tc_nn
where location like '%states%'
order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths_tc_nn
-- where location like '%states%'
group by Location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths_tc_nn
-- where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc


-- Let's Break Things Down by Continent


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths_tc_nn
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc



-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths_tc_nn
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc



--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths_tc_nn
where continent is not null
order by 1, 2



--  Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths_tc_nn dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths_tc_nn dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(Convert(bigint, vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths_tc_nn dea
join PortfolioProject..CovidVaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Create View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(Convert(bigint, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths_tc_nn dea
Join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated