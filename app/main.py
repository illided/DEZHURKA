from dotenv import load_dotenv, dotenv_values
import psycopg2 as ps
from layouts import *
from datetime import datetime, timedelta
from states import get

if __name__ == '__main__':
    load_dotenv()
    config = dotenv_values(".env")
    conn = ps.connect(dbname=config["DB_NAME"],
                      user=config["USER"],
                      password=config["PASSWORD"],
                      host="localhost")
    conn.autocommit = True
    state = get(date=datetime.today(), money=1000, difficulty=2, newGame=True)
    if state.newGame:
        tables_setup(conn)
        state.newGame = False

    st.sidebar.write(f"Бюджет: {state.money} руб.")
    st.sidebar.write(f"Дата: {str(state.date).split(' ')[0]}")

    page = st.sidebar.selectbox("", ["Задания", "Работники", "Предоставляемые услуги", "Обслуживаемые здания"])
    if page == "Работники":
        workers_layout(conn)
    elif page == "Задания":
        tasks_layout(conn)
    # elif page == "Предоставляемые услуги":
    #     services_layout()
    elif page == "Обслуживаемые здания":
        building_layout(conn)

    if st.sidebar.button("Следующий день"):
        total = count_income(conn) - count_lost(conn)
        state.money = state.money + total
        state.date = state.date + timedelta(days=1)
        add_new_tasks(conn, state.difficulty, str(state.date).split(" ")[0])
        add_new_services(conn)
        rerun()