SET search_path TO 'social_market';


    -- clienti
    INSERT INTO clienti VALUES
	(1, 'Adamo', 'Villarosa', '1973-08-17', 'Servizi sociali', '2022-02-13', '2022-08-13', 52, 33, 'BJUVGI24Y99N908L', 0, 1),
	(2, 'Cipriano', 'Cusano', '1994-07-20', "centro d'ascolto", '2022-05-06', '2022-11-06', 30, 35, 'QPFTST77K70H740X', 8, 1),
	(3, 'Simone', 'Molesini', '1974-02-08', 'Servizi sociali', '2022-06-15', '2022-12-15', 47, 53, 'MSDKTW15E01I749A', 6, 1)


    -- familiari
    INSERT INTO familiari VALUES
	('VFIXEH30N96L121A', 'Fortunata', 'Pisaroni', '1983-03-15', 'nemo', 2),
	('CQVRSM90N48G402E', 'Ricciotti', 'Inzaghi', '1976-02-29', 'ea', 2),
	('YDTNNL11X31T534B', 'Massimiliano', 'Faugno', '1971-04-20', 'ipsa', 2),
	('VGKVZQ87L15L653A', 'Pasquale', 'Speri', '1967-03-20', 'fuga', 2),
	('QJYXVZ54W19W017K', 'Ermes', 'Zetticci', '1972-11-03', 'maiores', 2),
	('OJVCCQ08B99B085S', 'Marissa', 'Grasso', '1972-02-15', 'voluptatibus', 2),
	('LVLWIF87O95G303Z', 'Girolamo', 'Dallara', '1982-04-10', 'facere', 2),
	('QJXPZM32K64I626E', 'Luisa', 'Iacovelli', '2013-09-25', 'nobis', 2),
	('AQHFTO23P19M414V', 'Pierina', 'Bonino', '2021-04-01', 'iusto', 3),
	('KSMNXO49F01Y355K', 'Elena', 'Nitti', '1975-07-06', 'eos', 3),
	('LJAHXR52G55Z263H', 'Dionigi', 'Niggli', '1980-11-03', 'doloribus', 3),
	('RQQCSW86Q54O438D', 'Benito', 'Ciani', '1971-11-22', 'consequuntur', 3),
	('EXHMJZ24B70X670G', 'Renata', 'Gremese', '2005-02-23', 'rem', 3),
	('SXQVIQ90Q82B903J', 'Laureano', 'Puccini', '2013-12-19', 'libero', 3)


    -- telefoni
    INSERT INTO telefoni VALUES
	('+390221323952', 1),
	('+396433637831', 2),
	('+397307115804', 3),
	('+397543987948', 3),
	('+398974976796', 1),
	('+399609188355', 1)


    -- email
    INSERT INTO email VALUES
	('facere@gmail.com', 1),
	('assumenda@gmail.com', 2),
	('veniam@gmail.com', 3),
	('facilis@gmail.com', 3),
	('aliquam@gmail.com', 3),
	('quia@gmail.com', 1)


    -- volontari
    INSERT INTO volontari VALUES
	(1, 'Francesco', 'Toso', '2001-06-30', '+398681068987', 'nulla@gmail.com', "giovedi' dalle 9 alle 21"),
	(2, 'Armando', 'Omma', '1955-12-09', '+398299392233', 'temporibus@gmail.com', "giovedi' dalle 15 alle 17"),
	(3, 'Vincenza', 'Lercari', '2015-07-01', '+396219732562', 'perferendis@gmail.com', 'sabato dalle 17 alle 21')

