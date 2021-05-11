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