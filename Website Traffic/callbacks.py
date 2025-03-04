from dash import Input, Output
import plotly.express as px
from data_processing import load_data

def register_callbacks(app):
    @app.callback(
        Output('conversion-rate-bar', 'figure'),
        Input('traffic-source-pie', 'clickData')
    )
    def update_conversion_rate_bar(clickData):
        # Load data
        df = load_data()
        
        # If no click, return full data
        if not clickData:
            conversion_by_source = df.groupby('Traffic Source')['Conversion Rate'].mean()
            
            return px.bar(
                x=conversion_by_source.index, 
                y=conversion_by_source.values, 
                title='Conversion Rate by Traffic Source',
                labels={'x': 'Traffic Source', 'y': 'Conversion Rate'}
            )
        
        # If a specific source is clicked
        clicked_source = clickData['points'][0]['label']
        filtered_df = df[df['Traffic Source'] == clicked_source]
        
        # Create bar chart for the specific source
        return px.bar(
            filtered_df, 
            x='Traffic Source', 
            y='Conversion Rate', 
            title=f'Conversion Rate for {clicked_source} Traffic'
        )