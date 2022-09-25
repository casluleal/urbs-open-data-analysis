import json
import os

from data_importer import DataImporter

BASE_URL = 'https://dadosabertos.c3sl.ufpr.br/curitibaurbs'
BUS_LINES = ('203', '020')
DEST_FOLDER = 'tmp/'
KEEP_DOWNLOADS = True
ROOT_DIR = os.path.dirname(os.path.abspath(os.curdir))
DROP_TABLES = True
TABLES_PREFIX = 'tcc_lucas_'

if __name__ == '__main__':
    print('----------- DADOS ABERTOS - URBS -----------')
    with open(os.path.join(ROOT_DIR, 'settings', 'urbs_files.json'), 'r') as f:
        files_dict = json.loads(f.read())
        files_to_import = [file for (file, included) in files_dict.items() if included]

    dates = ['2019-05-' + str(day).zfill(2) for day in range(1, 9)]

    di = DataImporter(files_to_import,
                      BASE_URL,
                      ROOT_DIR,
                      DEST_FOLDER,
                      KEEP_DOWNLOADS,
                      DROP_TABLES,
                      TABLES_PREFIX)
    for date in dates:
        di.import_files(date, BUS_LINES)
