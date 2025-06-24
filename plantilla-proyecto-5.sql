/*
PROYECTO 5 - ANÁLISIS DE FORMULA 1 - FORMULA UNICORN

Parte I - Respuesta a preguntas de negocio
*/

USE formula_unicorn;

-- 1. ¿Cuántos circuitos diferentes hay en el dataset?
SELECT COUNT(circuitId) AS cantidad_circuitos
FROM circuits;
-- 77
-- No usamos DISTINCT porque circuitId es primary key
-- DISTINCT ON


-- 2. ¿Cuántos pilotos han competido en la historia de la Fórmula 1?
SELECT COUNT(driverId)
FROM drivers;
-- 861

/*
Para buscar duplicados:

SELECT circuitRef, count(*)
FROM circuits
GROUP BY circuitRef
HAVING count(*) >= 2
*/

-- 3. ¿Cuáles son los equipos con más victorias en la historia?
SELECT 
	DISTINCT(c.name) AS nombre_escuderia,
    COUNT(r.constructorId) AS cantidad_victorias
FROM results AS r
LEFT JOIN constructors AS c ON  r.constructorId = c.constructorId 
WHERE position = '1'
GROUP BY
	c.name
ORDER BY 
	cantidad_victorias DESC;

/*
nombre_escuderia, cantidad_victorias
'Ferrari', '249'
'McLaren', '185'
'Mercedes', '129'
'Red Bull', '122'
'Williams', '114'
'Team Lotus', '45'
'Renault', '35'
'Benetton', '27'
'Brabham', '23'
'Tyrrell', '23'
*/

-- 4. ¿Qué piloto tiene la mayor cantidad de vueltas rápidas?
SELECT 
	CONCAT(d.forename,' ',d.surname) AS nombre_piloto,
    COUNT(*) AS vueltas
FROM results r
LEFT JOIN drivers d ON r.driverId = d.driverId
WHERE r.rankValue = '1'
GROUP BY
	nombre_piloto
ORDER BY
	vueltas DESC
LIMIT 1;
    
/* el rankvalue lo que nos dice es quien hizo la vuelta mas rapida dentro de una carrera. 
Rankvalue = 1, piloto que en esa carrera, hizo la vuelta mas rapida */

-- nombre_piloto, vueltas
-- 'Lewis Hamilton', '66'


-- 5. ¿Qué piloto ha obtenido más podios en la historia?
-- podio es cuando esta en la posicion 1,2,3

SELECT 
	CONCAT(d.forename,' ',d.surname) AS nombre_piloto,
    COUNT(*) AS podio_cantidad
FROM results r
LEFT JOIN drivers d ON r.driverId = d.driverId
WHERE 
	position IN ('1','2','3')
GROUP BY
	nombre_piloto
ORDER BY
	podio_cantidad DESC
LIMIT 1;
-- # nombre_piloto, podio_cantidad
-- 'Lewis Hamilton', '202'

-- 6. ¿Cuáles han sido los 5 pilotos con mejor promedio de posiciones finales?
SELECT 
	CONCAT(d.forename,' ',d.surname) AS nombre_piloto,
    AVG(r.positionOrder) AS promedio_final
FROM results r
LEFT JOIN drivers d ON r.driverId = d.driverId
WHERE
	r.positionOrder > 0
GROUP BY
	nombre_piloto
HAVING
	COUNT(*)>10
    -- hay personas que compiten solo una vez, entonces vemos a la gente que ha competido varias veces
ORDER BY
	promedio_final ASC
LIMIT 5;

/*
# nombre_piloto, promedio_final
'Juan Fangio', '4.7931'
'Lewis Hamilton', '5.0197'
'Max Verstappen', '5.6459'
'Nino Farina', '5.8378'
'Michael Schumacher', '6.8799'
*/


-- 7. ¿Qué equipo ha logrado mayor cantidad de poles position?
SELECT 
	c.name AS equipo_nombre,
    nationality AS nacionalidad,
    COUNT(*) AS poles
FROM qualifying AS q
LEFT JOIN constructors AS c ON q.constructorId = c.constructorId
WHERE 
	q.position =1
GROUP BY 
	c.name,
    nacionalidad,
    c.constructorId
ORDER BY
	poles DESC
LIMIT 1;

-- # equipo_nombre, nacionalidad, poles
-- 'Mercedes', 'German', '135'


