import json
import os
import sys

ROOT_DIR = os.path.dirname(os.path.abspath(os.curdir))


class FileToTableRemapper:

    def __init__(self):
        with open(os.path.join(ROOT_DIR, 'settings', 'table_remapping.json')) as f:
            self.remappers = json.loads(f.read())

    def _get_remapper(self, file_name):
        if file_name not in self.remappers.keys():
            print(f'File remapper {file_name} not found.')
            sys.exit(1)

        return self.remappers[file_name]

    def get_table_name(self, file_name):
        remapper = self._get_remapper(file_name)
        return remapper['table_name']

    def get_columns_remapper(self, file_name):
        remapper = self._get_remapper(file_name)
        return remapper['columns']


if __name__ == '__main__':
    t = FileToTableRemapper()
