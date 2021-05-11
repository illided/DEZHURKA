create type buildings_types as enum ('technical', 'living');

create table buildings
(
    id      SERIAL PRIMARY KEY,
    address VARCHAR(250)    NOT NULL UNIQUE,
    type    buildings_types NOT NULL
);

create table rooms
(
    id          SERIAL PRIMARY KEY,
    room_number integer                           NOT NULL,
    building    integer references buildings (id) NOT NULL,
    UNIQUE (building, room_number)
);

create type worker_type as enum ('electrician',
    'plumber', 'carpenter', 'cleaner', 'exterminator','elevator_operator', 'chairman');

create table workers
(
    id            SERIAL PRIMARY KEY,
    type          worker_type NOT NULL,
    surname       varchar(50) NOT NULL,
    name          varchar(50) NOT NULL,
    patronymic    varchar(50),
    qualification integer     NOT NULL,
    UNIQUE (type, surname, name, patronymic)
);


create table services
(
    service_id  SERIAL PRIMARY KEY,
    description varchar(400) NOT NULL UNIQUE,
    worker_type worker_type  NOT NULL
);

create table service_assignment
(
    building_id integer references buildings (id)                 NOT NULL,
    worker_id   integer references workers (id) on delete cascade NOT NULL,
    UNIQUE (building_id, worker_id)
);

create type completion as enum ('created', 'reviewed', 'rejected', 'assigned', 'work in progress', 'completed');

create table tasks
(
    id          SERIAL PRIMARY KEY,
    type        worker_type                       NOT NULL,
    description varchar(400)                      NOT NULL,
    progress    completion                        NOT NULL DEFAULT 'created' check (
        (not progress in ('created', 'rejected')) = (difficulty is NOT NULL)),
    assigned_at date                              NOT NULL,
    deadline    date                              NOT NULL,
    difficulty  integer,
    building_id integer references buildings (id) NOT NULL,
    room_id     integer references rooms (id) on delete cascade
);

create or replace function fill_deadline() RETURNS trigger as
$$
begin
    if new.deadline is NULL then
        new.deadline := new.assigned_at + interval '2' day;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger fill_deadline
    before insert
    on tasks
    for each row
execute procedure fill_deadline();

create table reject_cause
(
    task_id integer references tasks (id) PRIMARY KEY,
    cause   varchar(400) NOT NULL
);

create table task_assignment
(
    task_id   integer references tasks (id) on delete cascade PRIMARY KEY,
    worker_id integer references workers (id) on delete cascade not null
);

create or replace function check_difficulty() returns trigger as
$$
declare
    _difficulty    integer;
    _qualification integer;
begin
    select difficulty from tasks where id = new.task_id into _difficulty;
    select qualification from workers where id = new.worker_id into _qualification;
    if _difficulty > _qualification then
        raise 'Выдано слишком сложное задание';
    end if;
    return new;
end ;
$$ language plpgsql;

create trigger check_difficulty
    before insert or update
    on task_assignment
    for each row
execute procedure check_difficulty();

create or replace function check_type() returns trigger as
$$
declare
    _task_type   worker_type;
    _actual_type worker_type;
begin
    select type from tasks where id = new.task_id into _task_type;
    select type from workers where id = new.worker_id into _actual_type;
    if _task_type != _actual_type then
        raise 'Данный работник не может выполнить задание этого типа';
    end if;
    return new;
end ;
$$ language plpgsql;

create trigger check_type
    before insert or update
    on task_assignment
    for each row
execute procedure check_type();

create view workloads as
with counted as (select workers.id, count(*) as counted_tasks
                 from workers
                          join task_assignment on workers.id = task_assignment.worker_id
                          join (select progress, id
                                from tasks
                                where progress = 'assigned'
                                   or progress = 'work in progress') as work_left
                               on task_id = work_left.id
                 group by workers.id)
select workers.id, coalesce(counted_tasks, 0) as num_of_tasks
from workers
         left join counted on workers.id = counted.id;