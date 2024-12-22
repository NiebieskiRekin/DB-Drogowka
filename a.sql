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
	data_urodzenia DATE NULL CHECK(data_urodzenia IS NULL OR data_urodzenia > to_date('1-1-1900', 'DD-MM-YYYY'))
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
	UNIQUE(kategoria,od_kiedy,pesel)
);

CREATE TABLE FUNKCJONARIUSZE(
	nr_odznaki varchar(16) NOT NULL,
	stopien varchar(32) NOT NULL,
	pesel char(11) REFERENCES osoby(pesel) PRIMARY KEY
);

CREATE TABLE ZDARZENIA(
	id_zdarzenia integer PRIMARY KEY,
	data_zdarzenia DATE NOT NULL CHECK(data_zdarzenia > to_date('1-1-1900', 'DD-MM-YYYY')),
	wysokosc_geograficzna NUMBER(8,6) NOT NULL,
	szerokosc_geograficzna NUMBER(8,6) NOT NULL,
	opis varchar(128) NULL,
	UNIQUE(data_zdarzenia,wysokosc_geograficzna,szerokosc_geograficzna)
);

CREATE TABLE INTERWENCJE(
	id_interwencji integer PRIMARY KEY,
	data_i_czas_interwencji timestamp NOT NULL CHECK(data_i_czas_interwencji > to_timestamp('1-1-1900', 'DD-MM-YYYY')),
	funkcjonariusz char(11) NOT NULL REFERENCES Funkcjonariusze(pesel),
	zdarzenie integer NOT NULL REFERENCES zdarzenia(id_zdarzenia),
	UNIQUE(funkcjonariusz,zdarzenie)
);

CREATE TABLE UCZESTNICY_ZDARZENIA(
	id_uczestnika integer PRIMARY KEY,
	rola varchar(32) NOT NULL CHECK(rola IN ('poszkodowany', 'winowajca', 'zgłaszający', 'świadek', 'podejrzany')),
	pesel_uczestnika char(11) NOT NULL REFERENCES osoby(pesel),
	zdarzenie integer NOT NULL REFERENCES zdarzenia(id_zdarzenia),
	UNIQUE(rola,pesel_uczestnika,zdarzenie)
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
	PRIMARY KEY(id_uczestnika,id_interwencji)
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
	PRIMARY KEY(id_uczestnika,id_interwencji),
	FOREIGN KEY(id_uczestnika,id_interwencji) REFERENCES formy_wymiaru_kary(id_uczestnika,id_interwencji)
);

CREATE TABLE ARESZTOWANIA(
	id_uczestnika integer,
	id_interwencji integer,
	od_kiedy DATE NOT NULL CHECK( od_kiedy > to_date('1-1-1900', 'DD-MM-YYYY')),
  do_kiedy DATE NULL CHECK(do_kiedy IS NULL OR do_kiedy > to_date('1-1-1900', 'DD-MM-YYYY')),
  czy_w_zawieszeniu CHAR(1) NOT NULL CHECK ( czy_w_zawieszeniu IN ( 'N', 'T' ) ),
  PRIMARY KEY ( ID_UCZESTNIKA,ID_INTERWENCJI ),
  FOREIGN KEY(id_uczestnika,id_interwencji) REFERENCES formy_wymiaru_kary(id_uczestnika,id_interwencji)
);

CREATE SEQUENCE "SEKWENCJA_ID_WYKROCZENIA" MINVALUE 1 INCREMENT BY 1 START WITH 100;

CREATE SEQUENCE "SEKWENCJA_ID_PRAWA_JAZDY" MINVALUE 1 INCREMENT BY 1 START WITH 1000;

CREATE SEQUENCE "SEKWENCJA_ID_ZDARZENIA" MINVALUE 1 INCREMENT BY 1 START WITH 1000;

CREATE SEQUENCE "SEKWENCJA_ID_INTERWENCJI" MINVALUE 1 INCREMENT BY 1 START WITH 1000;

