import json
import os

from data_importer import DataImporter

BASE_URL = 'https://dadosabertos.c3sl.ufpr.br/curitibaurbs'
DEST_FOLDER = 'tmp/'
KEEP_DOWNLOADS = True
ROOT_DIR = os.path.dirname(os.path.abspath(os.curdir))
TABLE_PREFIX = 'tcc_lucas_'

if __name__ == '__main__':
    print('----------- DADOS ABERTOS - URBS -----------')
    with open(os.path.join(ROOT_DIR, 'settings', 'urbs_files.json'), 'r') as f:
        files_dict = json.loads(f.read())
        files_to_import = [file for (file, included) in files_dict.items() if included]

    di = DataImporter(files_to_import,
                      BASE_URL,
                      ROOT_DIR,
                      DEST_FOLDER,
                      KEEP_DOWNLOADS,
                      TABLE_PREFIX)

    di.import_files('2019-05-08')
