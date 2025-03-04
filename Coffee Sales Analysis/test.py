import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from datetime import datetime
from dash import Dash, dcc, html, Input, Output

# Load dataset
df1 = pd.read_csv('Coffee Sales_1.csv')
df2 = pd.read_csv('Coffee Sales_2.csv')
df = pd.concat([df1, df2], ignore_index=True)

# Convert columns for datetime format with explicit format
df['datetime'] = pd.to_datetime(df['datetime'], format='%Y-%m-%d %H:%M:%S', errors='coerce')
df['date'] = pd.to_datetime(df['date'], format='%Y-%m-%d', errors='coerce')

# Remove rows where 'datetime' or 'date' is NaT (invalid dates)
df = df.dropna(subset=['datetime', 'date'])

# Extract the month from the 'datetime' column
df['month'] = df['date'].dt.to_period('M')

# Create Dash app
app = Dash(__name__)

# Overall app layout
app.layout = html.Div(
    children=[
        html.H1("Coffee Sales Dashboard"),
        html.Div(
            children=[
                html.H2("Sales by Coffee Type (Date Range)"),
                dcc.DatePickerRange(
                    id='date-picker-range',
                    start_date=df['date'].min().strftime('%Y-%m-%d'),  # Start from the earliest date
                    end_date=datetime.today().strftime('%Y-%m-%d'),   # End at today's date
                    display_format='YYYY-MM-DD'
                ),
                dcc.Graph(id='sales-bar-chart')
            ]
        ),
        html.Div(
            children=[
                html.H2("Monthly Sales Trend"),
                dcc.Dropdown(
                    id='coffee-type-dropdown',
                    options=[{'label': coffee, 'value': coffee} for coffee in ['All'] + sorted(df['coffee_name'].unique().tolist())],
                    value=['All'],
                    multi=True,
                    clearable=False
                ),
                dcc.Graph(id='monthly-sales-line-chart')
            ]
        )
    ]
)

# Callback for Bar Chart
@app.callback(
    Output('sales-bar-chart', 'figure'),
    Input('date-picker-range', 'start_date'),
    Input('date-picker-range', 'end_date')
)
def update_bar_chart(start_date, end_date):
    # Convert start_date and end_date strings to datetime objects
    start_date = pd.to_datetime(start_date, format='%Y-%m-%d')
    end_date = pd.to_datetime(end_date, format='%Y-%m-%d')

    # Filter the DataFrame based on the date range
    filtered_df = df[(df['datetime'] >= start_date) & (df['datetime'] <= end_date)]
    aggregated_df = filtered_df.groupby('coffee_name', as_index=False)['money'].sum()
    aggregated_df = aggregated_df.sort_values('money', ascending=True)

    # Create the bar chart
    bar_fig = go.Figure(go.Bar(
        x=aggregated_df['money'],
        y=aggregated_df['coffee_name'],
        orientation='h',
        marker=dict(color='rgba(0, 123, 255, 0.3)'),
        hovertemplate='%{x:,.2f}<br>%{y}<extra></extra>'
    ))

    bar_fig.update_layout(
        title={
            'text': 'Total Sales per Coffee Type',
            'x': 0.5, 'xanchor': 'center',
            'font': {'size': 18, 'weight': 'bold'}
        },
        plot_bgcolor='white',
        paper_bgcolor='white',
        xaxis_title="Total Sales (₴)",
        yaxis_title="Coffee Type",
        xaxis_title_standoff=30,
        yaxis_title_standoff=30,
        height=500,
        font=dict(family="Arial", size=11),
    )
    return bar_fig

# Callback for Line Chart
@app.callback(
    Output('monthly-sales-line-chart', 'figure'),
    Input('coffee-type-dropdown', 'value')
)
def update_line_chart(selected_coffees):
    if "All" in selected_coffees:
        monthly_sales = df.groupby('month', as_index=False)['money'].sum()
    else:
        filtered_sales = df[df['coffee_name'].isin(selected_coffees)]
        monthly_sales = filtered_sales.groupby('month', as_index=False)['money'].sum()

    monthly_sales['month'] = monthly_sales['month'].astype(str)

    line_fig = px.line(
        monthly_sales,
        x='month',
        y='money',
        labels={'month': 'Month', 'money': 'Total Sales (₴)'},
        markers=True
    )
    return line_fig

# Run the Dash app
if __name__ == '__main__':
    app.run_server(debug=True)