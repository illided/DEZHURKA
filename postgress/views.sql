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