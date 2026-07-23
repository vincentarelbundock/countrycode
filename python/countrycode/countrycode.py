import os
import re
import pickle
from pathlib import Path

try:
    import polars as pl
except ImportError:
    pl = None
try:
    import pandas as pd
except ImportError:
    pd = None

pkg_dir, pkg_filename = os.path.split(__file__)

# Load the default codelist at module level for backwards compatibility
codelist = None


def prepare_codelist(custom_dict=None, origin=None, destination=None):
    """
    Prepare and validate a codelist from various input types.

    Parameters:
    custom_dict: Can be None, dict, polars.DataFrame, str (path), or Path
    origin (str, optional): The origin column that must be present
    destination (str, optional): The destination column that must be present

    Returns:
    dict: A validated codelist dictionary

    Raises:
    ValueError: If validation fails
    NotImplementedError: If the type is not supported
    FileNotFoundError: If a file path doesn't exist
    ImportError: If Polars is required but not installed
    """
    result_dict = None
    source_description = None

    # Load/convert based on input type
    if isinstance(custom_dict, (str, Path)):
        # Load from file path
        path = Path(custom_dict)
        source_description = f"file '{path}'"
        file_extension = path.suffix

        if file_extension == ".pickle":
            try:
                with open(path, "rb") as f:
                    result_dict = pickle.load(f)
            except Exception:
                raise FileNotFoundError(
                    f"Could not find file at `{path}`. Please make sure the file exists at the provided path."
                )
            # If loaded data is a Polars DataFrame, convert to dict
            if pl and isinstance(result_dict, pl.DataFrame):
                result_dict = result_dict.to_dict(as_series=False)

        elif file_extension == ".csv":
            if not pl:
                raise ImportError(
                    "Polars is required to read CSV files. Please install polars: pip install polars"
                )
            try:
                df = pl.read_csv(path)
                result_dict = df.to_dict(as_series=False)
            except Exception as e:
                raise FileNotFoundError(
                    f"Could not read CSV file at `{path}`. Error: {e}"
                )

        else:
            raise NotImplementedError(
                f"Custom dicts with `{file_extension}` are not implemented yet. Please use a `.pickle` or `.csv` file."
            )

    elif isinstance(custom_dict, dict):
        result_dict = custom_dict
        source_description = "provided dict"

    elif pl and isinstance(custom_dict, pl.DataFrame):
        result_dict = custom_dict.to_dict(as_series=False)
        source_description = "provided Polars DataFrame"

    elif custom_dict is None:
        # Default data path is just data/codelist.pickle
        default_path = os.path.join(pkg_dir, "data", "codelist.pickle")
        return prepare_codelist(default_path, origin, destination)

    else:
        error_msg = (
            "custom_dict must be one of: "
            "None (use default), "
            "dict, "
            "str or Path (path to .pickle or .csv file)"
        )
        if pl:
            error_msg += ", or polars.DataFrame"
        error_msg += f". Got {type(custom_dict)}"
        raise NotImplementedError(error_msg)

    # Validate the structure
    if not isinstance(result_dict, dict):
        raise ValueError(
            f"{source_description} must contain a dict-like structure, got {type(result_dict)}"
        )

    if len(result_dict) == 0:
        raise ValueError(f"{source_description} cannot be empty")

    # Validate that columns contain list-like structures
    for key, value in result_dict.items():
        if not isinstance(value, (list, tuple)):
            raise ValueError(
                f"Column '{key}' in {source_description} must be a list or tuple, got {type(value)}"
            )

    # Validate that all columns have the same length
    column_lengths = {key: len(value) for key, value in result_dict.items()}
    unique_lengths = set(column_lengths.values())
    if len(unique_lengths) > 1:
        raise ValueError(
            f"All columns in {source_description} must have the same length. "
            f"Found different lengths: {column_lengths}"
        )

    # Validate required columns if specified
    if origin is not None and origin not in result_dict:
        raise ValueError(
            f"{source_description} must contain the origin column '{origin}'. "
            f"Available columns: {', '.join(result_dict.keys())}"
        )

    if destination is not None and destination not in result_dict:
        raise ValueError(
            f"{source_description} must contain the destination column '{destination}'. "
            f"Available columns: {', '.join(result_dict.keys())}"
        )

    return result_dict


