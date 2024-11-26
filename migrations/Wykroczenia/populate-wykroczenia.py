import csv
import textwrap


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


with open("input.csv", newline="") as csvfile, open("output.csv", "w+") as out:
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
