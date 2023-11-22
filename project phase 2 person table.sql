DROP DATABASE IF EXISTS test_p2;
CREATE DATABASE test_p2;
USE test_p2;

DROP TABLE IF EXISTS person;
CREATE TABLE person (
personID char (20) NOT NULL,
first_name char(20) NOT NULL,
last_name char(20) NOT NULL,
locationID char(10) NOT NULL,
PRIMARY KEY (personID),
CONSTRAINT fk1 FOREIGN KEY (locationID) REFERENCES location (locID)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS pilot;
CREATE TABLE pilot (
personID char (20) NOT NULL,
taxID decimal(9,0) DEFAULT NULL,
experience decimal(2,0) DEFAULT NULL,
flying_airline char(20) DEFAULT NULL,
flying_tail char(20) DEFAULT NULL,
PRIMARY KEY (personID),
CONSTRAINT fk2 FOREIGN KEY (personID) REFERENCES person (personID),
CONSTRAINT fk3 FOREIGN KEY (flying_airline) REFERENCES airline (airlineID),
CONSTRAINT fk4 FOREIGN KEY (flying_tail) REFERENCES airplane (tail_num)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS passenger;
CREATE TABLE passenger (
personID char (20) NOT NULL,
miles decimal(10, 0) DEFAULT NULL,
PRIMARY KEY (personID),
CONSTRAINT fk5 FOREIGN KEY (personID) REFERENCES person (personID)
) ENGINE=InnoDB;

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







