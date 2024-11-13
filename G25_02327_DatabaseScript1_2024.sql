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
street_name varchar(50) not null,
civic_number varchar(10) not null,
zip_code varchar(10) not null,
country varchar(10) not null,
primary key(card_id)
);

create table phone_number (
phone_number char(8) not null,
card_id char(10) not null,
primary key(phone_number, card_id),
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

insert bus_line values 
("500S"),
("350A"),
("300S"),
("700D"),
("690E"),
("420S"),
("860R"),
("105T"),
("550H"),
("280K");

insert into passenger (card_id, email, first_name, last_name, street_name, civic_number, zip_code, country) values
	('1234512345', 'joey.tribbiani@gmail.com', 'Joey', 'Tribbiani', 'Sandwichvej', '10', '2480', 'Nulland'),
    ('1212112121', 'chandler.bing@gmail.com', 'Chandler', 'Bing', 'Sarcasm Street', '15', '3460', 'Nulland'),
    ('6767667676', 'ross.geller@gmail.com', 'Ross', 'Geller', 'Ona Breakway', '20', '4500', 'Nulland'),
    ('3232332323', 'phoebe.buffay@gmail.com', 'Phoebe', 'Buffay', 'Central Perk Boulevard', '25', '1348', 'Nulland'),
    ('4575045750', 'rachel.green@gmail.com', 'Rachel', 'Green', 'Bloomingdales', '30', '5670', 'Nulland'),
    ('9830298302', 'monica.geller@gmail.com', 'Monica', 'Geller', 'Clean Route', '35', '2934', 'Nulland'),
	('1396413964', 'matt.leblanc@gmail.com', 'Matt', 'LeBlanc', 'Sandwichvej', '40', '2480', 'Nulland'),
    ('8686886868', 'matthew.perry@gmail.com', 'Matthew', 'Perry', 'Sarcasm Street', '45', '3460', 'Nulland'),
    ('1289012890', 'david.schwimmer@gmail.com', 'David', 'Schwimmer', 'Ona Breakway', '50', '4500', 'Nulland'),
    ('3467034670', 'jennifer.aniston@gmail.com', 'Jennifer', 'Aniston', 'Bloomingdales', '55', '5670', 'Nulland'),
    ('4654646546', 'courteney.cox@gmail.com', 'Courteney', 'Cox', 'Clean Route', '60', '2934', 'Nulland'),
    ('9128591285', 'lisa.kudrow@gmail.com', 'Lisa', 'Kudrow', 'Central Perk Boulevard', '65', '1348', 'Nulland');
    
insert into phone_number (card_id, phone_number) values
('1234512345', "20782313"),
('1234512345', "12345678"),
('1212112121', "82646238"),
('1212112121', "44444444"),
('6767667676', "12345162"),
('3232332323', "65656565"),
('4575045750', "99999999"),
('9830298302', "43212343"),
('1396413964', "87657485"),
('8686886868', "45207823"),
('1289012890', "45753823"),
('3467034670', "76548203"),
('4654646546', "81247504"),
('9128591285', "91328503");