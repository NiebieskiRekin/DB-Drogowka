begin
    if :P1301_FFK = 'm' then
        insert into mandaty(nr_serii,kwota,punkty_karne,czy_przyjeto,czy_oplacone,opis,wykroczenie,id_uczestnika,id_interwencji)
        values (
            :P1301_NR_SERII,
            :P1301_KWOTA,
            :P1301_PUNKTY_KARNE,
            :P1301_CZY_PRZYJETO,
            :P1301_CZY_OPLACONE,
            :P1301_OPIS,
            :P1301_WYKROCZENIE,
            :P1301_ID_UCZESTNIKA,
            :P1301_ID_INTERWENCJI
        );
    elsif :P1301_FFK = 'a' then
        insert into aresztowania(od_kiedy,do_kiedy,czy_w_zawieszeniu,id_uczestnika,id_interwencji)
        values (
            :P1301_OD_KIEDY,
            :P1301_DO_KIEDY,
            :P1301_CZY_W_ZAWIESZENIU,
            :P1301_ID_UCZESTNIKA,
            :P1301_ID_INTERWENCJI
        );
    else
        insert into formy_wymiaru_kary(typ,id_uczestnika,id_interwencji)
        values (
            'p',
            :P1301_ID_UCZESTNIKA,
            :P1301_ID_INTERWENCJI
        );
    end if;
end;
