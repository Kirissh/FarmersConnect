import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
import matplotlib.pyplot as plt

# Crop Data Simulation (Based on Agmarknet seasonality and common trends in India)
CROPS = ["Tomato", "Onion", "Wheat", "Rice"]

def generate_historical_data():
    """Generates synthetic historical crop price data for the last 2 years."""
    data = []
    base_date = datetime.now() - timedelta(days=730)
    
    for crop in CROPS:
        # Base price and seasonal amplitude
        if crop == "Tomato":
            base, amp, noise = 20, 25, 5
        elif crop == "Onion":
            base, amp, noise = 25, 15, 3
        elif crop == "Wheat":
            base, amp, noise = 22, 5, 2
        else: # Rice
            base, amp, noise = 35, 4, 1
            
        for day in range(730):
            current_date = base_date + timedelta(days=day)
            # Seasonal factor (Sinosoidal based on Julian day, capturing monsoon/harvest cycles)
            month = current_date.month
            seasonal_factor = np.sin((month / 12.0) * 2 * np.pi) * amp
            
            # Random fluctuations
            random_factor = np.random.normal(0, noise)
            
            # Trend factor (General inflation ~5% per year)
            trend_factor = (day / 365) * 1.05
            
            price = base + seasonal_factor + trend_factor + random_factor
            price = max(price, 5) # Ensure price doesn't go below 5
            
            data.append({
                "Date": current_date,
                "Crop": crop,
                "Price": round(price, 2)
            })
            
    return pd.DataFrame(data)

class CropPredictor:
    def __init__(self, data):
        self.df = data
        self.models = {}
        
    def train_models(self):
        """Trains a Polynomial Regression model for each crop."""
        for crop in CROPS:
            crop_df = self.df[self.df["Crop"] == crop].copy()
            
            # Features: Days since start
            start_date = crop_df["Date"].min()
            crop_df["DaysFromStart"] = (crop_df["Date"] - start_date).dt.days
            
            X = crop_df["DaysFromStart"].values.reshape(-1, 1)
            y = crop_df["Price"].values
            
            # Use Polynomial degree 3 to capture curves (U-shape/Inverse-U seasonal cycles)
            poly = PolynomialFeatures(degree=3)
            X_poly = poly.fit_transform(X)
            
            model = LinearRegression()
            model.fit(X_poly, y)
            
            self.models[crop] = (model, poly, start_date)
            
    def predict_next_month(self):
        """Returns predictions and trends for all crops for the next 30 days."""
        predictions = []
        today = datetime.now()
        next_month = today + timedelta(days=30)
        
        for crop in CROPS:
            model, poly, start_date = self.models[crop]
            
            # Predict for today and 30 days later to calculate trend
            days_today = (today - start_date).days
            days_future = (next_month - start_date).days
            
            p_today = model.predict(poly.transform([[days_today]]))[0]
            p_future = model.predict(poly.transform([[days_future]]))[0]
            
            trend = "Rising" if p_future > p_today * 1.02 else ("Falling" if p_future < p_today * 0.98 else "Stable")
            change = ((p_future - p_today) / p_today) * 100
            
            predictions.append({
                "Crop": crop,
                "Current_Price": round(p_today, 2),
                "Predicted_Price": round(p_future, 2),
                "Trend": trend,
                "Change_%": round(change, 1)
            })
            
        return pd.DataFrame(predictions)

def main():
    print("--- [ Farmers Connect | Crop Price Predictor ] ---")
    print("Analyzing historical trends (Synthetic Data)...")
    
    historical_data = generate_historical_data()
    predictor = CropPredictor(historical_data)
    predictor.train_models()
    
    print("\n[ Next 30-Day Outlook ]")
    forecast = predictor.predict_next_month()
    print(forecast.to_string(index=False))
    
    # Save the chart
    plt.figure(figsize=(10, 6))
    for crop in CROPS:
        crop_df = historical_data[historical_data["Crop"] == crop]
        plt.plot(crop_df["Date"], crop_df["Price"], label=crop, alpha=0.3)
    
    plt.title("2-Year Crop Price History & Trends")
    plt.xlabel("Date")
    plt.ylabel("Price (₹/kg)")
    plt.legend()
    plt.grid(True, alpha=0.2)
    
    chart_path = "/Users/kirissh/FarmersConnect/FarmersConnect/Analysis/price_trends.png"
    plt.savefig(chart_path)
    print(f"\nPrice trend chart saved at: {chart_path}")

if __name__ == "__main__":
    main()
