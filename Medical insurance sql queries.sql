create database Healthcaredb;

CREATE Table Pateints(
id INT AUTO_INCREMENT PRIMARY KEY,
age INT,
sex VARCHAR(10),
bmi DECIMAL(5,2),
children INT,
smoker VARCHAR(10),
region VARCHAR(50),
charges DECIMAL(10,2)
);

LOAD DATA INFILE "C:\Users\prash\Downloads\Medical Insurance Dataset.csv"
INTO TABLE Pateints
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(age, sex, bmi, children, smoker, region, charges);

# Basic Data Exploration:
select count(*) from Pateints;

# Get the average age, BMI, and charges
select AVG(age) as avg_age, avg(bmi) as avg_bmi, avg(charges) as avg_charges from pateints;

#Find the average charges for smokers vs. non-smokers.
SELECT smoker, AVG(charges) AS avg_charges from pateints group by smoker;

#Analyze the relationship between BMI and charges.
select 
   case
       when bmi < 18.5 then 'Underweight'
       when bmi BETWEEN 18.5 AND 24.9 THEN 'Normal weight'
       when bmi BETWEEN 25 AND 29.9 THEN 'Overweight'
       else 'Obesity'
   END AS bmi_category,
   AVG(charges) AS avg_charges
from Pateints
group by bmi_category;

#Find out the region with the highest average charges.
select region, avg(charges) as avg_charges from pateints group by region order by avg_charges DESC limit 1; 


 #Correlation Between Age and Charges
select age, avg(charges) as avg_charges from pateints group by age order by age;

#Gender Distribution in Different Regions
SELECT region, sex, COUNT(*) AS count
FROM pateints
GROUP BY region, sex
ORDER BY region, sex;

#Top 10 Highest Medical Charges
select * from pateints order by charges DESC LIMIT 10;

#Charges Distribution by Number of Children
SELECT children, AVG(charges) AS avg_charges
FROM pateints
GROUP BY children
ORDER BY children;

#Region-wise Smoker Analysis
SELECT smoker, AVG(bmi) AS avg_bmi
FROM pateints
GROUP BY smoker;

#Age and Smoking Impact on Charges
SELECT region, smoker, COUNT(*) AS count
FROM pateints
GROUP BY region, smoker
ORDER BY region, smoker;

select age, charges, avg(charges) over(order by age rows between 2 predceding and 2 following) AS rolling_avg_charges
from pateints order by age;

#Identify patients with above-average charges for their region and rank them within their region.
WITH RegionalCharges AS (
    SELECT 
        region, 
        AVG(charges) AS avg_regional_charges
    FROM 
        pateints
    GROUP BY 
        region
),
RankedPateints AS (
    SELECT 
        p.*,
        rc.avg_regional_charges,
        RANK() OVER (PARTITION BY p.region ORDER BY p.charges DESC) AS rank_in_region
    FROM 
        pateints p
    JOIN 
        RegionalCharges rc 
    ON 
        p.region = rc.region
    WHERE 
        p.charges > rc.avg_regional_charges
)
SELECT 
    region,
    charges,
    avg_regional_charges,
    rank_in_region
FROM 
    RankedPateints
ORDER BY 
    region, rank_in_region;
    
 #Find the top 3 regions with the highest average charges, including the average BMI of patients in those regions.
select region, avg(charges) as avg_charges,(select avg(bmi) from pateints where region = p.region) as avg_bmi
from pateints p group by region order by avg_charges desc limit 3; 


#Pivot the data to show average charges for smokers and non-smokers across different regions.
SELECT 
    region,
    AVG(CASE WHEN smoker = 'yes' THEN charges END) AS avg_charges_smokers,
    AVG(CASE WHEN smoker = 'no' THEN charges END) AS avg_charges_non_smokers
FROM 
    pateints
GROUP BY 
    region;
    
# Find all patients who live in a region where at least one smoker has medical charges exceeding $20,000.
SELECT 
    region,
    charges
FROM 
    pateints p
WHERE 
    EXISTS (
        SELECT 
            1 
        FROM 
            pateints sub_p 
        WHERE 
            sub_p.region = p.region 
            AND sub_p.smoker = 'yes' 
            AND sub_p.charges > 20000
    );




