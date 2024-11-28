import faker
from faker_vehicle import VehicleProvider
import datetime
import random
from typing import Callable

from common import (
    gen_unique,
    gen_with_distribution,
    insert_csv,
    wrap_str,
    print_csv_null,
    us_date,
    fake,
    csv_reader,
)

fake.add_provider(VehicleProvider)

vin_pk = set()
nr_rejestracyjny_unique = set()

n = 100


def gen_pojazdy(
    i,
):
    np = print_csv_null
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
    return f"'{vin}','{nr_rejestracyjny}','{us_date(badanie_techniczne)}','{marka}','{model}',{rok_produkcji},'{czy_zarekwirowany}','{czy_poszukiwane}',{np(kolor)}\n"


insert_csv(
    "vin,nr_rejestracyjny,badanie_techniczne,marka,model,rok_produkcji,czy_zarekwirowany,czy_poszukiwane,kolor",
    gen_pojazdy,
    n,
    "Pojazdy/output.csv",
)
