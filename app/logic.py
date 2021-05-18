import random
from random import choice

num_of_services = 13


def tables_setup(conn):
    with conn.cursor() as cursor:
        cursor.execute("""
        truncate table services cascade;

        truncate table service_assignment cascade;

        truncate table reject_cause cascade;
        
        truncate table task_assignment cascade;
        
        truncate table workers cascade;
        
        truncate table tasks cascade;
        
        truncate table rooms cascade;
        
        truncate table buildings cascade;
        
        insert into buildings(id, address, type)
        values (8, 'штаб Сантехников', 'technical'),
       (9, 'Склад', 'technical'),
       (10, 'ДЕЖУРКА', 'technical');
        """)
        cursor.execute("insert into services values (2, 'Починка электроснабжения', 'electrician')")


def add_new_tasks(conn, difficulty, date):
    cursor = conn.cursor()

    cursor.execute("SELECT description FROM services")
    services = [x[0] for x in cursor.fetchall()]

    cursor.execute("SELECT address FROM buildings")
    buildings = [x[0] for x in cursor.fetchall()]

    service_string = ','.join([f"\'{x}\'" for x in services])
    cursor.execute(f"SELECT service_type, description FROM possible_tasks"
                   f" WHERE difficulty <= {difficulty}"
                   f" AND service_type IN ({service_string})")
    tasks = cursor.fetchall()

    tasks_assigned = [[*choice(tasks), building] for building in buildings if random.randint(1, 4) == 4]

    for task in tasks_assigned:
        cursor.execute(f"CALL create_task('{task[0]}', '{task[1]}', '{task[2]}', creation_date :='{date}')")


def check_answer(conn, task_id, choosen_dif):
    cursor = conn.cursor()

    cursor.execute(f"SELECT description FROM tasks WHERE id={task_id}")
    description = cursor.fetchone()

    cursor.execute(f"SELECT difficulty FROM possible_tasks WHERE description = '{description[0]}'")
    actual = cursor.fetchone()[0]
    cursor.close()

    if actual == -1 and choosen_dif != -1 or actual > choosen_dif:
        return "wrong"
    elif actual == -1:
        return "ok_rejected"
    else:
        return "ok"


def review_task(conn, task_id, chosen_dif):
    with conn.cursor() as cursor:
        cursor.execute(f"call review_task({task_id}, {chosen_dif})")


def reject_task(conn, task_id):
    with conn.cursor() as cursor:
        cursor.execute(f"UPDATE tasks SET progress='rejected' WHERE id={task_id}")


def assign_task(conn, task_id):
    with conn.cursor() as cursor:
        cursor.execute(f"select assign_task({task_id})")


def count_income(conn):
    return 100


def count_lost(conn):
    return 50


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
        target = ",".join([f"\'{x}\'" if x is not None else "DEFAULT" for x in cursor.fetchone()])
        cursor.execute(f"insert into workers(id, type, surname, name, patronymic, qualification)"
                       f" values ({target})")


def fire_worker(conn, worker_id):
    with conn.cursor() as cursor:
        cursor.execute(f"SELECT fire_worker({worker_id})")


def get_living_buildings(conn):
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM buildings WHERE type=\'living\'")
        served = cursor.fetchall()
        where_statement = "" if len(served) == 0 else f"WHERE id NOT IN ({','.join([str(x[0]) for x in served])})"
        cursor.execute(f"SELECT * FROM possible_buildings {where_statement}")
        free = cursor.fetchall()
    return served, free


def get_technical_buildings(conn):
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM buildings WHERE type=\'technical\'")
        buildings = cursor.fetchall()
    return buildings


def add_building(conn, building_id):
    with conn.cursor() as cursor:
        cursor.execute(f"SELECT * FROM possible_buildings WHERE id={building_id}")
        building = tuple([str(x) for x in cursor.fetchone()])
        cursor.execute(f"INSERT INTO buildings(id, address, type) values {building}")


def delete_building(conn, building_id):
    with conn.cursor() as cursor:
        cursor.execute(f"DELETE FROM buildings WHERE id={building_id}")


def retrieve_tasks(conn, progress):
    with conn.cursor() as cursor:
        cursor.execute(f"SELECT * FROM tasks WHERE progress=\'{progress}\'")
        return cursor.fetchall()


def get_services(conn):
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM services")
        return cursor.fetchall()


def add_new_services(conn):
    with conn.cursor() as cursor:
        if random.randint(1, 4) == 4:
            try:
                cursor.execute(
                    f"INSERT INTO services"
                    f" SELECT * FROM possible_services"
                    f" OFFSET {random.randint(0, num_of_services)} LIMIT 1")
            except:
                pass
