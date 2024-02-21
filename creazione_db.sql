--Creazione tabelle
--Per evitare errori inserire i comandi che si trovano tra le righe di commento

--Creazione tabella Giocatore
CREATE TABLE progetto.Giocatore(
    CodFisc char(16) PRIMARY KEY,
    Nome varchar NOT NULL,
    Cognome varchar NOT NULL,
    DataNascita Date NOT NULL,
    Piede char(2) NOT NULL,
    DataRitiro Date NULL
);

--Creazione tabella Campionato
CREATE TABLE progetto.Campionato(
    IdCampionato SERIAL,
    Nome varchar,
    Anno varchar,
    PRIMARY KEY (IdCampionato)
);

--Creazione tabella Caratteristica
CREATE TABLE progetto.Caratteristica(
    TipoCaratteristica varchar PRIMARY KEY
);
----------------------------------------
--Creazione tabella Squadra
CREATE TABLE progetto.Squadra(
    Nome varchar NOT NULL,
    Nazionalita varchar NOT NULL,
    IdCampionato integer NOT NULL,

    PRIMARY KEY (Nome, Nazionalita),
    UNIQUE(Nome, IdCampionato),
    FOREIGN KEY (IdCampionato) REFERENCES progetto.Campionato(IdCampionato)
);
---------------------------------------------
--Creazione tabella TrofeoDiSquadra
CREATE TABLE progetto.TrofeoDiSquadra(
    Nome varchar NOT NULL,
    Anno varchar NOT NULL,
    Merito varchar NOT NULL,
    NomeSquadra varchar NOT NULL,
    NazionalitaSquadra varchar NOT NULL,
    PRIMARY KEY(Nome, Anno),
    FOREIGN KEY (NomeSquadra, NazionalitaSquadra) REFERENCES progetto.Squadra(Nome, Nazionalita)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
   UNIQUE(Nome, Anno)
);

--Creazione tabella TrofeoIndividuale
CREATE TABLE progetto.TrofeoIndividuale(
    Nome varchar NOT NULL,
    Anno varchar NOT NULL,
    Merito varchar NOT NULL,
    CodF varchar NOT NULL,
	PRIMARY KEY(Nome, Anno),
    FOREIGN KEY (CodF) REFERENCES progetto.Giocatore(CodFisc)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
   UNIQUE(Nome, Anno)
);

--Creazione tabella Milita
CREATE TABLE progetto.Milita(
    CodFisc char(16) NOT NULL,
    NomeSquadra varchar NOT NULL,
    NazionalitaSquadra varchar NOT NULL,
    DataInizio Date NOT NULL,
    DataFine Date NOT NULL,
    Ruolo varchar NOT NULL,
    PartiteGiocate integer NOT NULL,
    GolEffettuati integer NOT NULL,
    GolSubiti integer NULL,
    Ammonizioni integer NOT NULL,
    Espulsioni integer NOT NULL,

    PRIMARY KEY(CodFisc, NomeSquadra, NazionalitaSquadra, DataInizio),
    FOREIGN KEY (CodFisc) REFERENCES progetto.Giocatore(CodFisc),
    FOREIGN KEY (NomeSquadra, NazionalitaSquadra) REFERENCES progetto.Squadra(Nome, Nazionalita)
);

--Creazione tabella Possiede
CREATE TABLE progetto.Possiede(
    CodFisc char(16) NOT NULL,
    Caratteristica varchar NOT NULL,

    PRIMARY KEY(CodFisc, Caratteristica),
    FOREIGN KEY (CodFisc) REFERENCES progetto.Giocatore(CodFisc),
    FOREIGN KEY (Caratteristica) REFERENCES progetto.Caratteristica(TipoCaratteristica)
);
-----------------------------------
--Inserimento vincoli
ALTER TABLE progetto.Milita
ADD CONSTRAINT DataMilitanza
CHECK(DataInizio < DataFine);
--Descrizione: la data inizio della militanza di un giocatore in una squadra non può essere maggiore della data di fine militanza.

