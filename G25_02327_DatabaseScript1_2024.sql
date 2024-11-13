drop database if exists movibus; 
create database movibus; 
use movibus; 

create table bus_line (
line_name varchar(4) not null,
primary key(line_name)
);

create table passenger ( 
card_id char(10) not null,
email varchar(30) not null,
first_name varchar(30) not null,
last_name varchar(30) not null,
primary key(card_id)
);

create table phone_number (
phone_number char(8) not null,
card_id char(10) not null,
primary key(phone_number, card_id),
foreign key(card_id) references passenger(card_id) on delete cascade
);

create table address (
card_id char(10) not null,
street_name varchar(50) not null,
civic_number varchar(10) not null,
zip_code varchar(10) not null,
country varchar(10) not null,
primary key(card_id),
foreign key(card_id) references passenger(card_id) on delete cascade 
);

create table bus_stop (
stop_name varchar(30) not null,
latitude char(9) not null,
longitude char(9) not null,
primary key(latitude, longitude)
);

create table bus_ride (
card_id char(10) not null,
line_name varchar(4) not null,
start_time datetime not null,
end_time datetime,
first_stop_latitude char(9) not null,
first_stop_longitude char(9) not null,
last_stop_latitude char(9),
last_stop_longitude char(9),
primary key(card_id, start_time),
foreign key(first_stop_latitude, first_stop_longitude) references bus_stop(latitude, longitude) on delete cascade,
foreign key(last_stop_latitude, last_stop_longitude) references bus_stop(latitude, longitude) on delete set null,
foreign key(card_id) references passenger(card_id) on delete cascade,
foreign key(line_name) references bus_line(line_name) on delete cascade
);

create table stops_at ( 
latitude char(9) not null,
longitude char(9) not null,
line_name varchar(4) not null,
stop_index int not null,
primary key(latitude, longitude, line_name),
foreign key(latitude, longitude) references bus_stop(latitude, longitude) on delete cascade,
foreign key(line_name) references bus_line(line_name) on delete cascade
);

insert busline values (
"500S",
"350A",
"300S",
"700D",
"690E",
"420S",
"860R",
"105T",
"550H",
"280K"
);

insert into passenger (card_id, email, first_name, last_name) values
(),
(),
(),
(),
(),
(),
(),
(),
(),
(),
(),
();