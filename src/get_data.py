import json
import lzma
import os
import shutil
import time

import pandas as pd
import requests
from sqlalchemy import create_engine

from file_remapper import get_table_name, get_columns_remapper

BASE_URL = 'https://dadosabertos.c3sl.ufpr.br/curitibaurbs'
FILES = {
    'trechosItinerarios': False,
    'tabelaVeiculo': True,
    'tabelaLinha': True,
    'shapeLinha': True,
    'pontosLinha': True,
    'veiculos': False,
    'pois': False,
    'linhas': True,
}
FOLDER = 'tmp/'
ROOT_DIR = os.path.dirname(os.path.abspath(os.curdir))
KEEP_DOWNLOADS = True

session = requests.Session()


def get_db_engine():
    with open(os.path.join(ROOT_DIR, 'keys', 'sql_connection.json'), 'r') as f:
        db = json.loads(f.read())

        return create_engine(
            f"{db['type']}://{db['username']}:{db['password']}@{db['hostname']}:{db['port']}/{db['database']}")


def main():
    print('----------- DADOS ABERTOS - URBS -----------')

    engine = get_db_engine()

    date = '2019_05_08'
    files = [file for (file, included) in FILES.items() if included]

    create_download_folder()

    for file in files:
        file_name = f'{date}_{file}.json.xz'
        file_path = os.path.join(ROOT_DIR, FOLDER, file_name)

        print('> File', file)

        table_name = get_table_name(file)
        columns_remapper = get_columns_remapper(file)

        download_file(file_path)

        df = pd.read_json(file_path, compression='xz')
        df.rename(columns_remapper, axis=1, inplace=True)

        df.to_sql(table_name, engine, if_exists='append', index=False)

    if not KEEP_DOWNLOADS:
        shutil.rmtree(os.path.join(ROOT_DIR, FOLDER))


def create_download_folder():
    if not os.path.exists(os.path.join(ROOT_DIR, FOLDER)):
        os.makedirs(os.path.join(ROOT_DIR, FOLDER))
        print('> Folder', FOLDER, 'created successfully!')


def read_file(file):
    with lzma.open(file, mode='rt') as file_data:
        file_name = file.split('/')[-1]
        print('\t> Uncompressing file', file_name)

        if 'veiculos' in file_name:
            data = str(file_data.readlines())
        else:
            data = file_data.read()

        return json.loads(data)


def download_file(file_path):
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
        time.sleep(5)
    else:
        print('\t> The file already exists, no need to download it.')
        print('\t\t- Path:', file_path)


if __name__ == '__main__':
    main()
