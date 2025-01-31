import csv
import textwrap
from common import shorten, shorten_no_elipsis

with (
    open("Wykroczenia/input.csv", newline="") as csvfile,
    open("Wykroczenia/output.csv", "w+") as out,
):
    wykroczenia_in = csv.reader(csvfile, delimiter=",", quotechar="'")
    wykroczenia_out = csv.writer(
        out, delimiter=",", quotechar="'", quoting=csv.QUOTE_ALL
    )
    first_row = next(wykroczenia_in)
    first_row.insert(0, "id_wykroczenia")
    wykroczenia_out.writerow(first_row)
    for i, row in enumerate(wykroczenia_in):
        v1 = shorten_no_elipsis(row[0], 127)
        v2 = shorten_no_elipsis(row[1], 31)
        wykroczenia_out.writerow([i, v1, v2, *row[2:]])
