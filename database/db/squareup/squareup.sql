create schema squareup;

create sequence squareup.paymentraw_id_seq start 1000000000;

create table squareup.payment_raw (
	id bigint not null default nextval('squareup.paymentraw_id_seq'),
	batch_id bigint not null,
	key text not null,
	datetime text not null,
    description text null,
	amount text not null,
	fee text not null,
	constraint paymentraw_pk primary key (id),
	constraint paymentraw_batchid_fk foreign key (batch_id) references etl.batch(id),
	constraint paymentraw_key_unq unique (key)
);

create index paymentraw_batchid_idx on squareup.payment_raw (batch_id);

create index paymentraw_datetime_idx on squareup.payment_raw (datetime);

comment on table squareup.payment_raw is
'Imported raw squareup payment data.';