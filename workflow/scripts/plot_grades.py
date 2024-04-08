#!/usr/bin/env python
"""Plot BBmap addadapter grading results"""
__author__ = "Fredrik Boulund"
__date__ = "2019"

from sys import argv, exit
from pathlib import Path
import argparse

import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt


parser = argparse.ArgumentParser(description=f"{__doc__}. {__author__} (c) {__date__}")
parser.add_argument("grades", metavar="FILE", nargs="+", help="Grading result(s)")
parser.add_argument("--output", default="plot.pdf", 
        help="Plot output. Will produce a png variant as well.")

if len(argv) < 2:
    parser.print_help()
    exit()

args = parser.parse_args()

dfs = []
for grade in args.grades:
    tool = Path(grade).stem.split(".", maxsplit=1)[0]
    data = {"Tool": tool}
    with open(grade) as f:
        for line in f:
            if line.startswith("Total output"):
                data["Total_output"] = int(line.split("\t")[1].split()[0])
            if line.startswith("Perfectly Correct"):
                data["Perfectly_correct"] = int(line.split("\t")[1].split()[0])
                data["Perfectly_correct_pct"] = float(line.split("\t")[1].split("(")[1].rstrip(" )%"))
            if line.startswith("Incorrect"):
                data["Incorrect"] = int(line.split("\t")[1].split()[0])
                data["Incorrect_pct"] = float(line.split("\t")[1].split("(")[1].rstrip(" )%"))
            if line.startswith("Adapters Remaining"):
                data["Adapters_remaining"] = int(line.split("\t")[1].split()[0])
                data["Adapters_remaining_pct"] = float(line.split("\t")[1].split("(")[1].rstrip(" )%"))
            if line.startswith("Non-Adapter"):
                data["Non_adapters_removed"] = int(line.split("\t")[1].split()[0])
                data["Non_adapters_removed_pct"] = float(line.split("\t")[1].split("(")[1].rstrip(" )%"))
    
    df = pd.DataFrame(data, index=[0]).set_index("Tool")
    dfs.append(df)

table = pd.concat(dfs)


fig, (ax1, ax2) = plt.subplots(1,2, figsize=(10,5))

reads = ["Total_output", "Perfectly_correct", "Incorrect", "Adapters_remaining", "Non_adapters_removed"]
pct = ["Perfectly_correct_pct", "Incorrect_pct", "Adapters_remaining_pct", "Non_adapters_removed_pct"]

table[reads].plot(kind="bar", ax=ax1)
table[pct].plot(kind="bar", ax=ax2)

ax1.legend(loc="center left")
ax1.set_ylabel("Reads")
ax2.legend(loc="center left")
ax2.set_ylabel("Percent")

fig.savefig(args.output, bbox_inches="tight")
fig.savefig(args.output.replace(".pdf", ".png"), bbox_inches="tight")

