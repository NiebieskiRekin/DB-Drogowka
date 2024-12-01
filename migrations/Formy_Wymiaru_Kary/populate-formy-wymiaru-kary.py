import random
from typing import List

from common import gen_with_distribution, insert_csv, csv_reader, cleanup, gen_unique

typy = ["m", "a", "p"]

interwencja_uczestnik_unique = set()


def uczestnicy_zdarzenia_filter(row: List[str]):
    if row[1] == "winowajca":
        uczestnicy_set.append(row)


def zdarzenia_filter(row: List[str]):
    zdarzenia_set.append(row)


def interwencje_filter(row: List[str]):
    interwencje_set.append(row)


uczestnicy_set = []
csv_reader("Uczestnicy_Zdarzenia/output.csv", uczestnicy_zdarzenia_filter)

interwencje_set = []
csv_reader("Interwencje/output.csv", interwencje_filter)

zdarzenia_set = []
csv_reader("Zdarzenia/output.csv", zdarzenia_filter)


n = len(uczestnicy_set)
random.shuffle(uczestnicy_set)


# select id_zdarzenia,id_uczestnika,id_interwencji
# from interwencje
# right join zdarzenia
# on interwencje.zdarzenie=zdarzenia.id_zdarzenia
# right join uczestnicy_zdarzenia
# on uczestnicy_zdarzenia.zdarzenie=zdarzenia.id_zdarzenia
# where id_uczestnika=...;
def join_zdarzenia_interwencje_uczestnicy():
    res = []
    temp = []

    for u in uczestnicy_set:
        for z in zdarzenia_set:
            z0 = cleanup(z[0])
            u3 = cleanup(u[3])
            u0 = cleanup(u[0])
            if u3 == z0:
                temp.append((z0, u0))

    for t in temp:
        for i in interwencje_set:
            i0 = cleanup(i[0])
            i3 = cleanup(i[3])
            if t[0] == i3:
                res.append((*t, i0))
    return res


joined_all = join_zdarzenia_interwencje_uczestnicy()


def gen_id_interwencji(id_uczestnika):
    return random.choice([x[2] for x in joined_all if cleanup(x[1]) == id_uczestnika])


def gen_formy_wymiaru_kary(i):
    id_uczestnika = cleanup(uczestnicy_set[i][0])
    _, id_interwencji = gen_unique(
        lambda: (id_uczestnika, int(gen_id_interwencji(id_uczestnika))),
        interwencja_uczestnik_unique,
    )
    out = ""
    typ = gen_with_distribution(typy, [0.5, 0.3, 0.2])

    out += f"{id_uczestnika},{id_interwencji},'{typ}'\n"

    return out


insert_csv(
    "id_uczestnika,id_interwencji,typ",
    gen_formy_wymiaru_kary,
    n,
    "Formy_Wymiaru_Kary/output.csv",
)