-- 8. ¿Cuántos puntos ha obtenido cada equipo en una temporada específica?
SELECT 
	ra.year,
    c.name AS equipo_nombre,
    SUM(re.points) AS puntos
FROM results AS re
LEFT JOIN races AS ra ON re.raceId = ra.raceId
LEFT JOIN constructors AS c ON re.constructorId = c.constructorId
GROUP BY
	ra.year,
    equipo_nombre
ORDER BY
	ra.year DESC,
    puntos DESC;
/*
# year, equipo_nombre, puntos
'2024', 'McLaren', '609.00'
'2024', 'Ferrari', '595.00'
'2024', 'Red Bull', '537.00'
'2024', 'Mercedes', '433.00'
'2024', 'Aston Martin', '94.00'
'2024', 'Alpine F1 Team', '63.00'
'2024', 'Haas F1 Team', '51.00'
'2024', 'RB F1 Team', '40.00'
'2024', 'Williams', '17.00'
'2024', 'Sauber', '4.00'

*/

-- 9. ¿Qué piloto ha mejorado más posiciones desde su salida en parrilla?
/*
Conceptos
parrilla: grid (tabla results)
*/
-- mio
SELECT 
	CONCAT(d.forename,' ',d.surname) AS nombre_piloto,
    AVG(r.grid - r.positionOrder) AS parrilla
FROM results AS r
LEFT JOIN drivers AS d ON r.driverId = d.driverId
WHERE 
	r.grid IS NOT NULL 
    AND r.grid > r.positionOrder
GROUP BY
	nombre_piloto,
    d.driverId
ORDER BY
	parrilla DESC;

-- otra persona
SELECT
	CONCAT(d.forename,' ',d.surname) AS nombre_piloto,
    SUM(r.grid - r.positionOrder) AS posiciones_ganadas
FROM results r
LEFT JOIN drivers d ON r.driverId = d.driverId
WHERE
	r.grid > 0 
    AND r.grid < 20
    AND r.positionOrder IS NOT NULL
GROUP BY
	d.driverId
ORDER BY
	posiciones_ganadas DESC;

/*
# nombre_piloto, posiciones_ganadas
'Mika Salo', '220'

*/

-- 10. ¿Cuáles son los equipos con mayor cantidad de dobletes (1er y 2do puesto en una carrera)?
SELECT constructors.name, COUNT(*) AS dobletes
FROM results r1
JOIN results r2 ON r1.raceId = r2.raceId
    AND r1.constructorId = r2.constructorId
    AND r1.driverId < r2.driverId
JOIN constructors ON r1.constructorId = constructors.constructorId
WHERE (
    (r1.position = 1 AND r2.position = 2) OR 
    (r1.position = 2 AND r2.position = 1)
)
GROUP BY constructors.name
ORDER BY dobletes DESC;

/*
# name, dobletes
'Ferrari', '88'
'Mercedes', '60'
'McLaren', '48'
'Williams', '33'

*/

-- 11. ¿Cuáles han sido los 5 GP con menor diferencia entre el 1er y 2do lugar?
SELECT 
    races.name,
    races.year, 
    MIN(ABS(r1.milliseconds - r2.milliseconds)) AS diferencia
FROM results r1
JOIN results r2 ON r1.raceId = r2.raceId 
    AND r1.driverId <> r2.driverId
JOIN races ON r1.raceId = races.raceId
WHERE r1.position = 1 
    AND r2.position = 2
    AND r1.milliseconds IS NOT NULL
    AND r2.milliseconds IS NOT NULL
GROUP BY races.name, races.year
ORDER BY diferencia ASC
LIMIT 5;

/*
# name, year, diferencia
'Italian Grand Prix', '1971', '10'
'United States Grand Prix', '2002', '11'
'Spanish Grand Prix', '1986', '14'
'Austrian Grand Prix', '1982', '50'
'Italian Grand Prix', '1969', '80'

*/

-- 12. ¿Cuántos pilotos han participado en cada temporada? (Usando LEFT JOIN)
SELECT 
	ra.year AS temporada,
    COUNT(DISTINCT(re.driverId)) AS cantidad_pilotos
FROM results re
LEFT JOIN races ra ON re.raceId=ra.raceId
GROUP BY
	temporada
ORDER BY
	temporada,
	cantidad_pilotos DESC;

