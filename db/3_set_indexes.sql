-- Colunas normais
CREATE INDEX tcc_lucas_vehicle_position_index
    ON tcc_lucas_vehicle_position (vehicle_id, bus_line_id, timestamp);

-- Coluna de geometria
CREATE INDEX tcc_lucas_vehicle_position_geom_index
    ON tcc_lucas_vehicle_position
        USING GIST (geom);