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