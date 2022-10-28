--------------- SETTING CURITIBA'S TIMEZONE ---------------
SET TIMEZONE = 'America/Sao_Paulo';

CREATE TABLE tcc_lucas_matches_vs_real_2019_05_02_bus_line_020 AS
--------------- BUS LINE ID ---------------
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
    FROM tcc_lucas_vehicle_position_2019_05_02_bus_line_020
),
     pontos_linha AS (
         SELECT
             -- (index) índice do ponto
             id,
             -- (nome) nome do ponto
             name,
             -- (num) código do ponto
             bus_stop_id,
             -- (seq) índice do ponto no percurso
             sequence,
             -- (grupo) grupo a qual este ponto de ônibus faz parte, onde pessoas podem pegar outros ônibus com uma mesma passagem
             "group",
             -- (sentido) nome do último ponto de ônibus no final do percurso
             direction,
             -- (tipo) tipo do ponto de ônibus
             type,
             -- (itinerary_id) id do itinerário
             itinerary_id,
             -- (cod) código da linha
             bus_line_id,
             -- (geom) coordenada geográfica do ponto de ônibus
             geom,
             -- a data do arquivo que originou o dado
             file_date
         FROM tcc_lucas_bus_line_stop
         WHERE file_date = '2019-05-02'
           AND bus_line_id = '020'
     ),
     shape_linha AS (
         SELECT id,
                shape_id,
                latitude,
                longitude,
                geom,
                bus_line_id,
                file_date
         FROM tcc_lucas_bus_line_shape
         WHERE file_date = '2019-05-02'
           AND bus_line_id = '020'
     ),
     tabela_veiculo AS (
         SELECT bus_line_id,
                bus_line_name,
                vehicle_id,
                "time",
                ("time" + file_date)::timestamptz programmed_timestamp,
                timetable_id,
                bus_stop_id,
                file_date
         FROM tcc_lucas_bus_vehicle_timetable
         WHERE file_date = '2019-05-02'
           AND bus_line_id = '020'
     ),
--------------- TABLE JOINS ---------------
--------------- SHAPES WITH AZIMUTHS ALGORITHMS ---------------
     shapes_as_polylines AS (
         SELECT file_date,
                bus_line_id,
                shape_id,
                st_makeline(geom ORDER BY id) shape_polyline_geom
         FROM shape_linha
         GROUP BY 1, 2, 3
     ),
     shapes_and_sentidos AS (
         SELECT file_date,
                bus_line_id,
                shape_id,
                direction
         FROM (
                  SELECT ROW_NUMBER() OVER (
                      PARTITION BY (file_date, bus_line_id)
                      ORDER BY
                          COUNT(*) DESC
                      )                                                            rank,
                         COUNT(*) OVER (PARTITION BY (file_date, bus_line_id))     rank_max,
                         COUNT(*) OVER (PARTITION BY (file_date, bus_line_id)) / 2 top_ranks,
                         COUNT(*),
                         file_date,
                         bus_line_id,
                         shape_id,
                         direction
                  FROM (
                           SELECT x1.st_distance,
                                  ROW_NUMBER() OVER (
                                      PARTITION BY pl.file_date, pl.id
                                      ORDER BY
                                          x1.st_distance
                                      ) rank,
                                  pl.file_date,
                                  pl.bus_line_id,
                                  pl.direction,
                                  sap.shape_id
                           FROM pontos_linha pl
                                    JOIN shapes_as_polylines sap
                                         ON pl.file_date = sap.file_date AND pl.bus_line_id = sap.bus_line_id,
                                LATERAL (
                                    SELECT st_distance(pl.geom, sap.shape_polyline_geom) AS st_distance
                                    ) x1
                           WHERE pl.bus_line_id = '020'
                           ORDER BY pl.file_date,
                                    pl.bus_line_id,
                                    pl.direction,
                                    pl.sequence
                       ) q1
                  WHERE rank = 1
                  GROUP BY (
                            file_date,
                            bus_line_id,
                            shape_id,
                            direction
                               )
              ) q2
         WHERE rank <= top_ranks
     ),