/*
# temporada, cantidad_pilotos
'1950', '81'
'1951', '84'
'1952', '105'
'1953', '108'
'1954', '97'
'1955', '84'
'1956', '85'
'1957', '76'
'1958', '87'
'1959', '88'
'1960', '91'
'1961', '62'
'1962', '61'
'1963', '62'
'1964', '41'
'1965', '54'
'1966', '33'
'1967', '45'
'1968', '43'
'1969', '31'
'1970', '43'
'1971', '50'
'1972', '42'
'1973', '43'
'1974', '62'
'1975', '52'
'1976', '54'
'1977', '61'
'1978', '46'
'1979', '36'
'1980', '41'
'1981', '39'
'1982', '40'
'1983', '35'
'1984', '35'
'1985', '36'
'1986', '32'
'1987', '32'
'1988', '36'
'1989', '47'
'1990', '40'
'1991', '41'
'1992', '37'
'1993', '35'
'1994', '46'
'1995', '35'
'1996', '24'
'1997', '28'
'1998', '23'
'1999', '24'
'2000', '23'
'2001', '26'
'2002', '23'
'2003', '24'
'2004', '25'
'2005', '27'
'2006', '27'
'2007', '26'
'2008', '22'
'2009', '25'
'2010', '27'
'2011', '28'
'2012', '25'
'2013', '23'
'2014', '24'
'2015', '22'
'2016', '24'
'2017', '25'
'2018', '20'
'2019', '20'
'2020', '23'
'2021', '21'
'2022', '22'
'2023', '22'
'2024', '24'

*/

-- 13. Ranking de los 5 mejores pilotos con más puntos en una temporada (Usando RANK())
-- mio
SELECT 
	CONCAT(d.forename,' ',d.surname) AS nombre_piloto,
    ra.year AS temporada,
    SUM(re.points) as puntos,
    RANK() OVER(ORDER BY SUM(re.points)) AS posicion
FROM results re
LEFT JOIN races ra ON re.raceId=ra.raceId
LEFT JOIN drivers d ON re.driverId=d.driverId
WHERE
	re.points > 0
    AND ra.year = 2024
GROUP BY
	temporada,
    nombre_piloto,
    d.driverId
LIMIT 5;
/*
# nombre_piloto, temporada, puntos, posicion
'Liam Lawson', '2024', '4.00', '1'
'Guanyu Zhou', '2024', '4.00', '1'
'Franco Colapinto', '2024', '5.00', '3'
'Oliver Bearman', '2024', '7.00', '4'
'Daniel Ricciardo', '2024', '7.00', '4'

*/


-- profe
SELECT 
	driverId,
    surname,
    year,
    total_puntos,
    RANK() OVER(ORDER BY total_puntos) AS ranking
FROM (
	SELECT 
		re.driverId,
        d.surname AS surname,
        ra.year,
        SUM(re.points) AS total_puntos
	FROM results re
    LEFT JOIN races ra ON re.raceId=ra.raceId
	LEFT JOIN drivers d ON re.driverId=d.driverId
    GROUP BY
		re.driverId,
        ra.year
) AS subquery
ORDER BY
	year DESC,
    ranking;

/*
# driverId, surname, year, total_puntos, ranking
'855', 'Zhou', '2024', '4.00', '2048'
'859', 'Lawson', '2024', '4.00', '2048'
'861', 'Colapinto', '2024', '5.00', '2145'
'817', 'Ricciardo', '2024', '7.00', '2285'
'860', 'Bearman', '2024', '7.00', '2285'

*/

-- 14. ¿Cuántos puntos ha obtenido cada equipo? Usando COALESCE para manejar valores nulos.
SELECT
	c.name AS equipo,
    COALESCE(SUM(r.points),0) AS puntos
FROM results r
LEFT JOIN constructors c ON r.constructorId = c.constructorId
GROUP BY
	equipo
ORDER BY
	puntos DESC;
    
    
