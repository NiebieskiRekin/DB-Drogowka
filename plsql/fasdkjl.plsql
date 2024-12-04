  create or replace procedure procedura_przypisz_osoby_do_nowego_pojazdu(
    pesele   apex_t_number;
    v_pesel     osoby.PESEL%TYPE;
      
  ) as
  BEGIN
    SAVEPOINT start_tran;
    -- Turn the ':' delimited string into a PL/SQL Array.
    pesele := apex_string.split_numbers(:P1104_PESEL_SELECTED,':');
    INSERT INTO POJAZDY(VIN, NR_REJESTRACYJNY,BADANIE_TECHNICZNE,MARKA, MODEL, ROK_PRODUKCJI, CZY_POSZUKIWANE, CZY_ZAREKWIROWANY, KOLOR)
      values
      (:P1104_VIN_SELECTED, :P1104_NR_REJESTRACYJNY, :P1104_BADANIE_TECHNICZNE, :P1104_MARKA, :P1104_MODEL, :P1104_ROK_PRODUKCJI,
      :P1104_CZY_POSZUKIWANE, :P1104_CZY_ZAREKWIROWANY, :P1104_KOLOR);
    -- Loop through the PL/SQL Array.
    FOR i IN 1..pesele.COUNT() LOOP
      v_pesel := pesele(i);
      INSERT INTO OSOBY_POJAZDY(vin,pesel) values (:P1104_VIN_SELECTED, v_pesel);
    end loop;
  end procedura_przypisz_osoby_do_nowego_pojazdu;
  /

  
  create or replace procedure procedura_przypisz_osoby_do_istniejacego_pojazdu(
    pesele   apex_t_number;
    v_pesel     osoby.PESEL%TYPE;
  ) as
 BEGIN
    SAVEPOINT start_tran;
    -- Turn the ':' delimited string into a PL/SQL Array.
    pesele := apex_string.split_numbers(:P1011_PESEL_SELECTED,':');
    delete from osoby_pojazdy where vin=:P1011_VIN_SELECTED;
    -- Loop through the PL/SQL Array.
    FOR i IN 1..pesele.COUNT() LOOP
      v_pesel := pesele(i);
      silent_insert_osoby_pojazdy(:P1011_VIN_SELECTED,v_pesel);
    end loop;
  END procedura_przypisz_osoby_do_istniejacego_pojazdu;

