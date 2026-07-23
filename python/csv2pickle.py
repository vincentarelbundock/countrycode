import pickle
import os

import polars as pl

# Read the CSV file
df = pl.read_csv("countrycode/data/codelist.csv")

# Convert to dictionary of lists
codelist = {col: df[col].to_list() for col in df.columns}

# Create data directory if it doesn't exist
os.makedirs("countrycode/data", exist_ok=True)

# Save as pickle
with open("countrycode/data/codelist.pickle", "wb") as f:
    pickle.dump(codelist, f, protocol=4)

print("Successfully converted CSV to pickle file") 
