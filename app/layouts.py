import streamlit as st
from logic import *

def rerun():
    raise st.script_runner.RerunException(st.script_request_queue.RerunData(None))

def workers_layout(conn):
    hired, free = get_workers(conn)
    worker_type = st.selectbox("Тип работника", list(set([x[1] for x in hired + free])))
    first, second = st.beta_columns([4, 1])

    hire_buttons = {}
    fire_buttons = {}
    filtered_hired = [x for x in hired if x[1] == worker_type]
    filtered_free = [x for x in free if x[1] == worker_type]

    for worker in filtered_free + filtered_hired:
        FIO = ' '.join(worker[2:4]) + (f" {worker[4]}" if worker[4] is not None else "")
        first.markdown(f"[{worker[1]} - {worker[5]}] {FIO}")

    for worker in filtered_free:
        hire_buttons[worker[0]] = second.button("Нанять", key=worker[0])
    for worker in filtered_hired:
        fire_buttons[worker[0]] = second.button("Уволить", key=worker[0])

    for worker_id, button in hire_buttons.items():
        if button:
            hire_worker(conn, worker_id)
            rerun()

    for worker_id, button in fire_buttons.items():
        if button:
            fire_worker(conn, worker_id)
            rerun()

def tasks_layout():
    pass