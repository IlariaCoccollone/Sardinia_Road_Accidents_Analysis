/*----------------------------------DATABASE CREATION AND SQL DATA MODELING----------------------------------*/
-----import csv in a unique table called "Accidents_Sardinia_clean" (removed at the end of the creation)-----
/*

 SELECT *
FROM Accidents_Sardinia_clean; 

#-----Creation of the 4 Tables-----

CREATE TABLE incidenti (
    id_incidente INTEGER PRIMARY KEY AUTOINCREMENT,
    anno INT NOT NULL,
    provincia VARCHAR(50) NOT NULL,
    tipo_strada VARCHAR(100),
    tipo_carreggiata VARCHAR(100),
    punto_incidente VARCHAR(100),
    segnaletica VARCHAR(100),
    condizioni_meteorologiche VARCHAR(50),
    natura_incidente VARCHAR(100),
    altri_veicoli_coinvolti INT,
    morti_entro_24_ore INT,
    morti_entro_30_giorni INT,
    feriti INT,
    Ora INT,
    trimestre INT
);

CREATE TABLE infrastrutture (
    provincia VARCHAR(50) PRIMARY KEY,
    hospital INT DEFAULT 0,
    police INT DEFAULT 0,
    school INT DEFAULT 0
);

CREATE TABLE province (
    provincia VARCHAR(50),
    anno INT,
    popolazione INT,
    PRIMARY KEY (provincia, anno)
);

CREATE TABLE veicoli_circolanti (
    provincia VARCHAR(50),
    anno INT,
    parco_veicolare INT,
    PRIMARY KEY (provincia, anno)
); 

-----Populating the Tables-----
INSERT INTO incidenti (
    anno, provincia, tipo_strada, tipo_carreggiata, punto_incidente, segnaletica, 
    condizioni_meteorologiche, natura_incidente, altri_veicoli_coinvolti, 
	morti_entro_24_ore, morti_entro_30_giorni, feriti, Ora, trimestre
)
SELECT 
    anno, provincia, tipo_strada, tipo_carreggiata, punto_incidente, segnaletica, 
    condizioni_meteorologiche, natura_incidente, altri_veicoli_coinvolti, 
	morti_entro_24_ore, morti_entro_30_giorni, feriti, Ora, trimestre
FROM Accidents_Sardinia_clean;

INSERT INTO infrastrutture (provincia, hospital, school, police)
SELECT DISTINCT provincia, hospital, school, police
FROM Accidents_Sardinia_clean; 

INSERT INTO province (provincia, anno, popolazione)
SELECT DISTINCT provincia, anno, popolazione_provincia
FROM Accidents_Sardinia_clean;

INSERT INTO veicoli_circolanti (provincia, anno, parco_veicolare)
SELECT DISTINCT provincia, anno, parco_veicolare
FROM Accidents_Sardinia_clean;

*/
/*LAST DATA QUALITY CHECK*/
---1 COMPLETENESS
---Check missing values in each table for each column
SELECT *
FROM incidenti 
WHERE anno IS NULL  OR provincia IS NULL  OR tipo_strada IS NULL 
OR tipo_carreggiata IS NULL OR punto_incidente IS NULL OR segnaletica IS NULL
OR condizioni_meteorologiche IS NULL OR natura_incidente IS NULL
OR altri_veicoli_coinvolti IS NULL OR morti_entro_24_ore IS NULL
OR morti_entro_30_giorni IS NULL OR feriti IS NULL OR Ora IS NULL OR trimestre IS NULL;
---complete, no lines in the result

SELECT *
FROM infrastrutture 
WHERE provincia IS NULL  OR hospital IS NULL  
OR school IS NULL  OR police IS NULL;
---complete, no lines in the result 
  
 SELECT *
FROM province 
WHERE provincia IS NULL  OR anno IS NULL  
OR popolazione IS NULL; 
---complete, no lines in the result 

 SELECT *
FROM veicoli_circolanti 
WHERE provincia IS NULL  OR anno IS NULL  
OR parco_veicolare IS NULL; 
---complete, no lines in the result 

---2 SEMANTIC ACCURACY
---Check for semantic accuracy: no negative values in death or injury columns  
---Ensures that deaths and injuries have realistic, non-negative values
SELECT *
FROM incidenti
WHERE morti_entro_24_ore < 0 
   OR morti_entro_30_giorni < 0 
   OR feriti < 0;
---accurate, no lines in the result
   
---3️ CONSISTENCY
---Check for inconsistencies ( deaths within 24 hours should not exceed deaths within 30 days)
---This ensures that 'morti_entro_24_ore' is never greater than 'morti_entro_30_giorni'. 
SELECT *
FROM incidenti
WHERE morti_entro_24_ore > morti_entro_30_giorni; 
---consistent, no lines in the result

