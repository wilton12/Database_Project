-- CS4400: Introduction to Database Systems: Wednesday, March 8, 2023
-- Flight Management Course Project Mechanics (v1.0) STARTING SHELL
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_management';

use flight_management;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a database-wide unique location if
it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin
	if not exists (select * from airline where airlineID = ip_airlineID) then
        signal sqlstate '45000' set message_text = 'Airline does not exist';
    end if;

    -- Check if the tail number is unique for the given airline
    if exists (select * from airplane where airlineID = ip_airlineID and tail_num = ip_tail_num) then
        signal sqlstate '45000' set message_text = 'Tail number already exists for this airline';
    end if;

    -- Check if seat capacity and speed are non-zero
    if ip_seat_capacity <= 0 or ip_speed <= 0 then
        signal sqlstate '45000' set message_text = 'Seat capacity and speed must be positive';
    end if;

    -- Check if airplane location is unique
    if exists (select * from airplane where locationID = ip_locationID) then
        signal sqlstate '45000' set message_text = 'Airplane location is not unique';
    end if;

    -- Insert new airplane record into the database
    insert into airplane (airlineID, tail_num, seat_capacity, speed, locationID, plane_type, skids, propellers, jet_engines)
    values (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);
end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a database-wide unique location if it will be used to support
airplane takeoffs and landings.  An airport may have a longer, more descriptive
name.  An airport must also have a city and state designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state char(2), in ip_locationID varchar(50))
sp_main: begin

	-- Check if the airport is unique 
    if exists (select * from airport where airportID = ip_airportID) then
        signal sqlstate '45000' set message_text = 'This airport already exists';
    end if;
    
    -- Check if the location is unique 
    if exists (select * from airport where locationID = ip_locationID) then
        signal sqlstate '45000' set message_text = 'This location already exists';
    end if;
    
    -- Check if the airport location is unique before using
    if ip_locationID is null and exists (select * from leg where departure = ip_airportID or arrival = ip_airportID) then
        signal sqlstate '45000' set message_text = 'This airport does not have a location before using';
    end if;
    
    -- Check if city and state are non null
    if ip_city is null or ip_state is null then
        signal sqlstate '45000' set message_text = 'City and state cannot be null';
    end if;
    
    -- Insert new airplane record into the database
    insert into airport (airportID, airport_name, city, state, locationID)
    values (ip_airportID, ip_airport_name, ip_city, ip_state, ip_locationID);
    

end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person may have a first and last name as well.

Also, a person can hold a pilot role, a passenger role, or both roles.  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  Also,
a pilot might be assigned to a specific airplane as part of the flight crew.  As a
passenger, a person will have some amount of frequent flyer miles. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_flying_airline varchar(50), in ip_flying_tail varchar(50),
    in ip_miles integer)
sp_main: begin

	if exists (select * from person where personID = ip_personID) then
        signal sqlstate '45000' set message_text = 'This person already exists';
    end if;
    
    if ip_locationID is null then
        signal sqlstate '45000' set message_text = 'This person must have a location';
    end if;
    
    if not exists (select * from location where locationID = ip_locationID) then
        signal sqlstate '45000' set message_text = 'This person has an invalid location';
    end if;
    
	insert into person (personID, first_name, last_name, locationID)
    values (ip_personID, ip_first_name, ip_last_name, ip_locationID);
    
    if ip_taxID is not null and ip_experience is not null then
		insert into pilot (personID, taxID, experience, flying_airline, flying_tail)
		values (ip_personID, ip_taxID, ip_experience, ip_flying_airline, ip_flying_tail);
    end if;
    
    if ip_miles is not null then 
		insert into passenger (personID, miles)
		values (ip_personID, ip_miles);
    end if;
    
end //
delimiter ;

-- [4] grant_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new pilot license.  The license must reference
a valid pilot, and must be a new/unique type of license for that pilot. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_pilot_license;
delimiter //
create procedure grant_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin

	if not exists (select * from pilot where personID = ip_personID) then 
		signal sqlstate '45000' set message_text = 'Cannot find this person in pilots';
    end if;
    
    if exists (select * from pilot_licenses where personID = ip_personID and license = ip_license) then 
		signal sqlstate '45000' set message_text = 'This pilot and license already exist';
    end if;
    
    insert into pilot_licenses (personID, license)
    values (ip_personID, ip_license);

