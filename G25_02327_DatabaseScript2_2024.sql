use movibus;

# triggers to handle constraints on index in StopsAt for insert/update/delete queries
# table modification examples for insert/update/delete
# DONE Show the ID of the passengers who took a ride from the first stop of the line taken.
# Show the name of the bus stop served by most lines.
# For each line, show the ID of the passenger who took the ride that lasted longer.
# Show the ID of the passengers who never took a bus line more than once per day.
# Show the name of the bus stops that are never used, that is, they are neither the start nor the end stop for any ride.
# a function that takes two stops and shows how many liens serve both stops
# a procedure that given a line and stop adds the stop to that line (after the last stop) if not already served by that line
# a trigger that prevents inserting a ride starting and ending at the same stop or at a stop not served by that line
# illustrative examples of all of the above

#################################################################################################

# Show the ID of the passengers who took a ride from the first stop of a given line
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

# A procedure that given a line and a stop adds the stop to that line after the last stop if the stop is not already served by that line
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