CREATE SEQUENCE "SEKWENCJA_ID_UCZESTNIKA_ZDARZENIA" MINVALUE 1 INCREMENT BY 1 START WITH 1000;

CREATE SEQUENCE "SEKWENCJA_NR_MANDATU"  INCREMENT BY 57 START WITH 1000000000;

CREATE OR REPLACE
VIEW perspektywa_pojazdy_danej_osoby AS SELECT
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
VIEW perspektywa_wyszukiwanie_informacje_ogolne_o_danej_osobie_2pola AS SELECT
	pesel,
	imie || ' ' || nazwisko AS "Imie_i_Nazwisko"
FROM
	osoby;

CREATE OR REPLACE
VIEW perspektywa_mandaty_danej_osoby AS SELECT
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
VIEW perspektywa_wlasciciele_pojazdu AS SELECT
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
VIEW perspektywa_aresztowania_danej_osoby AS SELECT
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
VIEW PERSPEKTYWA_ZDARZENIA_ILE AS SELECT
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
VIEW PERSPEKTYWA_FUNKCJONARIUSZE AS SELECT
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

CREATE OR REPLACE
VIEW perspektywa_interwencje_danego_policjanta AS SELECT 
  id_interwencji,
  data_i_czas_interwencji,
  funkcjonariusz,
  zdarzenie,
  opis,
  (SELECT COUNT(*) 
   FROM UCZESTNICY_ZDARZENIA
   WHERE i.zdarzenie=zdarzenie) AS "Liczba_uczestnikow_zdarzenia"
FROM INTERWENCJE i
LEFT JOIN ZDARZENIA
on zdarzenie=id_zdarzenia;

CREATE OR REPLACE
VIEW perspektywa_pouczenia_pesele_uczestnika_funkcjonariusza AS SELECT
  ID_UCZESTNIKA,
  ID_INTERWENCJI,
  PESEL_UCZESTNIKA,
  (o1.imie || ' ' || o1.nazwisko) as Imie_i_Nazwisko_Uczestnika,
  FUNKCJONARIUSZ AS PESEL_FUNKCJONARIUSZA,
  (o2.imie || ' ' || o2.nazwisko) as FUNKCJONARIUSZ,
  i.ZDARZENIE
FROM FORMY_WYMIARU_KARY 
JOIN UCZESTNICY_ZDARZENIA uz USING(id_uczestnika)
JOIN INTERWENCJE i USING(id_interwencji)
JOIN OSOBY o1 on uz.PESEL_UCZESTNIKA=o1.PESEL
JOIN OSOBY o2 on i.FUNKCJONARIUSZ=o2.PESEL
WHERE FORMY_WYMIARU_KARY.typ = 'p';

CREATE OR REPLACE
VIEW perspektywa_aresztowania_pesele_uczestnika_funkcjonariusza AS SELECT
  id_uczestnika,
  id_interwencji,
  PESEL_UCZESTNIKA,
  (o1.imie || ' ' || o1.nazwisko) as Imie_i_Nazwisko_Uczestnika,
  FUNKCJONARIUSZ AS PESEL_FUNKCJONARIUSZA,
  (o2.imie || ' ' || o2.nazwisko) as FUNKCJONARIUSZ,
  i.ZDARZENIE,
	od_kiedy,
  do_kiedy,
  czy_w_zawieszeniu
FROM ARESZTOWANIA
JOIN UCZESTNICY_ZDARZENIA uz USING(id_uczestnika)
JOIN INTERWENCJE i USING(id_interwencji)
JOIN OSOBY o1 on uz.PESEL_UCZESTNIKA=o1.PESEL
JOIN OSOBY o2 on i.FUNKCJONARIUSZ=o2.PESEL;

CREATE OR REPLACE
VIEW perspektywa_mandaty_pesele_uczestnika_funkcjonariusza AS SELECT
  id_uczestnika,
  id_interwencji,
  PESEL_UCZESTNIKA,
  (o1.imie || ' ' || o1.nazwisko) as Imie_i_Nazwisko_Uczestnika,
  FUNKCJONARIUSZ AS PESEL_FUNKCJONARIUSZA,
  (o2.imie || ' ' || o2.nazwisko) as FUNKCJONARIUSZ,
  i.ZDARZENIE,
	nr_serii,
	kwota,
	punkty_karne,
	czy_przyjeto,
	czy_oplacone,
	opis,
	wykroczenie
