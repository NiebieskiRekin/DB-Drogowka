CREATE TABLE POJAZDY (
    VIN CHAR(17) PRIMARY KEY,
    NR_REJESTRACYJNY VARCHAR(8) UNIQUE,
    BADANIE_TECHNICZNE DATE NOT NULL,
    MARKA VARCHAR(32) NOT NULL,
    MODEL VARCHAR(32) NOT NULL,
    ROK_PRODUKCJI INTEGER NOT NULL,
    CZY_ZAREKWIROWANY CHAR(1) DEFAULT (0) NOT NULL CHECK ( CZY_ZAREKWIROWANY IN ( 'N', 'T' ) ),
    CZY_POSZUKIWANE CHAR(1) DEFAULT (0) NOT NULL CHECK ( CZY_POSZUKIWANE IN ( 'N', 'T' ) ),
    KOLOR VARCHAR(32) NULL
);

CREATE TABLE UBEZPIECZENIA (
    NR_POLISY VARCHAR(10) ,
    DATA_WAZNOSCI DATE NOT NULL,
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
	czy_poszukiwana char(1) DEFAULT (0) NOT NULL CHECK ( czy_poszukiwana IN ( 'N', 'T' )),
	nr_dowodu_osobistego char(9) NULL,
	data_urodzenia DATE NULL
);

CREATE TABLE OSOBY_POJAZDY(
  id integer primary key,
	vin char(17) not null REFERENCES pojazdy(vin),
	pesel char(11) not null REFERENCES osoby(pesel),
  UNIQUE(PESEL,VIN)
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



