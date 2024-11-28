import csv
import textwrap
from common import shorten

with (
    open("Wykroczenia/input.csv", newline="") as csvfile,
    open("Wykroczenia/output.csv", "w+") as out,
):
    wykroczenia_in = csv.reader(csvfile, delimiter=",", quotechar="'")
    wykroczenia_out = csv.writer(
        out, delimiter=",", quotechar="'", quoting=csv.QUOTE_ALL
    )
    first_row = next(wykroczenia_in)
    wykroczenia_out.writerow(first_row)
    for row in wykroczenia_in:
        v1 = shorten(row[0], 127)
        v2 = shorten(row[1], 31)
        wykroczenia_out.writerow([v1, v2, *row[2:]])
