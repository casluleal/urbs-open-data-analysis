import json
import lzma
import os
import shutil
import time

import pandas as pd
import requests

from file_to_table_remapper import FileToTableRemapper
from db_connection import DbConnector

BASE_URL = 'https://dadosabertos.c3sl.ufpr.br/curitibaurbs'
FOLDER = 'tmp/'
ROOT_DIR = os.path.dirname(os.path.abspath(os.curdir))
KEEP_DOWNLOADS = True


class DataImporter:

    def __init__(self, files, root_dir, dest_folder, keep_downloads):
        self.files = files
        self.root_dir = root_dir
        self.dest_folder = dest_folder
        self.keep_downloads = keep_downloads
        self.db_engine = DbConnector().get_db_engine()

        self._create_download_folder()

    def _create_download_folder(self):
        download_path = os.path.join(self.root_dir, self.dest_folder)

        if not os.path.exists(download_path):
            os.makedirs(download_path)
            print('> Folder', self.dest_folder, 'created successfully!')

    def import_files(self, date):
        remapper = FileToTableRemapper()
        session = requests.Session()

        date_clean = date.replace('-', '_')

        for file in self.files:
            file_name = f'{date_clean}_{file}.json.xz'
            file_path = os.path.join(ROOT_DIR, FOLDER, file_name)

            print('> File', file)

            self._download_file(file_path, session)
            self._insert_db(file, file_path, remapper)

        if not KEEP_DOWNLOADS:
            shutil.rmtree(os.path.join(ROOT_DIR, FOLDER))

    def _insert_db(self, file, file_path, remapper):
        table_name = remapper.get_table_name(file)
        columns_remapper = remapper.get_columns_remapper(file)

        print(f'\t> Inserting table `{table_name}`')

        if file == 'veiculos':
            with lzma.open(file_path, mode='rt') as f:
                file_data = filter(lambda x: x != '\n', f.readlines())

                data = []
                for line in file_data:
                    data.append(json.loads(line))

                df = pd.DataFrame(data)
        else:
            df = pd.read_json(file_path, compression='xz')

        df.rename(columns_remapper, axis=1, inplace=True)
        df.to_sql(table_name, self.db_engine, if_exists='append', index=False)

        print('\t\t- Insertion complete')

    @staticmethod
    def _download_file(file_path, session):
        # Download the file if it doesn't exist
        if not os.path.exists(file_path):
            print('\t> Downloading file')
            download_start = time.time()

            url = f'{BASE_URL}/{file_path.split("/")[-1]}'
            response = session.get(url)

            with open(file_path, 'wb') as f:
                f.write(response.content)

            download_end = time.time()

            print('\t\t- Download complete. Saved as', file_path)
            print('\t\t- Time elapsed:', round(download_end - download_start, 2), 'secs.')

            # Prevent overloading the server
            time.sleep(2)
        else:
            print('\t> The file already exists, no need to download it.')
            print('\t\t- Path:', file_path)


if __name__ == '__main__':
    print('----------- DADOS ABERTOS - URBS -----------')
    with open(os.path.join(ROOT_DIR, 'settings', 'urbs_files.json'), 'r') as f:
        files_dict = json.loads(f.read())
        files_to_import = [file for (file, included) in files_dict.items() if included]

    di = DataImporter(files_to_import, ROOT_DIR, dest_folder='tmp', keep_downloads=KEEP_DOWNLOADS)
    di.import_files('2019-05-08')
