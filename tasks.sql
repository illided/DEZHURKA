call create_task('Починка электроснабжения',
                 'Баба клава сломала клаву',
                 'ул Печкина 78',
                 3,
                 current_date);
call review_task(1, 1);
select assign_task(1);

call create_task('Починка электроснабжения',
                 'Своровали лампочку',
                 'ДЕЖУРКА',
                 1,
                 current_date);
call review_task(2, 2);
select assign_task(2);

call create_task(service_type := 'Починка лифта',
                 info := 'Дети сломали двери лифта топором',
                 building_address := 'ул Печкина 78',
                 completion_date :=  current_date);
call review_task(3, 5);

call create_task(service_type := 'Травление тараканов',
                 info := 'Таракан унес тетю Машу. Нужно потравить',
                 building_address := 'ул Печкина 78',
                 completion_date :=  current_date);
call review_task(4, 5);
select assign_task(4);

call create_task(service_type := 'Починка системы водоснабжения',
                 info := 'Все трубы в доме украли',
                 building_address := 'пр Колотушкина 23');
call review_task(5, 2);
select assign_task(5);

call create_task(service_type := 'Починка системы водоснабжения',
                 info := 'На складе стало в два раза больше труб',
                 building_address := 'ДЕЖУРКА');
call review_task(6, 2);
select assign_task(6);

call create_task(service_type := 'Починка системы водоснабжения',
                 info := 'Трубу прорвало',
                 building_address := 'ул Печкина 78');
call review_task(7, 2);
select assign_task(7);