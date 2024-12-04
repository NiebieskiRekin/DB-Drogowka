-- this is just age() from postgres
CREATE OR REPLACE FUNCTION calculate_age (
    d1 IN DATE, 
    d2 IN DATE
) RETURN INTERVAL YEAR TO MONTH IS
    v_months_diff NUMBER;
    v_years NUMBER;
    v_months NUMBER;
    v_interval INTERVAL YEAR TO MONTH;
BEGIN
    v_months_diff := MONTHS_BETWEEN(d2, d1);
    v_years := TRUNC(v_months_diff / 12);
    v_months := MOD(TRUNC(v_months_diff), 12);
    
    v_interval := NUMTOYMINTERVAL(v_years, 'YEAR') +NUMTOYMINTERVAL(v_months, 'MONTH') ;
    RETURN v_interval;
END calculate_age;
/
