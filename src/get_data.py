import json
import os

from src.data_importer import DataImporter

BASE_URL = 'https://dadosabertos.c3sl.ufpr.br/curitibaurbs'
FOLDER = 'tmp/'
ROOT_DIR = os.path.dirname(os.path.abspath(os.curdir))
KEEP_DOWNLOADS = True

if __name__ == '__main__':
    print('----------- DADOS ABERTOS - URBS -----------')
    with open(os.path.join(ROOT_DIR, 'settings', 'urbs_files.json'), 'r') as f:
        files_dict = json.loads(f.read())
        files_to_import = [file for (file, included) in files_dict.items() if included]

    di = DataImporter(files_to_import, ROOT_DIR, dest_folder='tmp', keep_downloads=KEEP_DOWNLOADS)
    di.import_files('2019-05-08')
