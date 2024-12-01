import random
from typing import List

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


pesel_set = list()


def osoby_filter(row: List[str]):
    pesel_set.append(row[0])


csv_reader("Osoby/output.csv", osoby_filter)


n = len(pesel_set)

kategorie = [
    "AM",
    "A1",
    "A2",
    "A",
    "B1",
    "B",
    "B+E",
    "C",
    "C1",
    "C1+E",
    "C+E",
    "D",
    "D1",
    "D1+E",
    "D+E",
    "T",
    "Tramwaj",
]


def gen_prawa_jazdy(i):
    np = print_csv_null
    pesel = pesel_set[i]
    liczba_uprawnien = gen_with_distribution([0, 1, 2, 3], [0.2, 0.5, 0.2, 0.1])
    uprawnienia = random.sample(kategorie, liczba_uprawnien)
    out = ""

    for kategoria in uprawnienia:
        od_kiedy = fake.date_between(start_date="-20y")
        do_kiedy = fake.date_between(start_date=od_kiedy, end_date="+10y")
        out += (
            f"{i},'{kategoria}','{us_date(od_kiedy)}','{us_date(do_kiedy)}','{pesel}'\n"
        )
    return out


insert_csv(
    "id_prawa_jazdy,kategoria,od_kiedy,do_kiedy,PESEL",
    gen_prawa_jazdy,
    n,
    "Prawa_Jazdy/output.csv",
)
