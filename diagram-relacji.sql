CREATE TABLE POJAZDY (
    VIN CHAR(17) PRIMARY KEY,
    NR_REJESTRACYJNY VARCHAR(8) NOT NULL UNIQUE,
    BADANIE_TECHNICZNE DATE NOT NULL check(BADANIE_TECHNICZNE > to_date('1-1-1900')),
    MARKA VARCHAR(32) NOT NULL,
    MODEL VARCHAR(32) NOT NULL,
    ROK_PRODUKCJI INTEGER NOT NULL check(rok_produkcji > 1900),
    CZY_ZAREKWIROWANY CHAR(1) DEFAULT ('N') NOT NULL CHECK ( CZY_ZAREKWIROWANY IN ( 'N', 'T' ) ),
    CZY_POSZUKIWANE CHAR(1) DEFAULT ('N') NOT NULL CHECK ( CZY_POSZUKIWANE IN ( 'N', 'T' ) ),
    KOLOR VARCHAR(32) NULL
);

CREATE TABLE UBEZPIECZENIA (
    NR_POLISY VARCHAR(10) ,
    DATA_WAZNOSCI DATE NOT NULL check(data_waznosci > to_date('1-1-1900')),
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
	data_urodzenia DATE NULL check(data_urodzenia is null or data_urodzenia > to_date('1-1-1900'))
);

CREATE TABLE OSOBY_POJAZDY(
	vin char(17) not null REFERENCES pojazdy(vin),
	pesel char(11) not null REFERENCES osoby(pesel),
  primary key(PESEL,VIN)
);