--------------- CREATE SHAPES AND AZIMUTHS ---------------
     shapes_and_azimuths AS (
         SELECT *
         FROM (
                  SELECT *,
                         LAG(geom) OVER w,
                         st_makeline(
                                         LAG(geom) OVER w,
                                         geom
                             ) shape_line_geom,
                         st_azimuth(
                                         LAG(geom) OVER w,
                                         geom
                             ) shape_line_azimuth
                  FROM shape_linha
                      WINDOW w AS (PARTITION BY (file_date, bus_line_id, shape_id) ORDER BY id)
              ) AS q1
         WHERE shape_line_azimuth IS NOT NULL
     ),
     pontos_linha_and_azimuths AS (
         SELECT *
         FROM (
                  SELECT pl.id                                 "pl_id",
                         pl.*,
                         sa.id                                 "sa_id",
                         sa.shape_id,
                         shape_line_geom,
                         shape_line_azimuth,
                         st_distance(pl.geom, shape_line_geom) "st_distance",
                         ROW_NUMBER() OVER (
                             PARTITION BY pl.file_date, pl.id
                             ORDER BY
                                 st_distance(pl.geom, shape_line_geom)
                             )                                 "row_number"
                  FROM pontos_linha pl
                           JOIN shapes_and_sentidos ss ON ss.bus_line_id = pl.bus_line_id
                      AND ss.direction = pl.direction
                           JOIN shapes_and_azimuths sa ON sa.bus_line_id = ss.bus_line_id
                      AND sa.shape_id = ss.shape_id
                  WHERE pl.bus_line_id = '020'
              ) AS q1
         WHERE row_number = 1
         ORDER BY bus_line_id,
                  direction,
                  sequence
     ),