ALTER TABLE progetto.Giocatore
ADD CONSTRAINT checkPiede
CHECK(Piede='Dx' OR Piede='Sx' OR Piede='Am');
--Descrizione: un giocatore può essere solo destro(Dx), sinistro(Sx), oppure ambidestro(Am).


ALTER TABLE progetto.Milita
ADD CONSTRAINT checkDati
CHECK(PartiteGiocate >= 0 AND GolEffettuati >= 0 AND Ammonizioni >= 0 AND Espulsioni >= 0);
--Descrizione: le partite giocate, i gol effettuati, le ammonizioni e le espulsioni non possono avere valore minore di 0.

ALTER TABLE progetto.Milita
ADD CONSTRAINT checkRuoli
CHECK(ruolo = 'Portiere' OR ruolo = 'Difensore' OR ruolo = 'Centrocampista' OR ruolo = 'Attaccante');
--Descrizione: i ruoli all’interno della militanza possono essere solo quelli elencanti

ALTER TABLE progetto.Campionato
ADD CONSTRAINT checkanno1
CHECK(anno LIKE '____/__');
--Descrizione: gli anni dei campionati potranno apparire solo nella forma “yyyy/yy”

ALTER TABLE progetto.trofeoindividuale
ADD CONSTRAINT checkanno2
CHECK(anno LIKE '____/__')
--Descrizione: gli anni dei trofei individuali potranno apparire solo nella forma “yyyy/yy”

ALTER TABLE progetto.trofeodisquadra
ADD CONSTRAINT checkanno3
CHECK(anno LIKE '____/__')
--Descrizione: gli anni dei trofei di squadra potranno apparire solo nella forma “yyyy/yy”
-----------------------------------------------------------------------------
--Creazione procedure e funzioni
CREATE PROCEDURE progetto.InserisciGiocatore(IN CodF char(16), IN Nome varchar, IN Cognome varchar, IN Datanascita date, IN Piede char(2))
AS $$
BEGIN
	INSERT INTO progetto.Giocatore (CodFisc, Nome, Cognome, Datanascita, Piede)
	VALUES (CodF, Nome, Cognome, Datanascita, Piede);
END;
$$ LANGUAGE plpgsql;
--Descrizione: procedura per l’inserimento di un giocatore.

CREATE OR REPLACE FUNCTION progetto.getGiocatore(CodF IN char(16))
	RETURNS SETOF progetto.Giocatore
	LANGUAGE plpgsql
	AS 
$$
BEGIN
RETURN QUERY(SELECT * FROM progetto.Giocatore t where t.CodFisc = CodF);
END;
$$;
--Descrizione: funzione che dato in input un codice fiscale restituisce la riga del giocatore corrispondente.

--Le seguenti funzioni riguardo ai ruoli sono state implementate per questioni legate all’applicativo, per organizzare una buona visualizzazione dei dati.
CREATE OR REPLACE FUNCTION progetto.getRuoli(CodF varchar)
RETURNS TABLE
	(Ruolo varchar,
	 Ricorrenze bigint)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT t.Ruolo, Count(*)
	FROM progetto.Milita t
	WHERE CodFisc = CodF
	GROUP BY t.Ruolo;
END; $$;
--Descrizione: funzione che dato in input un codice fiscale, restituisce una lista contenente tutti i ruoli in cui il giocatore corrispondente al codice fiscale ha giocato.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION progetto.getMFRuolo(CodF varchar)
RETURNS TABLE(
		Ruolo varchar)
LANGUAGE plpgsql	
AS $$
BEGIN
	RETURN QUERY
	SELECT t.Ruolo
	FROM progetto.getRuoli(CodF) t
	WHERE ricorrenze = (SELECT MAX(Ricorrenze)
					FROM progetto.getRuoli(CodF));
END; $$;
--Descrizione: funzione che dato in input un codice fiscale restituisce i ruoli con il maggior numero di ricorrenze all’interno della carriera del giocatore.
------------------------------------------------------------
CREATE OR REPLACE FUNCTION progetto.getSingleMFRuolo(CodF char(16))
RETURNS varchar
LANGUAGE plpgsql
AS $$
	DECLARE
	ruolo_giocatore varchar;
