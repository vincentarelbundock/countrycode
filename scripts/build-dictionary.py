import pickle
from pathlib import Path

import polars as pl

project_dir = Path(__file__).resolve().parent.parent
data_dir = project_dir / "python" / "countrycode" / "data"

df = pl.read_csv(data_dir / "codelist.csv")
codelist = {col: df[col].to_list() for col in df.columns}

data_dir.mkdir(parents=True, exist_ok=True)
with (data_dir / "codelist.pickle").open("wb") as f:
    pickle.dump(codelist, f, protocol=4)

print("Converted the Python dictionary CSV to pickle")
