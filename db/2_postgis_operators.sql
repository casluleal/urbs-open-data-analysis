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
