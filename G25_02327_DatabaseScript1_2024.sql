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
("690E");

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

insert into bus_stop (latitude, longitude, stop_name) values
("55.826205", "12.319242", 'Gunther Street'),    
("55.846256", "12.414063", 'Joshua Street'),
("55.852423", "12.353598", 'Janice Street'),
("55.824893", "12.220631", 'Mike Street'),
("55.786303", "12.206889", 'Janine Street'),
("55.838776", "12.476234", 'Richard Street'),
("55.726027", "12.531202", 'Carol Street'),
("55.695080", "12.314077", 'David Street'),
("55.715198", "12.237122", 'Paul Street'),
("55.815635", "12.492725", 'Ben Street'),
("55.826401", "12.319674", 'Tag Street'),
("55.846501", "12.414829", 'Jack Street'),
("55.852601", "12.353293", 'Emily Street'),
("55.824701", "12.220951", 'Elizabeth Street'),
("55.786801", "12.206395", 'Kathy Street'),
("55.838901", "12.476012", 'Eddie Street'),
("55.726906", "12.531750", 'Frank Street'),
("55.695909", "12.314104", 'Susie Street'),
("55.715990", "12.237105", 'Pete Street'),
("55.712990", "12.247165", 'Gavin Street'),
("55.715728", "12.217155", 'Mona Street'),
("55.715123", "12.327145", 'Jill Street'),
("55.715321", "12.337132", 'Joana Street'),
("55.815997", "12.492073", 'Estelle Street'),
("55.123456", "12.123456", 'Estelle Street');

insert into stops_at (line_name, stop_index, latitude, longitude) values
("500S", 1, "55.726027", "12.531202"),
("500S", 2, "55.838776", "12.476234"),
("500S", 3, "55.846501", "12.414829"),
("500S", 4, "55.838901", "12.476012"),
("500S", 5, "55.715990", "12.237105"),
("500S", 6, "55.726906", "12.531750"),
("350A", 1, "55.695909", "12.314104"),
("350A", 2, "55.824701", "12.220951"),
("350A", 3, "55.726027", "12.531202"),
("350A", 4, "55.838776", "12.476234"),
("350A", 5, "55.846256", "12.414063"),
("350A", 6, "55.815997", "12.492073"),
("300S", 1, "55.824893", "12.220631"),
("300S", 2, "55.695080", "12.314077"),
("300S", 3, "55.815635", "12.492725"),
("300S", 4, "55.838776", "12.476234"),
("300S", 5, "55.726027", "12.531202"),
("700D", 1, "55.786801", "12.206395"),
("700D", 2, "55.852601", "12.353293"),
("700D", 3, "55.838776", "12.476234"),
("700D", 4, "55.726027", "12.531202"),
("700D", 5, "55.826205", "12.319242"),
("700D", 6, "55.826401", "12.319674"),
("700D", 7, "55.715198", "12.237122"),
("690E", 1, "55.712990", "12.247165"),
("690E", 2, "55.715728", "12.217155"),
("690E", 3, "55.726027", "12.531202"),
("690E", 4, "55.826205", "12.319242"),
("690E", 5, "55.715123", "12.327145"),
("690E", 6, "55.715321", "12.337132"),
("690E", 7, "55.123456", "12.123456");