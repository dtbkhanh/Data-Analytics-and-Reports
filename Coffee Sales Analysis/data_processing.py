import pandas as pd
from datetime import date
import warnings

# Load dataset
df1 = pd.read_csv('Coffee Sales_1.csv')
df2 = pd.read_csv('Coffee Sales_2.csv')

df = pd.concat([df1, df2], ignore_index=True)

# Convert the 'datetime' column to datetime type
df['datetime'] = pd.to_datetime(df['datetime'], format='ISO8601', errors='coerce')
df['date'] = pd.to_datetime(df['date'], errors='coerce')

# Extract the month from the 'datetime' column
df['month_year'] = df['datetime'].dt.to_period('M')

# Suppress specific deprecation warning
warnings.filterwarnings("ignore", category=DeprecationWarning)

def get_filtered_data(start_date, end_date):
    """Returns data filtered by date range."""
    filtered_df = df[(df['datetime'] >= pd.to_datetime(start_date)) & 
                     (df['datetime'] <= pd.to_datetime(end_date))]
    return filtered_df