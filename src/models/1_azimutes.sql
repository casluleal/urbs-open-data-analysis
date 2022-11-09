{%- from '1_azimutes.sql' import azimutes -%}

-- Get session volume by demographic
{{ azimutes(table_prefix, bus_line, file_year, file_month, file_day) }}
