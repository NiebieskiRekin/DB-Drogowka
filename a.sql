CREATE TABLE POJAZDY (
    VIN CHAR(17) PRIMARY KEY,
    NR_REJESTRACYJNY VARCHAR(8) NOT NULL UNIQUE,
    BADANIE_TECHNICZNE DATE NOT NULL CHECK(BADANIE_TECHNICZNE > to_date('1-1-1900', 'DD-MM-YYYY')),
    MARKA VARCHAR(32) NOT NULL,
    MODEL VARCHAR(32) NOT NULL,
    ROK_PRODUKCJI INTEGER NOT NULL CHECK(rok_produkcji > 1900),
    CZY_ZAREKWIROWANY CHAR(1) DEFAULT ('N') NOT NULL CHECK ( CZY_ZAREKWIROWANY IN ( 'N', 'T' ) ),
    CZY_POSZUKIWANE CHAR(1) DEFAULT ('N') NOT NULL CHECK ( CZY_POSZUKIWANE IN ( 'N', 'T' ) ),
    KOLOR VARCHAR(32) NULL
);

CREATE TABLE UBEZPIECZENIA (
    NR_POLISY VARCHAR(10) ,
    DATA_WAZNOSCI DATE NOT NULL CHECK(data_waznosci > to_date('1-1-1900', 'DD-MM-YYYY')),
    TYP CHAR(2) NOT NULL CHECK ( TYP IN ( 'OC', 'AC' ) ),
    FIRMA VARCHAR(32) NULL,
    VIN_POJAZDU CHAR(17) NOT NULL,
    PRIMARY KEY (NR_POLISY),
    FOREIGN KEY (VIN_POJAZDU) REFERENCES POJAZDY (VIN)
);

CREATE TABLE OSOBY(
	PESEL CHAR(11) PRIMARY KEY,
	imie VARCHAR(32) NOT NULL,
	nazwisko Varchar(64) NOT NULL,
	nr_telefonu varchar(16) NULL,
	czy_poszukiwana char(1) DEFAULT ('N') NOT NULL CHECK ( czy_poszukiwana IN ( 'N', 'T' )),
	nr_dowodu_osobistego char(9) NULL,
	data_urodzenia DATE NULL CHECK(data_urodzenia IS NULL
OR data_urodzenia > to_date('1-1-1900', 'DD-MM-YYYY'))
);

CREATE TABLE OSOBY_POJAZDY(
	vin char(17) NOT NULL REFERENCES pojazdy(vin),
	pesel char(11) NOT NULL REFERENCES osoby(pesel),
  PRIMARY KEY(PESEL,
VIN)
);

CREATE TABLE PRAWA_JAZDY(
  id_prawa_jazdy integer PRIMARY KEY,
	kategoria varchar(7) NOT NULL CHECK(kategoria IN (
    'AM',
    'A1',
    'A2',
    'A',
    'B1',
    'B',
    'B+E',
    'C',
    'C1',
    'C1+E',
    'C+E',
    'D',
    'D1',
    'D1+E',
    'D+E',
    'T',
    'Tramwaj'
    )
  ),
	od_kiedy DATE NOT NULL CHECK(od_kiedy > to_date('1-1-1900', 'DD-MM-YYYY')),
	do_kiedy DATE NOT NULL CHECK(do_kiedy > to_date('1-1-1900', 'DD-MM-YYYY')),
	PESEL char(11) NOT NULL REFERENCES osoby(pesel),
	UNIQUE(kategoria,
od_kiedy,
pesel)
);

CREATE TABLE FUNKCJONARIUSZE(
	nr_odznaki varchar(16) NOT NULL,
	stopien varchar(32) NOT NULL,
	pesel char(11) REFERENCES osoby(pesel) PRIMARY KEY
);

CREATE TABLE ZDARZENIA(
	id_zdarzenia integer PRIMARY KEY,
	data_zdarzenia DATE NOT NULL CHECK(data_zdarzenia > to_date('1-1-1900', 'DD-MM-YYYY')),
	wysokosc_geograficzna NUMBER(8,
6) NOT NULL,
	szerokosc_geograficzna NUMBER(8,
6) NOT NULL,
	opis varchar(128) NULL,
	UNIQUE(data_zdarzenia,
wysokosc_geograficzna,
szerokosc_geograficzna)
);

CREATE TABLE INTERWENCJE(
	id_interwencji integer PRIMARY KEY,
	data_i_czas_interwencji timestamp NOT NULL CHECK(data_i_czas_interwencji > to_timestamp('1-1-1900', 'DD-MM-YYYY')),
	funkcjonariusz char(11) NOT NULL REFERENCES Funkcjonariusze(pesel),
	zdarzenie integer NOT NULL REFERENCES zdarzenia(id_zdarzenia),
	UNIQUE(funkcjonariusz,
zdarzenie)
);

