--create table matches_with_theorical_2019_05_11 as(
/*
É preciso ter a tabela matches_2019_05_11 já criada
*/
WITH real_and_theorical AS (
    SELECT *,
           COALESCE(
                       DATE_PART('epoch', bus_arrival_time -
                                          LAG(bus_arrival_time)
                                          OVER (PARTITION BY "type", bus_line_id, vehicle_id ORDER BY bus_arrival_time)
                           ) / 60, 0
               ) dif_minutes
    FROM (

             SELECT DISTINCT bus_line_id,
                             vehicle_id,
                             bus_arrival_time,
                             bus_stop_id,
                             'real' "type"
             FROM tcc_lucas_matches_2019_05_03_bus_line_020 c

             UNION ALL

             SELECT bus_line_id,
                    vehicle_id,
                    file_date + "time" "bus_arrival_time",
                    bus_stop_id,
                    'theorical'        "type"
             FROM tcc_lucas_bus_vehicle_timetable
             WHERE bus_line_id = '020'
               AND file_date = '2019-05-03'
         ) aa
)
SELECT t.*,
--r_early.*,
--r_delayed.*,
       who,
       chosen.*
FROM real_and_theorical t
         LEFT JOIN LATERAL (
    SELECT rl.bus_arrival_time,
           rl.dif_minutes,
           DATE_PART('epoch', rl.bus_arrival_time - t.bus_arrival_time) arrival_time_delay
    FROM real_and_theorical rl
    WHERE "type" = 'real'
      AND rl.bus_line_id = t.bus_line_id
      AND rl.vehicle_id = t.vehicle_id
      AND rl.bus_stop_id = t.bus_stop_id
      AND rl.bus_arrival_time <= t.bus_arrival_time
    ORDER BY rl.bus_arrival_time DESC
    LIMIT 1
    ) r_early ON TRUE
         LEFT JOIN LATERAL (
    SELECT rl.bus_arrival_time,
           rl.dif_minutes,
           DATE_PART('epoch', rl.bus_arrival_time - t.bus_arrival_time) arrival_time_delay
    FROM real_and_theorical rl
    WHERE "type" = 'real'
      AND rl.bus_line_id = t.bus_line_id
      AND rl.vehicle_id = t.vehicle_id
      AND rl.bus_stop_id = t.bus_stop_id
      AND rl.bus_arrival_time > t.bus_arrival_time
    ORDER BY rl.bus_arrival_time ASC
    LIMIT 1
    ) r_delayed ON TRUE,
     LATERAL (
         SELECT CASE
                    WHEN r_early.arrival_time_delay IS NULL AND r_delayed.arrival_time_delay IS NOT NULL THEN 'delayed'
                    WHEN r_early.arrival_time_delay IS NOT NULL AND r_delayed.arrival_time_delay IS NULL THEN 'early'
                    WHEN r_early.arrival_time_delay IS NULL AND r_delayed.arrival_time_delay IS NULL THEN NULL
                    WHEN ABS(r_early.arrival_time_delay) >= ABS(r_delayed.arrival_time_delay) THEN 'delayed'
                    WHEN ABS(r_early.arrival_time_delay) < ABS(r_delayed.arrival_time_delay) THEN 'early'
                    ELSE NULL
                    END who
         ) who,
     LATERAL (
         SELECT CASE
                    WHEN who = 'early' THEN r_early.bus_arrival_time
                    WHEN who = 'delayed' THEN r_delayed.bus_arrival_time
                    ELSE NULL END AS bus_arrival_time,
                CASE
                    WHEN who = 'early' THEN r_early.arrival_time_delay
                    WHEN who = 'delayed' THEN r_delayed.arrival_time_delay
                    ELSE NULL END AS arrival_time_delay,
                CASE
                    WHEN who = 'early' THEN r_early.dif_minutes
                    WHEN who = 'delayed' THEN r_delayed.dif_minutes
                    ELSE NULL END AS dif_minutes
         ) chosen
WHERE t."type" = 'theorical'
;