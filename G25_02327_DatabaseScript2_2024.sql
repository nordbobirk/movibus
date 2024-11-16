use movibus;

# 1 DONE Triggers to handle indexes of bus stops
# 2 table modification examples for insert/update/delete
# 3 DONE Show the ID of the passengers who took a ride from the first stop of the line taken.
# 4 DONE Show the name of the bus stop served by most lines.
# 5 DONE For each line, show the ID of# 3 Show the ID of the passengers who took a ride from the first stop of a given line
# 6 Show the ID of the passengers who never took a bus line more than once per day.
# 7 DONE Show the name of the bus stops that are never used, that is, they are neither the start nor the end stop for any ride.
# 8 DONE a function that takes two stops and shows how many liens serve both stops
# 9 DONE a procedure that given a line and stop adds the stop to that line (after the last stop) if not already served by that line
# 10 DONE a trigger that prevents inserting a ride starting and ending at the same stop or at a stop not served by that line

# illustrative examples of all of the above

#################################################################################################

# A function that gets the index of the last stop of a line
drop function if exists LastStopIndex;
delimiter //
create function LastStopIndex(line_name varchar(4)) returns int
begin
return (select max(stop_index) from stops_at where stops_at.line_name = line_name);
end//
delimiter ;

#################################################################################################

# A procedure that gets the coordinates of the last stop of a line
drop procedure if exists LastStopCoordinates;
delimiter //
create procedure LastStopCoordinates(in line_name varchar(4), out last_stop_latitude char(9), out last_stop_longitude char(9))
begin
select latitude into last_stop_latitude from stops_at where stops_at.line_name = line_name and stops_at.stop_index = (select LastStopIndex(line_name));
select longitude into last_stop_longitude from stops_at where stops_at.line_name = line_name and stops_at.stop_index = (select LastStopIndex(line_name));
end//
delimiter ;

#################################################################################################

# A function that tells us whether a stop is served by some line
drop function if exists StopServedByLine;
delimiter //
create function StopServedByLine(stop_latitude char(9), stop_longitude char(9), line_name varchar(4)) returns boolean
begin
return exists (select * from stops_at where stops_at.line_name = line_name and stops_at.latitude = stop_latitude and stops_at.longitude = stop_longitude);
end//
delimiter ;

select StopServedByLine("55.846501", "12.414829", "500S") as servedByLine;

#################################################################################################

# 1 Triggers to handle indexes of bus stops

# We don't write a trigger to handle deleting bus stops in a line, because we assume in this project that we would never do that. 
# We do need a triger to move up the indexes of stops when inserting a stop in the middle of a line

drop trigger if exists StopsAt_Before_Insert;
delimiter // 
create trigger StopsAt_Before_Insert before insert on stops_at for each row
begin
declare last_stop_index int;
select LastStopIndex(new.line_name) into last_stop_index;
if new.stop_index <= 0 then
	signal sqlstate "HY000" set mysql_errno = 1525, message_text = "index must be a positive integer";
end if;
if new.stop_index <= last_stop_index then
	signal sqlstate "HY000" set mysql_errno = 1525, message_text = "cant insert into the middle of the bus line";
end if;
if new.stop_index > (last_stop_index + 1) then
	set new.stop_index = (last_stop_index + 1);
end if;
end//
delimiter ;

# this should fail because the index is negative
insert into stops_at (line_name, stop_index, latitude, longitude) values ("350A", -1, "55.824893", "12.220631");

# this should change the index to equal the last index plus one
insert into stops_at (line_name, stop_index, latitude, longitude) values ("350A", 1000, "55.824893", "12.220631");
# which can be verified by running this
select * from stops_at natural join bus_stop where line_name = "350A";

# this should fail because the index is not after the last current stop index
insert into stops_at (line_name, stop_index, latitude, longitude) values ("350A", 5, "55.695080", "12.314077");

#################################################################################################

# 2 table modification examples for insert/update/delete

#################################################################################################

# 3 Show the ID of the passengers who took a ride from the first stop of a given line

# here we use an inner join and NOT natural join, because attributes that are conceptually the same have different names
select card_id, bus_ride.line_name from bus_ride join stops_at where 
bus_ride.line_name = stops_at.line_name and 
first_stop_latitude = latitude and 
first_stop_longitude = longitude and
stop_index = 1;

# this query can be modified to find the passengers who took a ride from the first stop of only one line by adding a predicate to the where clause thus
# and bus_ride.line_name = LINE_NAME (where LINE_NAME is the desired line)

#################################################################################################

# 4 Show the name of the bus stop served by most lines.
# We count the occurance of each distinct stop name, order descending and limit to one result.
select stop_name, count(stop_name) as served_by_lines from bus_stop natural join stops_at 
group by stop_name 
order by served_by_lines desc limit 1;
  
#################################################################################################
  
# 5 For each line, show the ID of the passenger who took the ride that lasted longer.
select card_id, line_name, max(timediff(end_time, start_time)) as duration 
from bus_ride group by line_name;

