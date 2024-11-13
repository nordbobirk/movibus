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
# Here we use the line 4a
