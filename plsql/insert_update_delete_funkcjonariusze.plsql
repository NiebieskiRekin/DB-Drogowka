insert into perspektywa_funkcjonariusze(pesel,nr_odznaki,stopien,imie,nazwisko,nr_telefonu,czy_poszukiwana,nr_dowodu_osobistego,data_urodzenia) 
values (:P1501_PESEL_NEW,:P1501_NR_ODZNAKI,:P1501_STOPIEN,:P1501_IMIE,:P1501_NAZWISKO,:P1501_NR_TELEFONU,:P1501_CZY_POSZUKIWANA,:P1501_NR_DOWODU_OSOBISTEGO,:P1501_DATA_URODZENIA);

update perspektywa_funkcjonariusze
    set pesel=:P1501_PESEL_NEW,
            nr_odznaki=:P1501_NR_ODZNAKI,
            stopien=:P1501_STOPIEN,
            imie=:P1501_IMIE,
            nazwisko=:P1501_NAZWISKO,
            nr_telefonu=:P1501_NR_TELEFONU,
            czy_poszukiwana=:P1501_CZY_POSZUKIWANA,
            nr_dowodu_osobistego=:P1501_NR_DOWODU_OSOBISTEGO,
            data_urodzenia=:P1501_DATA_URODZENIA
where pesel=:P1501_PESEL;

delete from perspektywa_funkcjonariusze
where pesel=:P1501_PESEL;