CREATE TABLE PRAWA_JAZDY(
  id_prawa_jazdy integer primary key,
	kategoria varchar(7) not null check(kategoria in (
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
	od_kiedy DATE not null,
	do_kiedy DATE NOT NULL,
	PESEL char(11) REFERENCES osoby(pesel),
	UNIQUE(kategoria,od_kiedy,pesel)
);

CREATE TABLE FUNKCJONARIUSZE(
	nr_odznaki varchar(16) NOT NULL,
	stopien varchar(32) NOT NULL,
	pesel char(11) REFERENCES osoby(pesel) PRIMARY KEY
);

CREATE TABLE ZDARZENIA(
	id_zdarzenia integer PRIMARY KEY,
	data_zdarzenia DATE NOT NULL,
	wysokosc_geograficzna NUMBER(8,6) NOT NULL,
	szerokosc_geograficzna NUMBER(8,6) NOT NULL,
	opis varchar(128) NULL,
	UNIQUE(data_zdarzenia,wysokosc_geograficzna, szerokosc_geograficzna)
);

CREATE TABLE INTERWENCJE(
	id_interwencji integer PRIMARY KEY,
	data_i_czas_interwencji timestamp NOT NULL,
	funkcjonariusz char(11)  NOT NULL REFERENCES Funkcjonariusze(pesel),
	zdarzenie integer  NOT NULL REFERENCES zdarzenia(id_zdarzenia),
	UNIQUE(funkcjonariusz,zdarzenie)
);

CREATE TABLE UCZESTNICY_ZDARZENIA(
	id_uczestnika integer PRIMARY KEY,
	rola varchar(32) NOT NULL check(rola in ('poszkodowany', 'winowajca','zgłaszający', 'świadek','podejrzany')),
	pesel_uczestnika char(11) NOT NULL REFERENCES osoby(pesel),
	zdarzenie integer NOT NULL REFERENCES zdarzenia(id_zdarzenia),
	UNIQUE(rola,pesel_uczestnika,zdarzenie)
);

CREATE TABLE WYKROCZENIA(
  id_wykroczenia integer PRIMARY KEY,
	nazwa varchar(128) NOT NULL UNIQUE,
	punkty_karne integer NOT NULL CHECK(punkty_karne BETWEEN 0 AND 15),
	stawka_minimalna NUMBER NOT NULL CHECK(stawka_minimalna>=0),
	stawka_maksymalna NUMBER NOT NULL CHECK(stawka_maksymalna<=6000),
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
	punkty_karne integer NOT NULL,
	czy_przyjeto char(1) NOT NULL CHECK(czy_przyjeto IN ('N', 'T')),
	czy_oplacone char(1) NOT NULL CHECK(czy_oplacone IN ('N', 'T')),
	opis varchar(128) NOT NULL,
	wykroczenie integer REFERENCES wykroczenia(id_wykroczenia) NOT NULL,
	id_uczestnika integer,
	id_interwencji integer,
	UNIQUE(nr_serii),
	PRIMARY KEY(id_uczestnika,id_interwencji),
	FOREIGN KEY(id_uczestnika, id_interwencji) REFERENCES formy_wymiaru_kary(id_uczestnika,id_interwencji)
);

CREATE TABLE ARESZTOWANIA(
	id_uczestnika integer,
	id_interwencji integer,
	od_kiedy DATE NOT NULL,
    do_kiedy DATE NULL,
    czy_w_zawieszeniu CHAR(1) NOT NULL CHECK ( czy_w_zawieszeniu IN ( 'N', 'T' ) ),
    PRIMARY KEY ( ID_UCZESTNIKA,ID_INTERWENCJI ),
    FOREIGN KEY(id_uczestnika,id_interwencji) REFERENCES formy_wymiaru_kary(id_uczestnika,id_interwencji)
);


create or replace view perspektywa_pojazdy_danej_osoby as 
    select osoby_pojazdy.vin,nr_rejestracyjny,badanie_techniczne,marka,pojazdy.model,rok_produkcji, czy_zarekwirowany,
    czy_poszukiwane,kolor,pesel  from pojazdy right join osoby_pojazdy on pojazdy.vin=osoby_pojazdy.vin;


create or replace view perspektywa_wyszukiwanie_informacje_ogolne_o_danej_osobie_2pola as
    select pesel, imie || ' ' || nazwisko as "Imie_i_Nazwisko" from osoby;


create or replace view perspektywa_mandaty_danej_osoby as
select pesel_uczestnika as pesel, nr_serii, kwota, zdarzenie, punkty_karne, czy_przyjeto, czy_oplacone, opis, wykroczenie
from uczestnicy_zdarzenia uz join mandaty m on uz.id_uczestnika=m.id_uczestnika;


create or replace view perspektywa_wlasciciele_pojazdu as
select vin, o.pesel as pesel, imie, nazwisko, nr_telefonu, czy_poszukiwana, nr_dowodu_osobistego, data_urodzenia
from osoby o join osoby_pojazdy op on o.pesel = op.pesel;


create or replace view perspektywa_aresztowania_danej_osoby as
select pesel_uczestnika as pesel, od_kiedy, do_kiedy, czy_w_zawieszeniu, zdarzenie
from uczestnicy_zdarzenia uz join aresztowania ar on uz.id_uczestnika=ar.id_uczestnika;

CREATE SEQUENCE  "SEKWENCJA_ID_WYKROCZENIA"  MINVALUE 1 INCREMENT BY 1 START WITH 53;
CREATE SEQUENCE  "SEKWENCJA_ID_PRAWA_JAZDY"  MINVALUE 1 INCREMENT BY 1 START WITH 165;
CREATE SEQUENCE "SEKWENCJA_ID_ZDARZENIA" MINVALUE 1 INCREMENT BY 1 START WITH 291;


create trigger wyzwalacz_pojazdy_danej_osoby_update
    instead of update on PERSPEKTYWA_POJAZDY_DANEJ_OSOBY
    for each row
begin
    delete from osoby_pojazdy where vin=:OLD.vin and pesel=:OLD.pesel;
    insert into osoby_pojazdy(vin,pesel) values (:NEW.vin,:NEW.pesel);
end;

create trigger wyzwalacz_pojazdy_danej_osoby_insert
    instead of insert on PERSPEKTYWA_POJAZDY_DANEJ_OSOBY
    for each row
begin
    insert into osoby_pojazdy(vin,pesel) values (:NEW.vin,:NEW.pesel);
end;

create or replace trigger wyzwalacz_prawa_jazdy_insert
    before insert on prawa_jazdy 
    for each row 
begin 
    :NEW.id_prawa_jazdy := sekwencja_id_prawa_jazdy.NEXTVAL; 
end;

create or replace trigger wyzwalacz_wykroczenia_insert
    before insert on wykroczenia 
    for each row 
DECLARE
    e_kwota_min_max EXCEPTION;
    PRAGMA exception_init( e_kwota_min_max, -20001 );
begin 
    :NEW.id_wykroczenia := sekwencja_id_wykroczenia.NEXTVAL; 
    IF :NEW.kwota_min > :NEW.kwota_max THEN 
        RAISE e_kwota_min_max;
    END IF;
end;

create or replace trigger wyzwalacz_zdarzenia_insert
    before insert on zdarzenia
    for each row
begin
    :NEW.id_zdarzenia := SEKWENCJA_ID_ZDARZENIA.NEXTVAL;
end;

create or replace function funkcja_zweryfikuj_vin(
    vin varchar2
) return boolean as
begin
    return not vin is NULL and lengthb(vin) = 17 and REGEXP_LIKE(vin, '^[A-Z0-9]{17}$');
end;
/


create or replace procedure silent_insert_osoby_pojazdy(
    v_vin osoby_pojazdy.VIN%TYPE, v_pesel osoby_pojazdy.pesel%TYPE
) as
begin
     insert into osoby_pojazdy(pesel,vin) values (v_pesel,v_vin);
exception
    when DUP_VAL_ON_INDEX then
        null;
end silent_insert_osoby_pojazdy;


create or replace view PERSPEKTYWA_ZDARZENIA_ILE AS
select id_zdarzenia, data_zdarzenia, wysokosc_geograficzna, szerokosc_geograficzna, opis, 
(select count(zdarzenie) from interwencje where zdarzenie=id_zdarzenia) as "Liczba_funkcjonariuszy", 
(select count(zdarzenie) from uczestnicy_zdarzenia where zdarzenie=id_zdarzenia) as "Liczba_uczestnikow"
from zdarzenia;

create or replace view PERSPEKTYWA_FUNKCJONARIUSZE as
select f.nr_odznaki, f.stopien, f.pesel, o.imie, o.nazwisko, o.nr_telefonu, o.czy_poszukiwana, o.nr_dowodu_osobistego, o.data_urodzenia, o.PESEL as "LINK" 
from funkcjonariusze f left join osoby o on f.pesel=o.pesel;

create or replace trigger wyzwalacz_pojazdy_delete
    before delete on pojazdy
    for each row
declare
    CURSOR cUbezpieczenia IS 
        SELECT nr_polisy FROM Ubezpieczenia WHERE VIN_POJAZDU=:OLD.VIN;
    CURSOR cOsoby_Pojazdy IS
        SELECT pesel,vin FROM Osoby_Pojazdy op WHERE op.VIN=:OLD.VIN;
begin
    for vUbezpieczenie in cUbezpieczenia LOOP
        delete from Ubezpieczenia where nr_polisy=vUbezpieczenie.nr_polisy;
    end LOOP;

    for vOsoby_Pojazdy in cOsoby_Pojazdy LOOP
        delete from Osoby_Pojazdy op where op.pesel=vOsoby_Pojazdy.pesel and op.vin=vOsoby_Pojazdy.vin ;
    end LOOP;
end;
/


create or replace function funkcja_zweryfikuj_pesel(
    pesel varchar2
) return boolean as
begin
    return not pesel is NULL and lengthb(pesel) = 11 and REGEXP_LIKE(pesel, '^[0-9]{11}$');
end;
/

create or replace view PERSPEKTYWA_UCZESTNICY_W_ZDARZENIU as
select id_zdarzenia,pesel, imie, nazwisko, czy_poszukiwana, rola
from (zdarzenia z join UCZESTNICY_ZDARZENIA uz on z.ID_ZDARZENIA=uz.ZDARZENIE) join osoby o on uz.pesel_uczestnika=o.pesel;

create or replace view PERSPEKTYWA_FUNKCJONARIUSZE_W_ZDARZENIU as
select f.PESEL, imie, nazwisko, nr_odznaki, stopien, data_i_czas_interwencji, id_zdarzenia
from ((zdarzenia z join interwencje i on z.id_zdarzenia=i.zdarzenie) join funkcjonariusze f on i.funkcjonariusz=f.pesel) join osoby o on f.pesel=o.pesel;


create or replace trigger wyzwalacz_mandaty_insert
before insert on mandaty
for each row
begin
    insert into formy_wymiaru_kary(	id_uczestnika, id_interwencji, typ) values (:NEW.id_uczestnika,:NEW.id_interwencji,'m');
end;

create or replace trigger wyzwalacz_mandaty_delete
after delete on mandaty
for each row
begin
    delete from formy_wymiaru_kary
    where id_uczestnika=:OLD.id_uczestnika and id_interwencji=:OLD.id_interwencji;
end;

create or replace trigger wyzwalacz_aresztowania_insert
before insert on aresztowania
for each row
begin
    insert into formy_wymiaru_kary(	id_uczestnika, id_interwencji, typ) values (:NEW.id_uczestnika,:NEW.id_interwencji,'a');
end;

create or replace trigger wyzwalacz_aresztowania_delete
after delete on aresztowania
for each row
begin
    delete from formy_wymiaru_kary
    where id_uczestnika=:OLD.id_uczestnika and id_interwencji=:OLD.id_interwencji;
end;