CREATE TABLE UCZESTNICY_ZDARZENIA(
	id_uczestnika integer PRIMARY KEY,
	rola varchar(32) NOT NULL CHECK(rola IN ('poszkodowany', 'winowajca', 'zgłaszający', 'świadek', 'podejrzany')),
	pesel_uczestnika char(11) NOT NULL REFERENCES osoby(pesel),
	zdarzenie integer NOT NULL REFERENCES zdarzenia(id_zdarzenia),
	UNIQUE(rola,
pesel_uczestnika,
zdarzenie)
);

CREATE TABLE WYKROCZENIA(
  id_wykroczenia integer PRIMARY KEY,
	nazwa varchar(512) NOT NULL UNIQUE,
	punkty_karne integer NOT NULL CHECK(punkty_karne BETWEEN 0 AND 15),
	stawka_minimalna NUMBER NOT NULL CHECK(stawka_minimalna >= 0),
	stawka_maksymalna NUMBER NOT NULL CHECK(stawka_maksymalna <= 6000),
	ustawa varchar(32) NULL
);

CREATE TABLE FORMY_WYMIARU_KARY(
	id_uczestnika integer REFERENCES uczestnicy_zdarzenia(id_uczestnika),
	id_interwencji integer REFERENCES interwencje(id_interwencji),
	typ char(1) NOT NULL CHECK(typ IN ('m', 'a', 'p')),
	PRIMARY KEY(id_uczestnika,
id_interwencji)
);

CREATE TABLE MANDATY(
	nr_serii varchar(16) NOT NULL,
	kwota NUMBER CHECK(kwota BETWEEN 0 AND 6000) NOT NULL,
	punkty_karne integer NOT NULL CHECK(punkty_karne BETWEEN 0 AND 15),
	czy_przyjeto char(1) NOT NULL CHECK(czy_przyjeto IN ('N', 'T')),
	czy_oplacone char(1) NOT NULL CHECK(czy_oplacone IN ('N', 'T')),
	opis varchar(128) NOT NULL,
	wykroczenie integer REFERENCES wykroczenia(id_wykroczenia) NOT NULL,
	id_uczestnika integer,
	id_interwencji integer,
	UNIQUE(nr_serii),
	PRIMARY KEY(id_uczestnika,
id_interwencji),
	FOREIGN KEY(id_uczestnika,
id_interwencji) REFERENCES formy_wymiaru_kary(id_uczestnika,
id_interwencji)
);

CREATE TABLE ARESZTOWANIA(
	id_uczestnika integer,
	id_interwencji integer,
	od_kiedy DATE NOT NULL CHECK( od_kiedy > to_date('1-1-1900', 'DD-MM-YYYY')),
  do_kiedy DATE NULL CHECK(do_kiedy IS NULL
OR do_kiedy > to_date('1-1-1900', 'DD-MM-YYYY')),
  czy_w_zawieszeniu CHAR(1) NOT NULL CHECK ( czy_w_zawieszeniu IN ( 'N', 'T' ) ),
  PRIMARY KEY ( ID_UCZESTNIKA,
ID_INTERWENCJI ),
  FOREIGN KEY(id_uczestnika,
id_interwencji) REFERENCES formy_wymiaru_kary(id_uczestnika,
id_interwencji)
);

CREATE SEQUENCE "SEKWENCJA_ID_WYKROCZENIA" MINVALUE 1 INCREMENT BY 1
START WITH
100;

CREATE SEQUENCE "SEKWENCJA_ID_PRAWA_JAZDY" MINVALUE 1 INCREMENT BY 1
START WITH
1000;

CREATE SEQUENCE "SEKWENCJA_ID_ZDARZENIA" MINVALUE 1 INCREMENT BY 1
START WITH
1000;

CREATE SEQUENCE "SEKWENCJA_ID_INTERWENCJI" MINVALUE 1 INCREMENT BY 1
START WITH
1000;

CREATE SEQUENCE "SEKWENCJA_ID_UCZESTNIKA_ZDARZENIA" MINVALUE 1 INCREMENT BY 1
START WITH
1000;

CREATE OR REPLACE
VIEW perspektywa_pojazdy_danej_osoby AS 
    SELECT
	osoby_pojazdy.vin,
	nr_rejestracyjny,
	badanie_techniczne,
	marka,
	pojazdy.model,
	rok_produkcji,
	czy_zarekwirowany,
	czy_poszukiwane,
	kolor,
	pesel