BEGIN
	SELECT t.Ruolo INTO ruolo_giocatore
	FROM progetto.getmfruolo(CodF) t
	LIMIT 1;
	
	RETURN ruolo_giocatore;
END; $$;
--Descrizione: funzione che dato un codice fiscale restituisce uno dei ruoli con il maggior numero di ricorrenze del giocatore
--------------------------------------------
CREATE OR REPLACE FUNCTION progetto.getMilitanza(CodF char(16))
RETURNS SETOF progetto.Milita
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT *
	FROM progetto.Milita t
	WHERE t.CodFisc = CodF AND t.Nomesquadra = Nomesquadra;
END; $$;
--Descrizione: funzione che restituisce tutte le militanze di un giocatore

CREATE OR REPLACE FUNCTION progetto.getSquadra(Nome varchar(16), Nazionalita varchar)
RETURNS SETOF progetto.Squadra
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT *
	FROM progetto.Squadra t
	WHERE t.Nome = Nome;
END; $$;
--Descrizione: funzione che restituisce i dati di una determinata squadra
	
CREATE OR REPLACE FUNCTION progetto.getTrofeiSquadra(Nomef varchar, Nazionalitaf varchar)
RETURNS SETOF progetto.TrofeodiSquadra
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT *
	FROM progetto.TrofeodiSquadra t
	WHERE t.Nomesquadra = Nomef AND t.Nazionalitasquadra = Nazionalitaf;
END; $$;
--Descrizione: funzione che restituisce i dati dei trofei di una determinata squadra

CREATE OR REPLACE FUNCTION progetto.getCaratteristiche (CodF char(16))
RETURNS TABLE(Caratteristica varchar)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT p.caratteristica
    FROM progetto.possiede p
    WHERE p.CodFisc = CodF;
END; $$;
--Descrizione: funzione che restituisce tutte le caratteristiche tipiche di un giocatore

CREATE OR REPLACE FUNCTION progetto.getRuoloUtente()
RETURNS varchar AS $$
DECLARE
	str_out varchar;
BEGIN
	SELECT * INTO str_out from current_user;
    IF(str_out='admin_db') THEN
        RETURN 'amministratore';
    ELSE
        RETURN 'utente';
END; $$ LANGUAGE plpgsql;
--Descrizione: funzione che restituisce il ruolo dell’utente che ha effettuato l’accesso

CREATE OR REPLACE FUNCTION progetto.carrieraGiocatore(codicefiscale char(16))
RETURNS TABLE(
			  CodFisc char(16),
			  Nome varchar,
			  Cognome varchar,
			  Datanascita date,
			 Eta integer,
			  Piede char(2),
    		  SquadraAttuale varchar,
			  RuoloPrincipale varchar,
			  Caratteristiche varchar,
			  Partitegiocate integer,
			  Goleffettuati integer,
			  Golsubiti integer,
			  Ammonizioni integer,
			  Espulsioni integer)
AS $$
DECLARE
	nome varchar; cognome varchar; squadra varchar; ruolo varchar; caratteristiche varchar; carat varchar;
	datan date; datar date;
	piede char(2);
	partite integer; goleff integer; golsub integer; amm integer; esp integer; eta integer;
	cursor_caratteristiche REFCURSOR;
