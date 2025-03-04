from dash import Dash
import layout
import callbacks
from callbacks import register_callbacks

# Initialize Dash app
app = Dash(__name__)
app.layout = layout.layout

# Register the callbacks
callbacks.register_callbacks(app)

# Run server
if __name__ == '__main__':
    app.run_server(debug=True)