def countrycode(
    sourcevar=["DZA", "CAN"],
    origin="iso3c",
    destination="country.name.en",
    custom_dict=None,
):
    """
    Convert country codes or names from one format to another.

    This function takes a list, string, or Polars Series of country codes or names, and converts them to the desired
    format, such as ISO 3-letter codes, country names in different languages, etc.

    Parameters:
    sourcevar (list, str, int, or polars.series.series.Series, optional):
        A list, string, integer, or Polars Series of country codes or names to be converted. Default is ['DZA', 'CAN'].
    origin (str, optional):
        The format of the input country codes or names. Default is 'iso3c'.
    destination (str, optional):
        The desired format of the output country codes or names. Default is 'country.name.en'.
    custom_dict (str, Path, dict, polars.DataFrame, optional):
        A custom dictionary to be used for country code translations. Can be:
        - None: Use the default built-in dictionary (default)
        - dict: A raw dictionary with column names as keys and lists as values
        - polars.DataFrame: A Polars DataFrame (will be converted to dict internally)
        - str or Path: Path to a `.pickle` file (containing dict or DataFrame) or `.csv` file

    Returns:
    list, str, or polars.series.series.Series:
        The converted country codes or names in the desired format. The output type depends on the input type:
        - If `sourcevar` is a string or int, returns a string.
        - If `sourcevar` is a list, returns a list.
        - If `sourcevar` is a Polars Series, returns a Polars Series.

    Raises:
    ValueError:
        If the `origin` or `destination` format is not one of the supported formats.
        If the input `sourcevar` is not a string, list, or Polars Series.
        If custom_dict is missing required columns (origin or destination).
        If custom_dict columns have inconsistent lengths.
        If custom_dict columns are not list-like structures.
    NotImplementedError:
        If the custom_dict file path has an unsupported extension (not .pickle or .csv).
        If the custom_dict argument is not one of the supported types.
    FileNotFoundError:
        If the custom_dict file path does not exist or cannot be read.
    ImportError:
        If attempting to read a CSV file without Polars installed.

    Example:
    >>> countrycode(['DZA', 'CAN'], origin='iso3c', destination='country.name.en')
    ['Algeria', 'Canada']

    Note:
    This function uses two helper functions (`replace_regex` and `replace_exact`) to perform the actual conversion.
    """

    # user convenience shortcuts only for default dict
    if origin == "country.name":
        origin = "country.name.en.regex"

    if origin in [
        "country.name.en",
        "country.name.fr",
        "country.name.de",
        "country.name.it",
    ]:
        origin = origin + ".regex"

    if destination == "country.name":
        destination = "country.name.en"

    # Load and validate the codelist dict with required columns
    codelist_data = prepare_codelist(
        custom_dict, origin=origin, destination=destination
    )

    # Only validate origin against the predefined list if using the default dictionary
    if custom_dict is None:
        valid = [
            "cctld",
            "country.name",
            "country.name.de",
            "country.name.fr",
            "country.name.it",
            "cowc",
            "cown",
            "dhs",
            "ecb",
            "eurostat",
            "fao",
            "fips",
            "gaul",
            "genc2c",
            "genc3c",
            "genc3n",
            "gwc",
            "gwn",
            "imf",
            "ioc",
            "iso2c",
            "iso3c",
            "iso3n",
            "p5c",
            "p5n",
            "p4c",
            "p4n",
            "un",
            "un_m49",
            "unicode.symbol",
            "unhcr",
            "unpd",
            "vdem",
            "wb",
            "wb_api2c",
            "wb_api3c",
            "wvs",
            "country.name.en.regex",
            "country.name.de.regex",
            "country.name.fr.regex",
            "country.name.it.regex",
        ]
        if origin not in valid:
            raise ValueError("origin must be one of: " + ", ".join(valid))

    sourcevar_series = sourcevar
    if pl:
        if isinstance(sourcevar, pl.series.series.Series):
            sourcevar_series = sourcevar.to_list()
    if pd:
        if isinstance(sourcevar, pd.Series):
            sourcevar_series = sourcevar.to_list()
    if isinstance(sourcevar, (str, int)):
        sourcevar_series = [sourcevar]

    # conversion
    if origin in [
        "country.name.en.regex",
        "country.name.fr.regex",
        "country.name.de.regex",
        "country.name.it.regex",
    ]:
        out = replace_regex(sourcevar_series, origin, destination, codelist_data)
    else:
        out = replace_exact(sourcevar_series, origin, destination, codelist_data)

    # output type
    if isinstance(sourcevar, (str, int)):
        return out[0]
    elif pl and isinstance(sourcevar, pl.series.series.Series):
        return pl.Series(out)
    elif pd and isinstance(sourcevar, pd.Series):
        return pd.Series(out)
    else:
        return out


def get_first_match(pattern, string_list):
    for string in string_list:
        match = pattern.search(string)
        if match:
            return match.group()
    return None


def replace_exact(sourcevar, origin, destination, codelist):
    out = []
    for string in sourcevar:
        match_found = False
        for position, origin_i in enumerate(codelist[origin]):
            if origin_i is None or codelist[destination][position] is None:
                continue
            if string == origin_i:
                if (
                    isinstance(codelist[destination][position], str)
                    and codelist[destination][position].isdigit()
                ):
                    out.append(int(codelist[destination][position]))
                else:
                    out.append(codelist[destination][position])
                match_found = True
                break
        if not match_found:
            out.append(None)
    return out


def replace_regex(sourcevar, origin, destination, codelist):
    sourcevar_unique = list(set(sourcevar))
    o = []
    d = []
    for i, (val_origin, val_destination) in enumerate(
        zip(codelist[origin], codelist[destination])
    ):
        if val_origin is not None and val_destination is not None:
            o.append(re.compile(val_origin, flags=re.IGNORECASE))
            d.append(val_destination)

    result = []
    for string in sourcevar_unique:
        match_found = False
        for position, regex in enumerate(o):
            if re.search(regex, string):
                result.append(d[position])
                match_found = True
                break
        if not match_found:
            result.append(None)
    mapping = dict(zip(sourcevar_unique, result))
    out = [
        int(mapping[i])
        if mapping[i] and isinstance(mapping[i], str) and mapping[i].isdigit()
        else mapping[i]
        for i in sourcevar
    ]
    return out


# Initialize module-level codelist for backwards compatibility
try:
    codelist = prepare_codelist(None)
except Exception:
    # If loading fails, keep it as None
    pass
