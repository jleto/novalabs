
create or replace function etl.fn_generate_batch()
returns void as $$
declare r record;
		product_frequency text;
begin

    for r in
		select * from etl.product
    loop
		select frequency into product_frequency
		from etl.product
		where id = r.id;
		
		if product_frequency = 'daily' then
			insert into etl.batch (key, product_id)
			select dt::text, (select id from etl.product where key = r.key)
			from utility.generate_dates((select max(key)::date + 1 from etl.batch where product_id = r.id limit 1), (select now()::date), 1) dt
			order by dt asc;
		elsif product_frequency = 'weekly' then
			insert into etl.batch (key, product_id)
			select dt::text, (select id from etl.product where key = r.key)
			from utility.generate_dates((select max(key)::date + 1 from etl.batch where product_id = r.id limit 1), (select now()::date), 7) dt
			order by dt asc;
		elsif product_frequency = 'biweekly' then
			insert into etl.batch (key, product_id)
			select dt::text, (select id from etl.product where key = r.key)
			from utility.generate_dates((select max(key)::date + 1 from etl.batch where product_id = r.id limit 1), (select now()::date), 14) dt
			order by dt asc;
		elsif product_frequency = 'monthly' then
			insert into etl.batch (key, product_id)
			select dt::text, (select id from etl.product where key = r.key)
			from utility.generate_dates((select max(key)::date + 1 from etl.batch where product_id = r.id limit 1), (select now()::date), 30) dt
			order by dt asc;
		elsif product_frequency = 'quarterly' then 
			insert into etl.batch (key, product_id)
			select dt::text, (select id from etl.product where key = r.key)
			from utility.generate_dates((select max(key)::date + 1 from etl.batch where product_id = r.id limit 1), (select now()::date), 90) dt
			order by dt asc;
		end if;
    end loop;

end $$ language plpgsql;