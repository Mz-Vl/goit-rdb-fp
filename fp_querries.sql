CREATE TABLE countries (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(255) NOT NULL,
    country_code VARCHAR(50) NOT NULL,
    UNIQUE (country_name, country_code)
);


CREATE TABLE infectious_cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    country_id INT,
    year INT NOT NULL,
    yaws_cases INT,
    polio_cases INT,
    guinea_worm_cases INT,
    rabies_cases INT,
    malaria_cases INT,
    hiv_cases INT,
    tuberculosis_cases INT,
    smallpox_cases INT,
    cholera_cases INT,
    FOREIGN KEY (country_id) REFERENCES countries(country_id),
    UNIQUE (country_id, year)
);


INSERT INTO countries (country_name, country_code)
SELECT DISTINCT Entity, Code
FROM infectious_cases_original;


INSERT INTO infectious_cases (
    country_id,
    year,
    yaws_cases,
    polio_cases,
    guinea_worm_cases,
    rabies_cases,
    malaria_cases,
    hiv_cases,
    tuberculosis_cases,
    smallpox_cases,
    cholera_cases
)
SELECT 
    c.country_id,
    ic.Year,
    NULLIF(ic.Number_yaws, ''),
    NULLIF(ic.polio_cases, ''),
    NULLIF(ic.cases_guinea_worm, ''),
    NULLIF(ic.Number_rabies, ''),
    NULLIF(ic.Number_malaria, ''),
    NULLIF(ic.Number_hiv, ''),
    NULLIF(ic.Number_tuberculosis, ''),
    NULLIF(ic.Number_smallpox, ''),
    NULLIF(ic.Number_cholera_cases, '')
FROM infectious_cases_original ic
JOIN countries c ON ic.Entity = c.country_name AND ic.Code = c.country_code;
-- Була помилка "Incorrect integer value: '' for column 'yaws_cases'" тому знайшов рішення використовуючи NULLIF


SELECT 
    c.country_name,
    c.country_code,
    AVG(ic.rabies_cases) as avg_rabies,
    MIN(ic.rabies_cases) as min_rabies,
    MAX(ic.rabies_cases) as max_rabies,
    SUM(ic.rabies_cases) as total_rabies,
    COUNT(ic.rabies_cases) as years_reported
FROM countries c
JOIN infectious_cases ic ON c.country_id = ic.country_id
WHERE ic.rabies_cases IS NOT NULL 
GROUP BY c.country_name, c.country_code
ORDER BY avg_rabies DESC
LIMIT 10;


SELECT 
    year,
    DATE(CONCAT(year, '-01-01')) as year_start_date,
    CURDATE() as today_date,
    TIMESTAMPDIFF(YEAR, 
                  DATE(CONCAT(year, '-01-01')), 
                  CURDATE()) as years_difference
FROM infectious_cases
GROUP BY year
ORDER BY year DESC;


DELIMITER //

CREATE FUNCTION calculate_years_difference(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, 
                        DATE(CONCAT(input_year, '-01-01')), 
                        CURDATE());
END //

DELIMITER ;


SELECT 
    year,
    DATE(CONCAT(year, '-01-01')) as year_start_date,
    CURDATE() as today_date,
    calculate_years_difference(year) as years_diff_custom
FROM infectious_cases
GROUP BY year
ORDER BY year DESC;