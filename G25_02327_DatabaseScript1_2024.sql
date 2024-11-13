drop database if exists movibus; 
create database movibus; 
use movibus; 
create table busline (
line_name varchar(4),
primary key (line_name) 
); 
create table passengers ( 
card_id Char(10),
primary key (card_id),
email char(10),
first_name varchar(10),
last_name char(10)
); 
create table phonenumber (
phone_number char(10),
primary key phone_number char(10),
primary key card_id char(10)
); 
create table adress(
street_name varchar(10),
primary key card_id char(10) 
civic_number varchar(10),
zip_code char(4),
country char(10)
); 
create table busride(
start_time datetime,
primary key card_id char(10),
primary key start_time datetime,
end_time datetime,
);
create table busstop (
Bus_stop char(10),
primary key latitude char(9),
primary key longitude char(9),
); 
Create table first_stop (
first_stop varchar(10),
primary key latitude char(10),
primary key longitude char(10), 
primary key start_time datetime,
primary key card_id char(10)
); 
create table last_stop ( 
last_stop varchar(10), 
primary key latitude char(10),
primary key longitude char(10),
primary key start_time datetime, 
primary key card_id char(10)




