FROM
	pojazdy
RIGHT JOIN osoby_pojazdy ON
	pojazdy.vin = osoby_pojazdy.vin;

CREATE OR REPLACE
VIEW perspektywa_wyszukiwanie_informacje_ogolne_o_danej_osobie_2pola AS
    SELECT
	pesel,
	imie || ' ' || nazwisko AS "Imie_i_Nazwisko"
FROM
	osoby;

CREATE OR REPLACE
VIEW perspektywa_mandaty_danej_osoby AS
SELECT
	pesel_uczestnika AS pesel,
	nr_serii,
	kwota,
	zdarzenie,
	punkty_karne,
	czy_przyjeto,
	czy_oplacone,
	opis,
	wykroczenie
FROM
	uczestnicy_zdarzenia uz
JOIN mandaty m ON
	uz.id_uczestnika = m.id_uczestnika;

CREATE OR REPLACE
VIEW perspektywa_wlasciciele_pojazdu AS
SELECT
	vin,
	o.pesel AS pesel,
	imie,
	nazwisko,
	nr_telefonu,
	czy_poszukiwana,
	nr_dowodu_osobistego,
	data_urodzenia
FROM
	osoby o
JOIN osoby_pojazdy op ON
	o.pesel = op.pesel;

CREATE OR REPLACE
VIEW perspektywa_aresztowania_danej_osoby AS
SELECT
	pesel_uczestnika AS pesel,
	od_kiedy,
	do_kiedy,
	czy_w_zawieszeniu,
	zdarzenie
FROM
	uczestnicy_zdarzenia uz
JOIN aresztowania ar ON
	uz.id_uczestnika = ar.id_uczestnika;

CREATE OR REPLACE
VIEW PERSPEKTYWA_ZDARZENIA_ILE AS
SELECT
	id_zdarzenia,
	data_zdarzenia,
	wysokosc_geograficzna,
	szerokosc_geograficzna,
	opis,
	(
	SELECT
		count(zdarzenie)
	FROM
		interwencje
	WHERE
		zdarzenie = id_zdarzenia) AS "Liczba_funkcjonariuszy",
	(
	SELECT
		count(zdarzenie)
	FROM
		uczestnicy_zdarzenia
	WHERE
		zdarzenie = id_zdarzenia) AS "Liczba_uczestnikow"
FROM
	zdarzenia;

CREATE OR REPLACE
VIEW PERSPEKTYWA_FUNKCJONARIUSZE AS
SELECT
	f.nr_odznaki,
	f.stopien,
	f.pesel,
	o.imie,
	o.nazwisko,
	o.nr_telefonu,
	o.czy_poszukiwana,
	o.nr_dowodu_osobistego,
	o.data_urodzenia,
	o.PESEL AS "LINK"
FROM
	funkcjonariusze f
LEFT JOIN osoby o ON
	f.pesel = o.pesel;

CREATE TRIGGER wyzwalacz_pojazdy_danej_osoby_update
    instead OF
UPDATE
	ON
	PERSPEKTYWA_POJAZDY_DANEJ_OSOBY
    FOR EACH ROW
BEGIN
		DELETE
FROM
	osoby_pojazdy
WHERE
	vin =:OLD.vin
	AND pesel =:OLD.pesel;

INSERT
	INTO
	osoby_pojazdy(vin,
	pesel)
VALUES (:NEW.vin,
:NEW.pesel);
END;

/

CREATE TRIGGER wyzwalacz_pojazdy_danej_osoby_insert
    instead OF
INSERT
	ON
	PERSPEKTYWA_POJAZDY_DANEJ_OSOBY
    FOR EACH ROW
BEGIN
		INSERT
	INTO
	osoby_pojazdy(vin,
	pesel)
VALUES (:NEW.vin,
:NEW.pesel);
END;

/

CREATE OR REPLACE
TRIGGER wyzwalacz_prawa_jazdy_insert
    BEFORE
INSERT
	ON
	prawa_jazdy 
    FOR EACH ROW
DECLARE
		OD_KIEDY_POZNIEJ_NIZ_DO_KIEDY EXCEPTION;

PRAWO_JAZDY_PRZED_16 EXCEPTION;

data_ur osoby.data_urodzenia%TYPE;
BEGIN
	IF (NOT :NEW.DO_KIEDY IS NULL
		AND :NEW.od_kiedy > :NEW.do_kiedy) THEN
        raise OD_KIEDY_POZNIEJ_NIZ_DO_KIEDY;
END IF;

SELECT
	data_urodzenia
INTO
	data_ur
FROM
	osoby
WHERE
	pesel =:NEW.pesel;

