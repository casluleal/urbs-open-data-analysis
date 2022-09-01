import json
import lzma
import os
import shutil
import time

import pandas as pd
import requests

from db_client import DbClient
from file_to_table_remapper import FileToTableRemapper


class DataImporter:

    def __init__(self, files, base_url, root_dir, dest_folder, keep_downloads, table_prefix=''):
        self.files = files
        self.base_url = base_url
        self.root_dir = root_dir
        self.dest_folder = dest_folder
        self.keep_downloads = keep_downloads
        self.table_prefix = table_prefix
        self.db_client = DbClient()

        self._create_download_folder()

    def _create_download_folder(self):
        download_path = os.path.join(self.root_dir, self.dest_folder)

        if not os.path.exists(download_path):
            os.makedirs(download_path)
            print('> Folder', self.dest_folder, 'created successfully!')

    def import_files(self, date, bus_lines=()):
        session = requests.Session()

        date_clean = date.replace('-', '_')

        for file in self.files:
            file_name = f'{date_clean}_{file}.json.xz'
            file_path = os.path.join(self.root_dir, self.dest_folder, file_name)

            print('> File', file)

            self._download_file(file_path, session)
            self._insert_db(file, file_path, date, bus_lines)

        if not self.keep_downloads:
            shutil.rmtree(os.path.join(self.root_dir, self.dest_folder))

    def _insert_db(self, file_name, file_path, date, bus_lines):
        remapper = FileToTableRemapper()
        table_name = self.table_prefix + remapper.get_table_name(file_name)
        columns_remapper = remapper.get_columns_remapper(file_name)

        print(f'\t> Inserting into table `{table_name}`')

        if file_name == 'veiculos':
            with lzma.open(file_path, mode='rt') as f:
                file_data = filter(lambda x: x != '\n', f.readlines())

                data = []
                for line in file_data:
                    data.append(json.loads(line))

                df = pd.DataFrame(data)
        else:
            df = pd.read_json(file_path, compression='xz')

        df.rename(columns_remapper, axis=1, inplace=True)
        df['file_date'] = date
        df['file_date'] = pd.to_datetime(df['file_date'])

        df = df.query(f'bus_line_id in @bus_lines')

        df.to_sql(table_name, self.db_client.get_db_engine(), if_exists='append', index=False)

        print('\t\t- Insertion complete')

    def _download_file(self, file_path, session):
        # Download the file if it doesn't exist
        if not os.path.exists(file_path):
            print('\t> Downloading file')
            download_start = time.time()

            url = f'{self.base_url}/{file_path.split("/")[-1]}'
            response = session.get(url)

            with open(file_path, 'wb') as f:
                f.write(response.content)

            download_end = time.time()

            print('\t\t- Download complete. Saved as', file_path)
            print('\t\t- Time elapsed:', round(download_end - download_start, 2), 'secs.')

            # Prevent overloading the server
            # time.sleep(2)
        else:
            print('\t> The file already exists, no need to download it.')
            print('\t\t- Path:', file_path)
