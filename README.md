# 📁 COVID-19 Data Analysis with SQL

**Analyse des données COVID-19** pour explorer les tendances de décès et de vie , de cas confirmés et de vaccinations à travers le monde.

---

## 📦 **Dataset**  
- **Source**: [Our World in Data](https://ourworldindata.org/covid-deaths)  
- **Tables utilisées** :  
  - `CovidDeaths` : Décès, cas, et population par pays/date.  
  - `CovidVaccinations` : Vaccinations, doses administrées.  

---

## 🔎 **Exemples d'analyses**  

### 1. **Taux de mortalité par pays**  
```sql
SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    (total_deaths * 100.0 / total_cases) AS death_rate
FROM CovidDeaths
WHERE continent IS NOT NULL;
