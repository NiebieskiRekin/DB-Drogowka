import random
from typing import List
from common import (
    gen_unique,
    gen_with_distribution,
    insert_csv,
    csv_reader,
)

curr_id_uczestnika = 0
zdarzenia_set = []
role_set = []


def zdarzenia_filter(row: List[str]):
    zdarzenia_set.append((row[0], row[1]))


csv_reader("Zdarzenia/output.csv", zdarzenia_filter)


def role_zdarzenia_filter(row: List[str]):
    role_set.append(row[0])


csv_reader("Role_Zdarzenia/output.csv", role_zdarzenia_filter)

pesel_set = list()


def osoby_filter(row: List[str]):
    pesel_set.append(row[0])


csv_reader("Osoby/output.csv", osoby_filter)


n = len(zdarzenia_set)
random.shuffle(zdarzenia_set)


def gen_id_uczestnika():
    global curr_id_uczestnika
    curr_id_uczestnika += 10
    return curr_id_uczestnika


def gen_uczestnicy(i):
    id_zdarzenia = zdarzenia_set[i][0]

    num_uczestnikow_per_zdarzenie = gen_with_distribution(
        [1, 2, 3, 4, 5], [0.2, 0.6, 0.1, 0.05, 0.5]
    )
    uczestnicy_zdarzenia = set()

    out = ""

    for _ in range(num_uczestnikow_per_zdarzenie):
        id_uczestnika = gen_id_uczestnika()
        rola = random.choice(role_set)
        uczestnik = gen_unique(lambda: random.choice(pesel_set), uczestnicy_zdarzenia)
        out += f"{id_uczestnika},'{rola}','{uczestnik}',{id_zdarzenia}\n"

    return out


insert_csv(
    "id_uczestnika,rola,pesel_uczestnika,zdarzenie",
    gen_uczestnicy,
    n,
    "Uczestnicy_Zdarzenia/output.csv",
)
