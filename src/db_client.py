import json
import os

import sqlalchemy
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

        login_str = f"{self._type}://{self._username}:{self._password}@{self._hostname}:{self._port}/{self._database}"
        self._engine = create_engine(login_str)

    def get_db_engine(self):
        return self._engine

    def run_sql_command(self, command):
        with self._engine.connect() as conn:
            conn = conn.execution_options(isolation_level='AUTOCOMMIT')

            command = sqlalchemy.text(command)
            with conn.begin():
                result = conn.execute(command)
                return result
