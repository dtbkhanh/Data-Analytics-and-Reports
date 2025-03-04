import dash
from dash import dcc, html
import dash_bootstrap_components as dbc
import plotly.express as px

from layout import create_layout
from callbacks import register_callbacks

# Initialize the app
app = dash.Dash(external_stylesheets=[dbc.themes.BOOTSTRAP])

# Set up layout
app.layout = create_layout(app)

# Register callbacks
register_callbacks(app)

if __name__ == "__main__":
    app.run_server(debug=True)