end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  Once
an airplane has been assigned, we must also track where the airplane is along
the route, whether it is in flight or on the ground, and when the next action -
takeoff or landing - will occur. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_airplane_status varchar(100), in ip_next_time time)
sp_main: begin

	if exists (select * from flight where flightID = ip_flightID) then 
		signal sqlstate '45000' set message_text = 'This flight already exists';
    end if;
    
    if ip_routeID is null or not exists (select * from route where routeID = ip_routeID) then 
		signal sqlstate '45000' set message_text = 'This routeID is null or invalid';
    end if;
    
    if ip_support_tail is not null and (ip_progress is null or ip_airplane_status is null or ip_next_time is null) then
		signal sqlstate '45000' set message_text = 'Progress/status/next_time missing';
    end if;
    
    insert into flight (flightID, routeID, support_airline, support_tail, progress, airplane_status, next_time)
    values (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, ip_airplane_status, ip_next_time);
    

end //
delimiter ;

-- [6] purchase_ticket_and_seat()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ticket.  The cost of the flight is optional
since it might have been a gift, purchased with frequent flyer miles, etc.  Each
flight must be tied to a valid person for a valid flight.  Also, we will make the
(hopefully simplifying) assumption that the departure airport for the ticket will
be the airport at which the traveler is currently located.  The ticket must also
explicitly list the destination airport, which can be an airport before the final
airport on the route.  Finally, the seat must be unoccupied. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ticket_and_seat;
delimiter //
create procedure purchase_ticket_and_seat (in ip_ticketID varchar(50), in ip_cost integer,
	in ip_carrier varchar(50), in ip_customer varchar(50), in ip_deplane_at char(3),
    in ip_seat_number varchar(50))
sp_main: begin

	if not exists (select * from person where personID = ip_customer) then 
		signal sqlstate '45000' set message_text = 'Invalid customer';
    end if;
    
    if exists (select * from ticket_seats where ticketID = ip_ticketID and seat_number = ip_seat_number) then 
		signal sqlstate '45000' set message_text = 'Seat already occupied';
    end if;
    
    if not exists (
		select * from flight as f, route_path as r, leg as l where f.flightID = ip_carrier and 
		f.routeID = r.routeID and l.legID = r.legID and l.arrival = ip_deplane_at
    ) then 
		signal sqlstate '45000' set message_text = 'Invalid arrival';
    end if;
    
    insert into ticket (ticketID, cost, carrier, customer, deplane_at)
    values (ip_ticketID, ip_cost, ip_carrier, ip_customer, ip_deplane_at);
    
    insert into ticket_seats (ticketID, seat_number)
    values (ip_ticketID, ip_seat_number);
 
end //
delimiter ;

-- [7] add_update_leg()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new leg as specified.  However, if a leg from
the departure airport to the arrival airport already exists, then don't create a
new leg - instead, update the existence of the current leg while keeping the existing
identifier.  Also, all legs must be symmetric.  If a leg in the opposite direction
exists, then update the distance to ensure that it is equivalent.   */
-- -----------------------------------------------------------------------------
drop procedure if exists add_update_leg;
delimiter //
create procedure add_update_leg (in ip_legID varchar(50), in ip_distance integer,
    in ip_departure char(3), in ip_arrival char(3))
sp_main: begin

	-- Check if leg from departure to arrival already exist
    if exists (select * from leg where departure = ip_departure and arrival = ip_arrival) then
		signal sqlstate '45000' set message_text = ' This leg already exists';
        update leg set distance = ip_distance where departure = ip_departure and arrival = ip_arrival;
    else
        -- If the leg does not exist, create a new leg
        insert into leg (legID, distance, departure, arrival)
        values (ip_legID, ip_distance, ip_departure, ip_arrival);
    end if;
    
	-- Check if a symmetric leg exists (from arrival to departure and departure to arrival)
    if exists (select * from leg where departure = ip_arrival and arrival = ip_departure) then
        -- Update the symmetric leg's distance to match the first leg's distance
        update leg set distance = ip_distance where departure = ip_arrival and arrival = ip_departure;
    end if;
    
end //
delimiter ;


