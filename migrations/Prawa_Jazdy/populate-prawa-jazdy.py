import datetime
import faker
import random
from typing import Callable
import csv

# Create Faker instance
faker.Faker.seed(0)
fake = faker.Faker("pl_PL")

pesel_set = list()
with open("../Osoby/output.csv", newline="") as csvfile:
    osoby_reader = csv.reader(csvfile, delimiter=",", quotechar="'")
    first_row = next(osoby_reader)
    for row in osoby_reader:
        pesel_set.append(row[0])

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


def gen_unique(f, s: set):
    while (temp := f()) in s:
        continue
    s.add(temp)
    return temp


def gen_with_distribution(population, weights):
    chosen = random.choices(population, weights)[0]
    if isinstance(chosen, Callable):
        return chosen()
    return chosen


def insert_csv(cols, gen, n):
    print(cols)
    for i in range(n):
        print(f"{gen(i,print_csv_null)}", end="")


def wrap_str(x):
    return f"'{x}'"


def print_csv_null(v, wrapper=wrap_str):
    if v is None:
        return ""
    return wrapper(v)


def print_null(v, wrapper=wrap_str):
    if v is None:
        return "null"
    return wrapper(v)


def insert_query(table_name, cols, gen, n):
    for i in range(n):
        print(f"INSERT INTO {table_name}({cols}) VALUES")
        print(f"({gen(i + 1,print_null)})", end=";\n")


def us_date(d):
    return datetime.date.strftime(d, "%m-%d-%Y")


def gen_prawa_jazdy(i, null_parser):
    np = null_parser
    pesel = pesel_set[i]
    liczba_uprawnien = gen_with_distribution([0, 1, 2, 3], [0.2, 0.5, 0.2, 0.1])
    uprawnienia = random.sample(kategorie, liczba_uprawnien)
    out = ""

    for kategoria in uprawnienia:
        od_kiedy = fake.date_between(start_date="-20y")
        do_kiedy = fake.date_between(start_date=od_kiedy, end_date="+10y")
        out += (
            f"'{kategoria}', '{us_date(od_kiedy)}', '{us_date(do_kiedy)}', '{pesel}'\n"
        )
    return out


insert_csv(
    "kategoria,od_kiedy,do_kiedy,PESEL",
    gen_prawa_jazdy,
    n,
)
