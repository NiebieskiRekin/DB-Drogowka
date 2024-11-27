import datetime
import faker
import random
from typing import Callable
import csv

# Create Faker instance
faker.Faker.seed(0)
fake = faker.Faker("pl_PL")


curr_id_uczestnika = 0
zdarzenia_set = []
role_set = []
pesel_set = []

with open("../Zdarzenia/output.csv", newline="") as csvfile:
    zdarzenia_reader = csv.reader(csvfile, delimiter=",", quotechar="'")
    first_row = next(zdarzenia_reader)
    for row in zdarzenia_reader:
        zdarzenia_set.append((row[0], row[1]))

with open("../Role_Zdarzenia/output.csv", newline="") as csvfile:
    role_reader = csv.reader(csvfile, delimiter=",", quotechar="'")
    first_row = next(role_reader)
    for row in role_reader:
        role_set.append(row[0])

with open("../Osoby/output.csv", newline="") as csvfile:
    pesel_reader = csv.reader(csvfile, delimiter=",", quotechar="'")
    first_row = next(pesel_reader)
    for row in pesel_reader:
        pesel_set.append(row[0])

n = len(zdarzenia_set)
random.shuffle(zdarzenia_set)


def gen_id_uczestnika():
    global curr_id_uczestnika
    curr_id_uczestnika += 10
    return curr_id_uczestnika


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


def gen_uczestnicy(i, null_parser):
    np = null_parser
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
)
