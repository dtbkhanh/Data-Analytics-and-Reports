import dash
import dash_bootstrap_components as dbc
from dash import dcc, html
from datetime import date

layout = dbc.Container(
    [
        # FILTER CONTROL
        dbc.Row(
            [
                dbc.Col(
                    dcc.DatePickerRange(
                        id='date-picker-range',
                        start_date='2024-01-01',
                        end_date=date.today().strftime('%Y-%m-%d'),
                        display_format='YYYY-MM-DD',
                        style={'width': '100%', 'font-size': '14px'}
                    ),
                    width=4
                )
            ],
            className="mb-4"
        ),

        # FIRST ROW
        dbc.Row(
            [
                # Sales by Coffee Type
                dbc.Col(
                    dcc.Graph(id='sales-by-coffee-type'),
                    width=6
                ),
                
                # Monthly Sales
                dbc.Col(
                    dcc.Graph(id='monthly-sales'),
                    width=6
                )
            ],
            justify="center"
        )
    ],
    fluid=True
)