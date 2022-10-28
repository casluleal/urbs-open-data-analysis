CREATE TABLE IF NOT EXISTS tcc_lucas_bus_vehicle_timetable
(
    id            SERIAL PRIMARY KEY,
    bus_line_id   TEXT,
    bus_line_name TEXT,
    vehicle_id    TEXT,
    time          TIME,
    timetable_id  TEXT,
    bus_stop_id   TEXT,
    file_date     TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tcc_lucas_bus_line_timetable
(
    id            SERIAL PRIMARY KEY,
    time          TIME,
    bus_stop_name TEXT,
    type_of_day   INT,
    bus_stop_id   TEXT,
    timetable_id  TEXT,
    accessibility TEXT,
    bus_line_id   TEXT,
    file_date     TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tcc_lucas_bus_line_shape
(
    id          SERIAL PRIMARY KEY,
    shape_id    BIGINT,
    latitude    DOUBLE PRECISION,
    longitude   DOUBLE PRECISION,
    bus_line_id TEXT,
    file_date   TIMESTAMP,
    geom        GEOMETRY(POINT, 4326)
);

CREATE TABLE IF NOT EXISTS tcc_lucas_bus_line_stop
(
    id           SERIAL PRIMARY KEY,
    name         TEXT,
    bus_stop_id  TEXT,
    latitude     DOUBLE PRECISION,
    longitude    DOUBLE PRECISION,
    sequence     BIGINT,
    "group"      TEXT,
    direction    TEXT,
    type         TEXT,
    itinerary_id BIGINT,
    bus_line_id  TEXT,
    file_date    TIMESTAMP,
    geom        GEOMETRY(POINT, 4326)
);

CREATE TABLE IF NOT EXISTS tcc_lucas_vehicle_position
(
    id          SERIAL PRIMARY KEY,
    vehicle_id  TEXT,
    latitude    DOUBLE PRECISION,
    longitude   DOUBLE PRECISION,
    timestamp   TIMESTAMP,
    bus_line_id TEXT,
    file_date   TIMESTAMP,
    geom        GEOMETRY(POINT, 4326)
);

CREATE TABLE IF NOT EXISTS tcc_lucas_bus_line
(
    id          SERIAL PRIMARY KEY,
    bus_line_id TEXT,
    name        TEXT,
    card_only   TEXT,
    category    TEXT,
    color       TEXT,
    file_date   TIMESTAMP
);
