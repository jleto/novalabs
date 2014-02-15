create schema meetup;

create sequence meetup.paymentraw_id_seq start 1000000000;

create table meetup.payment_raw (
	id bigint not null default nextval('meetup.paymentraw_id_seq'),
	batch_id bigint not null,
	key text not null,
	datetime text not null,
	event_id text not null,
	event_name text not null,
	member_id text not null,
	member_name text not null,
	amount text not null,
	constraint paymentraw_pk primary key (id),
	constraint paymentraw_batchid_fk foreign key (batch_id) references etl.batch(id),
	constraint paymentraw_key_unq unique (key)
);

create index paymentraw_batchid_idx on meetup.payment_raw (batch_id);

comment on table meetup.payment_raw is
'Imported raw meetup payment data.';