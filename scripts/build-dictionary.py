"""Validate the generated Python data artifacts."""

import gzip
from pathlib import Path

import polars as pl

project_dir = Path(__file__).resolve().parent.parent
data_dir = project_dir / "python" / "countrycode" / "data"
path = data_dir / "codelist.csv.gz"

with gzip.open(path, "rb") as stream:
    dataframe = pl.read_csv(stream)

if dataframe.is_empty():
    raise RuntimeError(f"Generated dictionary is empty: {path}")

print(
    f"Validated compressed Python dictionary "
    f"({dataframe.height} rows, {dataframe.width} columns)"
)
