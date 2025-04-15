def analyze_major_events(results_df, window_data_df, baseline_df):
    # Get top 10 most impactful events
    major_events = results_df.nlargest(10, 'composite_score')
    
    # 1. Comparative Impact Plot
    plt.figure(figsize=(14, 7))
    melt_df = pd.melt(results_df, 
                     id_vars=['event', 'time'],
                     value_vars=['USOSFR5_max_diff', 'USOSFR10_max_diff'],
                     var_name='Instrument', 
                     value_name='Max Price Range')
    melt_df['Instrument'] = melt_df['Instrument'].str.replace('_max_diff', '')
    
    sns.barplot(data=melt_df[melt_df['event'].isin(major_events['event'])],
               x='event', y='Max Price Range', hue='Instrument',
               order=major_events.sort_values('composite_score', ascending=False)['event'])
    plt.title('Top 10 Events: Maximum Hourly Price Range Comparison')
    plt.ylabel('Basis Points')
    plt.xlabel('')
    plt.xticks(rotation=45, ha='right')
    plt.legend(title='Tenor')
    plt.tight_layout()
    plt.show()
    
    # 2. Volatility Timeline Comparison
    for event in major_events['event'].unique():
        event_time = major_events[major_events['event'] == event]['time'].iloc[0]
        event_data = window_data_df[
            (window_data_df['event'] == event) & 
            (abs(window_data_df['hour_offset']) <= 12)
        ]
        
        plt.figure(figsize=(14, 6))
        sns.lineplot(data=event_data, x='hour_offset', y='diff', 
                    hue='instrument', style='instrument',
                    markers=True, dashes=False)
        plt.title(f'{event}\nPrice Range Evolution ({event_time.strftime("%Y-%m-%d %H:%M")})')
        plt.axvline(0, color='red', linestyle='--', alpha=0.5)
        plt.xlabel('Hours Relative to Event Time')
        plt.ylabel('Hourly Price Range (bps)')
        plt.grid(True, alpha=0.3)
        plt.legend(title='Tenor')
        plt.show()
        
        # Print key metrics
        event_metrics = results_df[results_df['event'] == event].iloc[0]
        print(f"\n=== {event.upper()} ===")
        print(f"Event Time: {event_time}")
        print("\nPeak Volatility:")
        print(f"5Y Max Range: {event_metrics['USOSFR5_max_diff']:.2f} bps")
        print(f"10Y Max Range: {event_metrics['USOSFR10_max_diff']:.2f} bps")
        print(f"\nCumulative Impact:")
        print(f"5Y Net Change: {event_metrics['USOSFR5_event_impact']:.2f} bps")
        print(f"10Y Net Change: {event_metrics['USOSFR10_event_impact']:.2f} bps")
        print(f"\nVolatility Score: {event_metrics['composite_score']:.2f} (Percentile)")
    
    # 3. Term Structure Impact Analysis
    major_event_data = window_data_df[
        window_data_df['event'].isin(major_events['event']) & 
        (window_data_df['hour_offset'].between(-1, 1))
    ]
    
    plt.figure(figsize=(14, 7))
    sns.boxplot(data=major_event_data, x='event', y='diff', hue='instrument',
               order=major_events.sort_values('composite_score', ascending=False)['event'])
    plt.title('Immediate Impact (1hr Before/After Event)')
    plt.ylabel('Price Range (bps)')
    plt.xlabel('')
    plt.xticks(rotation=45, ha='right')
    plt.legend(title='Tenor')
    plt.tight_layout()
    plt.show()
    
    # 4. Tenor Comparison Scatter Plot
    plt.figure(figsize=(10, 8))
    sns.scatterplot(data=major_events, 
                   x='USOSFR5_max_diff', 
                   y='USOSFR10_max_diff',
                   hue='event',
                   s=200,
                   alpha=0.7)
    
    max_val = max(major_events[['USOSFR5_max_diff', 'USOSFR10_max_diff']].max().max(), 20)
    plt.plot([0, max_val], [0, max_val], 'k--', alpha=0.3)
    plt.title('5Y vs 10Y Volatility During Major Events')
    plt.xlabel('5Y Max Hourly Range (bps)')
    plt.ylabel('10Y Max Hourly Range (bps)')
    plt.legend(bbox_to_anchor=(1.05, 1))
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.show()

# Add this to your main execution after the existing visualizations
if __name__ == '__main__':
    # ... (previous code)
    
    # Enhanced analysis
    analyze_major_events(results_df, window_data_df, baseline_df)
