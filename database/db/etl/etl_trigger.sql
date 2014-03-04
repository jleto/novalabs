create or replace function etl.batch_insert() returns trigger as $$
declare job_id bigint = null;
		max_batch_key text;
begin
	
	select max(key) into max_batch_key
	from etl.batch
	inner join etl.job
	on batch.id = job.batch_id
	where product_id = new.product_id;

	select job.id into job_id
	from etl.job
	inner join etl.batch
		on batch.id = job.batch_id
	where batch.key = max_batch_key;

	if job_id is not null
	then
		insert into etl.job (parent_id, batch_id) values (job_id, new.id);           
	else
		insert into etl.job (batch_id) values (new.id);
	end if;

	return new;
        
end $$ language plpgsql;

create trigger batch_insert_trigger
after insert on etl.batch
    for each row execute procedure batch_insert();

create or replace function etl.job_status_update() returns trigger as $$
begin

	if new.status <> 'completed'
	then

		raise notice 'Rolling back transactions for Job ID: %.', old.batch_id::text;
		
		delete from meetup.payment_raw
		where batch_id = old.batch_id;
		
		delete from amazon.payment_raw
		where batch_id = old.batch_id;
		
		delete from squareup.payment_raw
		where batch_id = old.batch_id;
		
	end if;

	return new;
	
end$$ language plpgsql;

create trigger job_status_update_trigger
after update on etl.job
	for each row execute procedure job_status_update();