IF (NOT data_ur IS NULL
	AND calculate_age(data_ur,
	:NEW.od_kiedy)<INTERVAL '16' YEAR ) THEN
        raise PRAWO_JAZDY_PRZED_16;
END IF;

:NEW.id_prawa_jazdy := sekwencja_id_prawa_jazdy.NEXTVAL;
END;

/

CREATE OR REPLACE
TRIGGER wyzwalacz_wykroczenia_insert
    BEFORE
INSERT
	ON
	wykroczenia 
    FOR EACH ROW
DECLARE
		e_kwota_min_max EXCEPTION;

PRAGMA exception_init( e_kwota_min_max,
-20001 );
BEGIN
	:NEW.id_wykroczenia := sekwencja_id_wykroczenia.NEXTVAL;

IF :NEW.kwota_min > :NEW.kwota_max THEN 
        RAISE e_kwota_min_max;
END IF;
END;

/

CREATE OR REPLACE
TRIGGER wyzwalacz_zdarzenia_insert
    BEFORE
INSERT
	ON
	zdarzenia
    FOR EACH ROW
BEGIN
		:NEW.id_zdarzenia := SEKWENCJA_ID_ZDARZENIA.NEXTVAL;
END;

CREATE OR REPLACE
TRIGGER wyzwalacz_pojazdy_delete
    BEFORE
DELETE
	ON
	pojazdy
    FOR EACH ROW
DECLARE
		CURSOR cUbezpieczenia IS 
        SELECT
	nr_polisy
FROM
	Ubezpieczenia
WHERE
	VIN_POJAZDU =:OLD.VIN;

CURSOR cOsoby_Pojazdy IS
        SELECT
	pesel,
	vin
FROM
	Osoby_Pojazdy op
WHERE
	op.VIN =:OLD.VIN;

BEGIN
    FOR vUbezpieczenie IN cUbezpieczenia LOOP
        DELETE
FROM
	Ubezpieczenia
WHERE
	nr_polisy = vUbezpieczenie.nr_polisy;
END
LOOP;

FOR vOsoby_Pojazdy IN cOsoby_Pojazdy
LOOP
	DELETE
FROM
	Osoby_Pojazdy op
WHERE
	op.pesel = vOsoby_Pojazdy.pesel
	AND op.vin = vOsoby_Pojazdy.vin ;
END
LOOP;
END;

/

CREATE OR REPLACE
TRIGGER wyzwalacz_mandaty_insert
BEFORE
INSERT
	ON
	mandaty
FOR EACH ROW
DECLARE
		UCZESTNIK_INTERWENCJA_ROZNE_ZDARZENIA EXCEPTION;

zdarzenie_interwencja interwencje.zdarzenie%TYPE;

zdarzenie_uczestnik uczestnicy_zdarzenia.zdarzenie%TYPE;
BEGIN
	SELECT
	zdarzenie
INTO
	zdarzenie_interwencja
FROM
	interwencje
WHERE
	id_interwencji =:NEW.id_interwencji;

SELECT
	zdarzenie
INTO
	zdarzenie_uczestnik
FROM
	uczestnicy_zdarzenia
WHERE
	id_uczestnika =:NEW.id_uczestnika;

IF (zdarzenie_interwencja != zdarzenie_uczestnik ) THEN
    raise UCZESTNIK_INTERWENCJA_ROZNE_ZDARZENIA;
END IF;

INSERT
	INTO
	formy_wymiaru_kary(id_uczestnika,
	id_interwencji,
	typ)
VALUES (:NEW.id_uczestnika,
:NEW.id_interwencji,
'm');
END;

/

CREATE OR REPLACE
TRIGGER wyzwalacz_mandaty_delete
AFTER
DELETE
	ON
	mandaty
FOR EACH ROW
BEGIN
		DELETE
FROM
	formy_wymiaru_kary
WHERE
	id_uczestnika =:OLD.id_uczestnika
	AND id_interwencji =:OLD.id_interwencji;
END;

/

CREATE OR REPLACE
TRIGGER wyzwalacz_aresztowania_insert
BEFORE
INSERT
	ON
	aresztowania
FOR EACH ROW
DECLARE
		UCZESTNIK_INTERWENCJA_ROZNE_ZDARZENIA EXCEPTION;

OD_KIEDY_POZNIEJ_NIZ_DO_KIEDY EXCEPTION;

ARESZTOWANIE_PRZED_16 EXCEPTION;

zdarzenie_interwencja interwencje.zdarzenie%TYPE;

zdarzenie_uczestnik uczestnicy_zdarzenia.zdarzenie%TYPE;

