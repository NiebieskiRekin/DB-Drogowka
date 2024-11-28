import string
import faker
import random
import csv
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
    cleanup,
    randomword,
)

pesel_set = []


def osoby_filter(row: List[str]):
    pesel_set.append(row[0])


csv_reader("Osoby/output.csv", osoby_filter)

n = len(pesel_set) // 10

random.shuffle(pesel_set)
nr_odznaki_unique = set()
stopnie_policyjne = [
    "posterunkowy",
    "starszy posterunkowy",
    "sierżant",
    "starszy sierżant",
    "sierżant sztabowy",
    "młodszy aspirant",
    "aspirant",
    "starszy aspirant",
    "aspirant sztabowy",
    "podkomisarz",
    "komisarz",
    "nadkomisarz",
    "podinspektor",
    "młodszy inspektor",
    "inspektor",
    "nadinspektor",
    "generalny inspektor",
]


def gen_funkcjonariusze(i):
    pesel = pesel_set[i]
    stopien = random.choice(stopnie_policyjne)
    nr_odznaki = gen_unique(lambda: randomword(string.digits, 16), nr_odznaki_unique)
    return f"'{nr_odznaki}','{stopien}','{pesel}'\n"


insert_csv(
    "nr_odznaki,stopien,pesel", gen_funkcjonariusze, n, "Funkcjonariusze/output.csv"
)
