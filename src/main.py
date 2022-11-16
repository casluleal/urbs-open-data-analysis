import json
import os

from data_importer import DataImporter

BASE_URL = 'https://dadosabertos.c3sl.ufpr.br/curitibaurbs'
BUS_LINES = ('203', '020')
DEST_FOLDER = 'tmp/'
KEEP_DOWNLOADS = True
ROOT_DIR = os.path.dirname(os.path.abspath(os.curdir))
DROP_TABLES = False
TABLES_PREFIX = 'tcc_lucas_'


def run_algorithm_multiple_times(model_file, dates):
    for date in dates:
        for bus_line in BUS_LINES:
            file_year = date[:4]
            file_month = date[5:7]
            file_day = date[8:]
            file_next_day = str(int(file_day) + 1).zfill(2)

            if 'matches_vs_real' in model_file:
                di.run_algorithm(
                    os.path.join(ROOT_DIR, 'src', 'models', model_file),
                    table_prefix=TABLES_PREFIX,
                    bus_line=bus_line,
                    file_year=file_year,
                    file_month=file_month,
                    file_day=file_day,
                    file_next_day=file_next_day
                )
            else:
                di.run_algorithm(
                    os.path.join(ROOT_DIR, 'src', 'models', model_file),
                    table_prefix=TABLES_PREFIX,
                    bus_line=bus_line,
                    file_year=file_year,
                    file_month=file_month,
                    file_day=file_day
                )


if __name__ == '__main__':
    print('----------- DADOS ABERTOS - URBS -----------')
    with open(os.path.join(ROOT_DIR, 'settings', 'urbs_files.json'), 'r') as f:
        files_dict = json.loads(f.read())
        files_to_import = [file for (file, included) in files_dict.items() if included]

    dates = ['2019-05-' + str(day).zfill(2) for day in range(1, 15)]

    di = DataImporter(files_to_import,
                      BASE_URL,
                      ROOT_DIR,
                      DEST_FOLDER,
                      KEEP_DOWNLOADS,
                      DROP_TABLES,
                      TABLES_PREFIX)

    for date in dates:
        di.import_files(date, BUS_LINES)

    di.run_post_insert_script()

    run_algorithm_multiple_times('1_azimutes.sql', dates)
    run_algorithm_multiple_times('2_matches.sql', dates)
    run_algorithm_multiple_times('3_matches_vs_real.sql', dates)