BEGIN
	EXECUTE 'CREATE TABLE progetto.Tmp(
			  CodFisc char(16),
			  Nome varchar,
			  Cognome varchar,
			  Datanascita date,
			  Eta integer,
			  Piede char(2),
    		  SquadraAttuale varchar,
			  RuoloPrincipale varchar,
			  Caratteristiche varchar,
			  Partitegiocate integer,
			  Goleffettuati integer,
			  Golsubiti integer,
			  Ammonizioni integer,
			  Espulsioni integer)';
	
	IF NOT EXISTS(SELECT g.CodFisc FROM progetto.Giocatore g WHERE g.CodFisc = codicefiscale) THEN
		RAISE NOTICE 'Codice fiscale non collegato a nessun giocatore';
	END IF;
	
	caratteristiche = '';
	OPEN cursor_caratteristiche FOR SELECT caratteristica FROM progetto.getcaratteristiche(codicefiscale);
	LOOP
		FETCH cursor_caratteristiche INTO carat;
		EXIT WHEN NOT FOUND;
		caratteristiche = caratteristiche||', '||carat;
	END LOOP;
	CLOSE cursor_caratteristiche;
	caratteristiche = SUBSTRING(caratteristiche from 2 for LENGTH(caratteristiche));
	SELECT g.nome, g.cognome, g.piede, g.datanascita, g.dataritiro
	INTO nome, cognome, piede, datan, datar
	FROM progetto.Giocatore g 
	WHERE g.CodFisc = codicefiscale;
	
	SELECT EXTRACT('YEAR' FROM AGE(CURRENT_DATE, datan)) INTO eta;
	
	IF(datar IS NULL) THEN
		SELECT m.Nomesquadra 
		INTO squadra 
		FROM progetto.Giocatore g, progetto.Milita m 
		WHERE g.CodFisc = codicefiscale AND g.CodFisc = m.CodFisc AND m.Datainizio = (SELECT Max(m.Datainizio) 
				   FROM progetto.Giocatore g, progetto.Milita m
		   		   WHERE g.CodFisc = codicefiscale AND g.CodFisc = m.CodFisc);
	ELSE
		squadra = 'Ritirato';
	END IF;
																				  
	SELECT t.ruolo 
	INTO ruolo 
	FROM progetto.getmfruolo(codicefiscale) t;
	
	IF EXISTS(SELECT * FROM progetto.getruoli(codicefiscale) t WHERE t.ruolo = 'Portiere') THEN
		SELECT SUM(m.partitegiocate), SUM(m.goleffettuati), SUM(m.golsubiti), SUM(m.ammonizioni), SUM(m.espulsioni) 
		INTO partite, goleff, golsub, amm, esp
		FROM progetto.Giocatore g, progetto.Milita m 
		WHERE g.CodFisc = codicefiscale AND g.CodFisc = m.CodFisc;
		INSERT INTO progetto.Tmp VALUES(codicefiscale, nome, cognome, datan, eta, piede, squadra, ruolo, caratteristiche, partite, goleff, golsub, amm, esp);
	RETURN QUERY SELECT * FROM progetto.Tmp; DROP TABLE progetto.Tmp; RETURN;
	END IF;

	SELECT SUM(m.partitegiocate), SUM(m.goleffettuati), SUM(m.ammonizioni), SUM(m.espulsioni) 
	INTO partite, goleff, amm, esp
	FROM progetto.Giocatore g, progetto.Milita m 
	WHERE g.CodFisc = codicefiscale AND g.CodFisc = m.CodFisc;
	
	INSERT INTO progetto.Tmp VALUES(codicefiscale, nome, cognome, datan, eta, piede, squadra, ruolo, caratteristiche, partite, goleff, golsub, amm, esp);
	RETURN QUERY SELECT * FROM progetto.Tmp; DROP TABLE progetto.Tmp; RETURN;
END;  $$ LANGUAGE plpgsql;				
--Descrizione: funzione che dato in input il codice fiscale restituisce una tabella contenente un resoconto dei dati della carriera del giocatore
----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION progetto.carrieragiocatoriall()
RETURNS TABLE(CodiceFiscale char(16),
			  Nome varchar,
			  Cognome varchar,
			  Datanascita date,
			  Eta integer,
			  Piede char(2),
    		  SquadraAttuale varchar,
			  RuoloPrincipale varchar,
			  Caratteristiche varchar,
			  Partitegiocate integer,
			  Goleffettuati integer,
			  Golsubiti integer,
			  Ammonizioni integer,
			  Espulsioni integer)
AS $$
DECLARE
	cursor_codf REFCURSOR;
	codf char(16); nomef varchar; cognomef varchar; datanf date; piedef char(2); squadraf varchar; caratteristiche varchar;
	ruolof varchar; partitef integer; goleff integer; golsubf integer; ammf integer; espf integer; eta integer;
