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
        first.markdown(f"### [{worker[1]} - {worker[5]}] {FIO}")

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


def building_layout(conn):
    b_type = st.selectbox("Тип здания", ["Техническое", "Жилое"])
    if b_type == "Жилое":
        served, free = get_living_buildings(conn)
        first, second = st.beta_columns([3, 1])

        for building in free + served:
            first.markdown(f"### {building[1]}")
        add = {building_id: second.button("Добавить", key=building_id) for building_id in [x[0] for x in free]}
        delete = {building_id: second.button("Удалить", key=building_id) for building_id in [x[0] for x in served]}
        for building_id, button in add.items():
            if button:
                add_building(conn, building_id)
                rerun()
        for building_id, button in delete.items():
            if button:
                delete_building(conn, building_id)
                rerun()
    else:
        technical = get_technical_buildings(conn)
        for building in technical:
            st.markdown(f"### {building[1]}")


def tasks_layout(conn):
    progress = st.selectbox("Прогресс",
                             ['created', 'reviewed', 'rejected', 'assigned', 'work in progress', 'completed'])

    for task in retrieve_tasks(conn, progress):
        st.markdown(f"""
        **{task[1]}**. **Принято на обработку:** {task[4]}. **Дедлайн:** {task[5]} \n
        **Описание:** {task[2]}
        """)
        if progress == "created":
            st.write("Feature coming")