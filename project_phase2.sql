DROP DATABASE IF EXISTS project_phase2;
CREATE DATABASE project_phase2;
USE project_phase2;


DROP TABLE IF EXISTS airlines;
CREATE TABLE airlines (
 airlineID char(50) NOT NULL,
 revenueID char(50) NOT NULL,
 PRIMARY KEY (airlineID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS location;
CREATE TABLE location (
 	locID char(10) NOT NULL,
    PRIMARY KEY (locID)
)ENGINE = InnoDB;

DROP TABLE IF EXISTS route;
CREATE TABLE route (
  routeID char(50) not null,
  PRIMARY KEY (routeID)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
	airportID char(3) not null,
    name char(100) not null,
    locID char(20) default null,
    PRIMARY KEY (airportID),
    CONSTRAINT fk1 FOREIGN KEY   (locID) REFERENCES location(locID)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS airport_address;
CREATE TABLE airport_address (
	airportID char(3) not null,
    city char(50) not null,
    state char(20) not null,
    PRIMARY KEY (airportID, city, state),
    CONSTRAINT fk2 FOREIGN KEY  (airportID) REFERENCES airport(airportID)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS leg;
CREATE TABLE leg (
	legID char(20) not null,
    distance float not null,
    departsID char(3) not null,
    arrivesID char(3) not null,
	PRIMARY KEY (legID),
    	CONSTRAINT fk3 FOREIGN KEY  (departsID) REFERENCES airport(airportID),
	CONSTRAINT fk4 FOREIGN KEY  (arrivesID) REFERENCES airport(airportID)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS contain;
CREATE TABLE contain (
  routeID char(50) not null,
  legID char(20) not null,
  PRIMARY KEY (routeID, legID),
  CONSTRAINT fk5 FOREIGN KEY  (routeID) REFERENCES route(routeID),
  CONSTRAINT fk6 FOREIGN KEY  (legID) REFERENCES leg(legID)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS airplanes;
CREATE TABLE airplanes (
  airlineID char(20) NOT NULL,
  tail_num char(20) NOT NULL,
  seat_cap decimal(2,0) NOT NULL,
  speed decimal(4,0) NOT NULL,
  locID char(20)DEFAULT NULL,
  
  PRIMARY KEY (airlineID, tail_num),
  CONSTRAINT fk7 FOREIGN KEY (airlineID) REFERENCES airlines (airlineID),
  CONSTRAINT fk8 FOREIGN KEY (locID) REFERENCES location (locID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS propPlanes;
CREATE TABLE propPlanes (
 airlineID char(20) NOT NULL,
 tail_num char(20) NOT NULL,
 skid decimal(1,0) NOT NULL,
 prop decimal(1,0) NOT NULL,
 
 PRIMARY KEY (airlineID, tail_num),
 CONSTRAINT fk9 FOREIGN KEY  (airlineID, tail_num) REFERENCES airplanes (airlineID, tail_num)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS jetPlanes;
CREATE TABLE jetPlanes (
 airlineID char(20) NOT NULL,
 tail_num char(20) NOT NULL,
 jet decimal(1,0) NOT NULL,
  PRIMARY KEY (airlineID, tail_num),
 CONSTRAINT fk10 FOREIGN KEY  (airlineID, tail_num) REFERENCES airplanes (airlineID, tail_num)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS flights;
CREATE TABLE flights (
 flightID char(20) NOT NULL,
 routeID char(50) NOT NULL,
 support_airline char(50) DEFAULT NULL,
 support_tail char(50) DEFAULT NULL,
 progress decimal(1,0)DEFAULT NULL,
 airplane_status char(50) DEFAULT NULL,
 next_time time DEFAULT NULL,
 PRIMARY KEY (flightID),
 CONSTRAINT fk11 FOREIGN KEY  (routeID) REFERENCES route (routeID),
 CONSTRAINT fk12 FOREIGN KEY  (support_airline, support_tail) REFERENCES airplanes (airlineID, tail_num)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS person;
CREATE TABLE person (
personID char (20) NOT NULL,
first_name char(20) NOT NULL,
last_name char(20) NOT NULL,
locationID char(10) NOT NULL,
PRIMARY KEY (personID),
CONSTRAINT fk13 FOREIGN KEY  (locationID) REFERENCES location (locID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS pilot;
CREATE TABLE pilot (
personID char (20) NOT NULL,
taxID decimal(9,0) DEFAULT NULL,
experience decimal(2,0) DEFAULT NULL,
flying_airline char(20) DEFAULT NULL,
flying_tail char(20) DEFAULT NULL,
PRIMARY KEY (personID),
CONSTRAINT fk14 FOREIGN KEY  (personID) REFERENCES person (personID),
CONSTRAINT fk15 FOREIGN KEY  (flying_airline) REFERENCES airlines (airlineID),
CONSTRAINT fk16 FOREIGN KEY (flying_airline, flying_tail) REFERENCES airplanes (airlineID, tail_num)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS license;
CREATE TABLE license (
  pilotID char(20) not null,
  license char(20) not null,
  PRIMARY KEY (pilotID, license),
  CONSTRAINT fk17 FOREIGN KEY  (pilotID) REFERENCES person(personID)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS passenger;
CREATE TABLE passenger (
personID char (20) NOT NULL,
miles decimal(10, 0) DEFAULT NULL,
PRIMARY KEY (personID),
CONSTRAINT fk18 FOREIGN KEY  (personID) REFERENCES person (personID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS tickets;
CREATE TABLE tickets (
	ticketID char(10) NOT NULL,
    cost decimal(3) NOT NULL,
    carrier char(10) NOT NULL,
    customer char(10) NOT NULL,
    deplane_at char(3) NOT NULL,
    PRIMARY KEY (ticketID),
    CONSTRAINT fk19 FOREIGN KEY  (deplane_at) REFERENCES airport (airportID),
    CONSTRAINT fk20 FOREIGN KEY  (carrier) REFERENCES flights (flightID),
    CONSTRAINT fk21 FOREIGN KEY  (customer) REFERENCES person (personID)
) ENGINE = InnoDB;

DROP TABLE IF EXISTS ticket_seat;
CREATE TABLE ticket_seat (
	ticket_ID char(10) NOT NULL,
    seat char(2) NOT NULL,
    PRIMARY KEY (ticket_ID,seat),
    CONSTRAINT fk22 FOREIGN KEY  (ticket_ID) REFERENCES tickets (ticketID)
)ENGINE = InnoDB;

INSERT INTO airlines VALUES
('Air_France','25'),
('American','45'),
('Delta','46'),
('JetBlue','8'),
('Lufthansa','31'),
('Southwest','22'),
('Spirit','4'),
('United','40');

INSERT INTO location VALUES
('plane_1'),
('plane_11'),
('plane_15'),
('plane_2'),
('plane_4'),
('plane_7'),
('plane_8'),
('plane_9'),
('port_1'),
('port_10'),
('port_11'),
('port_13'),
('port_14'),
('port_15'),
('port_17'),
('port_18'),
('port_2'),
('port_3'),
('port_4'),
('port_5'),
('port_7'),
('port_9');

INSERT INTO route VALUES
('circle_east_coast'),
('circle_west_coast'),
('eastbound_north_milk_run'),
('eastbound_north_nonstop'),
('eastbound_south_milk_run'),
('hub_xchg_southeast'),
('hub_xchg_southwest'),
('local_texas'),
('northbound_east_coast'),
('northbound_west_coast'),
('southbound_midwest'),
('westbound_north_milk_run'),
('westbound_north_nonstop'),
('westbound_south_nonstop');

INSERT INTO airport VALUES
('ABQ', 'Albuquerque International Sunport', null),
('ANC', 'Ted Stevens Anchorage International Airport', null),
('ATL', 'Hartsfield-Jackson Atlanta International Airport', 'port_1'),
('BDL', 'Bradley International Airport', null),
('BFI', 'King County International Airport', 'port_10'),
('BHM', 'Birmingham-Shuttlesworth International Airport', null),
('BNA', 'Nashville International Airport', null),
('BOI', 'Boise Airport ', null),
('BOS', 'General Edward Lawrence Logan International Airport', null),
('BTV', 'Burlington International Airport', null),
('BWI', 'Baltimore_Washington International Airport', null),
('BZN', 'Bozeman Yellowstone International Airport', null),
('CHS', 'Charleston International Airport', null),
('CLE', 'Cleveland Hopkins International Airport', null),
('CLT', 'Charlotte Douglas International Airport', null),
('CRW', 'Yeager Airport', null),
('DAL', 'Dallas Love Field', 'port_7'),
('DCA', 'Ronald Reagan Washington National Airport', 'port_9'),
('DEN', 'Denver International Airport', 'port_3'),
('DFW', 'Dallas-Fort Worth International Airport', 'port_2'),
('DSM', 'Des Moines International Airport', null),
('DTW', 'Detroit Metro Wayne County Airport', null),
('EWR', 'Newark Liberty International Airport', null),
('FAR', 'Hector International Airport', null),
('FSD', 'Joe Foss Field', null),
('GSN', 'Saipan International Airport', null),
('GUM', 'Antonio B_Won Pat International Airport', null),
('HNL', 'Daniel K. Inouye International Airport', null),
('HOU', 'William P_Hobby Airport', 'port_18'),
('IAD', 'Washington Dulles International Airport', 'port_11'),
('IAH', 'George Bush Intercontinental Houston Airport', 'port_13'),
('ICT', 'Wichita Dwight D_Eisenhower National Airport ', null),
('ILG', 'Wilmington Airport', null),
('IND', 'Indianapolis International Airport', null),
('ISP', 'Long Island MacArthur Airport', 'port_14'),
('JAC', 'Jackson Hole Airport', null),
('JAN', 'Jackson_Medgar Wiley Evers International Airport', null),
('JFK', 'John F_Kennedy International Airport ', 'port_15'),
('LAS', 'Harry Reid International Airport', null),
('LAX', 'Los Angeles International Airport', 'port_5'),
('LGA', 'LaGuardia Airport', null),
('LIT', 'Bill and Hillary Clinton National Airport', null),
('MCO', 'Orlando International Airport', null),
('MDW', 'Chicago Midway International Airport', null),
('MHT', 'Manchester_Boston Regional Airport', null),
('MKE', 'Milwaukee Mitchell International Airport', null),
('MRI', 'Merrill Field', null),
('MSP', 'Minneapolis_St_Paul International Wold_Chamberlain Airport', null),
('MSY', 'Louis Armstrong New Orleans International Airport', null),
('OKC', 'Will Rogers World Airport', null),
('OMA', 'Eppley Airfield', null),
('ORD', 'O_Hare International Airport', 'port_4'),
('PDX', 'Portland International Airport', null),
('PHL', 'Philadelphia International Airport', null),
('PHX', 'Phoenix Sky Harbor International Airport', null),
('PVD', 'Rhode Island T_F_Green International Airport', null),
('PWM', 'Portland International Jetport', null),
('SDF', 'Louisville International Airport', null),
('SEA', 'Seattle-Tacoma International Airport', 'port_17'),
('SJU', 'Luis Munoz Marin International Airport', null),
('SLC', 'Salt Lake City International Airport', null),
('STL', 'St_Louis Lambert International Airport', null),
('STT', 'Cyril E_King Airport', null);



INSERT INTO airport_address VALUES
('ABQ', 'Albuquerque', 'NM'),
('ANC', 'Anchorage', 'AK'),
('ATL', 'Atlanta', 'GA'),
('BDL', 'Hartford', 'CT'),
('BFI', 'Seattle', 'WA'),
('BHM', 'Birmingham', 'AL'),
('BNA', 'Nashville', 'TN'),
('BOI', 'Boise', 'ID'),
('BOS', 'Boston', 'MA'),
('BTV', 'Burlington', 'VT'),
('BWI', 'Baltimore', 'MD'),
('BZN', 'Bozeman', 'MT'),
('CHS', 'Charleston', 'SC'),
('CLE', 'Cleveland', 'OH'),
('CLT', 'Charlotte', 'NC'),
('CRW', 'Charleston', 'WV'),
('DAL', 'Dallas', 'TX'),
('DCA', 'Washington', 'DC'),
('DEN', 'Denver', 'CO'),
('DFW', 'Dallas', 'TX'),
('DSM', 'Des Moines', 'IA'),
('DTW', 'Detroit', 'MI'),
('EWR', 'Newark', 'NJ'),
('FAR', 'Fargo', 'ND'),
('FSD', 'Sioux Falls', 'SD'),
('GSN', 'Obyan Saipan Island', 'MP'),
('GUM', 'Agana Tamuning', 'GU'),
('HNL', 'Honolulu Oahu', 'HI'),
('HOU', 'Houston', 'TX'),
('IAD', 'Washington', 'DC'),
('IAH', 'Houston', 'TX'),
('ICT', 'Wichita', 'KS'),
('ILG', 'Wilmington', 'DE'),
('IND', 'Indianapolis', 'IN'),
('ISP', 'New York Islip', 'NY'),
('JAC', 'Jackson', 'WY'),
('JAN', 'Jackson', 'MS'),
('JFK', 'New York', 'NY'),
('LAS', 'Las Vegas', 'NV'),
('LAX', 'Los Angeles', 'CA'),
('LGA', 'New York', 'NY'),
('LIT', 'Little Rock', 'AR'),
('MCO', 'Orlando', 'FL'),
('MDW', 'Chicago', 'IL'),
('MHT', 'Manchester', 'NH'),
('MKE', 'Milwaukee', 'WI'),
('MRI', 'Anchorage', 'AK'),
('MSP', 'Minneapolis Saint Paul', 'MN'),
('MSY', 'New Orleans', 'LA'),
('OKC', 'Oklahoma City', 'OK'),
('OMA', 'Omaha', 'NE'),
('ORD', 'Chicago', 'IL'),
('PDX', 'Portland', 'OR'),
('PHL', 'Philadelphia', 'PA'),
('PHX', 'Phoenix', 'AZ'),
('PVD', 'Providence', 'RI'),
('PWM', 'Portland', 'ME'),
('SDF', 'Louisville', 'KY'),
('SEA', 'Seattle Tacoma', 'WA'),
('SJU', 'San Juan Carolina', 'PR'),
('SLC', 'Salt Lake City', 'UT'),
('STL', 'Saint Louis', 'MO'),
('STT', 'Charlotte Amalie Saint Thomas', 'VI');

INSERT INTO leg VALUES
('leg_1', '600', 'ATL', 'IAD'),
('leg_10', '800', 'DFW', 'ORD'),
('leg_11', '600', 'IAD', 'ORD'),
('leg_12', '200', 'IAH', 'DAL'),
('leg_13', '1400', 'IAH', 'LAX'),
('leg_14', '2400', 'ISP', 'BFI'),
('leg_15', '800', 'JFK', 'ATL'),
('leg_16', '800', 'JFK', 'ORD'),
('leg_17', '2400', 'JFK', 'SEA'),
('leg_18', '1200', 'LAX', 'DFW'),
('leg_19', '1000', 'LAX', 'SEA'),
('leg_2', '600', 'ATL', 'IAH'),
('leg_20', '600', 'ORD', 'DCA'),
('leg_21', '800', 'ORD', 'DFW'),
('leg_22', '800', 'ORD', 'LAX'),
('leg_23', '2400', 'SEA', 'JFK'),
('leg_24', '1800', 'SEA', 'ORD'),
('leg_25', '600', 'ORD', 'ATL'),
('leg_26', '800', 'LAX', 'ORD'),
('leg_27', '1600', 'ATL', 'LAX'),
('leg_3', '800', 'ATL', 'JFK'),
('leg_4', '600', 'ATL', 'ORD'),
('leg_5', '1000', 'BFI', 'LAX'),
('leg_6', '200', 'DAL', 'HOU'),
('leg_7', '600', 'DCA', 'ATL'),
('leg_8', '200', 'DCA', 'JFK'),
('leg_9', '800', 'DFW', 'ATL');

INSERT INTO contain VALUES
('circle_east_coast', 'leg_4'),
('circle_east_coast', 'leg_20'),
('circle_east_coast', 'leg_7'),
('circle_west_coast', 'leg_18'),
('circle_west_coast', 'leg_10'),
('circle_west_coast', 'leg_22'),
('eastbound_north_milk_run', 'leg_24'),
('eastbound_north_milk_run', 'leg_20'),
('eastbound_north_milk_run', 'leg_8'),
('eastbound_north_nonstop', 'leg_23'),
('eastbound_south_milk_run', 'leg_18'),
('eastbound_south_milk_run', 'leg_9'),
('eastbound_south_milk_run', 'leg_1'),
('hub_xchg_southeast', 'leg_25'),
('hub_xchg_southeast', 'leg_4'),
('hub_xchg_southwest', 'leg_22'),
('hub_xchg_southwest', 'leg_26'),
('local_texas', 'leg_12'),
('local_texas', 'leg_6'),
('northbound_east_coast', 'leg_3'),
('northbound_west_coast', 'leg_19'),
('southbound_midwest', 'leg_21'),
('westbound_north_milk_run', 'leg_16'),
('westbound_north_milk_run', 'leg_22'),
('westbound_north_milk_run', 'leg_19'),
('westbound_north_nonstop', 'leg_17'),
('westbound_south_nonstop', 'leg_27');

INSERT INTO airplanes VALUES
('American','n330ss','4','200','plane_4'),
('American','n380sd','5','400',NULL),
('Delta','n106js','4','200','plane_1'),
('Delta','n110jn','5','600','plane_2'),
('Delta','n127js','4','800',NULL),
('Delta','n156sq','8','100',NULL),
('JetBlue','n161fk','4','200',NULL),
('JetBlue','n337as','5','400',NULL),
('Southwest','n118fm','4','100','plane_11'),
('Southwest','n401fj','4','200','plane_9'),
('Southwest','n653fk','6','400',NULL),
('Southwest','n815pw','3','200',NULL),
('Spirit','n256ap','4','400','plane_15'),
('United','n451fi','5','400',NULL),
('United','n517ly','4','400','plane_7'),
('United','n616lt','7','400',NULL),
('United','n620la','4','200','plane_8');

INSERT INTO propPlanes VALUES
('Southwest','n118fm','1','1'),
('Southwest','n815pw','0','2'),
('United','n620la','0','2');

INSERT INTO jetPlanes VALUES
('American','n330ss','2'),
('American','n380sd','2'),
('Delta','n106js','2'),
('Delta','n110jn','4'),
('JetBlue','n161fk','2'),
('JetBlue','n337as','2'),
('Southwest','n401fj','2'),
('Southwest','n653fk','2'),
('Spirit','n256ap','2'),
('United','n451fi','4'),
('United','n517ly','2'),
('United','n616lt','4');

INSERT INTO flights VALUES
('AM_1523','circle_west_coast','American','n330ss','2','on_ground','14:30:00'),
('DL_1174','northbound_east_coast','Delta','n106js','0','on_ground','08:00:00'),
('DL_1243','westbound_north_nonstop','Delta','n110jn','0','on_ground','09:30:00'),
('DL_3410','circle_east_coast',NULL,NULL,NULL,NULL,NULL),
('SP_1880','circle_east_coast','Spirit','n256ap','2','in_flight','15:00:00'),
('SW_1776','hub_xchg_southwest','Southwest','n401fj','2','in_flight','14:00:00'),
('SW_610','local_texas','Southwest','n118fm','2','in_flight','11:30:00'),
('UN_1899','eastbound_north_milk_run','United','n517ly','0','on_ground','09:30:00'),
('UN_523','hub_xchg_southeast','United','n620la','1','in_flight','11:00:00'),
('UN_717','circle_west_coast',NULL,NULL,NULL,NULL,NULL);

INSERT INTO person VALUES
('p1','Jeanne','Nelson','plane_1'),
('p10','Lawrence','Morgan','plane_9'),
('p11','Sandra','Cruz','plane_9'),
('p12','Dan','Ball','plane_11'),
('p13','Bryant','Figueroa','plane_2'),
('p14','Dana','Perry','plane_2'),
('p15','Matt','Hunt','plane_2'),
('p16','Edna','Brown','plane_15'),
('p17','Ruby','Burgess','plane_15'),
('p18','Esther','Pittman','port_2'),
('p19','Doug','Fowler','port_4'),
('p2','Roxanne','Byrd','plane_1'),
('p20','Thomas','Olson','port_3'),
('p21','Mona','Harrison','port_4'),
('p22','Arlene','Massey','port_2'),
('p23','Judith','Patrick','port_3'),
('p24','Reginald','Rhodes','plane_1'),
('p25','Vincent','Garcia','plane_1'),
('p26','Cheryl','Moore','plane_4'),
('p27','Michael','Rivera','plane_7'),
('p28','Luther','Matthews','plane_8'),
('p29','Moses','Parks','plane_8'),
('p3','Tanya','Nguyen','plane_4'),
('p30','Ora','Steele','plane_9'),
('p31','Antonio','Flores','plane_9'),
('p32','Glenn','Ross','plane_11'),
('p33','Irma','Thomas','plane_11'),
('p34','Ann','Maldonado','plane_2'),
('p35','Jeffrey','Cruz','plane_2'),
('p36','Sonya','Price','plane_15'),
('p37','Tracy','Hale','plane_15'),
('p38','Albert','Simmons','port_1'),
('p39','Karen','Terry','port_9'),
('p4','Kendra','Jacobs','plane_4'),
('p40','Glen','Kelley','plane_4'),
('p41','Brooke','Little','port_4'),
('p42','Daryl','Nguyen','port_3'),
('p43','Judy','Willis','port_1'),
('p44','Marco','Klein','port_2'),
('p45','Angelica','Hampton','port_5'),
('p5','Jeff','Burton','plane_4'),
('p6','Randal','Parks','plane_7'),
('p7','Sonya','Owens','plane_7'),
('p8','Bennie','Palmer','plane_8'),
('p9','Marlene','Warner','plane_8');

INSERT INTO pilot VALUES
('p1',330126907,31,'Delta','n106js'),
('p10',769601266,15,'Southwest','n401fj'),
('p11',369229505,22,'Southwest','n401fj'),
('p12',680925329,24,'Southwest','n118fm'),
('p13',513404168,24,'Delta','n110jn'),
('p14',454717847,13,'Delta','n110jn'),
('p15',153478101,30,'Delta','n110jn'),
('p16',598475172,28,'Spirit','n256ap'),
('p17',865716800,36,'Spirit','n256ap'),
('p18',250862784,23,NULL,NULL),
('p19',386397881,2,NULL,NULL),
('p2',842881257,9,'Delta','n106js'),
('p20',522443098,28,NULL,NULL),
('p21',621345755,2,NULL,NULL),
('p22',177479877,3,NULL,NULL),
('p23',528647912,12,NULL,NULL),
('p24',803301789,34,NULL,NULL),
('p25',986761587,13,NULL,NULL),
('p26',584775105,20,NULL,NULL),
('p27',NULL,NULL,NULL,NULL),
('p28',NULL,NULL,NULL,NULL),
('p29',NULL,NULL,NULL,NULL),
('p3',750247616,11,'American','n330ss'),
('p30',NULL,NULL,NULL,NULL),
('p31',NULL,NULL,NULL,NULL),
('p32',NULL,NULL,NULL,NULL),
('p33',NULL,NULL,NULL,NULL),
('p34',NULL,NULL,NULL,NULL),
('p35',NULL,NULL,NULL,NULL),
('p36',NULL,NULL,NULL,NULL),
('p37',NULL,NULL,NULL,NULL),
('p38',NULL,NULL,NULL,NULL),
('p39',NULL,NULL,NULL,NULL),
('p4',776218098,24,'American','n330ss'),
('p40',NULL,NULL,NULL,NULL),
('p41',NULL,NULL,NULL,NULL),
('p42',NULL,NULL,NULL,NULL),
('p43',NULL,NULL,NULL,NULL),
('p44',NULL,NULL,NULL,NULL),
('p45',NULL,NULL,NULL,NULL),
('p5',933932165,27,'American','n330ss'),
('p6',707844555,38,'United','n517ly'),
('p7',450255617,13,'United','n517ly'),
('p8',701382179,12,'United','n620la'),
('p9',936446941,13,'United','n620la');

INSERT INTO license VALUES
('p1', 'jet'),
('p10', 'jet'),
('p11', 'jet'),
('p11', 'prop'),
('p12', 'prop'),
('p13', 'jet'),
('p14', 'jet'),
('p15', 'jet'),
('p15', 'prop'),
('p15', 'testing'),
('p16', 'jet'),
('p17', 'jet'),
('p17', 'prop'),
('p18', 'jet'),
('p19', 'jet'),
('p2', 'jet'),
('p2', 'prop'),
('p20', 'jet'),
('p21', 'jet'),
('p21', 'prop'),
('p22', 'jet'),
('p23', 'jet'),
('p24', 'jet'),
('p24', 'prop'),
('p24', 'testing'),
('p25', 'jet'),
('p26', 'jet'),
('p3', 'jet'),
('p4', 'jet'),
('p4', 'prop'),
('p5', 'jet'),
('p6', 'jet'),
('p6', 'prop'),
('p7', 'jet'),
('p8', 'prop'),
('p9', 'jet'),
('p9', 'prop'),
('p9', 'testing');




INSERT INTO passenger VALUES
('p1',NULL),
('p10',NULL),
('p11',NULL),
('p12',NULL),
('p13',NULL),
('p14',NULL),
('p15',NULL),
('p16',NULL),
('p17',NULL),
('p18',NULL),
('p19',NULL),
('p2',NULL),
('p20',NULL),
('p21',771),
('p22',374),
('p23',414),
('p24',292),
('p25',390),
('p26',302),
('p27',470),
('p28',208),
('p29',292),
('p3',NULL),
('p30',686),
('p31',547),
('p32',257),
('p33',564),
('p34',211),
('p35',233),
('p36',293),
('p37',552),
('p38',812),
('p39',541),
('p4',NULL),
('p40',441),
('p41',875),
('p42',691),
('p43',572),
('p44',572),
('p45',663),
('p5',NULL),
('p6',NULL),
('p7',NULL),
('p8',NULL),
('p9',NULL);

INSERT INTO tickets VALUES
('tkt_dl_1',450,'DL_1174','p24','JFK'),
('tkt_dl_2',225,'DL_1174','p25','JFK'),
('tkt_am_3',250,'AM_1523','p26','LAX'),
('tkt_un_4',175,'UN_1899','p27','DCA'),
('tkt_un_5',225,'UN_523','p28','ATL'),
('tkt_un_6',100,'UN_523','p29','ORD'),
('tkt_sw_7',400,'SW_1776','p30','ORD'),
('tkt_sw_8',175,'SW_1776','p31','ORD'),
('tkt_sw_9',125,'SW_610','p32','HOU'),
('tkt_sw_10',425,'SW_610','p33','HOU'),
('tkt_dl_11',500,'DL_1243','p34','LAX'),
('tkt_dl_12',250,'DL_1243','p35','LAX'),
('tkt_sp_13',225,'SP_1880','p36','ATL'),
('tkt_sp_14',150,'SP_1880','p37','DCA'),
('tkt_un_15',150,'UN_523','p38','ORD'),
('tkt_sp_16',475,'SP_1880','p39','ATL'),
('tkt_am_17',375,'AM_1523','p40','ORD'),
('tkt_am_18',275,'AM_1523','p41','LAX');

INSERT INTO ticket_seat VALUES
('tkt_dl_1','1C'),
('tkt_dl_1','2F'),
('tkt_dl_2','2D'),
('tkt_am_3','3B'),
('tkt_un_4','ch'),
('tkt_un_5','1A'),
('tkt_un_6','3B'),
('tkt_sw_7','3C'),
('tkt_sw_8','3E'),
('tkt_sw_9','1C'),
('tkt_sw_10','1D'),
('tkt_dl_11','1E'),
('tkt_dl_11','1B'),
('tkt_dl_11','2F'),
('tkt_dl_12','2A'),
('tkt_sp_13','1A'),
('tkt_sp_14','2B'),
('tkt_un_15','1B'),
('tkt_sp_16','2C'),
('tkt_am_17','2B'),
('tkt_am_18','2A');

