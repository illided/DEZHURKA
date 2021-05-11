import streamlit as st
import pandas as pd
import psycopg2
from dotenv import load_dotenv, dotenv_values
import sqlalchemy as sq


def get_session_id():
    session_id = st.report_thread.get_report_ctx().session_id
    session_id = session_id.replace('-', '_')
    session_id = '_id_' + session_id
    return session_id


def write_state(column, value, engine, session_id):
    engine.execute("UPDATE %s SET %s='%s'" % (session_id, column, value))


def write_state_df(df, engine, session_id):
    df.to_sql('%s' % (session_id), engine, index=False, if_exists='replace', chunksize=1000)


def read_state(column, engine, session_id):
    state_var = engine.execute("SELECT %s FROM %s" % (column, session_id))
    state_var = state_var.first()[0]
    return state_var


def read_state_df(engine, session_id):
    try:
        df = pd.read_sql_table(session_id, con=engine)
    except:
        df = pd.DataFrame([])
    return df


if __name__ == '__main__':
    load_dotenv()
    config = dotenv_values(".env")
    engine = sq.create_engine(f'postgresql+psycopg2'
                              f'://{config["USER"]}:{config["PASSWORD"]}'
                              f'@localhost:5432/{config["DB_NAME"]}')

