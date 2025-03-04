from dash import Input, Output
import plotly.graph_objects as go
from data_processing import get_filtered_data  # Import the function for filtered data

# Update both charts based on selected date range
def register_callbacks(app):
    @app.callback(
        [Output('sales-by-coffee-type', 'figure'),
         Output('monthly-sales', 'figure')],
        [Input('date-picker-range', 'start_date'),
         Input('date-picker-range', 'end_date')]
    )
    def update_charts(start_date, end_date):
        # Get filtered data based on selected date range
        filtered_df = get_filtered_data(start_date, end_date)

        # 1. Sales by Coffee Type (Bar Chart)
        aggregated_df = filtered_df.groupby('coffee_name', as_index=False)['money'].sum()
        aggregated_df = aggregated_df.sort_values('money', ascending=True)

        bar_fig = go.Figure(go.Bar(
            x=aggregated_df['money'], 
            y=aggregated_df['coffee_name'], 
            orientation='h', 
            marker=dict(color='rgba(0, 123, 255, 0.3)'),
            hovertemplate='%{x:,.2f}<br>%{y}<extra></extra>'
        ))

        bar_fig.update_layout(
            title='Total Sales per Coffee Type',
            xaxis_title="Total Sales (₴)", 
            yaxis_title="Coffee Type", 
            height=500,
            font=dict(family="Arial", size=11),
        )

        # 2. Monthly Sales (Line Chart)
        # Aggregate the data by 'month_year' and calculate total sales for each month
        monthly_sales = filtered_df.groupby('month_year', as_index=False)['money'].sum()

        # Ensure 'month_year' is a string for proper display
        monthly_sales['month_year'] = monthly_sales['month_year'].astype(str)

        line_fig = go.Figure(go.Scatter(
            x=monthly_sales['month_year'],
            y=monthly_sales['money'], 
            mode='lines+markers',
            marker=dict(color='rgba(0, 123, 255, 0.6)'),
            line=dict(color='rgba(0, 123, 255, 1)'),
            hovertemplate='%{x}<br>Total Sales: %{y:,.2f}<extra></extra>'
        ))

        line_fig.update_layout(
            title='Monthly Sales',
            xaxis_title="Month",
            yaxis_title="Total Sales (₴)",
            plot_bgcolor='white',
            paper_bgcolor='white',
            height=500,
            font=dict(family="Arial", size=11),
        )

        return bar_fig, line_fig  # Return both figures