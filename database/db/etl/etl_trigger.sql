create or replace function batch_insert() returns trigger as $$
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
		raise notice 'not null: %', job_id;
		insert into etl.job (parent_id, batch_id) values (job_id, new.id);           
	else
		raise notice 'null: %', job_id;
		insert into etl.job (batch_id) values (new.id);
	end if;

	return new;
        
end $$ language plpgsql;

create trigger batch_insert_trigger
after of insert on etl.batch
    for each row execute procedure batch_insert();