import datetime
import faker
import random
from typing import Callable

# Create Faker instance
faker.Faker.seed(0)
fake = faker.Faker("pl_PL")


n = 30

wysokosc = (51.109720, 54.126880)
szerokosc = (15.137242, 22.752077)

opisy = []
with open("opisy-zdarzen.txt", "r") as f:
    opisy = list(map(str.strip, f.readlines()))

zdarzenie_unique = set()


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


def gen_zdarzenia(i, null_parser):
    np = null_parser
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
    return f"'{id_zdarzenia}', '{us_date(data_zdarzenia)}', '{wysokosc_geograficzna}', '{szerokosc_geograficzna}', {np(opis)}\n"


insert_csv(
    "id_zdarzenia,data_zdarzenia,wysokosc_geograficzna,szerokosc_geograficzna,opis",
    gen_zdarzenia,
    n,
)
