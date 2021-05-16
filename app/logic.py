import random
from random import choice


def add_new_tasks(conn, difficulty, date):
    cursor = conn.cursor()

    cursor.execute("SELECT description FROM services")
    services = [x[0] for x in cursor.fetchall()]

    cursor.execute("SELECT address FROM buildings")
    buildings = [x[0] for x in cursor.fetchall()]

    cursor.execute(f"SELECT service_type, description FROM possible_tasks"
                   f" WHERE difficulty <= {difficulty}"
                   f" AND service_type IN {tuple(services)}")
    tasks = cursor.fetchall()

    tasks_assigned = [[*choice(tasks), building] for building in buildings if random.randint(1, 4) == 4]

    for task in tasks_assigned:
        cursor.execute(f"CALL create_task({task[0]}, {task[1]}, {task[2]}, {date}")


def check_answer(conn, task_id, choosen_dif):
    cursor = conn.cursor()

    cursor.execute(f"SELECT difficulty FROM possible_tasks WHERE id = {task_id}")
    actual = cursor.fetchone()
    cursor.close()

    if actual == -1 and choosen_dif != -1 or actual > choosen_dif:
        return "wrong"
    else:
        return "ok"


# def review_tasks(conn):
#     cursor = conn.cursor()
#
#     cursor.execute("SELECT * FROM currently_reviewing")
#     tasks = cursor.fetchall()
#     for task in tasks:
#         result = check_answer(conn, task[0], task[1])
#         if result == "ok":
#             cursor.execute(f"SELECT * FROM tasks WHERE id={task[0]}")
#             task = cursor.fetchone()
#             cursor.execute(f"CALL assign_task()")


def count_income(conn):
    pass


def count_lost(conn):
    pass


def get_workers(conn):
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM workers")
    hired = cursor.fetchall()

    where_statement = "" if len(hired) == 0 else f"WHERE id NOT IN ({','.join([str(x[0]) for x in hired])})"
    cursor.execute(f"SELECT * FROM unlockable_workers {where_statement}")
    free = cursor.fetchall()
    cursor.close()

    return hired, free


def hire_worker(conn, worker_id):
    with conn.cursor() as cursor:
        cursor.execute(f"SELECT * FROM unlockable_workers WHERE id={worker_id}")
        target = tuple([f"{str(x)}" for x in cursor.fetchone()])
        cursor.execute(f"insert into workers(id, type, surname, name, patronymic, qualification)"
                       f" values {target}")


def fire_worker(conn, worker_id):
    with conn.cursor() as cursor:
        cursor.execute(f"SELECT fire_worker({worker_id})")


def get_buildings(conn):
    pass
