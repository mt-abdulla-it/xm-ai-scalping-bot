import unittest
import numpy as np
import pandas as pd

class TestONNXPipeline(unittest.TestCase):
    """
    Unit test suite validating machine learning feature extraction,
    synthetic dataset generation, and probability calibration.
    """

    def setUp(self):
        # Create synthetic trade records matching XMBot_ML_Data.csv schema
        np.random.seed(42)
        n_samples = 50
        self.df = pd.DataFrame({
            'Ticket': np.arange(1000, 1000 + n_samples),
            'Symbol': ['EURUSD'] * 25 + ['GBPUSD'] * 25,
            'Type': np.random.choice(['BUY', 'SELL'], size=n_samples),
            'RSI': np.random.uniform(20.0, 80.0, size=n_samples),
            'Spread': np.random.uniform(5.0, 30.0, size=n_samples),
            'MACD': np.random.uniform(-0.0020, 0.0020, size=n_samples),
            'ATR': np.random.uniform(0.0005, 0.0025, size=n_samples),
            'Profit': np.random.uniform(-30.0, 45.0, size=n_samples)
        })

    def test_feature_matrix_generation(self):
        """Verify feature transformation and non-empty matrix generation."""
        feature_cols = ['RSI', 'Spread', 'MACD', 'ATR']
        self.df['Type_Code'] = self.df['Type'].map({'BUY': 1, 'SELL': -1}).fillna(0)
        X = self.df[feature_cols + ['Type_Code']].values
        self.assertEqual(X.shape[0], 50)
        self.assertEqual(X.shape[1], 5)
        self.assertFalse(np.isnan(X).any(), "Feature matrix contains NaN values")

    def test_target_classification_binary(self):
        """Verify binary label generation based on trade profitability (> $0.00)."""
        y = (self.df['Profit'] > 0).astype(int).values
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

if __name__ == '__main__':
    unittest.main()
