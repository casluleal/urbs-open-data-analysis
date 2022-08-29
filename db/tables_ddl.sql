create table if not exists tcc_lucas_bus_vehicle_timetable
(
    id            serial,
    bus_line_id   text,
    bus_line_name text,
    vehicle_id    text,
    time          text,
    timetable_id  text,
    bus_stop_id   text,
    file_date     timestamp
);

create table if not exists tcc_lucas_bus_line_timetable
(
    id            serial,
    time          text,
    bus_stop_name text,
    type_of_day   int,
    bus_stop_id   text,
    timetable_id  text,
    accessibility text,
    bus_line_id   text,
    file_date     timestamp
);

create table if not exists tcc_lucas_bus_line_shape
(
    id          serial,
    shape_id    bigint,
    latitude    double precision,
    longitude   double precision,
    bus_line_id text,
    file_date   timestamp
);

create table if not exists tcc_lucas_bus_line_stop
(
    id           serial,
    name         text,
    bus_stop_id  text,
    latitude     double precision,
    longitude    double precision,
    sequence     bigint,
    "group"      text,
    direction    text,
    type         text,
    itinerary_id bigint,
    bus_line_id  text,
    file_date    timestamp
);

create table if not exists tcc_lucas_vehicle_position
(
    id          serial,
    vehicle_id  text,
    latitude    double precision,
    longitude   double precision,
    timestamp   timestamp,
    bus_line_id text,
    file_date   timestamp
);

create table if not exists tcc_lucas_bus_line
(
    id          serial,
    bus_line_id text,
    name        text,
    card_only   text,
    category    text,
    color       text,
    file_date   timestamp
);
