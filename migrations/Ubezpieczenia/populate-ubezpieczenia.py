import faker
import datetime
import random
import string
from typing import Callable, List
import csv

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

vin_set = list()


def pojazdy_filter(row: List[str]):
    vin_set.append(row[0])


csv_reader("Pojazdy/output.csv", pojazdy_filter)


# Create Faker instance
nr_polisy_pk = set()

n = len(vin_set)
random.shuffle(vin_set)


def gen_pojazdy(i):
    np = print_csv_null

    vin = vin_set[i]

    out = ""
    for typ in ["OC", "AC"]:
        nr_polisy = gen_unique(
            lambda: randomword(string.ascii_uppercase + string.digits, 10), nr_polisy_pk
        )
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

        out += (
            f"'{nr_polisy}','{us_date(data_waznosci)}','{typ}',{np(firma)}, '{vin}'\n"
        )
    return out


insert_csv(
    "nr_polisy,data_waznosci,typ,firma,vin_pojazdu",
    gen_pojazdy,
    n,
    "Ubezpieczenia/output.csv",
)
