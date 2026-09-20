import os
import glob
import pandas as pd
import numpy as np

# ==============================================================================
# 📊 AUTOMATED MACHINE LEARNING TRAINER FOR AI SCALPER (XMBot_ML_Data.csv)
# ==============================================================================

def get_mt5_files_dir():
    base_dir = os.path.expanduser("~/.wine/drive_c")
    found_files = []
    
    if os.path.exists(base_dir):
        for root, dirs, files in os.walk(base_dir):
            for file in files:
                if file.lower() == "xmbot_ml_data.csv":
                    full_path = os.path.join(root, file)
                    try:
                        mtime = os.path.getmtime(full_path)
                        found_files.append((mtime, root))
                    except Exception:
                        pass

    if found_files:
        found_files.sort(key=lambda x: x[0], reverse=True)
        return found_files[0][1]

    roaming_search = glob.glob(os.path.expanduser("~/.wine/drive_c/users/*/*/MetaQuotes/Terminal/*/MQL5/Files"))
    if roaming_search:
        return roaming_search[0]

    return os.path.expanduser("~/.wine/drive_c/Program Files/XM Global MT5/MQL5/Files")

def train_model():
    print("==========================================================")
    print("📊 AI SCALPER MACHINE LEARNING MODEL TRAINER")
    print("==========================================================")

    mt5_dir = get_mt5_files_dir()
    ml_file = os.path.join(mt5_dir, "XMBot_ML_Data.csv")

    if not os.path.exists(ml_file):
        print(f"❌ Error: ML dataset file not found at: {ml_file}")
        print("💡 Run gemini_ai_brain.py or MT5 EA to generate trade history dataset.")
        return

    print(f"📂 Loading ML dataset from: {ml_file}")
    
    try:
        df = pd.read_csv(ml_file)
        print(f"📊 Dataset Size: {len(df)} trade setup records loaded.\n")
        
        if len(df) < 5:
            print("⚠️ Notice: Need at least 5 trade setup records to train ML model effectively.")
            return

        print("📈 Sample Logged Features:")
        print(df.tail(5))
        print("-" * 58)

        # Check Schema Type A (Historical Ticket PnL Data)
        if 'Profit' in df.columns and 'Type' in df.columns:
            print("🔍 Schema Detected: Historical Executed Trade Ticket Dataset")
            df['Profit'] = pd.to_numeric(df['Profit'], errors='coerce')
            feature_cols = ['RSI', 'Spread', 'MACD', 'ATR']
            for col in feature_cols:
                if col in df.columns:
                    df[col] = pd.to_numeric(df[col], errors='coerce')
            df['Type_Code'] = df['Type'].astype(str).map({'BUY': 1, 'SELL': -1}).fillna(0)
            all_cols = feature_cols + ['Type_Code']
            df = df.dropna(subset=['Profit'] + feature_cols)
            
            df['Target'] = (df['Profit'] > 0).astype(int)  # 1 for Win (> $0.00), 0 for Loss
            X = df[all_cols].fillna(0)
            y = df['Target']
            feature_cols = all_cols
            
            wins = sum(y == 1)
            losses = sum(y == 0)
            total = len(y)
            win_rate = (wins / total) * 100 if total > 0 else 0
            print(f"📈 Total Executed Trades: {total} | Wins: {wins} | Losses: {losses} | Win Rate: {win_rate:.1f}%")

            # Built-in Statistical ML Feature Analyzer
            print("\n🧠 ML Feature Analysis & Win-Rate Optimization:")
            winning_trades = df[df['Profit'] > 0]
            losing_trades  = df[df['Profit'] <= 0]
            
            if not winning_trades.empty and not losing_trades.empty:
                print(f"   ├─ Avg RSI on Winning Trades: {winning_trades['RSI'].mean():.2f} (Losses: {losing_trades['RSI'].mean():.2f})")
                print(f"   ├─ Avg Spread on Winning Trades: {winning_trades['Spread'].mean():.1f} pts (Losses: {losing_trades['Spread'].mean():.1f} pts)")
                print(f"   └─ Avg ATR Volatility on Wins: {winning_trades['ATR'].mean():.5f}")
            
            buy_wins = winning_trades[winning_trades['Type'] == 'BUY']
            sell_wins = winning_trades[winning_trades['Type'] == 'SELL']

            if not buy_wins.empty:
                print(f"\n💡 ML Auto-Tuned Recommendation for BUY Setups:")
                print(f"   └─ Optimal Buy RSI Zone: <= {buy_wins['RSI'].quantile(0.5):.1f}")
            if not sell_wins.empty:
                print(f"\n💡 ML Auto-Tuned Recommendation for SELL Setups:")
                print(f"   └─ Optimal Sell RSI Zone: >= {sell_wins['RSI'].quantile(0.5):.1f}")

        # Schema Type B (Live Telemetry Decision Data)
        elif 'Decision' in df.columns:
            print("🔍 Schema Detected: Live Telemetry Decision Dataset")
            df['Trend_Code'] = df['Trend'].astype(str).map({'BULLISH': 1, 'BEARISH': -1}).fillna(0)
            df['Target'] = df['Decision'].astype(str).map({'BUY': 1, 'SELL': 2}).fillna(0)

            feature_cols = ['RSI', 'Spread', 'Trend_Code']
            X = df[feature_cols].fillna(0)
            y = df['Target']
        else:
            print("❌ Error: Unrecognized CSV column structure.")
            return

        # Attempt Scikit-Learn Model Training if installed
        try:
            from sklearn.ensemble import RandomForestClassifier
            from sklearn.model_selection import train_test_split

            if len(df) >= 10:
                X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
                clf = RandomForestClassifier(n_estimators=100, max_depth=5, random_state=42)
                clf.fit(X_train, y_train)
                acc = clf.score(X_test, y_test)
                
                print(f"\n🎉 ML Random Forest Classifier Trained!")
                print(f"🎯 Model Prediction Accuracy: {acc * 100:.1f}%")
                
                print("\n📊 Feature Importance Weightings:")
                for name, imp in zip(feature_cols, clf.feature_importances_):
                    print(f"   ├─ {name}: {imp * 100:.1f}%")
        except ImportError:
            pass

        print("\n==========================================================")
        print("✅ ML Dataset Analysis Complete!")
        print("==========================================================")

    except Exception as e:
        print(f"⚠️ Training error: {e}")

if __name__ == "__main__":
    train_model()
