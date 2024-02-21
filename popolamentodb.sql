--INSERIMENTO GIOCATORI
INSERT INTO progetto.Giocatore VALUES
('1234567891234567', 'Giacomo', 'Lombardi', '01/09/1995', 'Dx', NULL),
('ABCDEFGHILMNOPQR', 'Fabio', 'Lucci', '08/11/1997', 'Sx', NULL),
('ABC34FGHIL51OPQR', 'Roberto', 'Capasso', '21/02/1994', 'Dx', NULL),
('9BC34FG12L51OP0I', 'Francesco', 'Di Matteo', '12/10/1996', 'Am', NULL),
('9GMJLRAMT3U2LV63', 'Alessandro', 'Pasquini', '17/11/1996', 'Sx', NULL),
('Z3H0Z18D6JSE9HB5', 'Massimiliano', 'Richardi', '19/01/1994', 'Dx', NULL),
('JALKI6ANPIZ0YBI1', 'Rafaello', 'Butto', '04/06/2000', 'Dx', NULL),
('JS85KFQEOYYLAICT', 'Gian', 'Moffa', '11/12/1970', 'Dx', '10/03/2011'),
('ZPPYMR26L01D267Q', 'Ymer', 'Zapparoli', '01/07/1998', 'Sx', NULL);

--INSERIMENTO CAMPIONATI
INSERT INTO progetto.Campionato VALUES
(0, 'Serie A', '2022/23'),
(1, 'Serie A', '2023/24'),
(2, 'Serie A', '1998/99'),
(3, 'Premier League', '2023/24');

--INSERIMENTO CARATTERISTICHE
INSERT INTO progetto.Caratteristica VALUES
('Forza esplosiva'),
('Accelerazione'),
('Cambio di direzione'),
('Elevazione'),
('Agilità');

--INSERIMENTO SQUADRE
INSERT INTO progetto.Squadra VALUES
('Napoli','Italiana', 1),
('Chelsea','Inglese', 3),
('Torino','Italiana', 1),
('Juventus','Italiana', 1),
('Roma','Italiana', 1);

--INSERIMENTO TROFEI DI SQUADRA
INSERT INTO progetto.TrofeoDiSquadra VALUES
('Champions League', '2022/23', 'Squadra vincitrice della Champions League', 'Napoli', 'Italiana'),
('Coppa Italia', '2023/24', 'Squadra vincitrice della Coppa Italia', 'Torino', 'Italiana');

--INSERIMENTO TROFEI INDIVIDUALE
INSERT INTO progetto.TrofeoIndividuale VALUES
('Pallone d oro', '2022/23', 'Miglior giocatore della Champions League', '9BC34FG12L51OP0I');

--INSERIMENTO MILITANZE
INSERT INTO progetto.Milita VALUES
('9BC34FG12L51OP0I', 'Napoli', 'Italiana', '01/01/2020', '01/01/2024', 'Attaccante', 0, 0, NULL, 0, 0),
('1234567891234567', 'Juventus', 'Italiana', '01/01/2021', '01/01/2022', 'Portiere', 0, 0, 0, 0, 0),
('Z3H0Z18D6JSE9HB5', 'Torino', 'Italiana','01/01/2021', '01/01/2023', 'Centrocampista', 0, 0, NULL, 0, 0),
('ZPPYMR26L01D267Q', 'Chelsea', 'Inglese', '01/06/2020', '01/01/2022', 'Difensore', 0, 0, NULL, 0, 0),
('JS85KFQEOYYLAICT', 'Roma', 'Italiana', '01/01/1990', '01/01/1993', 'Portiere', 0, 0, 0, 0, 0),
('JS85KFQEOYYLAICT', 'Juventus', 'Italiana', '01/01/1994', '01/01/1996', 'Difensore', 0, 0, NULL, 0, 0);

--INSERIMENTO POSSIEDE
INSERT INTO progetto.Possiede VALUES
('9BC34FG12L51OP0I', 'Forza esplosiva'),
('9BC34FG12L51OP0I', 'Elevazione'),
('9BC34FG12L51OP0I', 'Agilità'),
('Z3H0Z18D6JSE9HB5', 'Accelerazione'),
('JS85KFQEOYYLAICT', 'Elevazione'),
('JS85KFQEOYYLAICT', 'Agilità'),
('ABCDEFGHILMNOPQR', 'Elevazione'),
('ZPPYMR26L01D267Q', 'Forza esplosiva');