---Check for inconsistent province names
---This query helps detect types or unexpected province names.
SELECT DISTINCT provincia
FROM province
ORDER BY provincia;
---consistent, no unexpected provincial names

---Check data consistency over time
-- Count incidents per year to check for anomalies
SELECT anno, COUNT(*) AS incident_count
FROM incidenti
GROUP BY anno
ORDER BY anno;

---Check data consistency over time
-- Count incidents per trimestre to check for anomalies
SELECT trimestre, COUNT(*) AS incident_count
FROM incidenti
GROUP BY trimestre
ORDER BY trimestre;

---4) CURRENCY
-- Check how recent the latest available data is
SELECT 
    MAX(anno) AS latest_year,
    2025 - MAX(anno) AS years_outdated
FROM incidenti;
----ISTAT has published data only up to 2022, and the most recent two years are not yet available.


/*----------------------------------QUERIES FOR THE ANALYSIS----------------------------------*/

-- This query provides a general overview of the total number of accidents per province, 
--helping identify the province with the highest number of incidents.
SELECT provincia, count(id_incidente) AS total_accidents
FROM incidenti
GROUP BY provincia;

-- 1) This query provides an overview of road accidents 
--by province and year, including total accidents, deaths, injuries, and fatality rates.
SELECT 
    i.provincia,
    COUNT(i.id_incidente) AS total_incidents,  -- Total number of accidents
    SUM(i.morti_entro_24_ore) AS total_deaths_24h,  -- Total deaths within 24 hours
    SUM(i.feriti) AS total_injuries,  -- Total number of injuries
    -- Fatality rate per accident (percentage of accidents resulting in at least one death)
    (SUM(i.morti_entro_24_ore) * 100.0 / NULLIF(COUNT(i.id_incidente), 0)) AS fatality_rate_per_incident,
    -- Fatality rate per injured (percentage of deaths compared to total injuries + deaths)
    (SUM(i.morti_entro_24_ore) * 100.0 / NULLIF(SUM(i.feriti) + SUM(i.morti_entro_24_ore), 0)) AS fatality_rate_per_injured
FROM incidenti i
GROUP BY  i.provincia
ORDER BY  i.provincia;

-- 2) This query retrieves the number of hospitals, police stations, and schools in each province, 
-- along with their distribution per 100,000 inhabitants,
-- using the most recent population data available.
SELECT 
    i.provincia,
    p.popolazione,
    i.hospital AS total_hospitals,
    i.police AS total_police_stations,
    i.school AS total_schools,
    -- Number of infrastructures for 100.000 inhabitants
    (i.hospital * 100000.0 / NULLIF(p.popolazione, 0)) AS hospitals_per_100k_population,
    (i.police * 100000.0 / NULLIF(p.popolazione, 0)) AS police_per_100k_population,
    (i.school * 100000.0 / NULLIF(p.popolazione, 0)) AS schools_per_100k_population
FROM infrastrutture i
LEFT JOIN (
    SELECT provincia, MAX(anno) AS latest_year, popolazione
    FROM province
    GROUP BY provincia
) p ON i.provincia = p.provincia
ORDER BY i.provincia;

--3)  This query counts and ranks accidents by weather conditions.
SELECT 
    condizioni_meteorologiche,
    COUNT(id_incidente) AS total_incidents
FROM incidenti
GROUP BY condizioni_meteorologiche
ORDER BY total_incidents DESC;

-- 4) This query displays the number of accidents (2018-2022) without signage per province,  
-- calculating the percentage relative to the total accidents in each province.  
SELECT 
    provincia, 
    COUNT(*) AS incidenti_senza_segnaletica,
    (COUNT(*) * 100.0) / NULLIF((SELECT COUNT(*) FROM incidenti i2 WHERE i2.provincia = i1.provincia), 0) AS percentuale_incidenti
FROM incidenti i1
WHERE segnaletica = 'Assente'
GROUP BY provincia
ORDER BY percentuale_incidenti DESC;

-- 5) This query identifies where most accidents occur, showing total accidents, 
--deaths within 24 hours, injuries, and the percentage of fatal and injury accidents per location.
SELECT 
    punto_incidente, 
    COUNT(*) AS total_accidents, 
    SUM(morti_entro_24_ore) AS total_deaths_24h,
    SUM(feriti) AS total_injuries,
    (SUM(morti_entro_24_ore) * 100.0 / COUNT(*)) AS death_rate_percentage,
    (SUM(feriti) * 100.0 / COUNT(*)) AS injury_rate_percentage
FROM incidenti
GROUP BY punto_incidente; 

