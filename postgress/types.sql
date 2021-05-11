create type buildings_types as enum ('technical', 'living');

create type worker_type as enum ('electrician',
    'plumber', 'carpenter', 'cleaner', 'exterminator','elevator_operator', 'chairman');

create type completion as enum ('created', 'reviewed', 'rejected', 'assigned', 'work in progress', 'completed');