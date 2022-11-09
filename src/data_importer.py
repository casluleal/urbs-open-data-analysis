import json
import lzma
import os
import shutil
import time

import pandas as pd
import requests

from db_client import DbClient
from file_to_table_remapper import FileToTableRemapper
from render import render_sql_template


class DataImporter:

    def __init__(self, files, base_url, root_dir, dest_folder, keep_downloads=True, drop_tables=False,
                 tables_prefix=''):
        self.files = files
        self.base_url = base_url
        self.root_dir = root_dir
        self.dest_folder = dest_folder
        self.keep_downloads = keep_downloads
        self.drop_tables = drop_tables
        self.tables_prefix = tables_prefix
        self.db_client = DbClient()

        self._create_download_folder()
        self._run_pre_insert_script()

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
        table_name = self.tables_prefix + remapper.get_table_name(file_name)
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

        if file_name == 'veiculos':
            df['timestamp'] = pd.to_datetime(df['timestamp'], dayfirst=True)

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

        else:
            print('\t> The file already exists, no need to download it.')
            print('\t\t- Path:', file_path)

    def run_post_insert_script(self):
        print('> Pos-insert steps')

        print('\t> Creating PostGIS fields')
        self._run_sql_file(os.path.join(self.root_dir, 'db', '2_postgis_operators.sql'))
        print('\t\t- PostGIS fields created successfully')

        print('\t> Setting indexes in fields')
        self._run_sql_file(os.path.join(self.root_dir, 'db', '3_create_indexes.sql'))
        print('\t\t- Indexes set successfully')

    def _run_pre_insert_script(self):
        print('> Pre-insert steps')

        if self.drop_tables:
            print('\t> Dropping tables')
            self._run_sql_file(os.path.join(self.root_dir, 'db', '0_drop_tables.sql'))
            print('\t\t- Tables dropped successfully')

        print('\t> Creating tables (if they do not exist)')
        self._run_sql_file(os.path.join(self.root_dir, 'db', '1_tables_ddl.sql'))
        print('\t\t- Tables dropped successfully')

    def _run_sql_file(self, sql_file_path):
        with open(sql_file_path, 'r') as sql:
            result = self.db_client.run_sql_command(sql.read())

            try:
                for row in result:
                    print(row)
            except Exception:
                return

    def run_algorithm(self, model_path: str, **kwargs) -> None:
        print('> Running script', model_path, '-', kwargs)

        sql_script = render_sql_template(model_path, **kwargs)
        result = self.db_client.run_sql_command(sql_script)

        try:
            for row in result:
                print(row)
        except Exception:
            return

        print('\t\t- Script finished successfully')
