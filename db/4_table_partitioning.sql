-- Table partitioning queries for better performance

-- 01/05/2019
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_01_bus_line_020 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-01'
--   AND bus_line_id = '020';
--
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_01_bus_line_203 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-01'
--   AND bus_line_id = '203';
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_01_bus_line_020
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_01_bus_line_020_pk
--         PRIMARY KEY (id);
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_01_bus_line_203
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_01_bus_line_203_pk
--         PRIMARY KEY (id);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_01_bus_line_020_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_01_bus_line_020
--         USING GIST (geom);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_01_bus_line_203_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_01_bus_line_203
--         USING GIST (geom);
--
-- -- 02/05/2019
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_02_bus_line_020 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-02'
--   AND bus_line_id = '020';
--
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_02_bus_line_203 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-02'
--   AND bus_line_id = '203';
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_02_bus_line_020
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_02_bus_line_020_pk
--         PRIMARY KEY (id);
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_02_bus_line_203
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_02_bus_line_203_pk
--         PRIMARY KEY (id);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_02_bus_line_020_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_02_bus_line_020
--         USING GIST (geom);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_02_bus_line_203_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_02_bus_line_203
--         USING GIST (geom);
--
-- -- 03/05/2019
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_03_bus_line_020 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-03'
--   AND bus_line_id = '020';
--
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_03_bus_line_203 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-03'
--   AND bus_line_id = '203';
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_03_bus_line_020
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_03_bus_line_020_pk
--         PRIMARY KEY (id);
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_03_bus_line_203
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_03_bus_line_203_pk
--         PRIMARY KEY (id);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_03_bus_line_020_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_03_bus_line_020
--         USING GIST (geom);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_03_bus_line_203_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_03_bus_line_203
--         USING GIST (geom);
--
-- -- 04/05/2019
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_04_bus_line_020 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-04'
--   AND bus_line_id = '020';
--
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_04_bus_line_203 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-04'
--   AND bus_line_id = '203';
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_04_bus_line_020
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_04_bus_line_020_pk
--         PRIMARY KEY (id);
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_04_bus_line_203
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_04_bus_line_203_pk
--         PRIMARY KEY (id);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_04_bus_line_020_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_04_bus_line_020
--         USING GIST (geom);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_04_bus_line_203_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_04_bus_line_203
--         USING GIST (geom);
--
-- -- 05/05/2019
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_05_bus_line_020 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-05'
--   AND bus_line_id = '020';
--
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_05_bus_line_203 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-05'
--   AND bus_line_id = '203';
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_05_bus_line_020
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_05_bus_line_020_pk
--         PRIMARY KEY (id);
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_05_bus_line_203
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_05_bus_line_203_pk
--         PRIMARY KEY (id);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_05_bus_line_020_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_05_bus_line_020
--         USING GIST (geom);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_05_bus_line_203_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_05_bus_line_203
--         USING GIST (geom);
--
-- -- 06/05/2019
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_06_bus_line_020 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-06'
--   AND bus_line_id = '020';
--
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_06_bus_line_203 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-06'
--   AND bus_line_id = '203';
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_06_bus_line_020
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_06_bus_line_020_pk
--         PRIMARY KEY (id);
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_06_bus_line_203
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_06_bus_line_203_pk
--         PRIMARY KEY (id);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_06_bus_line_020_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_06_bus_line_020
--         USING GIST (geom);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_06_bus_line_203_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_06_bus_line_203
--         USING GIST (geom);
--
-- -- 07/05/2019
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_07_bus_line_020 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-07'
--   AND bus_line_id = '020';
--
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_07_bus_line_203 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-07'
--   AND bus_line_id = '203';
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_07_bus_line_020
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_07_bus_line_020_pk
--         PRIMARY KEY (id);
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_07_bus_line_203
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_07_bus_line_203_pk
--         PRIMARY KEY (id);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_07_bus_line_020_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_07_bus_line_020
--         USING GIST (geom);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_07_bus_line_203_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_07_bus_line_203
--         USING GIST (geom);
--
-- -- 08/05/2019
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_08_bus_line_020 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-08'
--   AND bus_line_id = '020';
--
-- CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_08_bus_line_203 AS
-- SELECT *
-- FROM tcc_lucas_vehicle_position
-- WHERE file_date = '2019-05-08'
--   AND bus_line_id = '203';
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_08_bus_line_020
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_08_bus_line_020_pk
--         PRIMARY KEY (id);
--
-- ALTER TABLE tcc_lucas_vehicle_position_2019_05_08_bus_line_203
--     ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_08_bus_line_203_pk
--         PRIMARY KEY (id);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_08_bus_line_020_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_08_bus_line_020
--     USING GIST (geom);
--
-- CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_08_bus_line_203_geom_index
--     ON tcc_lucas_vehicle_position_2019_05_08_bus_line_203
--     USING GIST (geom);

-- 09/05/2019
CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_09_bus_line_020 AS
SELECT *
FROM tcc_lucas_vehicle_position
WHERE file_date = '2019-05-09'
  AND bus_line_id = '020';

CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_09_bus_line_203 AS
SELECT *
FROM tcc_lucas_vehicle_position
WHERE file_date = '2019-05-09'
  AND bus_line_id = '203';

ALTER TABLE tcc_lucas_vehicle_position_2019_05_09_bus_line_020
    ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_09_bus_line_020_pk
        PRIMARY KEY (id);

ALTER TABLE tcc_lucas_vehicle_position_2019_05_09_bus_line_203
    ADD CONSTRAINT tcc_lucas_vehicle_position_2019_05_09_bus_line_203_pk
        PRIMARY KEY (id);

CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_09_bus_line_020_geom_index
    ON tcc_lucas_vehicle_position_2019_05_09_bus_line_020
    USING GIST (geom);

CREATE INDEX IF NOT EXISTS tcc_lucas_vehicle_position_2019_05_09_bus_line_203_geom_index
    ON tcc_lucas_vehicle_position_2019_05_09_bus_line_203
    USING GIST (geom);
