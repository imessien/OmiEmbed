"""
Contain some omics data preprocess functions
"""
import pandas as pd


# CODAI

def preprocess_data(df):
    """
    Preprocess the omics data by standardizing the whole dataset and handling categorical columns

    Parameters:
        df(DataFrame) -- a dataframe that contains the omics data

    Return:
        df(DataFrame) -- a preprocessed dataframe
    """
    # Separate categorical columns
    cat_cols = df.select_dtypes(include=['object']).columns.tolist()
    num_cols = df.select_dtypes(include=['float64', 'int64']).columns.tolist()
    cat_df = df[cat_cols]
    num_df = df[num_cols]

    # One-hot encode categorical columns
    cat_df = pd.get_dummies(cat_df, drop_first=True)

    # Standardize numerical columns
    num_df = (num_df - num_df.mean()) / num_df.std()

    # Combine categorical and numerical dataframes
    df = pd.concat([cat_df, num_df], axis=1)

    return df
