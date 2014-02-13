create schema amazon;

create sequence amazon.paymentraw_id_seq start 1000000000;

create table amazon.payment_raw
(
	id bigint not null default nextval('amazon.paymentraw_id_seq'),
	batch_id bigint not null,
	key text not null,
	datetime text not null,
	status text not null,
	sender_key text not null,
	sender_name text not null,
	description text not null,
	fee text not null,
	amount text not null,
	constraint paymentraw_pk primary key (id),
	constraint paymentraw_batchid_fk foreign key (batch_id) references etl.batch (id) on delete cascade,
	constraint paymentraw_key_unq unique (key),
	constraint paymentraw_status_ck check (status in ('failed', 'success'))
);

comment on table amazon.payment_raw is
'Table to load raw Amazon payments data';
