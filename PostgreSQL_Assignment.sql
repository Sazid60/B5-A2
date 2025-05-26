-- Active: 1747459510114@@localhost@5432@conservation_db

-- ****SQL code for table creation, sample data insertion, and all queries.****

-- Create a database 
create database conservation_db

-- creating rangers table and inserting data 

CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL
);

INSERT INTO rangers(name,region) VALUES
('Alice Green','Northern Hills'),
('Bob White','River Delta'),
('Carol King','Mountain Range');

-- creating species table inserting data 

CREATE TABLE species(
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(100) NOT NULL,
    discovery_date DATE NOT NULL,
    conservation_status VARCHAR(30) NOT NULL
);

INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status) VALUES
('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');


-- creating sightings table inserting data 

CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    species_id INTEGER NOT NULL REFERENCES species(species_id) ON DELETE RESTRICT,
    ranger_id INTEGER NOT NULL REFERENCES rangers(ranger_id) ON DELETE RESTRICT,
    location VARCHAR(100) NOT NULL,
    sighting_time TIMESTAMP NOT NULL,
    notes TEXT
);


INSERT INTO sightings (species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 'Peak Ridge','2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 'Bankwood Area','2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 'Bamboo Grove East','2024-05-15 09:10:00', 'Feeding observed'),
(1, 2, 'Snowfall Pass','2024-05-18 18:30:00', NULL);


-- ****__________________________SQL queries for all problems__________________________****

--  problem-1 : Register a new ranger with provided data with name = 'Derek Fox' and region = 'Coastal Plains'

INSERT INTO rangers(name,region) VALUES('Derek Fox','Coastal Plains');

--  problem-2 : Count unique species ever sighted.

SELECT COUNT(DISTINCT species_id) AS unique_species_count FROM sightings;


-- problem-3 : Find all sightings where the location includes "Pass".

SELECT * FROM sightings WHERE location ILIKE '%Pass%';

-- problem-4 : List each ranger's name and their total number of sightings.

-- SELECT name, count(sighting_id) AS total_sightings FROM rangers
-- LEFT JOIN sightings ON rangers.ranger_id = sightings.ranger_id
-- GROUP BY name ORDER BY name;

SELECT name, count(*) AS total_sightings FROM sightings
JOIN rangers USING(ranger_id)
GROUP BY name ORDER BY name;

-- problem-5 :  List species that have never been sighted.

SELECT common_name FROM species
LEFT JOIN sightings ON sightings.species_id = species.species_id
WHERE sighting_id IS NULL;


-- problem-6 : Show the most recent 2 sightings.

SELECT common_name, sighting_time, name FROM species
JOIN sightings USING(species_id) 
JOIN rangers USING(ranger_id)
ORDER BY sighting_time DESC
LIMIT 2; 


-- problem-7 : Update all species discovered before year 1800 to have status 'Historic'.

UPDATE species
SET conservation_status = 'Historic'
WHERE extract(year from discovery_date) < 1800;


-- problem-8 : Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'.

SELECT 
  sighting_id,
  CASE
    WHEN extract(HOUR FROM sighting_time) < 12 THEN 'Morning'
    WHEN extract(HOUR FROM sighting_time) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS time_of_day
FROM sightings ORDER BY sighting_id;



-- problem-9 Delete rangers who have never sighted any species

DELETE FROM rangers
WHERE NOT EXISTS (
  SELECT 1 
  FROM sightings 
  WHERE sightings.ranger_id = rangers.ranger_id
);

