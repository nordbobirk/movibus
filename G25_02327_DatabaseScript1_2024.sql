drop database if exists movibus; 
create database movibus; 
use movibus; 

create table bus_line(
line_name varchar(4),
primary key(line_name)
);

create table passenger( 
card_id char(10),
email varchar(30) not null,
first_name varchar(30) not null,
last_name varchar(30) not null,
primary key(card_id)
);

create table phone_number(
phone_number char(8),
card_id char(10),
primary key(phone_number,card_id),
foreign key(card_id) references passenger(card_id) on delete cascade
);

create table address(
card_id char(10),
street_name varchar(50) not null,
civic_number varchar(10) not null,
zip_code varchar(10) not null,
country varchar(10) not null,
primary key(card_id),
foreign key(card_id) references passenger(card_id) on delete cascade 
);

create table bus_ride(
card_id char(10),
start_time datetime,
end_time datetime,
first_stop_latitude char(9) not null,
first_stop_longitude char(9) not null,
last_stop_latitude char(9),
last_stop_longitude char(9),
primary key(card_id, start_time),
foreign key(first_stop_latitude, first_stop_longitude) references bus_stop(first_stop_latitude, first_stop_longitude) on delete cascade,
foreign key(last_stop_latitude, last_stop_longitude) references bus_stop(last_stop_latitude, last_stop_longitude) on delete set null,
foreign key(card_id) references takes(card_id) on delete set null
);

create table bus_stop(
stop_name varchar(30) not null,
longitude char(9),
latitude char(9),
primary key (latitude, longitude)
); 

create table stops_at( 
latitude char(9),
longitude char(9),
line_name varchar(4),
stop_index int,
primary key(latitude, longitude, line_name)
foreign key(latitude, longitude) references bus_stop(latitude, longitude) on delete set cascade,
foreign key(line_name) references bus_line(line_name) on delete set cascade
); 

create table rides_on(
card_id char(10),
start_time datetime,
line_name varchar(4),
primary key(card_id, start_time, line_name),
foreign key(card_id, start_time) references bus_ride(card_id, start_id) on delete cascade,
foreign key(line_name) references bus_line(line_name) on delete cascade
); 

create table takes(
card_id char(10),
start_time datetime,
primary key(card_id, start_time)
foreign key(start_time) references busride(start_time) on delete cascade
); 




























