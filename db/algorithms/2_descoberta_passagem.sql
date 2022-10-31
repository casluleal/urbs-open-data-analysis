CREATE TABLE tcc_lucas_matches_2019_05_08_bus_line_203 AS
WITH veiculos AS (
    SELECT
        -- codigo da linha de ônibus
        bus_line_id,
        -- codigo do veiculo
        vehicle_id,
        -- data hora da mensuração
        timestamp,
        -- localização
        geom,
        -- data do arquivo
        file_date
    FROM tcc_lucas_vehicle_position_2019_05_08_bus_line_203
),
-- **************** VEICULOS WITH AZIMUTHS ****************
     veiculos_with_azimuth AS (
         SELECT file_date,
                bus_line_id,
                vehicle_id,
                LAG(timestamp) OVER w               AS prev_dthr,
                timestamp,
                timestamp - LAG(timestamp) OVER w   AS time_dif,
                st_makeline(LAG(geom) OVER w, geom) AS trajectory_line,
                st_azimuth(LAG(geom) OVER w, geom)  AS trajectory_azimuth
         FROM veiculos WINDOW w AS (
             PARTITION BY
                 file_date,
                 bus_line_id,
                 vehicle_id
             ORDER BY
                 timestamp
             )
         ORDER BY (
                   file_date,
                   bus_line_id,
                   vehicle_id,
                   timestamp
                      ) --LIMIT 100
     ),
     va_pa AS (
         SELECT va.file_date,
                va.bus_line_id,
                va.vehicle_id,
                va.prev_dthr,
                l1.bus_arrival_time,
                va.timestamp,
                va.time_dif,
                va.trajectory_line,
                va.trajectory_azimuth,
                id                                            bus_stop_index,
                sa.name,
                sa.bus_stop_id,
                sa.sequence,
                sa."group",
                sa.direction,
                sa.type,
                sa.itinerary_id,
                sa.geom,
                sa.id                                         shape_sequence,
                sa.shape_id,
                sa.shape_line_geom,
                sa.shape_line_azimuth                         bus_stop_azimuth,
                st_distance                                   distance_from_bus_stop_to_shape,
                l1.distance_bus_to_stop,
                closest_point_vehicle_bus_stop,
                ratio_closest_point_vehicle_bus_stop,
                MIN(l1.distance_bus_to_stop) OVER w_preceding min_distance_bus_to_stop_preceding,
                MIN(l1.distance_bus_to_stop) OVER w_following min_distance_bus_to_stop_following
         FROM veiculos_with_azimuth va -- O onibus e o ponto de onibus precisam ser da mesma linha
                  JOIN tcc_lucas_bus_line_stop_azimuth_2019_05_08_bus_line_203 sa
                       ON va.bus_line_id = sa.bus_line_id AND va.file_date = sa.file_date,
              LATERAL (
                  SELECT
                      -- Calcula o ponto geográfico onde o ônibus mais perto ficou do ponto de ônibus
                      st_closestpoint(va.trajectory_line, sa.geom)    closest_point_vehicle_bus_stop,
                      -- Calcula a proporção sobre a linha de trajetória do ponto geográfico onde o ônibus mais perto ficou do ponto de ônibus
                      st_linelocatepoint(va.trajectory_line, sa.geom) ratio_closest_point_vehicle_bus_stop
                  ) l0,
              LATERAL (
                  SELECT
                      -- Calcula a distância entre o ônibus e o ponto de ônibus
                      st_distance(
                              l0.closest_point_vehicle_bus_stop :: geography,
                              sa.geom :: geography
                          )                                                                  distance_bus_to_stop,
                      -- Calcula a diferença entre o azimute da trajetória e o azimute do ponto de onibus
                      (
                          va.trajectory_azimuth - sa.shape_line_azimuth + PI() + PI() * 2
                          ) :: NUMERIC % (PI() * 2) :: NUMERIC - PI()                        angle_dif,
                      -- Calcula a estimativa do momento passado pelo onibus
                      va.prev_dthr + (va.time_dif * l0.ratio_closest_point_vehicle_bus_stop) bus_arrival_time
                  ) l1
         WHERE TRUE                       -- A distância do ônibus até o ponto de ônibus precisa ser menor que 20m
           AND distance_bus_to_stop <= 40 -- A diferença em graus entre os azimutes precisa estar entre -45 e +45
           AND angle_dif BETWEEN - PI() / 4
             AND PI() / 4
             WINDOW w_preceding AS (
                 PARTITION BY
                     va.file_date,
                     va.bus_line_id,
                     va.vehicle_id,
                     sa.bus_stop_id,
                     sa.sequence
                 ORDER BY
                     timestamp RANGE BETWEEN '20 minutes' PRECEDING
                     AND CURRENT ROW EXCLUDE CURRENT ROW
                 ),
                 w_following AS (
                     PARTITION BY
                         va.file_date,
                         va.bus_line_id,
                         va.vehicle_id,
                         sa.bus_stop_id,
                         sa.sequence
                     ORDER BY
                         timestamp RANGE BETWEEN CURRENT ROW
                     AND INTERVAL '20 days' FOLLOWING EXCLUDE CURRENT ROW
                     )
     ),
     chegadas AS (
         SELECT *
         FROM va_pa
         WHERE TRUE
           AND distance_bus_to_stop < COALESCE(min_distance_bus_to_stop_preceding, '+Infinity')
           AND distance_bus_to_stop <= COALESCE(min_distance_bus_to_stop_following, '+Infinity')
         ORDER BY file_date,
                  bus_line_id,
                  vehicle_id,
                  timestamp
     )
SELECT *
FROM chegadas;
