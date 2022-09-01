import json
import os

from sqlalchemy import create_engine

ROOT_DIR = os.path.dirname(os.path.abspath(os.curdir))


class DbClient:

    def __init__(self):
        with open(os.path.join(ROOT_DIR, 'settings', 'sql_connection.json'), 'r') as f:
            db = json.loads(f.read())

            self._type = db['type']
            self._username = db['username']
            self._password = db['password']
            self._hostname = db['hostname']
            self._port = db['port']
            self._database = db['database']

        self._engine = None

    def get_db_engine(self):
        if self._engine is not None:
            return self._engine

        login_str = f"{self._type}://{self._username}:{self._password}@{self._hostname}:{self._port}/{self._database}"
        self._engine = create_engine(login_str)

        return self._engine
