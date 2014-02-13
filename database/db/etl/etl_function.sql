
do $$
declare r record;
begin

    for r in
		select * from etl.product
    loop
		insert into etl.batch (key, product_id)
		select dt::text, (select id from etl.product where key = r.key)
		from utility.generate_dates((select max(key)::date + 1 from etl.batch where product_id = r.id limit 1), (select now()::date), 1) dt
		order by dt asc;
    end loop;

end $$;

create or replace function batch_insert() returns trigger as $$
declare job_id bigint = null;
		max_batch_key text;
begin
	
	if (tg_op = 'insert') then

		select max(key) into max_batch_key
		from etl.batch
		where product_id = new.product_id;

		select job.id into job_id
		from etl.job
		inner join etl.batch
			on batch.id = job.batch_id
		where batch.key = max_batch_key;

		if job_id is not null
		then
			raise notice 'not null: %', job_id;
			insert into etl.job (parent_id, batch_id) values (job_id, new.id);           
		else
			raise notice 'null: %', job_id;
			insert into etl.job (batch_id) values (new.id);
		end if;

	end if;
	
	return new;
        
end $$ language plpgsql;

create trigger batch_insert_trigger
after of insert on etl.batch
    for each row execute procedure batch_insert();



select * from etl.product

	for select 
	insert into etl.batch (key, product_id)
	values 
end $$;
select id from etl.product where key = 'meetup_payments'

insert into etl.batch (key, product_id) values ('2014-02-06', 3001);
insert into etl.batch (key, product_id) values ('2014-02-07', 3001);

select * from etl.batch
select * from etl.job

delete from etl.job
delete from etl.batch

insert into etl.job (batch_id, status) values (100001, 'complete');
select * from etl.job

create schema utility;

CREATE OR REPLACE FUNCTION utility.generate_dates(
   dt1  date,
   dt2  date,
   n    int
) RETURNS SETOF date AS
$$
  SELECT $1 + i
  FROM generate_series(0, $2 - $1, $3) i;
$$ LANGUAGE 'sql' IMMUTABLE;

SELECT dt::text, (select id from etl.product where key = 'meetup_payments')
FROM utility.generate_dates((select max(key)::date from etl.batch limit 1), (select now()::date), 1) dt
order by dt asc