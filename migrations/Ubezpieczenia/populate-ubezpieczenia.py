import faker
import datetime
import random
import string
from typing import Callable
import csv

vin_set = list()
with open("../Pojazdy/output.csv", newline="") as csvfile:
    pojazdy_reader = csv.reader(csvfile, delimiter=",", quotechar="'")
    first_row = next(pojazdy_reader)
    for row in pojazdy_reader:
        vin_set.append(row[0])

# Create Faker instance
faker.Faker.seed(0)
random.seed(0)
fake = faker.Faker("pl_PL")

nr_polisy_pk = set()

n = len(vin_set)
random.shuffle(vin_set)


def us_date(d):
    return datetime.date.strftime(d, "%m-%d-%Y")


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


def randomword(length):
    letters = string.ascii_uppercase + string.digits
    return "".join(random.choice(letters) for i in range(length))


def gen_pojazdy(i, null_parser):
    np = null_parser

    vin = vin_set[i]

    out = ""
    for typ in ["OC", "AC"]:
        nr_polisy = gen_unique(lambda: randomword(10), nr_polisy_pk)
        data_waznosci = fake.date_between(start_date="-5d", end_date="+1y")
        firma = random.choice(
            [
                "PZU",
                "Ergo Hestia",
                "Warta",
                "PROAMA",
                "Uniqa",
                "InterRisk",
                "Uniqa",
                "Allianz",
                "TU Inter Polska",
                "Link4",
                "Balcia",
                "TUZ",
                "EuroIns",
                "MTU",
                "Benefia",
                "HDI",
                "Generali",
                "Compensa",
                "Wiener",
            ]
        )

        out += f"'{nr_polisy}', '{us_date(data_waznosci)}', '{typ}', {np(firma)}, '{vin}'\n"
    return out


insert_csv(
    "nr_polisy,data_waznosci,typ,firma,vin_pojazdu",
    gen_pojazdy,
    n,
)