data_ur_uczestnika osoby.data_urodzenia%TYPE;
BEGIN
	SELECT
	zdarzenie
INTO
	zdarzenie_interwencja
FROM
	interwencje
WHERE
	id_interwencji =:NEW.id_interwencji;

SELECT
	zdarzenie
INTO
	zdarzenie_uczestnik
FROM
	uczestnicy_zdarzenia
WHERE
	id_uczestnika =:NEW.id_uczestnika;

IF (zdarzenie_interwencja != zdarzenie_uczestnik ) THEN
      raise UCZESTNIK_INTERWENCJA_ROZNE_ZDARZENIA;
END IF;

IF (NOT :NEW.DO_KIEDY IS NULL
	AND :NEW.od_kiedy > :NEW.do_kiedy) THEN
        raise OD_KIEDY_POZNIEJ_NIZ_DO_KIEDY;
END IF;

SELECT
	data_urodzenia
INTO
	data_ur_uczestnika
FROM
	osoby
JOIN uczestnicy_zdarzenia ON
	osoby.pesel = uczestnicy_zdarzenia.pesel_uczestnika
WHERE
	id_uczestnika =:NEW.id_uczestnika;

IF (NOT data_ur_uczestnika IS NULL
	AND calculate_age(data_ur_uczestnika,
	:NEW.od_kiedy)<INTERVAL '16' YEAR ) THEN
        raise ARESZTOWANIE_PRZED_16;
END IF;

INSERT
	INTO
	formy_wymiaru_kary(id_uczestnika,
	id_interwencji,
	typ)
VALUES (:NEW.id_uczestnika,:NEW.id_interwencji,'a');
END;

/

CREATE OR REPLACE
TRIGGER wyzwalacz_aresztowania_delete
AFTER
DELETE
	ON
	aresztowania
FOR EACH ROW
BEGIN
		DELETE
FROM
	formy_wymiaru_kary
WHERE
	id_uczestnika =:OLD.id_uczestnika
	AND id_interwencji =:OLD.id_interwencji;
END;

/

CREATE OR REPLACE
PACKAGE
	Drogowka IS
  FUNCTION funkcja_zweryfikuj_vin(
      vin varchar2
  ) RETURN boolean;

PROCEDURE silent_insert_osoby_pojazdy(
      v_vin osoby_pojazdy.VIN%TYPE,
v_pesel osoby_pojazdy.pesel%TYPE
  );

FUNCTION funkcja_zweryfikuj_pesel(
      pesel varchar2
  ) RETURN boolean;

FUNCTION calculate_age (
      d1 IN DATE, 
      d2 IN DATE
  ) RETURN INTERVAL YEAR TO MONTH;
END Drogowka;

CREATE OR REPLACE
PACKAGE
	BODY Drogowka IS 
  
  CREATE OR REPLACE
	FUNCTION funkcja_zweryfikuj_vin(
      vin varchar2
  ) RETURN boolean AS
BEGIN
		RETURN NOT vin IS NULL
		AND lengthb(vin) = 17
		AND REGEXP_LIKE(vin, '^[A-Z0-9]{17}$');
END;

/

  CREATE OR REPLACE
PROCEDURE silent_insert_osoby_pojazdy(
      v_vin osoby_pojazdy.VIN%TYPE,
v_pesel osoby_pojazdy.pesel%TYPE
  ) AS
BEGIN
	INSERT
	INTO
	osoby_pojazdy(pesel,
	vin)
VALUES (v_pesel,
v_vin);

EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
          NULL;
END silent_insert_osoby_pojazdy;

/


  CREATE OR REPLACE
FUNCTION funkcja_zweryfikuj_pesel(
      pesel varchar2
  ) RETURN boolean AS
BEGIN
	RETURN NOT pesel IS NULL
	AND lengthb(pesel) = 11
	AND REGEXP_LIKE(pesel, '^[0-9]{11}$');
END;

/

  CREATE OR REPLACE
FUNCTION calculate_age (
      d1 IN DATE, 
      d2 IN DATE
  ) RETURN INTERVAL YEAR TO MONTH IS
      v_months_diff NUMBER;

v_years NUMBER;

v_months NUMBER;

v_interval INTERVAL YEAR TO MONTH;
BEGIN
	v_months_diff := MONTHS_BETWEEN(d2, d1);

	v_years := TRUNC(v_months_diff / 12);

	v_months := MOD(TRUNC(v_months_diff),12);

	v_interval := NUMTOYMINTERVAL(v_years, 'YEAR') + NUMTOYMINTERVAL(v_months, 'MONTH') ;

RETURN v_interval;
END calculate_age;

/
END Drogowka;

