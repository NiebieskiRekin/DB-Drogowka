import datetime
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


curr_id_interwencji = 0
zdarzenia_set = []
funkcjonariusze_set = []


def zdarzenia_filter(row: List[str]):
    zdarzenia_set.append((row[0], row[1]))


csv_reader("Zdarzenia/output.csv", zdarzenia_filter)

n = len(zdarzenia_set)
random.shuffle(zdarzenia_set)


def funkcjonariusze_filter(row: List[str]):
    funkcjonariusze_set.append(row[2])


csv_reader("Funkcjonariusze/output.csv", funkcjonariusze_filter)


def gen_id_interwencji():
    global curr_id_interwencji
    curr_id_interwencji += 10
    return curr_id_interwencji


def gen_interwencji(i):
    id_zdarzenia = zdarzenia_set[i][0]

    num_interwencji_per_zdarzenie = gen_with_distribution([1, 2, 3], [0.2, 0.7, 0.1])
    funkcjonariusze_zdarzenia = set()

    month, day, year = tuple(map(int, zdarzenia_set[i][1].replace("'", "").split("-")))
    that_day_00 = datetime.datetime(year, month, day, hour=0, minute=0)
    that_day_plus6 = that_day_00 + datetime.timedelta(days=1, hours=6)
    data_i_czas_pierwszej_interwencji = fake.date_time_between(
        start_date=that_day_00, end_date=that_day_plus6
    )
    out = ""

    for _ in range(num_interwencji_per_zdarzenie):
        id_interwencji = gen_id_interwencji()
        data_i_czas_interwencji = gen_with_distribution(
            [
                fake.date_time_between(
                    start_date=data_i_czas_pierwszej_interwencji
                    - datetime.timedelta(hours=1),
                    end_date=data_i_czas_pierwszej_interwencji
                    - datetime.timedelta(hours=1),
                ),
                data_i_czas_pierwszej_interwencji,
            ],
            [0.5, 0.5],
        )
        funkcjonariusz = gen_unique(
            lambda: random.choice(funkcjonariusze_set), funkcjonariusze_zdarzenia
        )
        out += f"{id_interwencji},'{datetime.datetime.strftime(data_i_czas_interwencji,"%Y-%m-%d %H:%M:%S")}','{funkcjonariusz}',{id_zdarzenia}\n"

    return out


insert_csv(
    "id_interwencji,data_i_czas_interwencji,funkcjonariusz,zdarzenie",
    gen_interwencji,
    n,
    "Interwencje/output.csv",
)
