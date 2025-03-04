import dash
import dash_bootstrap_components as dbc
from dash import dcc, html
import plotly.express as px
import plotly.graph_objs as go
from data_processing import load_data, calculate_metrics, prepare_visualizations

# Load dataset
df = load_data()
metrics = calculate_metrics(df)
viz_data = prepare_visualizations(df)

def create_metric_card(title, value, icon, color_class):
    return dbc.Card(
        dbc.CardBody([
            html.Div([
                html.Div([
                    html.I(className=f"bi {icon} me-2 fs-3"),
                ], className="col-auto"),
                html.Div([
                    html.H5(title, className="card-title text-muted mb-1 text-center"),
                    html.H3(value, className="card-text fw-bold text-center")
                ], className="col")
            ], className="row align-items-center text-center")
        ], className=f"text-{color_class}")
    )

def create_layout(app):
    return dbc.Container([
        # Header
        dbc.Row([
            dbc.Col(html.H1('Website Traffic Analysis', className="text-center my-4 py-3"), width=12)
        ]),
        
        #### KEY METRICS SECTION ####
        dbc.Row([
            dbc.Col(create_metric_card(
                title="Total Page Views", 
                value=f"{metrics['total_page_views']:,.0f}", 
                icon="bi-eye", 
                color_class="primary"
            ), width=3),
            
            dbc.Col(create_metric_card(
                title="Avg Session Duration", 
                value=f"{metrics['avg_session_duration']:.2f} mins", 
                icon="bi-clock", 
                color_class="success"
            ), width=3),
            
            dbc.Col(create_metric_card(
                title="Bounce Rate", 
                value=f"{metrics['avg_bounce_rate']:.2f}%", 
                icon="bi-arrow-return-right", 
                color_class="warning"
            ), width=3),
            
            dbc.Col(create_metric_card(
                title="Conversion Rate", 
                value=f"{metrics['conversion_rate']:.2f}%", 
                icon="bi-graph-up", 
                color_class="info"
            ), width=3)
        ], className="g-4 mb-4"),
        
        #### VISUALIZATION SECTION ####
        dbc.Row([
            #  Pie Chart: Traffic Source Distribution
            dbc.Col([
                html.H3('Traffic Source Distribution'),
                dcc.Graph(
                    id='traffic-source-pie',
                    figure=px.pie(
                        values=viz_data['traffic_source_counts'].values, 
                        names=viz_data['traffic_source_counts'].index, 
                        title='Traffic Source Distribution'
                    )
                )
            ], width=6),
            
            # Session Duration Histogram
            dbc.Col([
                html.H3('Session Duration Distribution'),
                dcc.Graph(
                    id='session-duration-hist',
                    figure=px.histogram(
                        x=viz_data['session_duration_distribution'], 
                        title='Session Duration Distribution',
                        labels={'x': 'Session Duration (mins)'}
                    )
                )
            ], width=6)
        ], className="mb-4"),

        dbc.Row([
            # Conversion Rate by Traffic Source
            dbc.Col([
                html.H3('Conversion Rate by Traffic Source'),
                dcc.Graph(
                    id='conversion-rate-bar',
                    figure=px.bar(
                        x=viz_data['conversion_rate_by_source'].index, 
                        y=viz_data['conversion_rate_by_source'].values, 
                        title='Conversion Rate by Traffic Source',
                        labels={'x': 'Traffic Source', 'y': 'Conversion Rate'}
                    )
                )
            ], width=6),
            
            # Bar Chart: Bounce Rate vs Conversion Rate by Traffic Source
            dbc.Col([
                html.H3('Bounce Rate vs Conversion Rate'),
                dcc.Graph(
                    id='bounce-conversion-bar',
                    figure=go.Figure(data=[
                        go.Bar(
                            name='Bounce Rate', 
                            x=viz_data['bounce_rate_by_source'].index, 
                            y=viz_data['bounce_rate_by_source'].values,
                            marker_color='rgba(255, 99, 132, 0.6)'
                        ),
                        go.Bar(
                            name='Conversion Rate', 
                            x=viz_data['conversion_rate_by_source'].index, 
                            y=viz_data['conversion_rate_by_source'].values,
                            marker_color='rgba(54, 162, 235, 0.6)'
                        )
                    ], layout=go.Layout(
                        title='Bounce Rate vs Conversion Rate by Traffic Source',
                        barmode='group',
                        xaxis_title='Traffic Source',
                        yaxis_title='Rate (%)'
                    ))
                )
            ], width=6)
        ])
    ],
    fluid=True,
    style={
        'margin': '20px auto',
        'max-width': '95%'
    }   
    )