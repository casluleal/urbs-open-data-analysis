CREATE TABLE tcc_lucas_bus_line_stop_azimuth_test AS
WITH chosen_bus_lines AS (
    SELECT *
    FROM (
             VALUES ('020')
         ) AS b (bus_line_id)
),
     chosen_dates AS (
         SELECT *
         FROM (
                  VALUES ('2019-05-01'::DATE)
              ) AS d (file_date)
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
         WHERE file_date IN (
             SELECT *
             FROM chosen_dates
         )
           AND bus_line_id IN (
             SELECT *
             FROM chosen_bus_lines
         )
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
         WHERE file_date IN (
             SELECT *
             FROM chosen_dates
         )
           AND bus_line_id IN (
             SELECT *
             FROM chosen_bus_lines
         )
     ),
     shapes_as_polylines AS (
         SELECT file_date,
                bus_line_id,
                shape_id,
                st_makeline(geom ORDER BY id) AS shape_polyline_geom
         FROM tcc_lucas_bus_line_shape
         WHERE file_date IN (
             SELECT *
             FROM chosen_dates
         )
           AND bus_line_id IN (
             SELECT *
             FROM chosen_bus_lines
         )
         GROUP BY file_date, bus_line_id, shape_id
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
                           WHERE pl.bus_line_id IN (
                               SELECT *
                               FROM chosen_bus_lines
                           )
                             AND pl.file_date IN (
                               SELECT *
                               FROM chosen_dates
                           )
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
                  SELECT pl.*,
                         sa.id "bus_line_shape_id",
                         sa.shape_id,
                         shape_line_geom,
                         shape_line_azimuth,
                         st_distance(pl.geom, shape_line_geom),
                         ROW_NUMBER() OVER (
                             PARTITION BY pl.file_date, pl.id
                             ORDER BY
                                 st_distance(pl.geom, shape_line_geom)
                             ) "row_number"
                  FROM pontos_linha pl
                           JOIN shapes_and_sentidos ss
                                ON ss.bus_line_id = pl.bus_line_id
                                    AND ss.direction = pl.direction
                           JOIN shapes_and_azimuths sa
                                ON sa.bus_line_id = ss.bus_line_id
                                    AND sa.shape_id = ss.shape_id
                  WHERE pl.bus_line_id IN (
                      SELECT *
                      FROM chosen_bus_lines
                  )
              ) AS q1
         WHERE row_number = 1
         ORDER BY bus_line_id,
                  direction,
                  sequence
     )
SELECT *
FROM pontos_linha_and_azimuths;
