from flask import Flask, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
import os

app = Flask(__name__)
CORS(app) # Allow iOS app (cross-origin) to call local server

CROPS = ["Tomato", "Onion", "Wheat", "Rice"]

# --- [ MOCK HISTORICAL DATA ENGINE ] ---
# In production, this function will call the data.gov.in API to get REAL Mandi prices.
def get_historical_data():
    """Generates synthetic historical crop price data for the last 2 years."""
    data = []
    base_date = datetime.now() - timedelta(days=730)
    
    for crop in CROPS:
        # Seasonality profiles for Indian crops (Price increases in monsoon/off-season)
        if crop == "Tomato": base, amp, noise = 20, 25, 5
        elif crop == "Onion": base, amp, noise = 25, 15, 3
        elif crop == "Wheat": base, amp, noise = 22, 5, 2
        else: base, amp, noise = 35, 4, 1
            
        for day in range(730):
            current_date = base_date + timedelta(days=day)
            month = current_date.month
            seasonal_factor = np.sin((month / 12.0) * 2 * np.pi) * amp
            random_factor = np.random.normal(0, noise)
            trend_factor = (day / 365) * 1.05
            
            price = max(base + seasonal_factor + trend_factor + random_factor, 5)
            data.append({"date": current_date.strftime("%Y-%m-%d"), "crop": crop, "price": round(price, 2)})
            
    return pd.DataFrame(data)

# --- [ PREDICTION ENGINE ] ---
def calculate_predictions(df):
    results = []
    today = datetime.now()
    next_month = today + timedelta(days=30)
    
    for crop in CROPS:
        crop_df = df[df["crop"] == crop].copy()
        crop_df["date"] = pd.to_datetime(crop_df["date"])
        start_date = crop_df["date"].min()
        crop_df["days"] = (crop_df["date"] - start_date).dt.days
        
        X = crop_df["days"].values.reshape(-1, 1)
        y = crop_df["price"].values
        
        # Polynomial fit (Degree 3) captures seasonal cycles best
        poly = PolynomialFeatures(degree=3)
        X_poly = poly.fit_transform(X)
        model = LinearRegression().fit(X_poly, y)
        
        # Forecasts
        days_today = (today - start_date).days
        days_future = (next_month - start_date).days
        
        p_today = model.predict(poly.transform([[days_today]]))[0]
        p_future = model.predict(poly.transform([[days_future]]))[0]
        
        diff = p_future - p_today
        trend = "Price Up" if diff > (p_today * 0.02) else ("Price Down" if diff < -(p_today * 0.02) else "Stable")
        
        results.append({
            "crop": crop,
            "current_price": round(p_today, 2),
            "predicted_price": round(p_future, 2),
            "trend": trend,
            "change_pct": round((diff / p_today) * 100, 1),
            "insight": f"Expect {trend.lower()} for {crop} next month based on seasonal trend."
        })
        
    return results

# --- [ API ENDPOINTS ] ---

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "Online", "v": "1.0.0", "timestamp": str(datetime.now())})

@app.route('/api/v1/forecast', methods=['GET'])
def get_forecast():
    """Returns predictions for top selling crops."""
    print("[API] Calculating crop forecasts...")
    history = get_historical_data()
    predictions = calculate_predictions(history)
    return jsonify(predictions)

@app.route('/api/v1/history', methods=['GET'])
def get_history():
    """Returns 30 days of historical data (for charts)."""
    history = get_historical_data()
    # Return last 30 days for each crop
    history["date"] = pd.to_datetime(history["date"])
    recent = history[history["date"] > (datetime.now() - timedelta(days=30))]
    return jsonify(recent.to_dict(orient="records"))

if __name__ == '__main__':
    # Local dev server runs on http://127.0.0.1:5001
    print("--- [ Farmers Connect | AI Price Engine API ] ---")
    print("Starting Flask server for iOS integration...")
    app.run(host='0.0.0.0', port=5001, debug=True)
