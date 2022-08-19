import json
import lzma
import os
import shutil
import time

import requests

BASE_URL = 'https://dadosabertos.c3sl.ufpr.br/curitibaurbs'
FILES = {
    'trechosItinerarios': True,
    'tabelaVeiculo': False,
    'tabelaLinha': False,
    'shapeLinha': False,
    'pontosLinha': False,
    'pois': False,
    'linhas': False,
}
FOLDER = 'tmp/'
ROOT_DIR = os.path.dirname(os.path.abspath(os.curdir))
KEEP_DOWNLOADS = True


def main():
    print('----------- DADOS ABERTOS - URBS -----------')

    if not os.path.exists(os.path.join(ROOT_DIR, FOLDER)):
        os.makedirs(os.path.join(ROOT_DIR, FOLDER))
        print('> Folder', FOLDER, 'created successfully!')

    date = '2022_08_18'
    session = requests.Session()

    for file, included in FILES.items():
        if not included:
            continue

        file_name = f'{date}_{file}.json.xz'
        file_path = os.path.join(ROOT_DIR, FOLDER, file_name)

        print('> File', file_name)

        # Download the file if it doesn't exist
        if not os.path.exists(file_path):
            print('\t> Downloading file')
            download_start = time.time()

            url = f'{BASE_URL}/{file_name}'
            response = session.get(url)

            with open(file_path, 'wb') as f:
                f.write(response.content)

            download_end = time.time()

            print('\t\t- Download complete. Saved as', file_path)
            print('\t\t- Time elapsed:', round(download_end - download_start, 2), 'secs.')
        else:
            print('\t> The file already exists, no need to download it.')
            print('\t\t- Path:', file_path)

        with lzma.open(file_path, mode='rt') as file_data:
            print('\t> Uncompressing file', file_name)
            data = json.loads(file_data.read())

    if not KEEP_DOWNLOADS:
        shutil.rmtree(os.path.join(ROOT_DIR, FOLDER))


if __name__ == '__main__':
    main()