FROM MANDATY
JOIN UCZESTNICY_ZDARZENIA uz USING(id_uczestnika)
JOIN INTERWENCJE i USING(id_interwencji)
JOIN OSOBY o1 on uz.PESEL_UCZESTNIKA=o1.PESEL
JOIN OSOBY o2 on i.FUNKCJONARIUSZ=o2.PESEL;


CREATE OR REPLACE TRIGGER wyzwalacz_mandaty_pesele_uczestnika_funkcjonariusza_update
    INSTEAD OF UPDATE ON perspektywa_mandaty_pesele_uczestnika_funkcjonariusza
    FOR EACH ROW
BEGIN
  UPDATE MANDATY
  SET nr_serii=:NEW.nr_serii,
      kwota=:NEW.kwota,
      punkty_karne=:NEW.punkty_karne,
      czy_przyjeto=:NEW.czy_przyjeto,
      czy_oplacone=:NEW.czy_oplacone,
      opis=:NEW.opis
  WHERE ID_INTERWENCJI=:NEW.ID_INTERWENCJI
  AND   ID_UCZESTNIKA=:NEW.ID_UCZESTNIKA;
END;

CREATE OR REPLACE TRIGGER wyzwalacz_mandaty_pesele_uczestnika_funkcjonariusza_delete
    INSTEAD OF DELETE ON perspektywa_mandaty_pesele_uczestnika_funkcjonariusza
    FOR EACH ROW
BEGIN
  DELETE FROM MANDATY WHERE ID_UCZESTNIKA=:OLD.ID_UCZESTNIKA AND ID_INTERWENCJI=:OLD.ID_INTERWENCJI;
END;

CREATE OR REPLACE TRIGGER wyzwalacz_aresztowania_pesele_uczestnika_funkcjonariusza_update
    INSTEAD OF UPDATE ON perspektywa_aresztowania_pesele_uczestnika_funkcjonariusza
    FOR EACH ROW
BEGIN
  UPDATE ARESZTOWANIA
  SET od_kiedy=:NEW.od_kiedy,
      do_kiedy=:NEW.do_kiedy,
      czy_w_zawieszeniu=:NEW.czy_w_zawieszeniu
  WHERE ID_INTERWENCJI=:NEW.ID_INTERWENCJI
  AND   ID_UCZESTNIKA=:NEW.ID_UCZESTNIKA;
END;

CREATE OR REPLACE TRIGGER wyzwalacz_aresztowania_pesele_uczestnika_funkcjonariusza_delete
    INSTEAD OF DELETE ON perspektywa_aresztowania_pesele_uczestnika_funkcjonariusza
    FOR EACH ROW
BEGIN
  DELETE FROM ARESZTOWANIA WHERE ID_UCZESTNIKA=:OLD.ID_UCZESTNIKA AND ID_INTERWENCJI=:OLD.ID_INTERWENCJI;
END;

CREATE OR REPLACE TRIGGER wyzwalacz_pouczenia_pesele_uczestnika_funkcjonariusza_delete
    INSTEAD OF DELETE ON perspektywa_pouczenia_pesele_uczestnika_funkcjonariusza
    FOR EACH ROW
BEGIN
  DELETE FROM FORMY_WYMIARU_KARY WHERE ID_UCZESTNIKA=:OLD.ID_UCZESTNIKA AND ID_INTERWENCJI=:OLD.ID_INTERWENCJI;
END;


CREATE OR REPLACE TRIGGER wyzwalacz_interwencje_insert
    BEFORE INSERT ON INTERWENCJE 
    FOR EACH ROW
BEGIN
  :NEW.id_interwencji := SEKWENCJA_ID_INTERWENCJI.NEXTVAL; 
END;
/

