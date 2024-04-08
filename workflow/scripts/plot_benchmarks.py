#!/usr/bin/env python
"""Plot Snakemake benchmark results"""
__author__ = "Fredrik Boulund"
__date__ = "2019"

from sys import argv, exit
from pathlib import Path
import argparse

import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt


parser = argparse.ArgumentParser(description=f"{__doc__}. {__author__} (c) {__date__}")
parser.add_argument("benchmarks", metavar="FILE", nargs="+", help="Benchmark output(s)")
parser.add_argument("--output", default="plot.pdf", 
        help="Plot output. Will produce a png variant as well")

if len(argv) < 2:
    parser.print_help()
    exit()

args = parser.parse_args()

dfs = []
for benchmark in args.benchmarks:
    tool = Path(benchmark).stem.split(".", maxsplit=1)[0]
    df = pd.read_csv(benchmark, sep="\t")
    df["Tool"] = tool
    dfs.append(df)

table = pd.concat(dfs)


fig, (ax1, ax2) = plt.subplots(1,2, figsize=(10,5))

ax1.set_title("Average time")
ax1.set_ylabel("seconds")
table\
    .groupby("Tool")\
    .mean()["s"]\
    .plot(kind="bar", ax=ax1)

ax2.set_title("Average max_vms")
ax2.set_ylabel("Megabytes")
table\
    .groupby("Tool")\
    .mean()["max_vms"]\
    .plot(kind="bar", ax=ax2)


fig.savefig(args.output, bbox_inches="tight")
fig.savefig(args.output.replace(".pdf", ".png"), bbox_inches="tight")

