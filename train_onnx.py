import os
import glob
import pandas as pd
import numpy as np
import sys

try:
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.model_selection import train_test_split
except ImportError:
    print("❌ scikit-learn is missing. Run: pip install scikit-learn pandas numpy")
    sys.exit(1)

try:
    from skl2onnx import convert_sklearn
    from skl2onnx.common.data_types import FloatTensorType
except ImportError:
    print("❌ skl2onnx is missing. Run: pip install skl2onnx onnx")
    sys.exit(1)

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

def train_onnx_model():
    print("==========================================================")
    print("🧠 AI SCALPER - ONNX MODEL GENERATOR")
    print("==========================================================")

    mt5_dir = get_mt5_files_dir()
    ml_file = os.path.join(mt5_dir, "XMBot_ML_Data.csv")

    if not os.path.exists(ml_file):
        print(f"❌ Error: ML dataset file not found at: {ml_file}")
        print("💡 Run the MT5 EA to generate trade history dataset first.")
        return

    print(f"📂 Loading ML dataset from: {ml_file}")
    df = pd.read_csv(ml_file)
    print(f"📊 Dataset Size: {len(df)} trade setup records loaded.\n")
    
    if len(df) < 10:
        print("⚠️ Error: Need at least 10 trade setup records to train the ONNX AI.")
        return

    if 'Profit' in df.columns and 'Type' in df.columns:
        df['Target'] = (df['Profit'] > 0).astype(int)  
        df['Type_Code'] = df['Type'].astype(str).map({'BUY': 1, 'SELL': -1}).fillna(0)
        
        feature_cols = ['RSI', 'Spread', 'MACD', 'ATR', 'Type_Code']
        
        for col in feature_cols:
            if col not in df.columns:
                df[col] = 0.0
            # Force numeric conversion to clear out old corrupted string rows like 'BEARISH'
            df[col] = pd.to_numeric(df[col], errors='coerce')

        # Drop any rows that failed conversion
        df = df.dropna(subset=feature_cols)
        
        if len(df) < 10:
            print("⚠️ Error: After cleaning old data, not enough records left to train.")
            return

        X = df[feature_cols].astype(np.float32)
        y = df['Target']
        
        print(f"📈 Extracting {len(feature_cols)} Features: {feature_cols}")
        
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        
        print("⚙️ Training Random Forest AI Model...")
        clf = RandomForestClassifier(n_estimators=100, max_depth=5, random_state=42)
        clf.fit(X_train, y_train)
        acc = clf.score(X_test, y_test)
        
        print(f"🎯 Model Prediction Accuracy: {acc * 100:.1f}%\n")
        
        print("🔄 Converting AI Model to ONNX format...")
        initial_type = [('float_input', FloatTensorType([None, len(feature_cols)]))]
        onnx_model = convert_sklearn(clf, initial_types=initial_type, target_opset=12, options={type(clf): {'zipmap': False}})
        
        onnx_path = os.path.join(mt5_dir, "ai_brain.onnx")
        with open(onnx_path, "wb") as f:
            f.write(onnx_model.SerializeToString())
            
        print(f"✅ ONNX AI Model Saved Successfully!")
        print(f"📂 Location: {onnx_path}")
        print("\n💡 NEXT STEP: Recompile the MT5 Bot to activate the ONNX AI!")
        
    else:
        print("❌ Error: Unrecognized CSV column structure.")
        return

if __name__ == "__main__":
    train_onnx_model()
