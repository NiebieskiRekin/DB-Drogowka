import faker
import random
from typing import Callable, List
import csv

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


vin_set = list()


def pojazdy_filter(row: List[str]):
    vin_set.append(row[0])


csv_reader("Pojazdy/output.csv", pojazdy_filter)


pesel_set = list()


def osoby_filter(row: List[str]):
    pesel_set.append(row[0])


csv_reader("Osoby/output.csv", osoby_filter)


n = len(vin_set)
random.shuffle(vin_set)


def gen_osoby_pojazdy(i):
    out = ""

    num_person_per_veh = gen_with_distribution([1, 2, 3], [0.8, 0.19, 0.01])
    vin = vin_set[i]
    wspolwlasciciele = set()
    for _ in range(num_person_per_veh):
        pesel = gen_unique(lambda: random.choice(pesel_set), wspolwlasciciele)
        wspolwlasciciele.add(pesel)
        out += f"{i},'{vin}','{pesel}'\n"

    return out


insert_csv("i,vin,pesel", gen_osoby_pojazdy, n, "Osoby_Pojazdy/output.csv")
