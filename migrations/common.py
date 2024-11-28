import random
from typing import Callable, List
import csv
import datetime
import faker
import textwrap


faker.Faker.seed(0)
fake = faker.Faker("pl_PL")
random.seed(0)


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
        print(f"{gen(i)}", end="")


def wrap_str(x):
    return f"'{x}'"


def print_csv_null(v, wrapper=wrap_str):
    if v is None:
        return ""
    return wrapper(v)


def us_date(d):
    return datetime.date.strftime(d, "%m-%d-%Y")


def csv_reader(path: str, func: Callable[[List[str]]]):
    with open(path, newline="") as csvfile:
        my_reader = csv.reader(csvfile, delimiter=",", quotechar="'")
        next(my_reader)  # Ignore header
        for row in my_reader:
            func(row)


def cleanup(v):
    return v.replace("'", "").strip()


def randomword(letters, length):
    return "".join(random.choice(letters) for i in range(length))


def shorten(s, w):
    encoded_string = textwrap.shorten(s, w, placeholder="...").encode("utf-8")
    truncated_encoded = encoded_string[:w]
    try:
        return truncated_encoded.decode("utf-8")
    except UnicodeDecodeError:
        # If decoding fails, we need to truncate further to avoid incomplete characters
        while truncated_encoded and not truncated_encoded.endswith(b"\x00"):
            truncated_encoded = truncated_encoded[:-1]
        return truncated_encoded.decode("utf-8", errors="ignore")
