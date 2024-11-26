import faker
import random
from typing import Callable
import csv

vin_set = list()
with open("../Pojazdy/output.csv", newline="") as csvfile:
    pojazdy_reader = csv.reader(csvfile, delimiter=",", quotechar="'")
    first_row = next(pojazdy_reader)
    for row in pojazdy_reader:
        vin_set.append(row[0])


pesel_set = list()
with open("../Osoby/output.csv", newline="") as csvfile:
    osoby_reader = csv.reader(csvfile, delimiter=",", quotechar="'")
    first_row = next(osoby_reader)
    for row in osoby_reader:
        pesel_set.append(row[0])

n = len(vin_set)
random.shuffle(vin_set)

# Create Faker instance
faker.Faker.seed(0)
random.seed(0)
fake = faker.Faker("pl_PL")


def gen_unique(f, s: set):
    while (temp := f()) in s:
        continue
    s.add(temp)
    return temp


def gen_with_distribution(population, weights):
    chosen = random.choices(population, weights)
    if isinstance(chosen, Callable) and not isinstance(chosen, object):
        chosen = chosen()
    return chosen[0]


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


def gen_osoby_pojazdy(i, null_wrapper):
    out = ""

    num_person_per_veh = gen_with_distribution([1, 2, 3], [0.8, 0.19, 0.01])
    vin = vin_set[i]
    wspolwlasciciele = set()
    for _ in range(num_person_per_veh):
        pesel = gen_unique(lambda: random.choice(pesel_set), wspolwlasciciele)
        wspolwlasciciele.add(pesel)
        out += f"'{vin}', '{pesel}'\n"

    return out


insert_csv(
    "vin,pesel",
    gen_osoby_pojazdy,
    n,
)
