import faker
import random
from typing import Callable, List
import csv
import string
from common import (
    gen_unique,
    gen_with_distribution,
    insert_csv,
    wrap_str,
    print_csv_null,
    us_date,
    fake,
    csv_reader,
    randomword,
)


formy_wymiaru_kary_set = []


def formy_wymiaru_kary_filter(row: List[str]):
    if row[2] == "m":
        formy_wymiaru_kary_set.append(row[:2])


csv_reader("Formy_Wymiaru_Kary/output.csv", formy_wymiaru_kary_filter)

wykroczenia_set = []


def wykroczenia_filter(row: List[str]):
    wykroczenia_set.append((row[0], *row[3:6]))


csv_reader("Wykroczenia/output.csv", wykroczenia_filter)

nr_serii_unique = set()
n = len(formy_wymiaru_kary_set)
random.shuffle(formy_wymiaru_kary_set)


def gen_mandaty(i):
    ffk = formy_wymiaru_kary_set[i]
    id_uczestnika = ffk[0]
    id_interwencji = ffk[1]
    nr_serii = gen_unique(
        lambda: randomword(string.digits + string.ascii_uppercase, 16), nr_serii_unique
    )

    czy_przyjeto = gen_with_distribution(["T", "N"], [0.9, 0.1])
    czy_oplacone = "N"
    if czy_przyjeto == "T":
        czy_oplacone = gen_with_distribution(["T", "N"], [0.5, 0.5])
    wykroczenie, kwota_min, kwota_max, punkty = random.choice(wykroczenia_set)
    opis = wykroczenie
    kwota = random.randint(int(kwota_min), int(kwota_max))

    return f"'{nr_serii}',{kwota},{punkty},'{czy_przyjeto}','{czy_oplacone}','{opis}',{wykroczenie},{id_uczestnika},{id_interwencji}\n"


insert_csv(
    "nr_serii,kwota,punkty_karne,czy_przyjeto,czy_oplacone,opis,wykroczenie,id_uczestnika,id_interwencji",
    gen_mandaty,
    n,
    "Mandaty/output.csv",
)