/*
# equipo, puntos
'Ferrari', '11091.27'
'Mercedes', '7730.64'
'Red Bull', '7673.00'
'McLaren', '7022.50'
'Williams', '3641.00'
'Renault', '1777.00'
'Force India', '1098.00'
'Team Lotus', '995.00'
'Benetton', '861.50'
'Tyrrell', '711.00'
'Lotus F1', '706.00'
'Brabham', '631.00'
'Sauber', '561.00'
'BRM', '537.50'
'Toro Rosso', '500.00'
'Alpine F1 Team', '498.00'
'Aston Martin', '492.00'
'Ligier', '388.00'
'Alfa Romeo', '361.00'
'Cooper-Climax', '336.50'
'Maserati', '313.14'
'BMW Sauber', '308.00'
'AlphaTauri', '306.00'
'Haas F1 Team', '293.00'
'Jordan', '291.00'
'Racing Point', '283.00'
'Lotus-Climax', '281.00'
'Toyota', '278.50'
'BAR', '227.00'
'Lotus-Ford', '209.00'
'Brabham-Repco', '175.00'
'Brawn', '172.00'
'Honda', '156.00'
'March', '148.00'
'McLaren-Ford', '143.00'
'Arrows', '142.00'
'Matra-Ford', '130.00'
'Kurtis Kraft', '130.00'
'Vanwall', '108.00'
'Cooper-Maserati', '83.00'
'Wolf', '79.00'
'Brabham-Climax', '78.00'
'Brabham-Ford', '68.00'
'Shadow', '59.00'
'Surtees', '54.00'
'Matra', '54.00'
'Cooper', '52.00'
'Porsche', '50.00'
'Jaguar', '49.00'
'Hesketh', '48.00'
'Stewart', '47.00'
'Fittipaldi', '44.00'
'Epperly', '44.00'
'RB F1 Team', '40.00'
'Minardi', '38.00'
'March-Ford', '37.00'
'Watson', '36.00'
'Prost', '35.00'
'Lotus-BRM', '29.00'
'Lola', '27.00'
'Toleman', '26.00'
'Footwork', '25.00'
'Gordini', '25.00'
'Talbot-Lago', '25.00'
'Penske', '23.00'
'Larrousse', '22.00'
'Kuzma', '21.00'
'Cooper-BRM', '20.00'
'Ensign', '19.00'
'Brabham-Alfa Romeo', '18.00'
'Connaught', '17.00'
'Dallara', '15.00'
'Eagle-Weslake', '13.00'
'Brabham-BRM', '13.00'
'BRP', '11.00'
'Lesovsky', '10.00'
'Deidt', '10.00'
'Shadow-Ford', '9.50'
'Lancia', '9.00'
'Leyton House', '8.00'
'ATS', '7.00'
'Phillips', '7.00'
'Onyx', '6.00'
'Rial', '6.00'
'Parnelli', '6.00'
'Iso Marlboro', '6.00'
'McLaren-BRM', '6.00'
'Osella', '5.00'
'Simca', '5.00'
'Super Aguri', '4.00'
'Eagle-Climax', '4.00'
'Embassy Hill', '3.00'
'Cooper-Castellotti', '3.00'
'Frazer Nash', '3.00'
'Sherman', '3.00'
'AGS', '2.00'
'Zakspeed', '2.00'
'Theodore', '2.00'
'HWM', '2.00'
'Schroeder', '2.00'
'Marussia', '2.00'
'Spyker', '1.00'
'Tecno', '1.00'
'McLaren-Serenissima', '1.00'
'Trevis', '1.00'
'Manor Marussia', '1.00'
'MF1', '0.00'
'Spyker MF1', '0.00'
'Forti', '0.00'
'Pacific', '0.00'
'Simtek', '0.00'
'Fondmetal', '0.00'
'Andrea Moda', '0.00'
'Lambo', '0.00'
'Coloni', '0.00'
'Euro Brun', '0.00'
'Life', '0.00'
'RAM', '0.00'
'Spirit', '0.00'
'Merzario', '0.00'
'Kauhsen', '0.00'
'Rebaque', '0.00'
'Martini', '0.00'
'LEC', '0.00'
'McGuire', '0.00'
'Boro', '0.00'
'Apollon', '0.00'
'Kojima', '0.00'
'Maki', '0.00'
'Lyncar', '0.00'
'Shadow-Matra', '0.00'
'Trojan', '0.00'
'Amon', '0.00'
'Token', '0.00'
'Politoys', '0.00'
'Connew', '0.00'
'March-Alfa Romeo', '0.00'
'Lotus-Pratt &amp; Whitney', '0.00'
'Bellasi', '0.00'
'De Tomaso', '0.00'
'McLaren-Alfa Romeo', '0.00'
'BRM-Ford', '0.00'
'LDS', '0.00'
'LDS-Climax', '0.00'
'Cooper-ATS', '0.00'
'Protos', '0.00'
'Cooper-Ferrari', '0.00'
'Shannon', '0.00'
'LDS-Alfa Romeo', '0.00'
'Cooper-Ford', '0.00'
'RE', '0.00'
'Scirocco', '0.00'
'Derrington', '0.00'
'Gilby', '0.00'
'Lotus-Borgward', '0.00'
'De Tomaso-Ferrari', '0.00'
'Lotus-Maserati', '0.00'
'Stebro', '0.00'
'Emeryson', '0.00'
'De Tomaso-Alfa Romeo', '0.00'
'ENB', '0.00'
'De Tomaso-Osca', '0.00'
'Cooper-Alfa Romeo', '0.00'
'JBW', '0.00'
'Ferguson', '0.00'
'MBM', '0.00'
'Behra-Porsche', '0.00'
'Scarab', '0.00'
'Meskowski', '0.00'
'Christensen', '0.00'
'Ewing', '0.00'
'Moore', '0.00'
'Dunn', '0.00'
'Elder', '0.00'
'Sutton', '0.00'
'Cooper-Borgward', '0.00'
'Fry', '0.00'
'Cooper-OSCA', '0.00'
'Tec-Mec', '0.00'
'OSCA', '0.00'
'Stevens', '0.00'
'Bugatti', '0.00'
'Pawl', '0.00'
'Pankratz', '0.00'
'Arzani-Volpini', '0.00'
'Nichels', '0.00'
'Bromme', '0.00'
'Klenk', '0.00'
'Turner', '0.00'
'Del Roy', '0.00'
'Veritas', '0.00'
'BMW', '0.00'
'EMW', '0.00'
'AFM', '0.00'
'Aston Butterworth', '0.00'
'ERA', '0.00'
'Alta', '0.00'
'Cisitalia', '0.00'
'Hall', '0.00'
'Marchese', '0.00'
'Langley', '0.00'
'Rae', '0.00'
'Olson', '0.00'
'Wetteroth', '0.00'
'Snowberger', '0.00'
'Adams', '0.00'
'Milano', '0.00'
'Lotus', '0.00'
'HRT', '0.00'
'Virgin', '0.00'
'Caterham', '0.00'

*/

