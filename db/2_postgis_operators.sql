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

-- create table bus_line_shape_unified
DROP TABLE IF EXISTS vw_tcc_lucas_bus_line_shape_unified;
CREATE TABLE IF NOT EXISTS tcc_lucas_bus_line_shape_unified AS
SELECT bus_line_id,
       file_date,
       ST_MakeLine(geom ORDER BY id) AS geom
FROM tcc_lucas_bus_line_shape
GROUP BY bus_line_id, file_date;

-- Create VIEWS for filtering duplicated data from different days
DROP VIEW IF EXISTS vw_tcc_lucas_bus_line;
CREATE VIEW vw_tcc_lucas_bus_line AS
SELECT DISTINCT bus_line_id,
                name,
                card_only,
                category,
                color
FROM tcc_lucas_bus_line;

DROP VIEW IF EXISTS vw_tcc_lucas_bus_line_shape_unified;
CREATE VIEW vw_tcc_lucas_bus_line_shape_unified AS
SELECT DISTINCT bus_line_id,
                geom
FROM tcc_lucas_bus_line_shape_unified;


