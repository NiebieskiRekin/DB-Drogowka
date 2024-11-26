import string
import faker
import random
import csv

# Create Faker instance
faker.Faker.seed(0)
fake = faker.Faker("pl_PL")

pesel_set = list()
with open("../Osoby/output.csv", newline="") as csvfile:
    osoby_reader = csv.reader(csvfile, delimiter=",", quotechar="'")
    first_row = next(osoby_reader)
    for row in osoby_reader:
        pesel_set.append(row[0])

n = len(pesel_set) // 10

random.shuffle(pesel_set)
nr_odznaki_unique = set()
stopnie_policyjne = [
    "posterunkowy",
    "starszy posterunkowy",
    "sierżant",
    "starszy sierżant",
    "sierżant sztabowy",
    "młodszy aspirant",
    "aspirant",
    "starszy aspirant",
    "aspirant sztabowy",
    "podkomisarz",
    "komisarz",
    "nadkomisarz",
    "podinspektor",
    "młodszy inspektor",
    "inspektor",
    "nadinspektor",
    "generalny inspektor",
]


def gen_unique(f, s: set):
    while (temp := f()) in s:
        continue
    s.add(temp)
    return temp


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


def randomword(length):
    letters = string.digits
    return "".join(random.choice(letters) for i in range(length))


def gen_funkcjonariusze(i, null_parser):
    pesel = pesel_set[i]
    stopien = random.choice(stopnie_policyjne)
    nr_odznaki = gen_unique(lambda: randomword(16), nr_odznaki_unique)
    return f"'{nr_odznaki}', '{stopien}', '{pesel}'\n"


insert_csv(
    "nr_odznaki,stopien,pesel",
    gen_funkcjonariusze,
    n,
)