-- 15. Determinar la clasificación de un piloto en una carrera con CASE
SELECT 
	CONCAT(d.forename,' ',d.surname) AS nombre_piloto,
    CASE
		WHEN positionOrder = 1 THEN 'Ganador'
        WHEN positionOrder BETWEEN 2 AND 3 THEN 'Podio' 
        WHEN positionOrder BETWEEN 4 AND 10 THEN 'Puntos'
        ELSE 'Fuera de puntos'
	END AS clasificacion
FROM results r
LEFT JOIN drivers d ON r.driverId=d.driverId
GROUP BY
	nombre_piloto,
    d.driverId,
    clasificacion;

/*
# nombre_piloto, clasificacion
'Lewis Hamilton', 'Ganador'
'Nick Heidfeld', 'Podio'
'Nico Rosberg', 'Podio'
'Fernando Alonso', 'Puntos'
'Heikki Kovalainen', 'Puntos'

*/

/*
Parte II - Automatización
*/

-- 1. Crear una vista que traduzca los estados de carrera al español.
CREATE VIEW estados_carrera_spanish AS
SELECT 
	statusId,
    CASE
		WHEN 'Finished' THEN 'Finalizado'
        WHEN 'Disqualified' THEN 'Descalificado'
        WHEN 'Accident' THEN 'Accidente'
        WHEN 'Collision' THEN 'Colicion'
        WHEN 'Engine' THEN 'Fallo de motor'
        WHEN 'Gearbox' THEN 'Fallo de caja de cambio'
        WHEN 'Hydraulics' THEN 'Fallo hidraulico'
        WHEN 'Electrical' THEN 'Fallo electrico'
        ELSE 'Otros'
	END AS estado_spanish
FROM status;


-- 2. Crear un procedure que calcule el número de victorias de un equipo en un año dado.
DELIMITER //
CREATE PROCEDURE victorias_year (IN equipo_id INT, IN anio INT)
BEGIN
	SELECT 
		c.name AS equipo_nombre,
		COUNT(*) AS victorias
	FROM results AS re
	LEFT JOIN races AS ra ON re.raceId = ra.raceId
	LEFT JOIN constructors AS c ON re.constructorId = c.constructorId
    WHERE 
		re.position = 1
        AND ra.year = anio
        AND c.constructorId = equipo_id
	GROUP BY
		equipo_nombre;
END //
DELIMITER ;

CALL victorias_year(1,2024)