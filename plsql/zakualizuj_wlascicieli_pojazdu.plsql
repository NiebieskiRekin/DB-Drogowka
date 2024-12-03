-- to jest w tabeli osoby_pojazdy
DECLARE
  pesele   apex_t_number;
  v_pesel     osoby.PESEL%TYPE;
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
END;