#################################################################################################

# 6 Show the ID of the passengers who never took a bus line more than once per day.
# We are not quite sure how to interpret this question, since it could either mean that multiple bus rides on different lines per day are included or not.
# We just decided to answer both questions.

# This query finds the ids of passengers who never takes more than one bus ride on the same line per day

# This query finds the ids of passengers who never takes more than one bus ride per day. Note that it also shows a meaningless date

  
#################################################################################################

# 7 Show the name of the bus stops that are never used, that is, they are neither the start nor the end stop for any ride.

select stop_name from bus_stop where 
latitude not in (select first_stop_latitude from bus_ride) and 
latitude not in (select last_stop_latitude from bus_ride) and 
longitude not in (select first_stop_longitude from bus_ride) and
longitude not in (select last_stop_longitude from bus_ride);

# Alternative solution
select stop_name from bus_stop where stop_name not in 
(select stop_name from bus_ride join bus_stop on (
	first_stop_latitude = latitude and first_stop_longitude = longitude) or
    (last_stop_latitude = latitude and last_stop_longitude = longitude));
    
# Running either of the above queries returns the three stops that are never used, Pete Street, Ben Street and Janice Street

#################################################################################################

# 8 a function that takes two stops and shows how many lines serve both stops

drop function if exists LinesServeStops;
delimiter //
create function LinesServeStops(lat1 char(9), long1 char(9), lat2 char(9), long2 char(9)) returns int
begin
return (select count(distinct line_name) from stops_at where line_name in 
	(select distinct line_name from stops_at where latitude = lat1 and longitude = long1) and 
	line_name in (select distinct line_name from stops_at where latitude = lat2 and longitude = long2));
end//
delimiter ;

# example
select LinesServeStops("55.726027", "12.531202", "55.838776", "12.476234");

#################################################################################################

# 9 A procedure that given a line and a stop adds the stop to that line after the last stop if the stop is not already served by that line
drop procedure if exists AddStopToLine;
delimiter //
create procedure AddStopToLine(in line_name varchar(4), in stop_latitude char(9), in stop_longitude char(9))
begin
	declare last_stop_index int;
	select LastStopIndex(line_name) into last_stop_index;
	if StopServedByLine(stop_latitude, stop_longitude, line_name)
		then signal sqlstate "HY000" set mysql_errno = 1525, message_text = "stop already served by line";
	end if;
insert stops_at (latitude, longitude, stop_index, line_name) values (stop_latitude, stop_longitude, (last_stop_index + 1), line_name);
end//
delimiter ;

# this should fail because stop is already served by line
call AddStopToLine("500S", "55.726027", "12.531202");

# this should succeed because stop is not served by line
call AddStopToLine("500S", "55.846256", "12.414063");
# which can be verified by running
select * from stops_at where line_name = "500S";

#################################################################################################

# 10 a trigger that prevents inserting a ride starting and ending at the same stop or at a stop not served by that line

drop trigger if exists BusRide_Before_Insert;
delimiter //
create trigger BusRide_Before_Insert before insert on bus_ride for each row
begin
if (new.first_stop_latitude = new.last_stop_latitude and new.first_stop_longitude = new.last_stop_longitude) then
	signal sqlstate "HY000" set mysql_errno = 1525, message_text = "ride can't start and stop at the same bus stop";
end if;
if not StopServedByLine(new.first_stop_latitude, new.first_stop_longitude, new.line_name) then 
	signal sqlstate "HY000" set mysql_errno = 1525, message_text = "first stop is not served by this line";
end if;
if not StopServedByLine(new.last_stop_latitude, new.last_stop_longitude, new.line_name) then 
	signal sqlstate "HY000" set mysql_errno = 1525, message_text = "last stop is not served by this line";
end if;
end //
delimiter ;

# this should fail because first and last stop are the same
insert into bus_ride (card_id, line_name, start_time, end_time, first_stop_latitude, first_stop_longitude, last_stop_latitude, last_stop_longitude) values
("1234512345", "500S", "2024-11-13 12:00:00", "2024-11-13 12:10:00", "55.726027", "12.531202", "55.726027", "12.531202");

# this should fail because first stop is not served by this line
insert into bus_ride (card_id, line_name, start_time, end_time, first_stop_latitude, first_stop_longitude, last_stop_latitude, last_stop_longitude) values
("1234512345", "500S", "2024-11-13 12:00:00", "2024-11-13 12:10:00", "55.695909", "12.314104", "55.726027", "12.531202"); # first stop is susie st

# this should fail because last stop is not served by this line
insert into bus_ride (card_id, line_name, start_time, end_time, first_stop_latitude, first_stop_longitude, last_stop_latitude, last_stop_longitude) values
("1234512345", "500S", "2024-11-13 12:00:00", "2024-11-13 12:10:00", "55.726027", "12.531202", "55.695909", "12.314104"); # last stop is susie st

