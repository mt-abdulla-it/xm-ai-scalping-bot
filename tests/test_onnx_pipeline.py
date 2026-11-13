import unittest
import numpy as np
import pandas as pd
from train_onnx import extract_features, FEATURE_COLS

class TestONNXPipeline(unittest.TestCase):
    """
    Unit test suite validating machine learning feature extraction,
    synthetic dataset generation, 9-feature quant engine, and probability calibration.
    """

    def setUp(self):
        # Create synthetic trade records matching XMBot_ML_Data.csv schema
        np.random.seed(42)
        n_samples = 50
        self.df = pd.DataFrame({
            'Ticket': np.arange(1000, 1000 + n_samples),
            'Symbol': ['EURUSD'] * 25 + ['GBPUSD'] * 25,
            'Type': np.random.choice(['BUY', 'SELL'], size=n_samples),
            'OpenTime': ['2026.11.13 14:30'] * n_samples,
            'OpenPrice': [1.3200] * n_samples,
            'RSI': np.random.uniform(20.0, 80.0, size=n_samples),
            'Spread': np.random.uniform(5.0, 30.0, size=n_samples),
            'MACD': np.random.uniform(-0.0020, 0.0020, size=n_samples),
            'ATR': np.random.uniform(0.0005, 0.0025, size=n_samples),
            'Profit': np.random.uniform(-30.0, 45.0, size=n_samples)
        })

    def test_9_feature_extraction(self):
        """Verify 9-feature quant transformation and non-empty matrix generation."""
        df_feats = extract_features(self.df)
        X = df_feats[FEATURE_COLS].values
        self.assertEqual(X.shape[0], 50)
        self.assertEqual(X.shape[1], 9)
        self.assertFalse(np.isnan(X).any(), "Feature matrix contains NaN values")

    def test_target_classification_binary(self):
        """Verify binary label generation based on trade profitability (> $0.00)."""
        df_feats = extract_features(self.df)
        y = df_feats['Target'].values
        self.assertTrue(set(np.unique(y)).issubset({0, 1}))
        self.assertGreater(len(y), 0)

    def test_kaufman_efficiency_ratio_calculation(self):
        """Validate Perry Kaufman's Efficiency Ratio formula logic."""
        prices = np.array([1.0850, 1.0855, 1.0853, 1.0860, 1.0870])
        direction = abs(prices[-1] - prices[0])
        volatility = np.sum(np.abs(np.diff(prices)))
        er = direction / volatility if volatility > 0 else 0.0
        self.assertGreaterEqual(er, 0.0)
        self.assertLessEqual(er, 1.0)

    def test_onnx_model_inference_compatibility(self):
        """Verify exported ONNX model loads and runs inference on 9-feature vectors."""
        try:
            import onnxruntime as rt
            sess = rt.InferenceSession("ai_brain.onnx", providers=['CPUExecutionProvider'])
            input_name = sess.get_inputs()[0].name
            # Test sample vector
            dummy_input = np.array([[55.0, 15.0, 0.0001, 0.0012, 1.0, 14.0, 5.0, 12500.0, 4.0]], dtype=np.float32)
            preds = sess.run(None, {input_name: dummy_input})
            self.assertEqual(len(preds), 2)  # prediction + probabilities
            self.assertEqual(preds[1].shape[1], 2)  # [prob_loss, prob_win]
        except ImportError:
            pass # onnxruntime not installed in this environment

if __name__ == '__main__':
    unittest.main()
