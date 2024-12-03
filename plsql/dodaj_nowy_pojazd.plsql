-- to jest przy dodawaniu nowego pojazdu
DECLARE
  pesele   apex_t_number;
  v_pesel     osoby.PESEL%TYPE;
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
END;

