{%- from 'matches_vs_real.sql' import matches_vs_real -%}

{{ matches_vs_real(bus_line, file_year, file_month, file_day, file_next_day) }}