CREATE OR REPLACE TRIGGER wyzwalacz_uczestnicy_zdarzenia_insert
    BEFORE INSERT ON UCZESTNICY_ZDARZENIA 
    FOR EACH ROW
BEGIN
  :NEW.id_uczestnika := SEKWENCJA_ID_UCZESTNIKA_ZDARZENIA.NEXTVAL; 
END;
/

CREATE OR REPLACE TRIGGER wyzwalacz_pojazdy_danej_osoby_update
    instead OF UPDATE ON PERSPEKTYWA_POJAZDY_DANEJ_OSOBY
    FOR EACH ROW
BEGIN
    DELETE FROM osoby_pojazdy
    WHERE
      vin =:OLD.vin
      AND pesel =:OLD.pesel;

    INSERT INTO
      osoby_pojazdy(vin,pesel)
    VALUES (:NEW.vin,:NEW.pesel);
END;
/

CREATE OR REPLACE TRIGGER wyzwalacz_pojazdy_danej_osoby_insert
    instead OF INSERT ON PERSPEKTYWA_POJAZDY_DANEJ_OSOBY
    FOR EACH ROW
BEGIN
	INSERT INTO
  	osoby_pojazdy(vin,pesel)
  VALUES (:NEW.vin,:NEW.pesel);
END;
/

CREATE OR REPLACE TRIGGER wyzwalacz_prawa_jazdy_insert
    BEFORE INSERT	ON prawa_jazdy 
    FOR EACH ROW
DECLARE
	OD_KIEDY_POZNIEJ_NIZ_DO_KIEDY EXCEPTION;
  PRAGMA exception_init(OD_KIEDY_POZNIEJ_NIZ_DO_KIEDY,-20003 );
  PRAWO_JAZDY_PRZED_16 EXCEPTION;
  PRAGMA exception_init(PRAWO_JAZDY_PRZED_16 ,-20005 );
  data_ur osoby.data_urodzenia%TYPE;
BEGIN
	IF (NOT :NEW.DO_KIEDY IS NULL AND :NEW.od_kiedy > :NEW.do_kiedy) THEN
    apex_error.add_error (
    p_message          => 'Czas zakończenia uprawnień mija przed ich rozpoczęciem.',
    p_display_location => apex_error.c_inline_in_notification );
  END IF;

  SELECT
    data_urodzenia
  INTO
    data_ur
  FROM
    osoby
  WHERE
    pesel =:NEW.pesel;

  IF (NOT data_ur IS NULL AND calculate_age(data_ur,:NEW.od_kiedy)<INTERVAL '16' YEAR ) THEN
    apex_error.add_error (
    p_message          => 'Prawo jazdy nie może zostać przyznane przed 16 rokiem życia.',
    p_display_location => apex_error.c_inline_in_notification );
  END IF;

  :NEW.id_prawa_jazdy := sekwencja_id_prawa_jazdy.NEXTVAL;
END;
/

CREATE OR REPLACE TRIGGER wyzwalacz_wykroczenia_insert
    BEFORE INSERT ON wykroczenia 
    FOR EACH ROW
DECLARE
		e_kwota_min_max EXCEPTION;

  PRAGMA exception_init( e_kwota_min_max,-20001 );
BEGIN
  :NEW.id_wykroczenia := sekwencja_id_wykroczenia.NEXTVAL;

  IF :NEW.stawka_minimalna> :NEW.stawka_maksymalna THEN 
    apex_error.add_error (
    p_message          => 'Minimalna stawka wykroczenia nie może być większa niż maksymalna.',
    p_display_location => apex_error.c_inline_in_notification );
  END IF;
END;
/

CREATE OR REPLACE TRIGGER wyzwalacz_zdarzenia_insert
    BEFORE INSERT ON zdarzenia
    FOR EACH ROW
BEGIN
		:NEW.id_zdarzenia := SEKWENCJA_ID_ZDARZENIA.NEXTVAL;
END;

