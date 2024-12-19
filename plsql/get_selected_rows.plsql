select listagg(PESEL,':')  into :P1011_PESEL_SELECTED from osoby_pojazdy where vin=:P1011_VIN_SELECTED;
