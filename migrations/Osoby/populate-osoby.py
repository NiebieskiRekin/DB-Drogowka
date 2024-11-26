import faker
import datetime
import random

# Create Faker instance
faker.Faker.seed(0)
fake = faker.Faker("pl_PL")
# pesel_gen = faker.providers.ssn.pl_PL.Provider()
pesel_pk = set()

n = 100


def insert_query(table_name, cols, gen, n):
    for i in range(n):
        print(f"INSERT INTO {table_name}({cols}) VALUES")
        print(f"({gen(i + 1,print_null)})", end=";\n")


def insert_csv(table_name, cols, gen, n):
    print(cols)
    for i in range(n):
        print(f"{gen(i + 1,print_csv_null)}", end="\n")


def print_csv_null(v):
    if v is None:
        return ""
    return f"'{v}'"


def print_null(v):
    if v is None:
        return "null"
    return f"'{v}'"


def gen_osoby(i, null_parser):
    np = null_parser
    data_ur = (
        fake.date_between(start_date="-70y", end_date="-18y")
        if random.randint(1, 100) > 30
        else None
    )
    pesel = fake.pesel(date_of_birth=data_ur)
    while pesel in pesel_pk:
        pesel = fake.pesel(date_of_birth=data_ur)
    pesel_pk.add(pesel)
    imie = fake.first_name()
    nazwisko = fake.last_name()
    nr_telefonu = (
        random.randint(100_000_000, 999_999_999)
        if random.randint(1, 100) > 80
        else None
    )
    czy_poszukiwana = "T" if random.randint(1, 100) > 99 else "N"
    nr_dowodu_osobistego = fake.identity_card_number()
    if data_ur is not None:
        data_ur = datetime.date.strftime(data_ur, "%m-%d-%Y")
    return f"'{pesel}', '{imie}', '{nazwisko}', {np(nr_telefonu)}, '{czy_poszukiwana}', {np(nr_dowodu_osobistego)}, {np(data_ur)}"


insert_csv(
    "osoby",
    "PESEL,imie,nazwisko,nr_telefonu,czy_poszukiwana,nr_dowodu_osobistego,data_urodzenia",
    gen_osoby,
    n,
)
