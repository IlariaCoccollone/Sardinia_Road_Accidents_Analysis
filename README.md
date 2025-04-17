# Sardinia_Road_Accidents_Analysis
A Data Management Project focused on analyzing road accidents in Sardinia (2018–2022), integrating ISTAT and OpenStreetMap data.

## Abstract
A Data Management Project focused on analyzing road accidents in Sardinia (2018–2022), integrating ISTAT and OpenStreetMap data. Through a complete pipeline involving acquisition, integration, quality assessment, and enrichment, the project explores the relationship between road infrastructure and accident patterns, highlighting data quality challenges and their impact on public safety.

## File Structure 📁

1. **[Data](./Data)**  
   - **Dataset_incidenti_completi_ISTAT**: Contains 5 datasets (2018-2022) from ISTAT on road accidents in Italy.
   - **Dataset_incidenti_Sardegna_ISTAT**: Contains 5 datasets (2018-2022) on road accidents specifically for Sardinia.
   - **Significato_Categorie_Variabili**: Contains metadata that explains the encoded variables in the datasets.

2. **[Accidents_Sardinia.ipynb](./Accidents_Sardinia.ipynb)**: Python script that contains:
   - Data integration process for the 5 datasets and the data obtained from the Overpass API.
   - Data preparation, enrichment, and quality assessment before storing the data in the database.

3. **[Accidents_Sardinia_clean.csv](./Accidents_Sardinia_clean.csv)**: The cleaned CSV file obtained from the data preparation process, ready to be loaded into the database.

4. **[Data_Storage](./Data_Storage)**  
   - **Accidents_Sardinia_script.sql**: SQL script for creating database tables, running queries for analysis, and performing final data quality verification.
   - **Accidents_Sardinia.db**: The database containing the processed road accidents data for Sardinia.
   - **Accidents_Sardinia.sqbpro**: Data storage project file.

5. **[Road_Accidents_report.pdf](./Road_Accidents_report.pdf)**: The final report summarizing the findings, data analysis, and insights.

## How to Use the Project 🛠️

1. **Preprocess the Data in Python**:  
   Run the Python script `Accidents_Sardinia.ipynb` for the data integration, preparation, enrichment, and quality assessment processes.
   
2. **Load Data into SQL Database**:  
   Use the SQL script `Accidents_Sardinia_script.sql` to create the database tables and load the prepared data.

3. **Run Queries for Analysis**:  
   Use the same SQL script to run queries for analyzing the road accident data, based on different parameters and insights.

4. **View the Final Report**:  
   Read the `Road_Accidents_report.pdf` for the detailed analysis and conclusions based on the data.

## Author 👩🏻‍💻

**Name**: Ilaria Coccollone  
**Email**: i.coccollone@campus.unimib.it
