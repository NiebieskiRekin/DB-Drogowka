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
    VIN_POJAZDU CHAR(17),
    NR_REJESTRACYJNY_POJAZDU VARCHAR(8),
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
	data_urodzenia DATE NOT NULL
);

CREATE TABLE Osoby_Pojazdy(
	PESEL CHAR(11) REFERENCES OSOBY(Pesel),
	VIN CHAR(17) REFERENCES POJAZDY(vin),
    PRIMARY KEY(PESEL,VIN)
);

CREATE TABLE prawa_jazdy(
	kategoria varchar(7),
	od_kiedy DATE,
	do_kiedy DATE NOT NULL,
	PESEL char(11) REFERENCES osoby(pesel),
	PRIMARY KEY(kategoria,od_kiedy,pesel)
);

CREATE TABLE Funkcjonariusze(
	nr_odznaki varchar(16) NOT NULL,
	stopien varchar(32) NOT NULL,
	pesel char(11) REFERENCES osoby(pesel) PRIMARY KEY
);

CREATE TABLE zdarzenia(
	id_zdarzenia integer PRIMARY KEY,
	data_zdarzenia DATE,
	miejsce varchar(128),
	opis varchar(128) NULL,
	UNIQUE(data_zdarzenia,miejsce)
);

CREATE TABLE interwencje(
	id_interwencji integer PRIMARY KEY,
	data_i_czas_interwencji timestamp NOT NULL,
	funkcjonariusz char(11) REFERENCES Funkcjonariusze(pesel),
	zdarzenie integer REFERENCES zdarzenia(id_zdarzenia),
	UNIQUE(funkcjonariusz,zdarzenie)
);

CREATE TABLE role_zdarzenia(
	rola varchar(32) PRIMARY KEY
);

CREATE TABLE uczestnicy_zdarzen(
	id_uczestnika integer PRIMARY KEY,
	rola varchar(32) REFERENCES role_zdarzenia(rola),
	pesel_uczestnika char(11) REFERENCES osoby(pesel),
	zdarzenie integer REFERENCES zdarzenia(id_zdarzenia),
	UNIQUE(rola,pesel_uczestnika,zdarzenie)
);

CREATE TABLE wykroczenia(
	nazwa varchar(128) PRIMARY KEY,
	punkty_karne integer NOT NULL CHECK(punkty_karne BETWEEN 0 AND 15),
	stawka_minimalna NUMBER NOT NULL,
	stawka_maksymalna NUMBER NOT NULL,
	ustawa varchar(32) NULL
);

CREATE TABLE formy_wymiaru_kary(
	id_uczestnika integer REFERENCES uczestnicy_zdarzen(id_uczestnika),
	id_interwencji integer REFERENCES interwencje(id_interwencji),
	typ char(1) NOT NULL CHECK(typ IN ('m', 'a', 'p')),
	PRIMARY KEY(id_uczestnika,id_interwencji)
);

CREATE TABLE mandaty(
	nr_serii varchar(16) NOT NULL,
	kwota NUMBER CHECK(kwota BETWEEN 0 AND 6000) NOT NULL,
	punkty_karne integer NOT NULL,
	czy_przyjeto char(1) NOT NULL CHECK(czy_przyjeto IN ('N', 'T')),
	czy_oplacone char(1) NOT NULL CHECK(czy_oplacone IN ('N', 'T')),
	opis varchar(128) NOT NULL,
	wykroczenie varchar(128) REFERENCES wykroczenia(nazwa) NOT NULL,
	id_uczestnika integer,
	id_interwencji integer,
	UNIQUE(nr_serii),
	PRIMARY KEY(id_uczestnika,id_interwencji),
	FOREIGN KEY(id_uczestnika, id_interwencji) REFERENCES formy_wymiaru_kary(id_uczestnika,id_interwencji)
);

CREATE TABLE aresztowania(
	id_uczestnika integer,
	id_interwencji integer,
	od_kiedy DATE NOT NULL,
    DO_KIEDY DATE NULL,
    CZY_W_ZAWIESZENIU CHAR(1) NOT NULL CHECK ( CZY_W_ZAWIESZENIU IN ( 'N', 'T' ) ),
    PRIMARY KEY ( ID_UCZESTNIKA,ID_INTERWENCJI ),
    FOREIGN KEY(id_uczestnika,id_interwencji) REFERENCES formy_wymiaru_kary(id_uczestnika,id_interwencji)
);



