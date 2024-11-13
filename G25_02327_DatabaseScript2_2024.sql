use movibus;

# triggers to handle constraints on index in StopsAt for insert/update/delete queries
# table modification examples for insert/update/delete
# Show the ID of the passengers who took a ride from the first stop of the line taken.
# Show the name of the bus stop served by most lines.
# For each line, show the ID of the passenger who took the ride that lasted longer.
# Show the ID of the passengers who never took a bus line more than once per day.
# Show the name of the bus stops that are never used, that is, they are neither the start nor the end stop for any ride.
# a function that takes two stops and shows how many liens serve both stops
# a procedure that given a line and stop adds the stop to that line (after the last stop) if not already served by that line
# a trigger that prevents inserting a ride starting and ending at the same stop or at a stop not served by that line
# illustrative examples of all of the above

# Show the ID of the passengers who took a ride from the first stop of a given line
# Instead of writing a query for a single line we create a function to get these passengers from any line
drop function if exists PassengersFromFirstStop;
DELIMITER //
create function PassengersFromFirstStop(line_name varchar(4)) returns char(10)
begin
return (select card_id from bus_ride where 
bus_ride.first_stop_latitude = (select latitude from stops_at where stops_at.line_name = line_name and stop_index = 1) 
and bus_ride.first_stop_longitude = (select longitude from stops_at where stops_at.line_name = line_name and stop_index = 1));
end//
DELIMITER ;

# A function that gets the index of the last stop of a line
drop function if exists LastStopIndex;
DELIMITER //
create function LastStopIndex(line_name varchar(4)) returns int
begin
return (select max(stop_index) from stops_at where stops_at.line_name = line_name);
end//
DELIMITER ;

# A procedure that gets the coordinates of the last stop of a line
DELIMITER //
create procedure LastStopCoordinates(in line_name varchar(4), out last_stop_latitude char(9), out last_stop_longitude char(9))
begin
declare last_stop_index int;
select max(stop_index) into last_stop_index from stops_at where stops_at.line_name = line_name;
select latitude into last_stop_latitude from stops_at where stops_at.line_name = line_name and stops_at.stop_index = last_stop_index;
select longitude into last_stop_longitude from stops_at where stops_at.line_name = line_name and stops_at.stop_index = last_stop_index;
end//
DELIMITER ;

# A function that tells us whether a stop is served by some line
DELIMITER //
create function StopServedByLine(stop_latitude char(9), stop_longitude char(9), line_name varchar(4)) returns boolean
begin
return exists (select * from stops_at where stops_at.line_name = line_name and stops_at.latitude = stop_latitude and stops_at.longitude = stop_longitude);
end//
DELIMITER ;

# A procedure that given a line and a stop adds the stop to that line after the last stop if the stop is not already served by that line
DELIMITER //
create procedure AddStopToLine(in line_name varchar(4), in stop_latitude char(9), in stop_longtitide char(9), in stop_name varchar(20))
begin
declare last_stop_index int;
select LastStopIndex(line_name) into last_stop_index;
if StopServedByLine(stop_latitude, stop_longitude, line_name)
then signal sqlstate "HY000" set mysql_errno = 1525, message_text = "stop already served by line";
end if;
insert stops_at values (latitude = stop_latitude, longitude = stop_longitude, stop_name = stop_name, stop_index = last_stop_index);
end//
DELIMITER ;
