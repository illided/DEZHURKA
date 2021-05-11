insert into services(description, worker_type)
values ('Починка лифта', 'elevator_operator'),
       ('Починка электроснабжения', 'electrician'),
       ('Очистка труб', 'plumber'),
       ('Диагностика водоснабжения', 'plumber'),
       ('Починка системы водоснабжения', 'plumber'),
       ('Починка мебели', 'carpenter'),
       ('Травление тараканов', 'exterminator'),
       ('Травление мышей/крыс', 'exterminator'),
       ('Составления договора', 'chairman'),
       ('Уборка лифта', 'cleaner'),
       ('Уборка корридоров', 'cleaner'),
       ('Уборка двора', 'cleaner'),
       ('Консультация', 'chairman');


insert into buildings(address, type)
values ('пр Колотушкина 23', 'living'),
       ('ул Печкина 78', 'living'),
       ('ДЕЖУРКА', 'technical');

insert into rooms(room_number, building)
values (1, 1),
       (2, 1),
       (3, 1),
       (4, 1),
       (1, 2),
       (2, 2),
       (3, 2),
       (4, 2),
       (1, 3),
       (2, 3),
       (3, 3),
       (4, 3);

insert into workers(type, surname, name, patronymic, qualification)
values ('electrician', 'Электронов', 'Василий', 'Петрович', 3),
       ('electrician', 'Пикачуев', 'Антон', 'Валерьевич', 5),
       ('plumber', 'Водоносов', 'Григорий', 'Посейдонов', 1),
       ('plumber', 'Трубач', 'Олег', 'Антонович', 3),
       ('plumber', 'Карпов', 'Павел', 'Алексеевич', 6),
       ('carpenter', 'Плотников', 'Илья', 'Артемович', 4),
       ('cleaner', 'Помело', 'Анатолий', 'Сергеевич', 2),
       ('exterminator', 'Травитель', 'Сергей', 'Петрович', 9),
       ('elevator_operator', 'Кабинов', 'Петр', 'Васильевич', 3),
       ('chairman', 'Агутин', 'Михаил', NULL, 2);
