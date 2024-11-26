import faker
from faker_vehicle import VehicleProvider
import datetime
import random
from typing import Callable

# Create Faker instance
faker.Faker.seed(0)
fake = faker.Faker("pl_PL")
fake.add_provider(VehicleProvider)

# pesel_gen = faker.providers.ssn.pl_PL.Provider()
vin_pk = set()
nr_rejestracyjny_unique = set()

n = 100


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


def insert_query(table_name, cols, gen, n):
    for i in range(n):
        print(f"INSERT INTO {table_name}({cols}) VALUES")
        print(f"({gen(i + 1,print_null)})", end=";\n")


def insert_csv(cols, gen, n):
    print(cols)
    for i in range(n):
        print(f"{gen(i + 1,print_csv_null)}", end="\n")


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


def gen_pojazdy(i, null_parser):
    np = null_parser
    vin = gen_unique(fake.vin, vin_pk)
    nr_rejestracyjny = gen_unique(fake.license_plate, nr_rejestracyjny_unique).replace(
        " ", ""
    )
    badanie_techniczne = fake.date_between(start_date="-5d", end_date="+1y")
    vehicle = fake.vehicle_object()
    marka = vehicle["Make"]
    model = vehicle["Model"]
    rok_produkcji = vehicle["Year"]
    czy_zarekwirowany = gen_with_distribution(["T", "N"], [0.05, 0.95])
    czy_poszukiwane = gen_with_distribution(["T", "N"], [0.035, 1 - 0.035])
    kolor = random.choice(["niebieski", "czerwony", "czarny", "biały", "szary", None])
    return f"'{vin}', '{nr_rejestracyjny}', '{us_date(badanie_techniczne)}', '{marka}', '{model}', {rok_produkcji}, '{czy_zarekwirowany}', '{czy_poszukiwane}', {np(kolor)}"


insert_csv(
    "vin,nr_rejestracyjny,badanie_techniczne,marka,model,rok_produkcji,czy_zarekwirowany,czy_poszukiwane,kolor",
    gen_pojazdy,
    n,
)