-- **************** VEICULOS WITH AZIMUTHS ****************
     veiculos_with_azimuth AS (
         SELECT file_date,
                bus_line_id,
                vehicle_id,
                LAG(timestamp) OVER w               AS prev_dthr,
                timestamp,
                timestamp - LAG(timestamp) OVER w      time_dif,
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
                pa.id                                         bus_stop_index,
                pa.name,
                pa.bus_stop_id,
                pa.sequence,
                pa."group",
                pa.direction,
                pa.type,
                pa.itinerary_id,
                geom,
                pa.sequence                                   shape_sequence,
                pa.shape_id,
                pa.shape_line_geom,
                pa.shape_line_azimuth                         bus_stop_azimuth,
                st_distance                                   distance_from_bus_stop_to_shape,
                l1.distance_bus_to_stop,
                closest_point_vehicle_bus_stop,
                ratio_closest_point_vehicle_bus_stop,
                MIN(l1.distance_bus_to_stop) OVER w_preceding min_distance_bus_to_stop_preceding,
                MIN(l1.distance_bus_to_stop) OVER w_following min_distance_bus_to_stop_following
         FROM veiculos_with_azimuth va -- O onibus e o ponto de onibus precisam ser da mesma linha
                  JOIN pontos_linha_and_azimuths pa
                       ON va.bus_line_id = pa.bus_line_id
                           AND va.file_date = pa.file_date,
              LATERAL (
                  SELECT
                      -- Calcula o ponto geográfico onde o ônibus mais perto ficou do ponto de ônibus
                      st_closestpoint(va.trajectory_line, pa.geom)    closest_point_vehicle_bus_stop,
                      -- Calcula a proporção sobre a linha de trajetória do ponto geográfico onde o ônibus mais perto ficou do ponto de ônibus
                      st_linelocatepoint(va.trajectory_line, pa.geom) ratio_closest_point_vehicle_bus_stop
                  ) l0,
              LATERAL (
                  SELECT
                      -- Calcula a distância entre o ônibus e o ponto de ônibus
                      st_distance(
                              l0.closest_point_vehicle_bus_stop :: geography,
                              pa.geom :: geography
                          )                                                                  distance_bus_to_stop,
                      -- Calcula a diferença entre o azimute da trajetória e o azimute do ponto de onibus
                      (
                          va.trajectory_azimuth - pa.shape_line_azimuth + PI() + PI() * 2
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
                     pa.bus_stop_id,
                     pa.sequence
                 ORDER BY
                     timestamp RANGE BETWEEN '20 minutes' PRECEDING
                     AND CURRENT ROW EXCLUDE CURRENT ROW
                 ),
                 w_following AS (
                     PARTITION BY
                         va.file_date,
                         va.bus_line_id,
                         va.vehicle_id,
                         pa.bus_stop_id,
                         pa.sequence
                     ORDER BY
                         timestamp RANGE BETWEEN CURRENT ROW
                     AND '20 minutes' FOLLOWING EXCLUDE CURRENT ROW
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
                  "timestamp"
     ),
     chegadas_bus_stop_distinct AS (
         SELECT DISTINCT bus_line_id, vehicle_id, bus_stop_id, bus_arrival_time
         FROM chegadas
     ),
     tabela_veiculo_window AS (
         SELECT *,
                LAG("time") OVER w,
                "time" - LAG("time") OVER w  dif_lag,
                LEAD("time") OVER w,
                LEAD("time") OVER w - "time" dif_lead
         FROM tabela_veiculo
             WINDOW w AS (PARTITION BY bus_line_id, vehicle_id, bus_stop_id ORDER BY "time")
         ORDER BY bus_line_id, vehicle_id, "time"
     ),
     tabela_veiculo_bounds AS (
         SELECT *
         FROM tabela_veiculo_window,
              LATERAL (
                  SELECT GREATEST("time" - LEAST(dif_lag / 2, "time"::INTERVAL),
                                  '00:00:00'::TIME WITH TIME ZONE) +
                         file_date                             left_bound,
                         LEAST("time" + LEAST(dif_lead / 2, '23:59:59'::INTERVAL - "time"),
                               '23:59:59'::TIME WITH TIME ZONE) + file_date right_bound
                  ) l1
     ),
     chegadas_com_teoricos AS (
         SELECT tvb.*,
                c.bus_arrival_time,
                c.bus_arrival_time - tvb.programmed_timestamp AS bus_delay
         FROM tabela_veiculo_bounds tvb
                  LEFT JOIN chegadas_bus_stop_distinct c ON TRUE
             AND c.bus_line_id = tvb.bus_line_id
             AND c.vehicle_id = tvb.vehicle_id
             AND c.bus_stop_id = tvb.bus_stop_id
--AND c.bus_arrival_time BETWEEN tvb.left_bound AND tvb.right_bound 
             AND c.bus_arrival_time >= tvb.left_bound
             AND c.bus_arrival_time < tvb.right_bound
     ),
     matches_theorical_report AS (
         SELECT bus_line_id,
                vehicle_id,
                programmed_timestamp,
                SUM(CASE WHEN bus_arrival_time IS NULL THEN 0 ELSE 1 END) "sum"
         FROM chegadas_com_teoricos
         GROUP BY bus_line_id, vehicle_id, programmed_timestamp
     ),
     matches_theorical_report_count AS (
         SELECT bus_line_id,
                vehicle_id,
                COUNT(*) FILTER (WHERE "sum" = 1)                          eq_1,
                COUNT(*) FILTER (WHERE "sum" <> 1)                         dif_1,
                COUNT(*)                                                   total,
                (COUNT(*) FILTER (WHERE "sum" = 1))::REAL / COUNT(*)::REAL ratio
         FROM matches_theorical_report
         GROUP BY bus_line_id, vehicle_id
     ),
     chegadas_com_teoricos_filtrados AS (
         SELECT *,
                DATE_PART('epoch', bus_delay) / 60 bus_delay_minutes
         FROM chegadas_com_teoricos
         WHERE vehicle_id IN (
             SELECT vehicle_id
             FROM matches_theorical_report_count
             WHERE ratio > 0.75
         )
     )
SELECT *
FROM chegadas_com_teoricos_filtrados