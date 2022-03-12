--Select *
--From PorfolioProject..CovidDeaths$
--Order by 3 , 4 

----This is for selecting data from CovidVaccination Table
--Select *
--From PorfolioProject..CovidVaccination$
--Order by 3, 4 

Select Location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject..CovidDeaths$
Order by 1,2 

Select Location, date, total_cases, new_cases, (total_deaths/total_cases)*100
From PorfolioProject..CovidDeaths$
Where location like '%Vietnam%'
Order by 1,2 

Select Location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentageInfection
From PorfolioProject..CovidDeaths$
--Where location like '%Vietnam%'
Group by Location, population
Order by PercentageInfection Desc


Select * 
FROM PorfolioProject..CovidDeaths$ dea
JOIN PorfolioProject..CovidVaccination$ vac
ON dea.date = vac.date 
and dea.location = vac.location

With PpvsVac (Location, Date, Continent, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.location, dea.date,dea.continent, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths$ dea
JOIN PorfolioProject..CovidVaccination$ vac
ON dea.date = vac.date 
and dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 1, 2
)

Select * 
FROM PpvsVac

Drop Table if exists #PeopleVaccinated
Create Table #PeopleVaccinated
(Location nvarchar(255),
 Date datetime,
 Continent nvarchar(255),
 Population numeric,
 New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PeopleVaccinated
Select dea.location, dea.date,dea.continent, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths$ dea
JOIN PorfolioProject..CovidVaccination$ vac
ON dea.date = vac.date 
and dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 1, 2

Select *, (RollingPeopleVaccinated/ Population *100) as PercentVaccinated
FROM #PeopleVaccinated

USE PorfolioProject
GO
Create View [dbo].[PeopleVaccinated1]  as
Select dea.location, dea.date,dea.continent, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths$ dea
JOIN PorfolioProject..CovidVaccination$ vac
ON dea.date = vac.date 
and dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 1, 2
GO

Select *, (RollingPeopleVaccinated/ Population *100) as PercentVaccinated
FROM #PeopleVaccinated
