import pandas as pd
import numpy as np

def load_data(filepath = 'website_data.csv'):
    df = pd.read_csv(filepath)
    return df

# Calculate metrics
def calculate_metrics(df):
    metrics = {
        'total_page_views': df["Page Views"].sum(),
        'avg_session_duration': df["Session Duration"].mean(),
        'avg_bounce_rate': df["Bounce Rate"].mean() * 100,
        'conversion_rate': (df["Conversion Rate"].sum() / len(df)) * 100,
        'traffic_source_distribution': df["Traffic Source"].value_counts(normalize=True) * 100
    }
    return metrics

# Group data for analysis
def prepare_visualizations(df):
    return {
        'traffic_source_counts': df['Traffic Source'].value_counts(),
        'session_duration_distribution': df['Session Duration'],
        'conversion_rate_by_source': df.groupby('Traffic Source')['Conversion Rate'].mean(),
        'page_views_by_source': df.groupby('Traffic Source')['Page Views'].mean(),
        'bounce_rate_by_source': df.groupby('Traffic Source')['Bounce Rate'].mean() * 100
    }