BEGIN
	EXECUTE 'CREATE TABLE progetto.Tmpfunc(CodFisc char(16),
			  Nome varchar,
			  Cognome varchar,
			  Datanascita date,
			  Eta integer,
			  Piede char(2),
    		  SquadraAttuale varchar,
			  RuoloPrincipale varchar,
			  Caratteristiche varchar,
			  Partitegiocate integer,
			  Goleffettuati integer,
			  Golsubiti integer,
			  Ammonizioni integer,
			  Espulsioni integer)';

	OPEN cursor_codf FOR SELECT CodFisc FROM progetto.Giocatore;
	LOOP
        FETCH cursor_codf INTO codf;
        EXIT WHEN NOT FOUND;
		SELECT * INTO codf, nomef, cognomef, datanf, eta, piedef, squadraf, ruolof, caratteristiche, partitef, goleff, golsubf, ammf, espf FROM progetto.carrieragiocatore(codf);
		INSERT INTO progetto.Tmpfunc VALUES(codf, nomef, cognomef, datanf, eta, piedef, squadraf, ruolof, caratteristiche, partitef, goleff, golsubf, ammf, espf);
	END LOOP;
	CLOSE cursor_codf;
	RETURN QUERY SELECT * FROM progetto.Tmpfunc; DROP TABLE progetto.Tmpfunc; RETURN;
END; $$ LANGUAGE plpgsql;
--Descrizione: funzione che restituisce un resoconto di tutte le militanze di tutti i giocatori


CREATE OR REPLACE FUNCTION progetto.ricerca(nomeg varchar, ruolo varchar, piedeg char(2), golsegnati integer,  
											segnogolsegnati varchar, ordinegolsegnati varchar, golsubitig integer, 
											segnogolsubiti varchar, ordinegolsubiti varchar, etag integer, segnoeta varchar, ordineeta varchar,
											squadra varchar)
RETURNS TABLE (Codicefiscale char(16),
			  Nome varchar,
			  Cognome varchar,
			  Datanascita date,
			  Eta integer,
			  Piede char(2),
    		  SquadraAttuale varchar,
			  RuoloPrincipale varchar,
			  Caratteristiche varchar,
			  Partitegiocate integer,
			  Goleffettuati integer,
			  Golsubiti integer,
			  Ammonizioni integer,
			  Espulsioni integer)
AS $$
DECLARE
	condizione varchar;
	andv varchar;
	return_query varchar;
BEGIN
	condizione = 'WHERE ';
	andv = '';
	return_query = 'SELECT * FROM progetto.carrieragiocatoriall() ';
	
	IF(nomeg <> ' ') THEN
		condizione = condizione || 'nome = '||quote_literal(nomeg);
		andv = ' AND ';
	END IF;
	
	IF(ruolo <> ' ') THEN
		condizione = condizione||andv||'RuoloPrincipale = '||quote_literal(ruolo);
		andv = ' AND ';
	END IF;
	
	IF(piedeg <> ' ') THEN
		condizione = condizione||andv||'piede = '||quote_literal(piedeg);
		andv = ' AND ';
	END IF;
	
	IF(golsegnati <> -1) THEN
		IF(segnogolsegnati <> ' ') THEN
			condizione = condizione||andv||'goleffettuati '||segnogolsegnati||' '||golsegnati;
		ELSE
			condizione = condizione||andv||'goleffettuati '||'= '||golsegnati;
		END IF;
		andv = ' AND ';
	END IF;
	
	IF(golsubitig <> -1) THEN
		IF(segnogolsubiti <> ' ') THEN
			condizione = condizione||andv||'golsubiti IS NOT NULL AND golsubiti '||segnogolsubiti||' '||golsubitig;
		ELSE
			condizione = condizione||andv||'golsubiti IS NOT NULL AND golsubiti '||'= '||golsubitig;
		END IF;
		andv = ' AND ';
	END IF;
	
	IF(etag <> -1) THEN
		IF(segnoeta <> ' ') THEN
			condizione = condizione||andv||'eta '||segnoeta||etag;
		ELSE
			condizione = condizione||andv||'eta '||'= '||etag;
		END IF;
		andv = ' AND ';
	END IF;
	
	IF(squadra <> ' ') THEN
		condizione = condizione||andv||'squadraattuale = '||quote_literal(squadra);
		andv = ' AND ';
	END IF;
	
	IF(condizione = 'WHERE ') THEN
		condizione = '';
	END IF;
	condizione = condizione||' ORDER BY ';
	
	andv = '';
	IF(ordinegolsubiti <> ' ') THEN
		condizione = condizione||'Golsubiti '||ordinegolsubiti;
		andv=', ';
	END IF;
	
	IF(ordinegolsegnati <> ' ') THEN
		condizione = condizione||andv||'Goleffettuati '||ordinegolsegnati;
		andv=', ';
	END IF;
	
	IF(ordineeta <> ' ') THEN
		condizione = condizione||andv||'Eta '||ordineeta;
		andv=', ';
	END IF;

	IF(ordinegolsubiti = ' ' AND ordinegolsegnati = ' ' AND ordineeta = ' ') THEN
		condizione = SUBSTRING(condizione, 1, position(' ORDER BY ' IN condizione));
	END IF;
	
	return_query = return_query || condizione;
	RETURN QUERY EXECUTE return_query;