-- [8] start_route()
-- -----------------------------------------------------------------------------
/* This stored procedure creates the first leg of a new route.  Routes in our
system must be created in the sequential order of the legs.  The first leg of
the route can be any valid leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_route;
delimiter //
create procedure start_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin

    -- Check if the leg with the given legID exists
    if not exists (select * from leg where legID = ip_legID) then
        signal sqlstate '45000' set message_text = 'Leg does not exist';
    end if;

    -- Check if the route with the given routeID already exists
    if exists (select * from route where routeID = ip_routeID) then
        signal sqlstate '45000' set message_text = 'Route already exists';
    end if;

    -- Insert the new route into the route table
    insert into route (routeID)
    values (ip_routeID);

    -- Insert the first leg of the route into the route_path table (不确定)
    insert into route_path (routeID, legID, sequence)
    values (ip_routeID, ip_legID, 1);

end //
delimiter ;



-- [9] extend_route()
-- -----------------------------------------------------------------------------
/* This stored procedure adds another leg to the end of an existing route.  Routes
in our system must be created in the sequential order of the legs, and the route
must be contiguous: the departure airport of this leg must be the same as the
arrival airport of the previous leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists extend_route;
delimiter //
create procedure extend_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin

    -- Declare variables
    declare last_arrival char(3);
    declare new_departure char(3);
    declare new_sequence integer;

    -- Check if the leg with the given legID exists
    if not exists (select * from leg where legID = ip_legID) then
        signal sqlstate '45000' set message_text = 'This leg does not exist';
    end if;

    -- Check if the route with the given routeID exists
    if not exists (select * from route where routeID = ip_routeID) then
        signal sqlstate '45000' set message_text = 'This route does not exist';
    end if;

    -- Get the arrival airport of the last leg in the route
    select arrival into last_arrival from leg join route_path on leg.legID = route_path.legID
    where route_path.routeID = ip_routeID
    order by route_path.sequence desc
    limit 1;

    -- Get the departure airport of the new leg
    select departure into new_departure from leg where legID = ip_legID;

    -- Check if the new leg's departure airport is the same as the previous leg's arrival airport
    if new_departure != last_arrival then
        signal sqlstate '45000' set message_text = 'The new leg is not contiguous with the existing route';
    end if;

    -- Determine the new leg's sequence number
    select max(sequence) + 1 into new_sequence from route_path where routeID = ip_routeID;

    -- Insert the new leg into the route_path table
    insert into route_path (routeID, legID, sequence)
    values (ip_routeID, ip_legID, new_sequence);

end //
delimiter ;


-- [10] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin

if (select airplane_status from flight as f where f.flightID = ip_flightID) = 'in_flight'
    then
    UPDATE flight
    set airplane_status = 'on_ground', next_time = date_add(next_time, interval 1 hour) where flightID = ip_flightID; 

	set @d_mile = (select distance from leg as l where l.legID = 
				(select r.legID from route_path as r where r.routeID =
                (select f.routeID from flight as f where f.flightID = ip_flightID and f.progress = 2) and r.sequence = 2));
    
    UPDATE passenger
    set passenger.miles = passenger.miles + @d_mile where passenger.personID in (select t.customer from ticket as t where t.carrier = ip_flightID);
    
	
		if (select count(*) from person as p where p.locationID =  (select a.locationID from airplane as a where a.tail_num = 
																(select f.support_tail from flight as f where f.flightID = ip_flightID))) > 0
		then 
        -- select arrival airport of the flight
		set @flight_airport = (select arrival from leg as l where l.legID in (select rp.legID from route_path as rp 
									where rp.routeID = (select f.routeID from flight as f where f.flightID = ip_flightID)
									AND  (rp.sequence) = (select progress from flight where flightID = ip_flightID)));
									
		-- find locationID of the airport where airplane locates
		set @flight_airport_loc = (select airport.locationID from airport where airport.airportID = @flight_airport);

		-- find locationID of the airplane
		set @flight_loc = (select ap.locationID from airplane as ap where ap.tail_num = (select f.support_tail from flight as f where f.flightID = ip_flightID));

        set @new_loc = @flight_airport_loc;
                
        UPDATE person
		set person.locationID = @new_loc where person.personID in (select t.customer from ticket as t where t.carrier = ip_flightID);
        
        UPDATE person
		set person.locationID = @new_loc where person.personID in (select pilot.personID from pilot where flying_tail =
																(select f.support_tail from flight as f where f.flightID = ip_flightID)); 
        
		UPDATE airplane
        set airplane.locationID = @new_loc where airplane.tail_num = (select f.support_tail from flight as f where f.flightID = ip_flightID);
        end if;
        
	UPDATE pilot
	set experience = experience + 1
	where flying_airline = (SELECT support_airline from flight WHERE flightID = ip_flightID)
	AND flying_tail = (SELECT support_tail from flight WHERE flightID = ip_flightID);
    
   
    end if;

end //
delimiter ;

-- [11] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin

set @d_distance = (select l.distance from leg as l where l.legID = (select rp.legID from route_path as rp 
						where rp.routeID = (select f.routeID from flight as f where f.flightID = ip_flightID)
						and (rp.sequence - 1) = (select f.progress from flight as f where f.flightID = ip_flightID)));
set @d_speed = (select speed from airplane as a where a.tail_num = (select f.support_tail from flight as f where f.flightID = ip_flightID));
set @d_time = @d_distance/@d_speed;
UPDATE flight
set progress = progress+1, airplane_status = 'in_flight', next_time = date_add(next_time, interval @d_time hour) 
where flightID = ip_flightID;
IF ((select plane_type from airplane where tail_num = (select support_tail from flight where flightID = ip_flightID)) = 'prop'
		AND (select count(*) from person as p where p.locationID = 
			(select ap.locationID from airplane as ap where ap.tail_num = (select support_tail from flight where flightID = ip_flightID))AND p.locationID IS NOT NULL) < 1)
then UPDATE flight
set next_time = date_add(next_time, interval 0.5 hour) where flightID = ip_flightID;
END IF;
IF ((select plane_type from airplane where tail_num = (select support_tail from flight where flightID = ip_flightID)) = 'jet'
		AND (select count(*) from person as p where p.locationID = 
			(select ap.locationID from airplane as ap where ap.tail_num = (select support_tail from flight where flightID = ip_flightID))AND p.locationID is NOT NULL) < 2)
then UPDATE flight
set next_time = date_add(next_time, interval 0.5 hour) where flightID = ip_flightID;
END IF;


end //
delimiter ;

-- [12] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the airport and hold a valid ticket
for the flight. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin

-- select departure airport of the flight
set @flight_airport = (select departure from leg as l where l.legID in (select rp.legID from route_path as rp 
							where rp.routeID = (select f.routeID from flight as f where f.flightID = ip_flightID)
                            AND  (rp.sequence-1) = (select progress from flight where flightID = ip_flightID)));
                            
-- find locationID of the airport where airplane locates
set @flight_airport_loc = (select airport.locationID from airport where airport.airportID = @flight_airport);

-- find locationID of the airplane
set @flight_loc = (select ap.locationID from airplane as ap where ap.tail_num = (select f.support_tail from flight as f where f.flightID = ip_flightID));

IF EXISTS (
	select * 
    from person as p 
    where p.locationID = @flight_airport_loc
		and p.personID in (select pa.personID from passenger as pa)
		and p.personID in (select customer from ticket where carrier = ip_flightID)
)
THEN UPDATE person
	set person.locationID = @flight_loc where person.locationID = @flight_airport_loc
										and person.personID in (select pa.personID from passenger as pa)
										and person.personID in (select customer from ticket where carrier = ip_flightID)
;

END IF;


end //
delimiter ;


-- [13] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin

-- select departure airport of the flight
set @flight_arrival_airport = (select arrival from leg as l where l.legID in (select rp.legID from route_path as rp 
							where rp.routeID = (select f.routeID from flight as f where f.flightID = ip_flightID)
                            AND  (rp.sequence) = (select progress from flight where flightID = ip_flightID)));

-- find locationID of the airport where airplane will arrive
set @flight_airport_loc = (select airport.locationID from airport where airport.airportID = @flight_arrival_airport);

-- find locationID of the airplane
set @flight_loc = (select ap.locationID from airplane as ap where ap.tail_num = (select f.support_tail from flight as f where f.flightID = ip_flightID));

IF exists (
select * 
from person 
	where person.locationID = @flight_loc 
    and person.personID in (select customer from ticket where carrier = ip_flightID 
														and deplane_at = @flight_arrival_airport)
)

THEN UPDATE person
	set person.locationID = @flight_airport_loc
	where person.locationID = @flight_loc 
    and person.personID in (select customer from ticket where carrier = ip_flightID 
														and deplane_at = @flight_arrival_airport)
;
END IF;



end //
delimiter ;

-- [14] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
airplane.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin

-- select departure airport of the flight
set @flight_departure_airport = (select departure from leg as l where l.legID in (select rp.legID from route_path as rp 
							where rp.routeID = (select f.routeID from flight as f where f.flightID = ip_flightID)
                            AND  (rp.sequence - 1) = (select progress from flight where flightID = ip_flightID)));

-- find locationID of the airport where airplane will arrive
set @flight_airport_loc = (select airport.locationID from airport where airport.airportID = @flight_departure_airport);

-- find locationID of the airplane
set @flight_loc = (select ap.locationID from airplane as ap where ap.tail_num = (select f.support_tail from flight as f where f.flightID = ip_flightID));
-- debug: select @flight_departure_airport, @flight_airport_loc, @flight_loc;

IF (
  (select count(*) from airplane as a, flight as f, pilot_licenses as pl
  where a.tail_num = f.support_tail
  and pl.license = a.plane_type
  and pl.personID = ip_personID
  and f.flightID = ip_flightID) >= 1
  AND 
  (select count(*) from person as p
	join pilot on p.personID = pilot.personID 
	where p.locationID = @flight_airport_loc
	and pilot.flying_airline IS NULL and pilot.flying_tail IS NULL) >=1
  )
then UPDATE pilot
set flying_airline = (select support_airline from flight where flightID = ip_flightID)
where pilot.personID = ip_personID;

UPDATE pilot
set flying_tail = (select support_tail from flight where flightID = ip_flightID)
where pilot.personID = ip_personID;

UPDATE person
set locationID = @flight_loc
where person.personID = ip_personID;

END IF;

end //
delimiter ;

-- [15] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin

DECLARE isAtEnd bit default 0;

-- select departure airport of the flight
set @flight_arrival_airport = (select arrival from leg as l where l.legID in (select rp.legID from route_path as rp 
       where rp.routeID = (select f.routeID from flight as f where f.flightID = ip_flightID)
                            AND  (rp.sequence) = (select progress from flight where flightID = ip_flightID)));

-- find locationID of the airport where airplane will arrive
set @flight_airport_loc = (select airport.locationID from airport where airport.airportID = @flight_arrival_airport);

-- find locationID of the airplane
set @flight_loc = (select ap.locationID from airplane as ap where ap.tail_num = (select f.support_tail from flight as f where f.flightID = ip_flightID));
 -- select @flight_arrival_airport, @flight_airport_loc, @flight_loc;

SELECT COUNT(distinct flightID) INTO isAtEnd
from flight as f, route_path as r
where f.flightID = ip_flightID
and f.routeID = r.routeID
and airplane_status = 'on_ground'
and progress = (select max(sequence) max_sequence from route_path where route_path.routeID = f.routeID);



set @disemberk = 
(select count(*) from ticket, person
where ticket.customer = person.personID
and ticket.carrier = ip_flightID
and left(person.locationID, 4) != 'port'); 

-- IF isAtEnd and @disemberk = 0
IF isAtEnd =1 and @disemberk = 0

Then 
UPDATE person
set person.locationID = @flight_airport_loc
where person.personID in (select * from (select pilot.personID 
      from pilot, flight
      where pilot.flying_tail = flight.support_tail
      and flight.flightID = ip_flightID) temp)
;

UPDATE pilot
set flying_airline = NULL 
where pilot.personID in (select * from (select pilot.personID 
      from pilot, flight
      where pilot.flying_tail = flight.support_tail
      and flight.flightID = ip_flightID) temp)
;
UPDATE pilot
 set flying_tail = NULL 
    where pilot.personID in (select * from (select pilot.personID 
      from pilot, flight
      where pilot.flying_tail = flight.support_tail
      and flight.flightID = ip_flightID) temp)
;


END IF;

end //
delimiter ;

-- [16] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin

   set @max_sequence = (select MAX (r.sequence) from route_path as r where r.routeID in (select f.routeID from flight as f where f.flightID = @ip_flightID));
	set @c_progress = (select progress from flight where flightID = ip_flightID);
	set @isOnGround = (select airplane_status from flight where flightID = ip_flightID);
    
		if @c_progress = 0
		then set @newAPortL = (select departure from leg where leg.legID = 
							(select route_path.legID from route_path where route_path.routeID = 
							(select flight.routeID from flight where flight.flightID = ip_flightID)));
		ELSEIF @c_progress = (@max_sequence - 1)
		then set @enwAPortL = (select arrival from leg where leg.legID = 
							(select route_path.legID from route_path where route_path.routeID = 
							(select flight.routeID from flight where flight.flightID = ip_flightID)));
		END IF;	
    
	if @isOnGround = 'on_ground' OR @c_progress = (@max_sequence or 0)
    
	then 
    UPDATE pilot
	set flying_airline = NULL, flying_tail = NULL
	where flying_airline = (SELECT support_airline from flight WHERE flightID = ip_flightID)
	AND flying_tail = (SELECT support_tail from flight WHERE flightID = ip_flightID);
	
	UPDATE person
    set person.locationID = (select airport.locationID from airport where airportID = @newAPortL)
    where person.locationID = (select airplane.locationID from airplane where tail_num = 
							(select support_tail from flight where flightID = ip_flightID));
	UPDATE airplane
	set locationID = NULL
	where tail_num = (SELECT support_tail FROM flight WHERE flightID = ip_flightID);
    
	Delete from flight where flightID = ip_flightID;
	END IF;

end //
delimiter ;

-- [17] remove_passenger_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the passenger role from person.  The passenger
must be on the ground at the time; and, if they are on a flight, then they must
disembark the flight at the current airport.  If the person had both a pilot role
and a passenger role, then the person and pilot role data should not be affected.
If the person only had a passenger role, then all associated person data must be
removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_passenger_role;
delimiter //
create procedure remove_passenger_role (in ip_personID varchar(50))
sp_main: begin

	DECLARE hasPilotRole, hasPassengerRole, willDispark, isOnGround, buyATicket BIT DEFAULT 0;
    
    SELECT COUNT(*) INTO hasPilotRole FROM pilot WHERE personID = ip_personID;
    
    SELECT COUNT(*) INTO buyATicket FROM ticket WHERE customer = ip_personID;
    
    SELECT COUNT(*) INTO hasPassengerRole FROM passenger WHERE personID = ip_personID;
    
    IF hasPassengerRole = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Person does not have a passenger role';
	END IF;
    
    SELECT COUNT(*) INTO isOnGround FROM person WHERE personID = ip_personID and left(locationID, 4) = 'port';
    
    if isOnGround = 0 then 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Person is not on ground';
	END IF;
    
    if isOnGround = 1 then
		select count(*) into willDispark from airport as a, ticket as t, person as p
		where t.customer = ip_personID
		and p.locationID = a.locationID
		and a.airportID = t.deplane_at;
	end if;
    
    if (buyATicket = 1 and willDispark = 0) then 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Person will not dispark at the current airport';
	end if;
    
    DELETE FROM passenger WHERE personID = ip_personID;
    
    IF hasPilotRole = 0 THEN
		DELETE FROM person WHERE personID = ip_personID;
	END IF;

end //
delimiter ;

-- [18] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the pilot role from person.  The pilot must not
be assigned to a flight; or, if they are assigned to a flight, then that flight
must either be at the start or end of its route.  If the person had both a pilot
role and a passenger role, then the person and passenger role data should not be
affected.  If the person only had a pilot role, then all associated person data
must be removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_personID varchar(50))
sp_main: begin
	
    DECLARE hasPilotRole, hasPassengerRole, isAssignedToFlight, isAssignedToStartOrEndFlight BIT DEFAULT 0;
    
    SELECT COUNT(*) INTO hasPilotRole FROM pilot WHERE personID = ip_personID;
    
    IF hasPilotRole = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Person does not have a pilot role';
	END IF;
    
    SELECT COUNT(*) INTO hasPassengerRole FROM passenger WHERE personID = ip_personID;
    
    SELECT COUNT(*) INTO isAssignedToFlight FROM pilot WHERE personID = ip_personID and flying_tail IS NOT NULL;
    
    if isAssignedToFlight = 1 then
		SELECT COUNT(distinct flightID) INTO isAssignedToStartOrEndFlight 
		from flight as f, route_path as r, pilot as p
        where p.personID = ip_personID
		and f.support_tail = p.flying_tail
		and f.routeID = r.routeID
        and airplane_status = 'on_ground'
		and (progress = (select max(sequence) max_sequence from route_path where route_path.routeID = f.routeID)
		or progress = 0);
	end if;
    
    if (isAssignedToFlight = 1 and isAssignedToStartOrEndFlight = 0) then 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Person is assigned to a flight that is not at the start or end of its route';
	end if;
    
    DELETE FROM pilot_licenses WHERE personID = ip_personID;
    DELETE FROM pilot WHERE personID = ip_personID;
    
    IF hasPassengerRole = 0 THEN
		DELETE FROM person WHERE personID = ip_personID;
	END IF;
  
end //
delimiter ;


-- [19] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
CREATE or replace view route_with_start_end_legs AS
SELECT 
  route.routeID,
  MIN(smallest_seq.legID) AS start_legID,
  MAX(largest_seq.legID) AS end_legID
FROM route
JOIN route_path AS smallest_seq ON (
    route.routeID = smallest_seq.routeID
    AND smallest_seq.sequence = (
        SELECT MIN(inner_route_path.sequence)
        FROM route_path AS inner_route_path
        WHERE inner_route_path.routeID = route.routeID
    )
)
JOIN route_path AS largest_seq ON (
    route.routeID = largest_seq.routeID
    AND largest_seq.sequence = (
        SELECT MAX(inner_route_path.sequence)
        FROM route_path AS inner_route_path
        WHERE inner_route_path.routeID = route.routeID
    )
)
GROUP BY route.routeID;


CREATE OR REPLACE VIEW route_with_departure_arrival AS
SELECT 
  route_with_start_end_legs.routeID,
  route_with_start_end_legs.start_legID,
  route_with_start_end_legs.end_legID,
  start_leg.departure AS start_departure,
  end_leg.arrival AS end_arrival
FROM route_with_start_end_legs
JOIN leg AS start_leg ON route_with_start_end_legs.start_legID = start_leg.legID
JOIN leg AS end_leg ON route_with_start_end_legs.end_legID = end_leg.legID;


CREATE OR REPLACE VIEW flight_with_departure_arrival AS
SELECT 
  flight.*,
  route_departure_arrival.start_departure,
  route_departure_arrival.end_arrival
FROM flight
JOIN route_with_departure_arrival AS route_departure_arrival ON flight.routeID = route_departure_arrival.routeID;
--

CREATE OR REPLACE VIEW flight_in_flight_leg_info AS
SELECT
  flight.*,
  route_path.legID,
  leg.departure,
  leg.arrival
FROM flight
JOIN route_path ON (
  flight.routeID = route_path.routeID
  AND flight.progress = route_path.sequence
)
JOIN leg ON route_path.legID = leg.legID
WHERE flight.airplane_status = 'in_flight';


create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
SELECT
  flight_in_flight_leg_info.departure AS departing_from,
  flight_in_flight_leg_info.arrival AS arriving_at,
  COUNT(*) AS num_flights,
  GROUP_CONCAT(flight_in_flight_leg_info.flightID ORDER BY flight_in_flight_leg_info.flightID) AS flight_list,
  MIN(flight_in_flight_leg_info.next_time) AS earliest_arrival,
  MAX(flight_in_flight_leg_info.next_time) AS latest_arrival,
  GROUP_CONCAT(airplane.locationID ORDER BY airplane.locationID) AS airplane_list
FROM flight_in_flight_leg_info
JOIN airplane ON (
  flight_in_flight_leg_info.support_airline = airplane.airlineID
  AND flight_in_flight_leg_info.support_tail = airplane.tail_num
)
GROUP BY flight_in_flight_leg_info.departure, flight_in_flight_leg_info.arrival;

  

-- [20] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW flight_on_ground_info AS
SELECT
  flight.*,
  route_path.legID,
  CASE
    WHEN flight.progress = 0 THEN flight_with_departure_arrival.start_departure
    ELSE leg.arrival
  END AS departing_from
FROM flight
LEFT JOIN route_path ON (
  flight.routeID = route_path.routeID
  AND flight.progress = route_path.sequence
)
LEFT JOIN leg ON route_path.legID = leg.legID
JOIN flight_with_departure_arrival ON flight.flightID = flight_with_departure_arrival.flightID
WHERE flight.airplane_status = 'on_ground';


create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
SELECT
  departing_from,
  COUNT(*) AS num_flights,
  GROUP_CONCAT(flightID) AS flight_list,
  MIN(next_time) AS earliest_arrival,
  MAX(next_time) AS latest_arrival,
  GROUP_CONCAT((
    SELECT locationID
    FROM airplane
    WHERE airplane.airlineID = flight_on_ground_info.support_airline
      AND airplane.tail_num = flight_on_ground_info.support_tail
  )) AS airplane_list
FROM flight_on_ground_info
GROUP BY departing_from;

-- [21] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
SELECT
  flights_in_the_air.departing_from,
  flights_in_the_air.arriving_at,
  flights_in_the_air.num_flights AS num_airplanes,
  flights_in_the_air.airplane_list,
  flights_in_the_air.flight_list,
  flights_in_the_air.earliest_arrival,
  flights_in_the_air.latest_arrival,
  COUNT(pilot.personID) AS num_pilots,
  COUNT(passenger.personID) AS num_passengers,
  COUNT(person.personID) AS joint_pilots_passengers,
  GROUP_CONCAT(person.personID) AS person_list
FROM flights_in_the_air
JOIN airplane ON FIND_IN_SET(airplane.locationID, flights_in_the_air.airplane_list) > 0
JOIN person ON person.locationID = airplane.locationID
LEFT JOIN pilot ON pilot.personID = person.personID AND pilot.flying_airline = airplane.airlineID AND pilot.flying_tail = airplane.tail_num
LEFT JOIN passenger ON passenger.personID = person.personID
GROUP BY flights_in_the_air.departing_from, flights_in_the_air.arriving_at;

-- [22] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
SELECT
  airport.airportID AS departing_from,
  airport.locationID AS airport,
  airport.airport_name,
  airport.city,
  airport.state,
  COUNT(pilot.personID) AS num_pilots,
  COUNT(passenger.personID) AS num_passengers,
  COUNT(person.personID) AS joint_pilots_passengers,
  GROUP_CONCAT(person.personID) AS person_list
FROM airport
JOIN person ON person.locationID = airport.locationID
LEFT JOIN pilot ON pilot.personID = person.personID
LEFT JOIN passenger ON passenger.personID = person.personID
GROUP BY airport.airportID, airport.locationID, airport.airport_name, airport.city, airport.state;

-- [23] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary_test AS
SELECT
  r.routeID as route,
  COUNT(DISTINCT rp.legID) AS num_legs,
  GROUP_CONCAT(DISTINCT rp.legID ORDER BY rp.sequence) AS leg_sequence,
  SUM(l.distance) AS route_length,
  GROUP_CONCAT(
      DISTINCT CONCAT(l.departure, '->', l.arrival)
      ORDER BY rp.sequence
    ) AS airport_sequence
FROM
  route r
  JOIN route_path rp ON r.routeID = rp.routeID
  JOIN leg l ON rp.legID = l.legID
GROUP BY r.routeID;

create or replace view route_summary (route, num_legs, leg_sequence, route_length,
 num_flights, flight_list, airport_sequence) as 
 SELECT
  rst.route,
  rst.num_legs,
  rst.leg_sequence,
  rst.route_length,
  COUNT(DISTINCT f.flightID) AS num_flights,
  GROUP_CONCAT(DISTINCT f.flightID) AS flight_list,
  rst.airport_sequence
FROM
  route_summary_test rst
  LEFT JOIN flight f ON rst.route = f.routeID
GROUP BY rst.route;



-- [24] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, num_airports,
 airport_code_list, airport_name_list) as
SELECT 
  city, 
  state, 
  COUNT(airportID) AS num_airports,
  GROUP_CONCAT(airportID ORDER BY airportID) AS airport_codes_list,
  GROUP_CONCAT(airport_name ORDER BY airportID) AS airport_names_list
FROM airport
GROUP BY city, state
HAVING COUNT(airportID) > 1;

-- [25] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin

 DECLARE next_flight_id VARCHAR(50);
    DECLARE cur_status VARCHAR(50);
    DECLARE isAtEnd bit default 0;
    
    select flightID into next_flight_id from flight where next_time is not null order by next_time, airplane_status, flightID limit 1;
    select airplane_status into cur_status from flight where next_time is not null order by next_time, airplane_status, flightID limit 1;
    
    if cur_status = 'on_ground' then 
  SELECT COUNT(distinct flightID) INTO isAtEnd 
  from flight as f, route_path as r
        where f.flightID = next_flight_id
  and f.routeID = r.routeID
  and progress = (select max(sequence) max_sequence from route_path where route_path.routeID = f.routeID);
 end if;
    
    if cur_status = 'in_flight' then
  call flight_landing(next_flight_id);
        call passengers_disembark(next_flight_id);
    end if;
    
    if cur_status = 'on_ground' then 
  if isAtEnd = 0 then 
   call passengers_board(next_flight_id);
   call flight_takeoff(next_flight_id);
  end if;
  if isAtEnd = 1 then 
   call recycle_crew(next_flight_id);
   call retire_flight(next_flight_id);
  end if;
 end if;
end //
delimiter ;

