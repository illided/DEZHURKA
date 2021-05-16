from dotenv import load_dotenv, dotenv_values
import psycopg2 as ps
from layouts import *


if __name__ == '__main__':
    load_dotenv()
    config = dotenv_values(".env")
    conn = ps.connect(dbname=config["DB_NAME"],
                      user=config["USER"],
                      password=config["PASSWORD"],
                      host="localhost")
    conn.autocommit = True
    # load some state
    date = "2021-01-01"
    page = st.sidebar.selectbox("",["Задания", "Работники", "Предоставляемые услуги", "Обслуживаемые здания"])
    if page == "Работники":
        workers_layout(conn)
    # elif page == "Задания":
    #     tasks_layout()
    # elif page == "Предоставляемые услуги":
    #     services_layout()
    elif page == "Обслуживаемые здания":
        building_layout(conn)
