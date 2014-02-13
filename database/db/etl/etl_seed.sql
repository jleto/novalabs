/* Providers */
insert into etl.provider (key, name) values ('amazon', 'Amazon');
insert into etl.provider (key, name) values ('meetup', 'Meetup');

/* Products */
insert into etl.product (key, name, provider_id, frequency)
values ('amazon_payments', 'Flexible Payment Service', (select id from etl.provider where key = 'amazon'), 'daily');

insert into etl.product (key, name, provider_id, frequency)
values ('meetup_payments', 'Meetup Payments', (select id from etl.provider where key = 'meetup'), 'daily');