CREATE OR REPLACE TRIGGER wyzwalacz_pojazdy_delete
    BEFORE DELETE ON pojazdy
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
    DELETE FROM
      Ubezpieczenia
    WHERE
      nr_polisy = vUbezpieczenie.nr_polisy;
  END LOOP;

  FOR vOsoby_Pojazdy IN cOsoby_Pojazdy LOOP
    DELETE FROM
      Osoby_Pojazdy op
    WHERE
      op.pesel = vOsoby_Pojazdy.pesel
      AND op.vin = vOsoby_Pojazdy.vin ;
  END LOOP;
END;
/

CREATE OR REPLACE TRIGGER wyzwalacz_mandaty_update
  BEFORE UPDATE ON mandaty
  FOR EACH ROW
BEGIN
  Drogowka.procedura_uczestnik_interwencja_to_samo_zdarzenie(:NEW.id_interwencji,:NEW.id_uczestnika);
END;
/

CREATE OR REPLACE TRIGGER wyzwalacz_mandaty_insert
  BEFORE INSERT ON mandaty
  FOR EACH ROW
DECLARE
	UCZESTNIK_INTERWENCJA_ROZNE_ZDARZENIA EXCEPTION;
  PRAGMA exception_init(UCZESTNIK_INTERWENCJA_ROZNE_ZDARZENIA,-20002 );
  zdarzenie_interwencja interwencje.zdarzenie%TYPE;
  zdarzenie_uczestnik uczestnicy_zdarzenia.zdarzenie%TYPE;
BEGIN
  
  Drogowka.procedura_uczestnik_interwencja_to_samo_zdarzenie(:NEW.id_interwencji,:NEW.id_uczestnika);

  INSERT INTO
    formy_wymiaru_kary(id_uczestnika,id_interwencji,typ)
  VALUES
    (:NEW.id_uczestnika,:NEW.id_interwencji,'m');
END;
/

CREATE OR REPLACE TRIGGER wyzwalacz_mandaty_delete
  AFTER DELETE ON mandaty
  FOR EACH ROW
BEGIN
		DELETE FROM
      formy_wymiaru_kary
    WHERE
      id_uczestnika =:OLD.id_uczestnika
      AND id_interwencji =:OLD.id_interwencji;
END;
/

CREATE OR REPLACE TRIGGER wyzwalacz_aresztowania_insert
  BEFORE INSERT ON aresztowania
  FOR EACH ROW
DECLARE
	UCZESTNIK_INTERWENCJA_ROZNE_ZDARZENIA EXCEPTION;
  PRAGMA exception_init(UCZESTNIK_INTERWENCJA_ROZNE_ZDARZENIA,-20002 );
  OD_KIEDY_POZNIEJ_NIZ_DO_KIEDY EXCEPTION;
  PRAGMA exception_init(OD_KIEDY_POZNIEJ_NIZ_DO_KIEDY,-20003 );
  ARESZTOWANIE_PRZED_16 EXCEPTION;
  PRAGMA exception_init(ARESZTOWANIE_PRZED_16 ,-20004 );
  zdarzenie_interwencja interwencje.zdarzenie%TYPE;
  zdarzenie_uczestnik uczestnicy_zdarzenia.zdarzenie%TYPE;
  data_ur_uczestnika osoby.data_urodzenia%TYPE;
BEGIN

  Drogowka.procedura_uczestnik_interwencja_to_samo_zdarzenie(:NEW.id_interwencji, :NEW.id_uczestnika);
  
  Drogowka.procedura_od_kiedy_przed_do_kiedy(:NEW:od_kiedy, :NEW.do_kiedy);
  
  Drogowka.procedura_uczestnik_min_16_lat(:NEW.od_kiedy, :NEW.id_uczestnika);

  INSERT INTO
    formy_wymiaru_kary(id_uczestnika,id_interwencji,typ)
  VALUES 
    (:NEW.id_uczestnika,:NEW.id_interwencji,'a');
END;
/

CREATE OR REPLACE TRIGGER wyzwalacz_aresztowania_update
  BEFORE UPDATE ON aresztowania
  FOR EACH ROW
