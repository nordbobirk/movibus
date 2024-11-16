use movibus;

# 1 Triggers to handle indexes of bus stops
# 2 table modification examples for insert/update/delete
# 3 DONE Show the ID of the passengers who took a ride from the first stop of the line taken.
# 4 DONE Show the name of the bus stop served by most lines.
# 5 DONE For each line, show the ID of# 3 Show the ID of the passengers who took a ride from the first stop of a given line
# 6 DONE Show the ID of the passengers who never took a bus line more than once per day.
# 7 DONE Show the name of the bus stops that are never used, that is, they are neither the start nor the end stop for any ride.
# 8 a function that takes two stops and shows how many liens serve both stops
# 9 a procedure that given a line and stop adds the stop to that line (after the last stop) if not already served by that line
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
# As coordinates match in bus_stop and stops_at we use natural join and then count(stop_name) to find the most used stops. which we named most_used in this example.
select stop_name, count(stop_name) as most_used 
from bus_stop natural join stops_at 
group by stop_name 
order by most_used desc;
# Then we add a limit of 1 to only get the most used.
  
#code
select stop_name, count(stop_name) as most_used 
from Bus_stop natural join stops_at 
group by stop_name 
order by most_used desc limit 1;
  
#################################################################################################
  
# 5 For each line, show the ID of the passenger who took the ride that lasted longer.
#code
select card_id, line_name, max(timediff(end_time, start_time)) as duration 
from bus_ride 
group by line_name;

#################################################################################################

# 6 Show the ID of the passengers who never took a bus line more than once per day.
#I have grouped by card_id even though it is the only thing shown to order card_id numerically
#code
select CAST(start_time as date) as date, card_id 
from bus_ride 
group by CAST(start_time as date), card_id 
having count(card_id) = 1;

  
#################################################################################################

# 7 Show the name of the bus stops that are never used, that is, they are neither the start nor the end stop for any ride.
#code for unused stops.
select stop_name 
from Bus_stop natural left join stops_at 
where line_name is null;

#tested with
select * from Bus_stop natural left join stops_at;
#to see which stops are never used, that is where line_name is null.
  

#code for where stops where no passengers started or ended their ride.
select stop_name from bus_stop left join bus_ride 
on bus_ride.first_stop_latitude = bus_stop.latitude and bus_ride.first_stop_longitude = bus_stop.longitude 
or bus_ride.last_stop_latitude = bus_stop.latitude and bus_ride.last_stop_longitude = bus_stop.longitude
where card_id is null
group by stop_name;

#tested with
select * from bus_stop 
left join bus_ride on bus_ride.first_stop_latitude = bus_stop.latitude and
bus_ride.first_stop_longitude = bus_stop.longitude or
bus_ride.last_stop_latitude = bus_stop.latitude and 
bus_ride.last_stop_longitude = bus_stop.longitude;

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

# 8 a function that takes two stops and shows how many liens serve both stops

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

select * from stops_at natural join bus_stop order by line_name asc, stop_index asc;
call AddStopToLine("300S", "55.715321", "12.337132");

#################################################################################################

# 10 a trigger that prevents inserting a ride starting and ending at the same stop or at a stop not served by that line
#Checks whether the latitude/longitude is the same for the start/end stop and uses our function 'StopServedByLine' to check if the stop is on that particular line. Though that is actually not needed as foreign 
#key constrains prevent inserting coordinates in Bus_ride that is not served by the concerning line.
#Only works if the function "# A function that tells us whether a stop is served by some line" is created. Tested with:
insert into bus_ride values('3232332323', '500S', '2024-11-14 13:50:00', '2024-11-14 13:55:00', '55.826205', '12.319242', '55.826205', '12.319242');

#code
drop trigger if exists wrongstop;
delimiter //
create trigger wrongstop
before insert on bus_ride for each row
begin
 if (new.first_stop_latitude = new.last_stop_latitude and new.first_stop_longitude = new.last_stop_longitude)
 or StopServedByLine(new.last_stop_latitude, new.first_stop_longitude, new.line_name) 
 then signal sqlstate "HY000" set mysql_errno = 1525, message_text = "Cannot start and end a ride on the same stop, or at a stop not served by that line.";
 end if;
 end //
 delimiter ;

