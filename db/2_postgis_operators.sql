-- FILL GEOMETRY FIELDS FROM POSTGIS
-- bus_line_stop
UPDATE tcc_lucas_bus_line_stop
SET geom = st_setsrid(st_makepoint(longitude, latitude), 4326);

-- bus_line_shape
UPDATE tcc_lucas_bus_line_shape
SET geom = st_setsrid(st_makepoint(longitude, latitude), 4326);

-- bus_line_stop
UPDATE tcc_lucas_bus_line_stop
SET geom = st_setsrid(st_makepoint(longitude, latitude), 4326);

-- vehicle_position
UPDATE tcc_lucas_vehicle_position
SET geom = st_setsrid(st_makepoint(longitude, latitude), 4326);

-- Create VIEWS for filtering duplicated data from different days
DROP VIEW IF EXISTS vw_tcc_lucas_bus_line;
CREATE VIEW vw_tcc_lucas_bus_line AS
SELECT DISTINCT bus_line_id,
                name,
                card_only,
                category,
                color
FROM tcc_lucas_bus_line;

DROP VIEW IF EXISTS vw_tcc_lucas_bus_line_shape;
CREATE VIEW vw_tcc_lucas_bus_line_shape AS
WITH line_shape AS (
    SELECT bus_line_id,
           shape_id,
           file_date,
           ST_MakeLine(geom ORDER BY id) AS "geom"
    FROM tcc_lucas_bus_line_shape
    GROUP BY 1, 2, 3
),
     ranked_line_shape AS (
         SELECT *,
                st_length(geom)                    AS "length",
                RANK() OVER (
                    PARTITION BY bus_line_id, file_date
                    ORDER BY st_length(geom) DESC) AS "rank"
         FROM line_shape
         ORDER BY st_length(geom) DESC
     )
SELECT bus_line_id, shape_id, file_date, geom, length
FROM ranked_line_shape
WHERE rank = 1;
