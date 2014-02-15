create schema amazon;

create sequence amazon.paymentraw_id_seq start 1000000000;

create table amazon.payment_raw
(
	id bigint not null default nextval('amazon.paymentraw_id_seq'),
	batch_id bigint not null,
	key text not null,
	datetime text not null,
	type text not null,
	status text not null,
	sender_key text not null,
	sender_name text not null,
	description text,
	fee text not null,
	amount text not null,
	constraint paymentraw_pk primary key (id),
	constraint paymentraw_batchid_fk foreign key (batch_id) references etl.batch (id) on delete cascade
);

comment on table amazon.payment_raw is
'Table to load raw Amazon payments data';
