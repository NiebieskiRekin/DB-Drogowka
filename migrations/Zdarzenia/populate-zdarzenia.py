import random
from typing import Callable

from common import (
    gen_unique,
    gen_with_distribution,
    insert_csv,
    wrap_str,
    print_csv_null,
    us_date,
    fake,
    csv_reader,
)


n = 30

wysokosc = (51.109720, 54.126880)
szerokosc = (15.137242, 22.752077)

opisy = []
with open("Zdarzenia/opisy-zdarzen.txt", "r") as f:
    opisy = list(map(str.strip, f.readlines()))

zdarzenie_unique = set()


def gen_zdarzenia(i):
    np = print_csv_null
    id_zdarzenia = i * 10
    temp = gen_unique(
        lambda: (
            fake.date_between(start_date="-1y"),
            random.uniform(*wysokosc),
            random.uniform(*szerokosc),
        ),
        zdarzenie_unique,
    )
    data_zdarzenia = temp[0]
    wysokosc_geograficzna = temp[1]
    szerokosc_geograficzna = temp[2]

    opis = random.choice(opisy)
    return f"'{id_zdarzenia}','{us_date(data_zdarzenia)}','{wysokosc_geograficzna}','{szerokosc_geograficzna}',{np(opis)}\n"


insert_csv(
    "id_zdarzenia,data_zdarzenia,wysokosc_geograficzna,szerokosc_geograficzna,opis",
    gen_zdarzenia,
    n,
    "Zdarzenia/output.csv",
)
