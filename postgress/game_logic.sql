create table unlockable_workers
(
    id            SERIAL PRIMARY KEY,
    type          worker_type NOT NULL,
    surname       varchar(50) NOT NULL,
    name          varchar(50) NOT NULL,
    patronymic    varchar(50),
    qualification integer     NOT NULL,
    UNIQUE (type, surname, name, patronymic)
);

create table possible_tasks
(
    id           SERIAL PRIMARY KEY,
    service_type varchar(400) NOT NULL,
    description  varchar(400) NOT NULL,
    difficulty   integer      not null
);

create table possible_services
(
    service_id  SERIAL PRIMARY KEY,
    description varchar(400) NOT NULL UNIQUE,
    worker_type worker_type  NOT NULL
);

create table possible_buildings
(
    id SERIAL PRIMARY KEY,
    address varchar(400),
    type    buildings_types
);
