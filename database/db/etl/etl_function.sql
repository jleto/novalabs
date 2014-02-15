
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
			from utility.generate_dates((select max(key)::date + 1 from etl.batch where product_id = r.id limit 1), (select now()::date)-1, 1) dt
			order by dt asc;
		elsif product_frequency = 'weekly' then
			insert into etl.batch (key, product_id)
			select dt::text, (select id from etl.product where key = r.key)
			from utility.generate_dates((select max(key)::date + 1 from etl.batch where product_id = r.id limit 1), (select now()::date)-1, 7) dt
			order by dt asc;
		elsif product_frequency = 'biweekly' then
			insert into etl.batch (key, product_id)
			select dt::text, (select id from etl.product where key = r.key)
			from utility.generate_dates((select max(key)::date + 1 from etl.batch where product_id = r.id limit 1), (select now()::date)-1, 14) dt
			order by dt asc;
		elsif product_frequency = 'monthly' then
			insert into etl.batch (key, product_id)
			select dt::text, (select id from etl.product where key = r.key)
			from utility.generate_dates((select max(key)::date + 1 from etl.batch where product_id = r.id limit 1), (select now()::date)-1, 30) dt
			order by dt asc;
		elsif product_frequency = 'quarterly' then 
			insert into etl.batch (key, product_id)
			select dt::text, (select id from etl.product where key = r.key)
			from utility.generate_dates((select max(key)::date + 1 from etl.batch where product_id = r.id limit 1), (select now()::date)-1, 90) dt
			order by dt asc;
		end if;
    end loop;

end $$ language plpgsql;


create or replace function etl.fn_meetup_payment_importcsv(lJobId bigint, strCSVFilePath text)
returns integer as $$
declare strBatchDate text;
        lBatchId bigint;
begin

	begin
		/* Prevent data from getting loaded twice. */
	    if (select status from etl.job where id = lJobId) = 'completed'
	    then
			return -2;
		end if;
		
		/* pull date from batch table. */
		select batch.key, batch_id into strBatchDate, lBatchId
		from etl.job
		inner join etl.batch
		on job.batch_id = batch.id
		where job.id = lJobId;

		/* create temp table for data import from csv file. */
		drop table if exists meetup_payment_csv;		
		create temp table meetup_payment_csv (key text, datetime text, event_id text, event_name text, member_id text, member_name text, amount text);

		/* Import data from csv file on disk to temp table */
		execute E'COPY meetup_payment_csv from ''' || strCSVFilePath || ''' DELIMITER '','' CSV header;';
     
		/* insert data from temp table to permanent raw table. */
		insert into meetup.payment_raw (batch_id, key, datetime, event_id, event_name, member_id, member_name, amount)
		select lBatchId::bigint, key, datetime, event_id, event_name, member_id, member_name, amount
		from meetup_payment_csv;

		/* update job status to completed. */
		update etl.job
		set status = 'completed'
		where id = lJobId;

		/* Return value indicating success. */
		return 0;
		
	exception when others then 

		raise notice 'The transaction is in an uncommittable state. '
					 'Transaction was rolled back';
 
		raise notice 'Meetup Payment Import Error: % %', SQLERRM, SQLSTATE;

		/* update job status with error. */
		update etl.job
		set status = 'error'
		where id = lJobId;

		/* Return vaue indicating error. */
		return -1;
		
	end;
	
end $$ language plpgsql;

create or replace function etl.fn_amazon_payment_importcsv(lJobId bigint, strCSVFilePath text)
returns integer as $$
declare strBatchDate text;
        lBatchId bigint;
begin

	begin
	
	    /* Prevent loading data twice */
	    if (select status from etl.job where id = lJobId) = 'completed'
	    then	        
			return -2;
		end if;
		
		/* pull date from batch table. */
		select batch.key, batch_id into strBatchDate, lBatchId
		from etl.job
		inner join etl.batch
		on job.batch_id = batch.id
		where job.id = lJobId;

		/* create temp table for data import from csv file. */
		drop table if exists amazon_payment_csv;
		create temp table amazon_payment_csv (key text, datetime text, fps_operation text, sender_key text, sender_name text, description text, fee text, status text, amount text);

		/* Import data from csv file on disk to temp table */
		execute E'COPY amazon_payment_csv from ''' || strCSVFilePath || ''' DELIMITER '','' CSV header;';
     
		/* insert data from temp table to permanent raw table. */
		insert into amazon.payment_raw (batch_id, key, datetime, type, status, sender_key, sender_name, description, fee, amount)
		select lBatchId::bigint, key, datetime, fps_operation, status, sender_key, sender_name, case when description = '' then null else description end, fee, amount
		from amazon_payment_csv;

		/* update job status to completed. */
		update etl.job
		set status = 'completed'
		where id = lJobId;

		/* Return value indicating success. */
		return 0;
		
	exception when others then 

		raise notice 'The transaction is in an uncommittable state. '
					 'Transaction was rolled back';
 
		raise notice 'Amazon Payment Import Error: % %', SQLERRM, SQLSTATE;

		/* update job status with error. */
		update etl.job
		set status = 'error'
		where id = lJobId;

		/* Return vaue indicating error. */
		return -1;
		
	end;
	
end $$ language plpgsql;