END; $$ LANGUAGE plpgsql;
--Descrizione: funzione che restituisce la tabella di resoconto del giocatore filtrata in base alla scelta dei parametri

CREATE OR REPLACE PROCEDURE progetto.createUser(nome VARCHAR, pass VARCHAR(20))
AS $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_user WHERE usename = nome) THEN
        EXECUTE 'CREATE USER ' || quote_ident(nome) || ' WITH PASSWORD '||quote_literal(pass);
        EXECUTE 'GRANT utente TO ' || quote_ident(nome);
    ELSE
        RAISE NOTICE 'Utente % già esistente', nome;
    END IF;
END;
$$ LANGUAGE plpgsql;	
	
--Descrizione: procedura che dato in input un nome, ed una password, permette di creare un nuovo utente che come permesso avrà solo quello di interrogare la base di dati.
-------------------------------------------------
--Creazione trigger
CREATE OR REPLACE FUNCTION progetto.updateGolSubiti()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Ruolo = 'Portiere' AND NEW.Ruolo <> OLD.Ruolo THEN
        NEW.Golsubiti := 0;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Descrizione: funzione trigger che si occupa di modificare l’attributo Golsubiti della --tabella Militanza nel momento in cui il ruolo del giocatore viene modificato in --‘Portiere’;

CREATE OR REPLACE FUNCTION progetto.inserisciDateOverleap() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM progetto.Milita t
        WHERE NEW.CodFisc = t.CodFisc AND NEW.Nomesquadra = t.Nomesquadra AND (NEW.datainizio BETWEEN t.datainizio AND t.datafine 
        OR NEW.datafine BETWEEN t.datainizio AND t.datafine)
    )
    THEN
        -- Le nuove date sono comprese tra date già presenti
        RAISE EXCEPTION 'Errore: le date di inizio o fine sono comprese tra date già presenti in tabella';
    END IF;

    RETURN NEW;  -- Restituisci la riga inserita
END;
$$ LANGUAGE plpgsql;
--Descrizione: funzione trigger che si occupa del controllo delle date all’interno --della tabella militanza, se uno stesso giocatore ha date di militanza che si --sovrappongono tra di loro viene sollevato un errore che impedisce l’inserimento --della tupla.

CREATE FUNCTION progetto.inseriscimilitanza() RETURNS TRIGGER AS $$
BEGIN
	IF(NEW.ruolo = 'Portiere') THEN
		IF(NEW.golsubiti IS NULL) THEN
			NEW.golsubiti = 0;
		END IF;
	END IF;
	
	RETURN NEW;
END; $$ LANGUAGE plpgsql;
--Descrizione: funzione trigger che si occupa del controllo dei gol subiti all’interno di una nuova tupla inserita dentro la tabella milita

CREATE OR REPLACE FUNCTION progetto.datamilitanza() RETURNS TRIGGER AS $$
BEGIN
	IF(NEW.datainizio < (SELECT t.datanascita FROM progetto.giocatore t WHERE NEW.codfisc = t.codfisc)) THEN
		RAISE EXCEPTION 'La data di inizio militanza non può essere minore della data di nascita del giocatore'; 
	END IF;
	
	RETURN NEW;