BEGIN
  Drogowka.procedura_uczestnik_interwencja_to_samo_zdarzenie(:NEW.id_interwencji, :NEW.id_uczestnika);
  Drogowka.procedura_od_kiedy_przed_do_kiedy(:NEW.od_kiedy, :NEW.do_kiedy);
  Drogowka.procedura_uczestnik_min_16_lat(:NEW.od_kiedy, :NEW.id_uczestnika);
END;

CREATE OR REPLACE TRIGGER wyzwalacz_aresztowania_delete
  AFTER DELETE ON aresztowania
  FOR EACH ROW
BEGIN
  DELETE FROM
    formy_wymiaru_kary
  WHERE
    id_uczestnika =:OLD.id_uczestnika
    AND id_interwencji =:OLD.id_interwencji;
END;
/

CREATE OR REPLACE PACKAGE Drogowka IS

  PROCEDURE procedura_wyswietl_stawki_wykroczenia(
    wykroczenie wykroczenia.id_wykroczenia%TYPE
  );

  FUNCTION funkcja_numer_mandatu
  RETURN varchar2;

  FUNCTION funkcja_zweryfikuj_nr_telefonu(
    nr_telefonu varchar2
  ) RETURN boolean;

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

  FUNCTION funkcja_zweryfikuj_kwote_mandatu (
    kwota IN NUMERIC,
    wykroczenie IN WYKROCZENIA.ID_WYKROCZENIA%TYPE
  ) RETURN boolean;

  FUNCTION funkcja_zweryfikuj_ffk(
    interwencja IN Interwencje.id_interwencji%TYPE, uczestnik IN Uczestnicy_Zdarzenia.id_uczestnika%TYPE
  ) RETURN BOOLEAN;


  PROCEDURE procedura_uczestnik_interwencja_to_samo_zdarzenie(
    interwencja IN Interwencje.id_interwencji%TYPE, uczestnik IN Uczestnicy_Zdarzenia.id_uczestnika%TYPE
  );

  PROCEDURE procedura_od_kiedy_przed_do_kiedy(
    od_kiedy aresztowania.od_kiedy%TYPE,do_kiedy aresztowania.do_kiedy%TYPE
  );

  PROCEDURE procedura_uczestnik_min_16_lat(
    od_kiedy aresztowania.od_kiedy%TYPE,uczestnik uczestnicy_zdarzenia.id_uczestnika%TYPE
  );

END Drogowka;

