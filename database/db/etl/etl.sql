create schema etl;

create sequence etl.provider_id_seq start 1000;

create table etl.provider (
	id bigint not null default nextval('etl.provider_id_seq'),
	key text not null,
	name text not null,
	constraint provider_pk primary key (id),
	constraint provider_key_unq unique (key)
);

comment on table etl.provider is
'Provider of the data product.';

create sequence etl.product_id_seq start 3000;

create table etl.product (
	id bigint not null default nextval('etl.product_id_seq'),
	key text not null,
	name text not null,
	provider_id bigint not null,
	frequency text not null check (frequency in ('hourly','daily','weekly', 'biweekly', 'bimonthly', 'monthly', 'quarterly')),
	constraint product_pk primary key (id),
	constraint product_key_unq unique (key),
	constraint product_providerid_fk foreign key (provider_id) references etl.provider (id)
);

create index product_providerid_idx on etl.product (provider_id);

comment on table etl.product is
'Data products to be consumed.';

create sequence etl.batch_id_seq start 100000;

create table etl.batch (
	id bigint not null default nextval('etl.batch_id_seq'),
	key text not null,
	product_id bigint not null,
	constraint batch_pk primary key (id),
	constraint batch_keyproductid_unq unique (key, product_id),
	constraint batch_productid_fk foreign key (product_id) references etl.product (id)
);

comment on table etl.batch is
'Batches for data processing jobs.';

create sequence etl.job_id_seq start 200000;

create table etl.job
(
	id bigint not null default nextval('etl.job_id_seq'),
	parent_id bigint,
	batch_id bigint not null,
	status text not null default 'pending' check (status in ('pending', 'ready', 'running', 'completed', 'error')),
	constraint job_pk primary key (id),
	constraint job_batchid_fk foreign key (batch_id) references etl.batch (id),
	constraint job_parentid_batchid_unq unique (batch_id),
	constraint job_parentid_fk foreign key (parent_id) references etl.job (id)
);

comment on table etl.job is
'To manage the processing of ETL jobs. Jobs are batched and generated according to product schedule.';