END; $$ LANGUAGE plpgsql;

--Descrizione: funzione trigger che controlla se la data di inizio militanza sia minore della data di nascita del giocatore

CREATE OR REPLACE FUNCTION progetto.datatrofeo() RETURNS TRIGGER AS $$
DECLARE
    datan date;
    annoint int;
    annotrofeoint int;
BEGIN
    SELECT datanascita INTO datan FROM progetto.giocatore WHERE codfisc = NEW.codf;

    annoint := EXTRACT(YEAR FROM datan);
    annotrofeoint := CAST(SUBSTR(NEW.anno, 1, 4) AS INTEGER);

    IF annoint > annotrofeoint THEN
        RAISE EXCEPTION 'La data di assegnazione del trofeo non può essere minore della data di nascita del giocatore'; 
    END IF;
    
    RETURN NEW;
END; 
$$ LANGUAGE plpgsql;
--Descrizione: funzione trigger che controlla se la data del trofeo individuale sia minore della data di nascita del giocatore

CREATE OR REPLACE FUNCTION progetto.squadramilitanza() RETURNS TRIGGER AS $$
BEGIN
	IF((SELECT t.dataritiro FROM progetto.Giocatore t WHERE t.codfisc = NEW.codfisc) IS NOT NULL) THEN
		RAISE EXCEPTION 'Il giocatore si è ritirato'; 
	END IF;
	
	RETURN NEW;
END; $$ LANGUAGE plpgsql;

--Descrizione: funzione trigger che controlla se la militanza che si vuole inserire abbia collegata ad essa un giocatore ritirato.
------------------------------------------------------
--Creazione trigger associato alla funzione
CREATE TRIGGER ritiratomilita
BEFORE INSERT ON progetto.milita
FOR EACH ROW
EXECUTE FUNCTION progetto.squadramilitanza()
--Creazione trigger associato alla funzione
CREATE TRIGGER datatrofeo
BEFORE INSERT ON progetto.trofeoindividuale
FOR EACH ROW
EXECUTE FUNCTION progetto.datatrofeo()
--Creazione trigger associato alla funzione
CREATE TRIGGER datamilitanza
BEFORE INSERT ON progetto.Milita
FOR EACH ROW
EXECUTE FUNCTION progetto.datamilitanza()
--Creazione del trigger associato
CREATE TRIGGER inserimentoMilitanza
BEFORE INSERT ON progetto.Milita
FOR EACH ROW
EXECUTE FUNCTION progetto.inseriscimilitanza();
-- Creazione del trigger associato alla funzione
CREATE TRIGGER triggerDateOverleap
BEFORE INSERT ON progetto.Milita
FOR EACH ROW
EXECUTE FUNCTION progetto.inserisciDateOverleap();

CREATE TRIGGER triggerUpdateGolSubiti
BEFORE UPDATE ON progetto.Milita
FOR EACH ROW
EXECUTE FUNCTION progetto.updateGolSubiti();
------------------------------
--Creazione ruoli e utenti
CREATE ROLE amministratore WITH SUPERUSER;
CREATE USER admin_db WITH PASSWORD 'admin';
--Descrizione: creazione dello user ‘admin_db’ ed assegnamento dei privilegi a ques’ultimo, l’amministratore avrà pieni privilegi su tutto il db.

CREATE ROLE ist_registrazione WITH LOGIN SUPERUSER PASSWORD 'registrazione';
--Descrizione: creazione dello user ‘ist_registrazione’ ed assegnamento dei privilegi a ques’ultimo, questo sarà un ruolo ausiliare utilizzato per la registrazione di nuovi utenti

CREATE ROLE utente;
GRANT pg_read_all_data TO utente;
GRANT USAGE, CREATE ON SCHEMA progetto TO utente;
--Descrizione: creazione dello ruolo utente ed assegnazione dei privilegi a ques’ultimo, tutti gli user che avranno questo ruolo potranno eseguire esclusivamente le interrogazioni

CREATE USER asd WITH PASSWORD 'asd';
GRANT ruolo_select to asd;
--Descrizione: creazione del primo utente del db