CREATE OR REPLACE PACKAGE BODY Drogowka IS 
 
  FUNCTION funkcja_numer_mandatu
  RETURN varchar2  AS
      v_nr integer;
  BEGIN
      v_nr := SEKWENCJA_NR_MANDATU.NEXTVAL;
      RETURN 'DR' || v_nr;
  END;

  FUNCTION funkcja_zweryfikuj_vin(
      vin varchar2
  ) RETURN boolean AS
  BEGIN
      RETURN NOT vin IS NULL
      AND lengthb(vin) = 17
      AND REGEXP_LIKE(vin, '^[A-Z0-9]{17}$');
  END;

  PROCEDURE silent_insert_osoby_pojazdy(
    v_vin osoby_pojazdy.VIN%TYPE,
    v_pesel osoby_pojazdy.pesel%TYPE
  ) AS
  BEGIN
    INSERT INTO
    osoby_pojazdy(pesel,vin)
  VALUES (v_pesel,v_vin);

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      NULL;
  END silent_insert_osoby_pojazdy;

  FUNCTION funkcja_zweryfikuj_pesel(
    pesel varchar2
  ) RETURN boolean AS
  BEGIN
    RETURN NOT pesel IS NULL
    AND lengthb(pesel) = 11
    AND REGEXP_LIKE(pesel, '^[0-9]{11}$');
  END;


  FUNCTION funkcja_zweryfikuj_nr_telefonu(
    nr_telefonu varchar2
  ) RETURN boolean AS
  BEGIN
    RETURN NOT nr_telefonu IS NULL
    AND REGEXP_LIKE(nr_telefonu, '^(\+\d{2})?\d{9}$');
  END;


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
  

  FUNCTION funkcja_zweryfikuj_kwote_mandatu (
    kwota IN NUMERIC,
    wykroczenie IN WYKROCZENIA.ID_WYKROCZENIA%TYPE
  ) RETURN boolean AS
    v_min NUMERIC;
    v_max NUMERIC;
  BEGIN
    SELECT stawka_minimalna, stawka_maksymalna into v_min, v_max from wykroczenia where id_wykroczenia=wykroczenie;
    RETURN kwota between v_min and v_max;
  END;

 FUNCTION funkcja_zweryfikuj_ffk(
      interwencja IN Interwencje.id_interwencji%TYPE, uczestnik IN Uczestnicy_Zdarzenia.id_uczestnika%TYPE
    ) RETURN boolean as
      v_has_ffk integer;
    begin
      select COUNT(*) into v_has_ffk from formy_wymiaru_kary where id_uczestnika=uczestnik and id_interwencji=interwencja;
      return v_has_ffk = 0;
    end;

  PROCEDURE procedura_uczestnik_interwencja_to_samo_zdarzenie(
    interwencja IN Interwencje.id_interwencji%TYPE, uczestnik IN Uczestnicy_Zdarzenia.id_uczestnika%TYPE
  ) AS
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
      id_interwencji =interwencja;

    SELECT
      zdarzenie
    INTO
      zdarzenie_uczestnik
    FROM
      uczestnicy_zdarzenia
    WHERE
      id_uczestnika =uczestnik;

    IF (zdarzenie_interwencja != zdarzenie_uczestnik ) THEN
      apex_error.add_error (
      p_message          => 'Uczestnik zdarzenia i interwencja dotyczą różnych zdarzeń. Zweryfikuj poprawność wybranych danych.',
      p_display_location => apex_error.c_inline_in_notification );
    END IF;
  END;

  PROCEDURE procedura_od_kiedy_przed_do_kiedy(
    od_kiedy aresztowania.od_kiedy%TYPE,do_kiedy aresztowania.do_kiedy%TYPE
  ) as
  begin
    IF (NOT do_kiedy IS NULL AND od_kiedy > do_kiedy) THEN
      apex_error.add_error (
      p_message          => 'Czas zakończenia aresztowania mija przed jego rozpoczęciem.',
      p_display_location => apex_error.c_inline_in_notification );
    END IF;
  end;

  PROCEDURE procedura_uczestnik_min_16_lat(
    od_kiedy aresztowania.od_kiedy%TYPE,uczestnik uczestnicy_zdarzenia.id_uczestnika%TYPE
  ) as
    data_ur_uczestnika osoby.data_urodzenia%TYPE;
  begin
    SELECT
      data_urodzenia
    INTO
      data_ur_uczestnika
    FROM
      osoby
    JOIN uczestnicy_zdarzenia ON
      osoby.pesel = uczestnicy_zdarzenia.pesel_uczestnika
    WHERE
      id_uczestnika =uczestnik;

    IF (NOT data_ur_uczestnika IS NULL AND calculate_age(data_ur_uczestnika, od_kiedy)<INTERVAL '16' YEAR ) THEN
      apex_error.add_error (
      p_message          => 'Aresztowanie osób do 16 roku życia nie jest dozwolone.',
      p_display_location => apex_error.c_inline_in_notification );
    END IF;
  end;

  PROCEDURE procedura_wyswietl_stawki_wykroczenia(
    wykroczenie wykroczenia.id_wykroczenia%TYPE
  ) as
    s_min wykroczenia.stawka_minimalna%TYPE;
    s_max wykroczenia.stawka_maksymalna%TYPE;
  begin
    select stawka_minimalna, stawka_maksymalna into s_min, s_max from wykroczenia where id_wykroczenia=wykroczenie;

    apex_error.add_error (
    p_message          => 'Kwota za podane wykroczenie pownna zawierać się w przedziale od ' || s_min || ' do ' || s_max,
    p_display_location => apex_error.c_inline_in_notification );
  end;

END Drogowka;

