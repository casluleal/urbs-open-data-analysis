import sys

file_remapper = {
    'linhas': {
        'table_name': 'bus_line',
        'columns': {
            'COD': 'id',
            'NOME': 'name',
            'SOMENTE_CARTAO': 'card_only',
            'CATEGORIA_SERVICO': 'category',
            'NOME_COR': 'color'
        }
    },
    'pontosLinha': {
        'table_name': 'bus_line_stop',
        'columns': {
            'NOME': 'name',
            'NUM': 'bus_stop_id',
            'LAT': 'latitude',
            'LON': 'longitude',
            'SEQ': 'sequence',
            'GRUPO': 'group',
            'SENTIDO': 'direction',
            'TIPO': 'type',
            'ITINERARY_ID': 'itinerary_id',
            'COD': 'bus_line_id'
        }
    },
    'shapeLinha': {
        'table_name': 'bus_line_shape',
        'columns': {
            'SHP': 'shape_id',
            'LAT': 'latitude',
            'LON': 'longitude',
            'COD': 'bus_line_id'
        }
    },
    'tabelaLinha': {
        'table_name': 'bus_line_timetable',
        'columns': {
            'HORA': 'time',
            'PONTO': 'bus_stop_name',
            'DIA': 'type_of_day',
            'NUM': 'bus_stop_id',
            'TABELA': 'timetable_id',
            'ADAPT': 'accessibility',
            'COD': 'bus_line_id'
        }
    },
    'tabelaVeiculo': {
        'table_name': 'bus_vehicle_timetable',
        'columns': {
            'COD_PONTO': 'bus_stop_id',
            'COD_LINHA': 'bus_line_id',
            'NOME_LINHA': 'bus_line_name',
            'VEICULO': 'vehicle_id',
            'HORARIO': 'time',
            'TABELA': 'timetable_id'
        }
    },
    'veiculos': {
        'table_name': 'vehicle_position',
        'columns': {
            'VEIC': 'vehicle_id',
            'LAT': 'latitude',
            'LON': 'longitude',
            'DTHR': 'timestamp',
            'COD_LINHA': 'bus_line_id'
        }
    }
}


def _get_file_remapper(file_name):
    if file_name not in file_remapper.keys():
        print('File remapper not found.')
        sys.exit(1)

    return file_remapper[file_name]


def get_table_name(file_name):
    return _get_file_remapper(file_name)['table_name']


def get_columns_remapper(file_name):
    return _get_file_remapper(file_name)['columns']
