begin
    update osoby
    set pesel=:P1003_PESEL,
            imie=:P1003_IMIE,
            nazwisko=:P1003_NAZWISKO,
            nr_telefonu=:P1003_NR_TELEFONU,
            czy_poszukiwana=:P1003_CZY_POSZUKIWANA,
            NR_DOWODU_OSOBISTEGO=:P1003_NR_DOWODU_OSOBISTEGO,
            data_urodzenia=:P1003_DATA_URODZENIA
    where pesel=:P1003_CURRENT_PESEL;
end;

