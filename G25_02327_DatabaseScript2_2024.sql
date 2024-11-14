use movibus;

# 1 triggers to handle constraints on index in StopsAt for insert/update/delete queries
# 2 table modification examples for insert/update/delete
# 3 DONE Show the ID of the passengers who took a ride from the first stop of the line taken.
# 4 DONE Show the name of the bus stop served by most lines.
# 5 DONE For each line, show the ID of the passenger who took the ride that lasted longer.
# 6 Show the ID of the passengers who never took a bus line more than once per day.
# 7 DONE Show the name of the bus stops that are never used, that is, they are neither the start nor the end stop for any ride.
# 8 a function that takes two stops and shows how many liens serve both stops
# 9 a procedure that given a line and stop adds the stop to that line (after the last stop) if not already served by that line
# 10 DONE a trigger that prevents inserting a ride starting and ending at the same stop or at a stop not served by that line
# illustrative examples of all of the above

#################################################################################################

# 3 Show the ID of the passengers who took a ride from the first stop of a given line
# we demonstrate this query with the bus line 350A
set @q1_line_name = "350A";

# here we use an inner join and NOT natural join, because attributes that are conceptually the same have different names
select card_id from bus_ride join stops_at where 
bus_ride.line_name = stops_at.line_name and 
bus_ride.line_name = @q1_line_name and 
first_stop_latitude = latitude and 
first_stop_longitude = longitude and
stop_index = 1;

#################################################################################################

# 4 Show the name of the bus stop served by most lines.
# As coordinates match in bus_stop and stops_at we use natural join and then count(stop_name) to find the most used stops. which we named most_used in this example.
select stop_name, count(stop_name) as most_used from bus_stop natural join stops_at group by stop_name order by most_used desc;
# Then we add a limit of 1 to only get the most used.
  
#code
select stop_name, count(stop_name) as most_used from Bus_stop natural join stops_at group by stop_name order by most_used desc limit 1;
  
#################################################################################################
  
# 5 For each line, show the ID of the passenger who took the ride that lasted longer.
#tested with
insert into bus_ride values('1234512345', '500S', '2024-11-14 13:50:00', '2024-11-14 13:55:00', '55.826205', '12.319242', '55.846256', '12.414063');
insert into bus_ride values('1212112121', '500S', '2024-11-14 13:50:00', '2024-11-14 13:52:00', '55.826205', '12.319242', '55.846256', '12.414063');
insert into bus_ride values('6767667676', '350A', '2024-11-14 13:50:00', '2024-11-14 13:57:00', '55.826205', '12.319242', '55.846256', '12.414063');

#code
select card_id, line_name, max(timediff(end_time, start_time)) as duration from bus_ride group by line_name;

#################################################################################################

# 7 Show the name of the bus stops that are never used, that is, they are neither the start nor the end stop for any ride.
#tested with
select * from Bus_stop natural left join stops_at;
#to see which stops are never used, that is where line_name is null.

#code
select stop_name from Bus_stop natural left join stops_at where line_name is null;

#################################################################################################

# A function that gets the index of the last stop of a line
drop function if exists LastStopIndex;
DELIMITER //
create function LastStopIndex(line_name varchar(4)) returns int
begin
return (select max(stop_index) from stops_at where stops_at.line_name = line_name);
end//
DELIMITER ;

#################################################################################################

# A procedure that gets the coordinates of the last stop of a line
drop procedure if exists LastStopCoordinates;
DELIMITER //
create procedure LastStopCoordinates(in line_name varchar(4), out last_stop_latitude char(9), out last_stop_longitude char(9))
begin
select latitude into last_stop_latitude from stops_at where stops_at.line_name = line_name and stops_at.stop_index = (select LastStopIndex(line_name));
select longitude into last_stop_longitude from stops_at where stops_at.line_name = line_name and stops_at.stop_index = (select LastStopIndex(line_name));
end//
DELIMITER ;

#################################################################################################

# A function that tells us whether a stop is served by some line
drop function if exists StopServedByLine;
DELIMITER //
create function StopServedByLine(stop_latitude char(9), stop_longitude char(9), line_name varchar(4)) returns boolean
begin
return exists (select * from stops_at where stops_at.line_name = line_name and stops_at.latitude = stop_latitude and stops_at.longitude = stop_longitude);
end//
DELIMITER ;

select StopServedByLine("55.846501", "12.414829", "500S") as servedByLine;

#################################################################################################

# 9 A procedure that given a line and a stop adds the stop to that line after the last stop if the stop is not already served by that line
drop procedure if exists AddStopToLine;
DELIMITER //
create procedure AddStopToLine(in line_name varchar(4), in stop_latitude char(9), in stop_longitude char(9))
begin
declare last_stop_index int;
select LastStopIndex(line_name) into last_stop_index;
if StopServedByLine(stop_latitude, stop_longitude, line_name)
then signal sqlstate "HY000" set mysql_errno = 1525, message_text = "stop already served by line";
end if;
insert stops_at (latitude, longitude, stop_index, line_name) values (stop_latitude, stop_longitude, (last_stop_index + 1), line_name);
end//
DELIMITER ;

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
