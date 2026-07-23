import pytest

from countrycode import countrycode

try:
    import polars as pl

    _has_polars = True
except ImportError:
    _has_polars = False


def test_custom_dict_as_dict():
    """Test using a custom dictionary as dict"""
    custom_data = {
        "code": ["A", "B", "C"],
        "name": ["Alpha", "Beta", "Gamma"],
        "number": [1, 2, 3],
    }

    result = countrycode(
        ["A", "C"], origin="code", destination="name", custom_dict=custom_data
    )
    assert result == ["Alpha", "Gamma"]

    result = countrycode(
        "B", origin="code", destination="number", custom_dict=custom_data
    )
    assert result == 2  # Note: should be converted to int


@pytest.mark.skipif(not _has_polars, reason="Polars not installed")
def test_custom_dict_as_polars_dataframe():
    """Test using a custom dictionary as Polars DataFrame"""
    custom_df = pl.DataFrame(
        {
            "code": ["A", "B", "C"],
            "name": ["Alpha", "Beta", "Gamma"],
            "number": ["1", "2", "3"],
        }
    )

    result = countrycode(
        ["A", "C"], origin="code", destination="name", custom_dict=custom_df
    )
    assert result == ["Alpha", "Gamma"]

    result = countrycode(
        "B", origin="code", destination="number", custom_dict=custom_df
    )
    assert result == 2  # Should be converted to int


@pytest.mark.skipif(not _has_polars, reason="Polars not installed")
def test_custom_dict_as_csv_path_str(tmp_path):
    """Test loading custom dictionary from CSV file using string path"""
    csv_file = tmp_path / "custom_codes.csv"
    csv_file.write_text("code,name,number\nA,Alpha,1\nB,Beta,2\nC,Gamma,3\n")

    result = countrycode(
        ["A", "C"], origin="code", destination="name", custom_dict=str(csv_file)
    )
    assert result == ["Alpha", "Gamma"]


@pytest.mark.skipif(not _has_polars, reason="Polars not installed")
def test_custom_dict_as_csv_path_object(tmp_path):
    """Test loading custom dictionary from CSV file using Path object"""
    csv_file = tmp_path / "custom_codes.csv"
    csv_file.write_text("code,name,number\nA,Alpha,1\nB,Beta,2\nC,Gamma,3\n")

    result = countrycode(
        ["A", "C"], origin="code", destination="name", custom_dict=csv_file
    )
    assert result == ["Alpha", "Gamma"]


def test_custom_dict_validation_missing_origin():
    """Test that validation fails when origin column is missing"""
    custom_data = {
        "name": ["Alpha", "Beta", "Gamma"],
        "number": [1, 2, 3],
    }

    with pytest.raises(ValueError, match="must contain the origin column"):
        countrycode(["A"], origin="code", destination="name", custom_dict=custom_data)


def test_custom_dict_validation_missing_destination():
    """Test that validation fails when destination column is missing"""
    custom_data = {
        "code": ["A", "B", "C"],
        "number": [1, 2, 3],
    }

    with pytest.raises(ValueError, match="must contain the destination column"):
        countrycode(["A"], origin="code", destination="name", custom_dict=custom_data)


def test_custom_dict_validation_inconsistent_lengths():
    """Test that validation fails when columns have different lengths"""
    custom_data = {
        "code": ["A", "B", "C"],
        "name": ["Alpha", "Beta"],  # Shorter than code
    }

    with pytest.raises(ValueError, match="must have the same length"):
        countrycode(["A"], origin="code", destination="name", custom_dict=custom_data)


def test_custom_dict_validation_empty():
    """Test that validation fails for empty dict"""
    custom_data = {}

    with pytest.raises(ValueError, match="cannot be empty"):
        countrycode(["A"], origin="code", destination="name", custom_dict=custom_data)


def test_custom_dict_validation_not_list():
    """Test that validation fails when column is not a list"""
    custom_data = {
        "code": "ABC",  # String instead of list
        "name": ["Alpha", "Beta", "Gamma"],
    }

    with pytest.raises(ValueError, match="must be a list or tuple"):
        countrycode(["A"], origin="code", destination="name", custom_dict=custom_data)


def test_custom_dict_invalid_type():
    """Test that providing an invalid type for custom_dict raises error"""
    with pytest.raises(NotImplementedError, match="custom_dict must be one of"):
        countrycode(["A"], origin="code", destination="name", custom_dict=123)


@pytest.mark.skipif(not _has_polars, reason="Polars not installed")
def test_custom_dict_polars_series_conversion():
    """Test that custom_dict works with Polars Series in sourcevar"""
    custom_df = pl.DataFrame(
        {
            "code": ["A", "B", "C"],
            "name": ["Alpha", "Beta", "Gamma"],
        }
    )

    source_series = pl.Series(["A", "C", "B"])
    result = countrycode(
        source_series, origin="code", destination="name", custom_dict=custom_df
    )

    assert isinstance(result, pl.Series)
    assert result.to_list() == ["Alpha", "Gamma", "Beta"]
