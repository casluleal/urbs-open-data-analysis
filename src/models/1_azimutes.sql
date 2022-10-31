{%- from 'azimutes.sql' import azimutes -%}

-- Get session volume by demographic
{{ azimutes(bus_line, file_year, file_month, file_day) }}
