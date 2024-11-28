import datetime
import string

from common import (
    gen_unique,
    gen_with_distribution,
    insert_csv,
    randomword,
    wrap_str,
    print_csv_null,
    us_date,
    fake,
    csv_reader,
)


pesel_pk = set()

n = 100


def gen_osoby(i):
    np = print_csv_null
    data_ur: datetime.datetime | None = gen_with_distribution(
        [fake.date_between(start_date="-70y", end_date="-18y"), None], [0.7, 0.3]
    )
    pesel = gen_unique(lambda: fake.pesel(date_of_birth=data_ur), pesel_pk)
    imie = fake.first_name()
    nazwisko = fake.last_name()
    nr_telefonu = gen_with_distribution(
        [randomword(string.digits, 9), None], [0.2, 0.8]
    )
    czy_poszukiwana = gen_with_distribution(["T", "N"], [0.01, 0.99])
    nr_dowodu_osobistego = fake.identity_card_number()
    return f"'{pesel}','{imie}','{nazwisko}',{np(nr_telefonu)},'{czy_poszukiwana}',{np(nr_dowodu_osobistego)},{np(data_ur,us_date)}\n"


insert_csv(
    "PESEL,imie,nazwisko,nr_telefonu,czy_poszukiwana,nr_dowodu_osobistego,data_urodzenia",
    gen_osoby,
    n,
    "Osoby/output.csv",
)
