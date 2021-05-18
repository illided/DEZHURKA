create or replace procedure create_task(
    service_type varchar(400),
    info varchar(400),
    building_address varchar(250),
    room integer default NULL,
    creation_date date default current_date,
    completion_date date default NULL
)
    language plpgsql as
$$
declare
    _building_id integer;
    _worker_type worker_type;
    _room_id     integer;
begin
    _building_id = (select id from buildings where address = building_address);
    _room_id = (select id from rooms where rooms.room_number = room and building = _building_id);
    _worker_type = (select worker_type from services where description = service_type);
    insert into tasks (type, description, assigned_at, deadline, building_id, room_id)
    values (_worker_type, info, creation_date, completion_date, _building_id, _room_id);
end;
$$;

create or replace procedure review_task(
    task_id integer,
    chosen_difficulty integer
)
    language plpgsql as
$$
declare
    _was_updated bool;
begin
    with u as (update tasks
        set difficulty = chosen_difficulty,
            progress = 'reviewed'
        where task_id = id
            and progress = 'created'
        returning true)
    select *
    from u
    limit 1
    into _was_updated;
    if not _was_updated then
        raise 'The task is being processed, rejected, or has never been submitted for execution';
    end if;
end;
$$;

create or replace function assign_task(
    _task_id integer
) returns integer
    language plpgsql as
$$
declare
    _building_id integer;
    _type        worker_type;
    _worker_id   integer;
    _difficulty  integer;
begin
    select building_id, type, difficulty from tasks where id = _task_id into _building_id, _type, _difficulty;
    if _building_id is Null then
        raise 'No task with such id';
    end if;
    _worker_id = (with possible_workers as (select w.id
                                            from (select id
                                                  from workers
                                                  where type = _type
                                                    and qualification >= _difficulty) as w
                                                     left join workloads on workloads.id = w.id
                                            order by num_of_tasks)
                  select worker_id
                  from possible_workers
                           join service_assignment on id = worker_id
                  union all
                  select *
                  from possible_workers
                  limit 1);
    if _worker_id is NULL then
        raise 'No worker can take such task';
    end if;
    insert into task_assignment(task_id, worker_id) values (_task_id, _worker_id);
    update tasks set progress = 'assigned' where id = _task_id;
    return _worker_id;
end;
$$;

create or replace function fire_worker(
    _worker_id integer
)
    returns table
            (
                _task_id integer
            )
    language plpgsql
as
$$
declare
    _task task_assignment;
begin
    drop table if exists unassigned;
    create temp table unassigned as
    select task_id from task_assignment where worker_id = _worker_id;
    delete from workers where id = _worker_id;
    for _task in
        select * from unassigned
        loop
            perform assign_task(_task.task_id);
        end loop;
    return query select * from unassigned;
end;
$$;

create or replace function find_unfitting_tasks(
    _worker_id integer
)
    returns table
            (
                task_id            integer,
                recommended_worker integer
            )
    language sql
as
$$
with worker_tasks as (select t.task_id, building_id
                      from task_assignment
                               join (select id as task_id, building_id
                                     from tasks
                                     where progress = 'assigned') t
                                    on t.task_id = task_assignment.task_id
                      where worker_id = _worker_id)
select task_id, worker_id
from worker_tasks
         join service_assignment on service_assignment.building_id = worker_tasks.building_id
where worker_id != _worker_id;
$$;

create or replace procedure swap_tasks_workers(
    _first_task integer,
    _second_task integer)
    language plpgsql as
$$
declare
    _first_worker  integer;
    _second_worker integer;
begin
    select worker_id from task_assignment where task_id = _first_task into _first_worker;
    select worker_id from task_assignment where task_id = _second_task into _second_worker;
    update task_assignment set worker_id = _first_worker where task_id = _second_task;
    update task_assignment set worker_id = _second_worker where task_id = _first_task;
end;
$$;

create or replace procedure adjust_for_service_assignments()
    language plpgsql as
$$
declare
    _worker_id   workers;
    _first_task  integer;
    _second_task integer;
begin
    drop table if exists recommended_workers;
    create temp table recommended_workers
    (
        task_id     integer,
        recommended integer,
        actual      integer
    );
    for _worker_id in
        select id
        from workers
                 join service_assignment sa on workers.id = sa.worker_id
        loop
            with recomendation as (select task_id, recommended_worker from find_unfitting_tasks(_worker_id.id))
            insert
            into recommended_workers
            select task_id, recommended_worker, _worker_id.id
            from recomendation;
        end loop;
    for _first_task, _second_task in
        select rw1.task_id, rw2.task_id
        from recommended_workers rw1
                 join recommended_workers rw2
                      on rw1.recommended = rw2.actual and rw1.actual = rw2.recommended
        where rw1.task_id > rw2.task_id
        loop
            call swap_tasks_workers(_first_task, _second_task);
        end loop;
end;
$$;
