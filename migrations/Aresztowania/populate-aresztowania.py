import random
from typing import List
from common import (
    gen_with_distribution,
    insert_csv,
    print_csv_null,
    us_date,
    fake,
    csv_reader,
)

formy_wymiaru_kary_set = []


def gen_aresztowania(i):
    ffk = formy_wymiaru_kary_set[i]
    id_uczestnika = ffk[0]
    id_interwencji = ffk[1]
    czy_w_zawieszeniu = gen_with_distribution(["T", "N"], [0.1, 0.9])
    od_kiedy = fake.date_between(start_date="-2y", end_date="+0d")
    do_kiedy = gen_with_distribution(
        [fake.date_between(start_date=od_kiedy, end_date="+20y"), None], [0.7, 0.3]
    )

    return f"{id_uczestnika},{id_interwencji},{us_date(od_kiedy)},{print_csv_null(do_kiedy,wrapper=us_date)},'{czy_w_zawieszeniu}'\n"


def main():
    def formy_wymiaru_kary_filter(row: List[str]):
        if row[2] == "a":
            formy_wymiaru_kary_set.append(row[:2])

    csv_reader("Formy_Wymiaru_Kary/output.csv", formy_wymiaru_kary_filter)

    n = len(formy_wymiaru_kary_set)
    random.shuffle(formy_wymiaru_kary_set)

    insert_csv(
        "id_uczestnika,id_interwencji,od_kiedy,do_kiedy,czy_w_zawieszeniu",
        gen_aresztowania,
        n,
        "Aresztowania/output.csv",
    )
    pass


if __name__ == "__main__":
    main()
