import os
import glob
import json
import pandas as pd
import numpy as np
import sys
from datetime import datetime

try:
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.model_selection import StratifiedKFold, cross_val_score, train_test_split
except ImportError:
    print("❌ scikit-learn is missing. Run: pip install scikit-learn pandas numpy")
    sys.exit(1)

try:
    from skl2onnx import convert_sklearn
    from skl2onnx.common.data_types import FloatTensorType
except ImportError:
    print("❌ skl2onnx is missing. Run: pip install skl2onnx onnx")
    sys.exit(1)

FEATURE_COLS = [
    'RSI',              # 1. Momentum oscillator
    'Spread',           # 2. Broker transaction friction
    'MACD',             # 3. Trend velocity & divergence
    'ATR',              # 4. Market volatility range
    'Type_Code',        # 5. Direction (BUY=1, SELL=-1)
    'Hour',             # 6. Session timing (London/NY liquidity)
    'RSI_Dev',          # 7. Deviation from neutral 50 level
    'Spread_ATR_Ratio', # 8. Friction-to-volatility ratio
    'DayOfWeek'         # 9. Day of week (0=Mon, 4=Fri)
]

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

def extract_features(df):
    """Engineers high-impact quantitative features from raw trade data."""
    df = df.copy()
    
    # 1. Clean profit & binary target
    df['Profit'] = pd.to_numeric(df['Profit'], errors='coerce')
    df = df.dropna(subset=['Profit'])
    df['Target'] = (df['Profit'] > 0).astype(int)
    
    # 2. Type direction
    df['Type_Code'] = df['Type'].astype(str).map({'BUY': 1, 'SELL': -1}).fillna(0)
    
    # 3. Base numeric features
    for col in ['RSI', 'Spread', 'MACD', 'ATR']:
        if col not in df.columns:
            df[col] = 0.0
        df[col] = pd.to_numeric(df[col], errors='coerce')
        
    df = df.dropna(subset=['RSI', 'Spread', 'MACD', 'ATR'])
    
    # 4. Temporal Features
    df['dt'] = pd.to_datetime(df['OpenTime'], format='%Y.%m.%d %H:%M', errors='coerce')
    df['Hour'] = df['dt'].dt.hour.fillna(12).astype(float)
    df['DayOfWeek'] = df['dt'].dt.dayofweek.fillna(2).astype(float)
    
    # 5. Non-linear interaction features
    df['RSI_Dev'] = (df['RSI'] - 50.0).abs()
    df['Spread_ATR_Ratio'] = df['Spread'] / (df['ATR'] + 1e-5)
    
    return df

def train_onnx_model():
    print("==========================================================")
    print("🧠 AI SCALPER - ENHANCED 9-FEATURE ONNX MODEL GENERATOR")
    print("==========================================================")

    mt5_dir = get_mt5_files_dir()
    ml_file = os.path.join(mt5_dir, "XMBot_ML_Data.csv")

    if not os.path.exists(ml_file):
        print(f"❌ Error: ML dataset file not found at: {ml_file}")
        print("💡 Run the MT5 EA to generate trade history dataset first.")
        return None

    print(f"📂 Loading ML dataset from: {ml_file}")
    raw_df = pd.read_csv(ml_file)
    print(f"📊 Dataset Size: {len(raw_df)} trade setup records loaded.\n")
    
    if len(raw_df) < 50:
        print("⚠️ Error: Need at least 50 trade setup records to train the enhanced ONNX AI.")
        return None

    df = extract_features(raw_df)
    
    if len(df) < 50:
        print("⚠️ Error: After cleaning, not enough valid records left.")
        return None

    X = df[FEATURE_COLS].astype(np.float32)
    y = df['Target'].astype(int)
    
    print(f"📈 Extracting {len(FEATURE_COLS)} High-Impact Features:")
    for i, col in enumerate(FEATURE_COLS, 1):
        print(f"   [{i}] {col}")

    # 5-Fold Stratified Cross-Validation
    cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=42)
    clf = RandomForestClassifier(
        n_estimators=250,
        max_depth=6,
        min_samples_split=4,
        class_weight="balanced",
        random_state=42,
        n_jobs=-1
    )
    
    print("\n⚙️ Running 5-Fold Stratified Cross-Validation...")
    cv_scores = cross_val_score(clf, X, y, cv=cv, scoring="accuracy")
    mean_acc = cv_scores.mean() * 100
    std_acc = cv_scores.std() * 100
    print(f"🎯 5-Fold CV Accuracy: {mean_acc:.2f}% (+/- {std_acc:.2f}%)")

    # Train production model on full dataset
    clf.fit(X, y)

    # Feature Importance Breakdown
    print("\n📊 Feature Importance Ranking:")
    for f, imp in sorted(zip(FEATURE_COLS, clf.feature_importances_), key=lambda x: x[1], reverse=True):
        print(f"   • {f:18s}: {imp*100:5.2f}%")

    print("\n🔄 Converting Production Model to ONNX format...")
    initial_type = [('float_input', FloatTensorType([None, len(FEATURE_COLS)]))]
    onnx_model = convert_sklearn(
        clf,
        initial_types=initial_type,
        target_opset=12,
        options={type(clf): {'zipmap': False}}
    )
    
    onnx_bytes = onnx_model.SerializeToString()
    
    # Save to MT5 Files directory
    onnx_path = os.path.join(mt5_dir, "ai_brain.onnx")
    with open(onnx_path, "wb") as f:
        f.write(onnx_bytes)
        
    # Save local copy in repo root
    local_path = os.path.join(os.getcwd(), "ai_brain.onnx")
    with open(local_path, "wb") as f:
        f.write(onnx_bytes)
        
    # Save metadata state
    state = {
        "timestamp": datetime.now().isoformat(),
        "total_records": len(df),
        "features": FEATURE_COLS,
        "cv_accuracy": round(mean_acc, 2),
        "target_win_ratio": round((y.sum() / len(y)) * 100, 2)
    }
    with open(".ml_state.json", "w") as f:
        json.dump(state, f, indent=2)

    print(f"\n✅ Enhanced ONNX AI Model Saved Successfully!")
    print(f"   ├─ MT5 Path:  {onnx_path}")
    print(f"   ├─ Repo Path: {local_path}")
    print(f"   └─ State:     .ml_state.json ({len(df)} records, {mean_acc:.2f}% acc)")
    
    return state

if __name__ == "__main__":
    train_onnx_model()
