--1. 
--a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS sum_total_claim_count
FROM prescription
GROUP BY npi
ORDER BY sum_total_claim_count DESC;
--1881634483, 199.414 claims

--b.Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, SUM(total_claim_count) AS sum_total_claim_count
FROM prescription
INNER JOIN prescriber USING(npi)
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY sum_total_claim_count DESC;

--2.
--a.Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description, SUM(total_claim_count) AS sum_total_claim_count
FROM prescription
INNER JOIN prescriber USING(npi)
GROUP BY specialty_description
ORDER BY sum_total_claim_count DESC;
--Family Practice, 39.009.388 claims

--b.Which specialty had the most total number of claims for opioids?
SELECT specialty_description, SUM(total_claim_count) AS sum_total_claim_count_opioid
FROM prescription
LEFT JOIN drug USING(drug_name)
LEFT JOIN prescriber USING(npi)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY sum_total_claim_count_opioid DESC;
--Nurse Practitioner, 7.206.760 claims

--c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
--d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. 
--Which speciatiles have a high percentage of opioids?

--3.
--a. Which drug (generic_name) had the highest total drug cost?
SELECT drug.drug_name, generic_name, SUM(total_drug_cost) AS sum_total_drug_cost
FROM prescription
INNER JOIN drug USING(drug_name)
GROUP BY drug.drug_name, generic_name
ORDER BY sum_total_drug_cost DESC;
--Pregabalin, $314583759

--b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT drug.drug_name, generic_name, ROUND((SUM(total_drug_cost))/(SUM(total_day_supply)),2) AS total_drug_cost_per_day
FROM prescription
LEFT JOIN drug USING(drug_name)
GROUP BY drug.drug_name, generic_name
ORDER BY total_drug_cost_per_day DESC;
--C1 esterase inhibitor, $3495.22/day

--4.
--a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for 
--those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug;

--b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT SUM(total_drug_cost) AS sum_total_drug_cost,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		 WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		 ELSE 'neither' END AS drug_type
FROM drug
RIGHT JOIN prescription USING(drug_name)
GROUP BY drug_type
ORDER BY sum_total_drug_cost DESC;
--More was spent on opioids.

--5.
--a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(cbsa)
FROM cbsa
WHERE cbsaname LIKE '%TN%';
--112

--b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, SUM(population) AS total_pop
FROM cbsa
LEFT JOIN population USING(fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY total_pop DESC;
--Nashville-Davidson_Murfreesboro--Franklin, TN is the largest with population of 7321640; Morristown, TN is smallest with population of 465408.

--c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT DISTINCT county, population
FROM population
LEFT JOIN fips_county USING(fipscounty)
LEFT JOIN cbsa USING(fipscounty)
WHERE cbsaname IS NULL
ORDER BY population DESC;
--Sevier county is the largest with population of 95523; Grundy county is the smallest with population of 13359.

--6.
--a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT npi, drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000
GROUP BY npi, drug_name, total_claim_count
ORDER BY npi;

--b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT npi, drug_name, total_claim_count, opioid_drug_flag
FROM prescription
INNER JOIN drug USING(drug_name)
WHERE total_claim_count >= 3000
GROUP BY npi, drug_name, total_claim_count, opioid_drug_flag;

--c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT nppes_provider_last_org_name, nppes_provider_first_name, drug_name, total_claim_count, opioid_drug_flag
FROM prescription
INNER JOIN drug USING(drug_name)
INNER JOIN prescriber USING(npi)
WHERE total_claim_count >= 3000
GROUP BY nppes_provider_last_org_name, nppes_provider_first_name, drug_name, total_claim_count, opioid_drug_flag
ORDER BY nppes_provider_last_org_name;

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will 
--have 637 rows.
--a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), 
--where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims 
--numbers yet.
SELECT npi, drug_name
FROM prescriber
CROSS JOIN drug 
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
GROUP BY npi, drug_name;
	
--b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the 
--number of claims (total_claim_count).
SELECT prescriber.npi, drug.drug_name, total_claim_count
FROM prescriber
CROSS JOIN drug 
FULL JOIN prescription ON (prescriber.npi, drug.drug_name) = (prescription.npi, prescription.drug_name)				  
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name, total_claim_count;
	
--c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT prescriber.npi, drug.drug_name, COALESCE(total_claim_count,0)
FROM prescriber
CROSS JOIN drug 
FULL JOIN prescription ON (prescriber.npi, drug.drug_name) = (prescription.npi, prescription.drug_name)				  
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name, COALESCE(total_claim_count,0);
	

--*BONUS*
--1. How many npi numbers appear in the prescriber table but not in the prescription table?
SELECT COUNT(prescriber.npi)
FROM prescriber
FULL JOIN prescription USING(npi)
WHERE prescription.npi IS NULL;
--8916

--2.
--a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.
SELECT generic_name, SUM(total_claim_count) AS sum_total_claim_count
FROM prescription
INNER JOIN prescriber USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY sum_total_claim_count DESC
LIMIT 5;
--Levothyroxine, Lisinopril, Atorvastatin, Amlodipine, Omeprazole

--b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT generic_name, SUM(total_claim_count) AS sum_total_claim_count
FROM prescription
INNER JOIN prescriber USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY sum_total_claim_count DESC
LIMIT 5;
--Atorvastatin, Carvedilol, Metoprolol, Clopidogrel, Amlodipine

--c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.
SELECT generic_name, SUM(total_claim_count) AS sum_total_claim_count
FROM prescription
INNER JOIN prescriber USING(npi)
INNER JOIN drug USING(drug_name)
WHERE specialty_description = 'Cardiology'
	OR specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY sum_total_claim_count DESC
LIMIT 5;
--Atorvastatin, Levothyroxine, Amlodipine, Lisinopril, Furosemide

--3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, 
--and include a column showing the city.


--b. Now, report the same for Memphis.
--c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

--4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

--5.
--a. Write a query that finds the total population of Tennessee.
--b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is 
--contained in that county.