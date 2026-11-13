//+------------------------------------------------------------------+
//|                                          XM_AI_ScalpingBot.mq5   |
//|                        AI-Powered Scalping Expert Advisor         |
//|                            For XM MetaTrader 5                    |
//+------------------------------------------------------------------+
#property copyright   "AI Trading Bot"
#property link        "https://www.xm.com"
#property version     "16.10"
#property description "AI-Powered Institutional Scalping Bot"
#property description "🛡️ v16.10 0.10-LOT PRO ACCELERATOR"
#property description "Top 20 Portfolio | Safe 0.10 Lot ($15-$25 Win) | $30 Loss Shield"

//--- Include the trade library
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//| INPUT PARAMETERS — MT5 Settings-la Adjust Pannalam               |
//+------------------------------------------------------------------+

//--- Gemini AI Bridge (Removed - 100% Standalone MQL5 Agent)

//--- Risk Management Inputs
input group "=== 👑 $100 Account Risk Management ==="
input double   InpRiskPercent      = 1.0;     // 🛡️ 1.0% Risk per trade
input double   InpMaxAllowedLot    = 0.10;    // 🛡️ Global Hard Max Lot (Pro 0.10 Lot Scaling: +$15 to +$25 per Win)
input bool     InpUseCompounding   = true;    // Auto-compounding lot sizing enabled?
input bool     InpUseKellyCriterion = false;  // ⛔ DISABLED - dangerous on micro accounts < $500
input double   InpDailyProfitTargetPercent = 10.0; // 🎯 Stop trading if NET profit hits +10% ($10 today)
input double   InpDailyProfitTrailingTriggerPercent = 3.0; // 🛡️ Start locking profit after +3% ($3)
input double   InpDailyProfitTrailingLockPercent    = 1.5;  // 🛡️ Lock at least +1.5% ($1.50)
input double   InpDailyLossLimitPercent = 3.0;  // ⛔ Daily Loss Limit 3.0% (Max -$3.00 on $100 balance)
input double   InpMaxDrawdownPercent   = 3.0;   // Maximum Equity Drawdown Shield (3.0%)
input double   InpMaxDollarLossPerTrade = 30.00; // 🛡️ Hard Dollar Loss Shield ($30.00 max loss cap per trade for 0.10 lot)
input int      InpMaxOpenTrades    = 60;        // Max 60 total open trades across all pairs (Turbo-60 Portfolio)
input int      InpMaxTradesPerSymbol = 3;       // Max 3 open trades per symbol for fast scaling
input double   InpMaxSpreadPoints  = 35.0;    // Max spread 35 pts (allows major & cross pairs to trade)

//--- Anti-Whipsaw & Multi-Chart Guard
input group "=== ⏳ Anti-Whipsaw & Multi-Chart Protection ==="
input int      InpLossCooldownMinutes   = 1;      // ⏳ Loss Cooldown: Pause symbol for 1m after hitting Stop Loss (Hyper-Turbo)
input int      InpGlobalOrderBufferSeconds = 1;   // 🛡️ Global Order Lock: Min 1s between trades across charts (prevents race conditions)
input bool     InpAutoFilterLowWinSymbols  = false; // Auto-block disabled: all Top 20 pairs active with safe lot
input int      InpMaxConcurrentYenTrades   = 4;    // 🛡️ Max concurrent JPY trades (Allows up to 4 Yen pairs)

//--- Market Sentiment (Order Flow)
input group "=== 📊 Order Flow (DOM) ==="
input bool     InpUseDOM_Filter    = true;    // 🛡️ Avoid trading into Sell/Buy Walls
input double   InpDOM_WallRatio    = 3.0;     // Ratio to consider as Wall (e.g. 3x volume)

//--- News Filter Settings
input group "=== 📰 News Filter ==="
input bool     InpAvoidHighImpactNews = false; // ⚡ Disabled for dataset gathering to allow continuous rapid-fire trades
input int      InpNewsPauseBefore     = 5;    // Pause trading 5 mins BEFORE news
input int      InpNewsPauseAfter      = 5;    // Pause trading 5 mins AFTER news

//--- KAMA (Kaufman Adaptive Moving Average) Inputs
input group "=== 📈 KAMA Settings (Rule 5) ==="
   input int      InpKAMA_Period      = 10;      // ER Period for KAMA
   input int      InpKAMA_Fast        = 2;       // Fast Smoothing Constant
   input int      InpKAMA_Slow        = 30;      // Slow Smoothing Constant

//--- EMA Crossover (Rule 4)
input group "=== 🌊 EMA Trend Surfing (Rule 4) ==="
input int      InpEmaFast          = 9;       // Fast EMA
input int      InpEmaSlow          = 21;      // Slow EMA

//--- MTF (Multi-Timeframe) Trend Filter
input group "=== ⏱️ MTF Trend Filter ==="
input bool           InpUseMTFFilter   = false;        // Fast Scalping: disabled to allow both BUY & SELL M5 swings
input ENUM_TIMEFRAMES InpTrendTimeframe = PERIOD_H1;    // Higher Timeframe — H1 for strong trend (Elder Triple Screen)
input int            InpTrendEMA       = 50;           // EMA Period for Trend Filter

//--- Pin Bar Reversal Strategy
input group "=== 📌 Pin Bar Reversal Strategy ==="
input bool     InpUsePinBarReversal = true;   // Trade Pin Bar Reversals (Counter-Trend)
//--- RSI (Relative Strength Index) Inputs
input group "=== 📊 RSI Settings ==="
input int      InpRSI_Period       = 14;      // RSI Period
input double   InpRSI_BuyMax       = 80.0;    // 📈 (Relaxed) RSI maximum for BUY (don't chase overbought)
input double   InpRSI_BuyMin       = 20.0;    // 📈 (Relaxed) RSI minimum for BUY (don't buy at extreme oversold)
input double   InpRSI_SellMax      = 80.0;    // 📉 (Relaxed) RSI maximum for SELL (don't sell at extreme overbought)
input double   InpRSI_SellMin      = 20.0;    // 📉 (Relaxed) RSI minimum for SELL (don't chase oversold)

//--- ONNX AI Machine Learning
input group "=== 🧠 ONNX AI Machine Learning ==="
input bool     InpUseONNX_AI       = true;    // 🧠 ONNX AI Win-Probability Filter (ACTIVATED!)
input double   InpONNX_MinProb     = 0.50;    // Minimum Win Probability (50%)

//--- SMC (Smart Money Concepts) Settings
input group "=== 🏛️ Smart Money Concepts (SMC) ==="
input bool     InpUseSMC_FVG       = false;   // (Turned OFF for Scalping) Only trade inside Fair Value Gaps (FVG)
input int      InpFVG_Lookback     = 10;      // FVG Lookback bars

//--- Multi-Currency Correlation Settings
input group "=== 🌍 Multi-Currency Correlation ==="
input bool     InpUseCorrelation   = false;   // (Turned OFF for Scalping) Use correlation filter
input string   InpCorrSymbol       = "USDCHF"; // Inversely correlated symbol
input int      InpCorrEmaPeriod    = 21;      // Trend EMA for correlated symbol

//--- MACD Inputs
input group "=== 📉 MACD Settings ==="
input int      InpMACD_Fast        = 12;      // MACD Fast EMA
input int      InpMACD_Slow        = 26;      // MACD Slow EMA
input int      InpMACD_Signal      = 9;       // MACD Signal Period

//--- ATR (Average True Range) — SL/TP Calculation
input group "=== 📏 ATR & SL/TP Settings ==="
input bool     InpUseStealthMode   = true;    // 👻 Stealth Mode (Hide SL/TP from Broker)
input int      InpATR_Period       = 14;      // ATR Period
input double   InpSL_ATR_Multi     = 2.0;     // 🛡️ Stop Loss = ATR × 2.0
input double   InpTP_ATR_Multi     = 1.8;     // ⚡ Take Profit = ATR × 1.8 (Fast Micro-Scalp Profit Hits)

//--- Trailing Stop Settings
input group "=== 🔄 Trailing Stop Settings ==="
input bool     InpUseTrailingStop  = true;    // Enable dynamic ATR trailing stop
input double   InpTrailATR_Multi   = 0.8;     // ⚡ Trailing start: ATR × 0.8 (Locks profit sooner)
input double   InpTrailStepATR     = 0.5;     // ⚡ Trail step buffer: ATR × 0.5

//--- Session Filter Settings
input group "=== ⏰ Trading Session Filter ==="
input bool     InpTradeLondon      = true;    // London Session (08:00-16:00 GMT) - High Win %
input bool     InpTradeNewYork     = true;    // New York Session (13:00-21:00 GMT) - High Win %
input bool     InpTradeAsian       = true;    // Asian Session (Turned ON: 24/7 continuous trading to reach 1000 milestone)
input bool     InpUseGoldenHoursOnly = false; // 🛡️ Golden hours only (Set false for full London/NY sessions)

//--- General Settings
input group "=== ⚙️ General Settings ==="
input bool     InpAutoMultiSymbol  = false;   // 🌐 Auto-Scan All Top Low-Spread Pairs from 1 Single Chart?
input string   InpPortfolioSymbols = "EURUSD,GBPUSD,USDJPY"; // Portfolio symbols (GOLD & USDCHF removed - too volatile for micro account)
input int      InpMagicNumber      = 202609;  // Magic Number (unique bot ID)
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_CURRENT; // Trading Timeframe (Adapts to chart)
input bool     InpShowDashboard    = true;    // Show dashboard on chart?
input int      InpMinBarsBetween   = 0;       // ⚡ 0 bar cooldown between trades (Instant re-entry on new signal)

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                 |
//+------------------------------------------------------------------+

//--- Trade objects
CTrade         m_trade;
CPositionInfo  m_position;
CAccountInfo   m_account;
CSymbolInfo    m_symbol;

//--- Indicator handles
int            h_kama;              // KAMA handle
int            h_rsi;              // RSI handle
int            h_macd;             // MACD handle
int            h_atr;              // ATR handle
int            h_emaFast;          // Fast EMA handle
int            h_emaSlow;          // Slow EMA handle
int            h_emaTrend;         // MTF Trend EMA handle
int            h_corrEma;          // Correlation EMA handle
long           h_onnx = INVALID_HANDLE; // ONNX AI Model Handle

//--- Indicator buffers
double         bufKama[];
double         bufEmaFast[];
double         bufEmaSlow[];
double         bufEmaTrend[];
double         bufRSI[];
double         bufMACD_Main[];
double         bufMACD_Signal[];
double         bufATR[];

//--- Trading state
double         g_dailyStartBalance;  // Balance at start of day
datetime       g_lastTradeTime;      // Time of last trade
datetime       g_currentDay;         // Current trading day
int            g_totalTradesToday;   // Total trades today
int            g_winTrades;          // Winning trades count
int            g_lossTrades;         // Losing trades count
double         g_totalProfit;        // Total profit today
bool           g_dailyLossHit;       // Daily loss limit hit flag
double         g_maxDailyProfit;     // Highest profit reached today
double         g_dailyProfitLock;    // Dynamic profit lock
double         g_maxSpreadPoints;    // Adjusted max spread
double         g_initialDeposit;     // 🛡️ Initial deposit tracked for Total Drawdown Circuit Breaker
bool           g_accountHalted;      // 🛡️ TRUE = Account equity dropped below 50% of deposit → HALT

//--- Dashboard Status
string         g_signalStatus = "Scanning...";

//--- ML Data Collection
struct TradeData
{
   ulong    ticket;
   int      type;       // 0=BUY, 1=SELL
   double   rsi;
   double   macd;
   double   atr;
   double   spread;
   double   openPrice;
   datetime openTime;
};
TradeData g_activeTrades[]; // Dynamic array to hold open trades

//+------------------------------------------------------------------+
//| FUNCTION PROTOTYPES (MQL5 Compiler Forward Declarations)          |
//+------------------------------------------------------------------+
void     CheckNewDay();
bool     CheckDailyLimits();
bool     CheckEquityDrawdown();
bool     UpdateIndicators();
void     ManageOpenPositions();
void     ShadowManualTrades();
void     CheckClosedTradesAndLog();
bool     IsSpreadAcceptable();
bool     IsTradingSession();
bool     IsNewsTime();
int      CountOpenPositions();
int      CountOpenPositionsForSymbol(string symbol);
int      CountOpenJPYPositions();
bool     IsMasterChart();
bool     IsMinBarsPassed();
int      GetTradeSignal();
void     ExecuteBuy();
void     ExecuteSell();
double   GetCurrentSpreadPoints();
void     UpdateDashboard(string status);
double   CalculateLotSize(double slDistancePrice, ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY);
bool     ValidateStopLevels(ENUM_ORDER_TYPE orderType, double price, double sl, double tp);
void     LogTrade(string symbol, double entry, double exit, double spread, double profit);
double   CalculateER(int period);
bool     CheckPriceShock(double currentATR);
bool     IsAnyPositionInLoss();
void     SetSymbolLossCooldown(string sym);
bool     IsSymbolInCooldown(string sym);
bool     IsGlobalOrderLockActive();
void     SetGlobalOrderLock();

//+------------------------------------------------------------------+
//| Expert initialization function                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Validate inputs
   if(InpRiskPercent <= 0 || InpRiskPercent > 10)
   {
      Print("❌ ERROR: Risk percent must be between 0.1 and 10!");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   if(InpDailyProfitTargetPercent <= 0 || InpDailyLossLimitPercent < 0)
   {
      Print("❌ ERROR: Daily target must be greater than 0!");
      return(INIT_PARAMETERS_INCORRECT);
   }

   //--- Setup dynamic variables
   g_maxSpreadPoints = InpMaxSpreadPoints;
   
   //--- Auto-detect GOLD (XAU), BTC & US30
   string sym = _Symbol;
   StringToUpper(sym);
   if(StringFind(sym, "GOLD") >= 0 || StringFind(sym, "XAU") >= 0)
   {
      g_maxSpreadPoints = 500.0; // Gold spread is much wider
      Print("🥇 GOLD Detected! Auto-adjusted Spread to ", g_maxSpreadPoints);
   }
   if(StringFind(sym, "BTC") >= 0 || StringFind(sym, "ETH") >= 0)
   {
      g_maxSpreadPoints = 5000.0; // Crypto spread allowance
      Print("🪙 Crypto Detected! Auto-adjusted Spread to ", g_maxSpreadPoints);
   }
   if(StringFind(sym, "US30") >= 0 || StringFind(sym, "US100") >= 0 || StringFind(sym, "US500") >= 0)
   {
      g_maxSpreadPoints = 500.0; // Index spread allowance
      Print("🚀 Index Detected! Auto-adjusted Spread to ", g_maxSpreadPoints);
   }

   //--- Ensure symbol is selected in Market Watch for active tick streaming
   SymbolSelect(_Symbol, true);

   //--- Initialize symbol info
   if(!m_symbol.Name(_Symbol))
   {
      Print("❌ ERROR: Failed to initialize symbol info for ", _Symbol);
      return(INIT_FAILED);
   }

   //--- Setup trade object
   m_trade.SetExpertMagicNumber(InpMagicNumber);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(10); // 1 pip slippage allowed
   
   //--- Create indicator handles
   h_kama      = iAMA(_Symbol, InpTimeframe, InpKAMA_Period, InpKAMA_Fast, InpKAMA_Slow, 0, PRICE_CLOSE);
   h_emaFast   = iMA(_Symbol, InpTimeframe, InpEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   h_emaSlow   = iMA(_Symbol, InpTimeframe, InpEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   h_rsi       = iRSI(_Symbol, InpTimeframe, InpRSI_Period, PRICE_CLOSE);
   h_macd      = iMACD(_Symbol, InpTimeframe, InpMACD_Fast, InpMACD_Slow, InpMACD_Signal, PRICE_CLOSE);
   h_atr       = iATR(_Symbol, InpTimeframe, InpATR_Period);
   
   if(InpUseMTFFilter)
   {
      h_emaTrend = iMA(_Symbol, InpTrendTimeframe, InpTrendEMA, 0, MODE_EMA, PRICE_CLOSE);
   }
   
   if(InpUseCorrelation)
   {
      SymbolSelect(InpCorrSymbol, true);
      h_corrEma = iMA(InpCorrSymbol, InpTimeframe, InpCorrEmaPeriod, 0, MODE_EMA, PRICE_CLOSE);
   }
   
   //--- Initialize ONNX Model
   if(InpUseONNX_AI)
   {
      h_onnx = OnnxCreate("ai_brain.onnx", ONNX_DEFAULT);
      if(h_onnx == INVALID_HANDLE)
      {
         Print("⚠️ Notice: ai_brain.onnx not found in MQL5/Files. AI Filter Disabled.");
      }
      else
      {
         long input_shape[] = {1, 5};
         if(!OnnxSetInputShape(h_onnx, 0, input_shape)) Print("❌ ONNX Input Shape Error");
         
         long output_shape1[] = {1};
         if(!OnnxSetOutputShape(h_onnx, 0, output_shape1)) Print("❌ ONNX Output Shape 1 Error");
         
         long output_shape2[] = {1, 2};
         if(!OnnxSetOutputShape(h_onnx, 1, output_shape2)) Print("❌ ONNX Output Shape 2 Error");
         
         Print("🧠 ONNX AI Brain Loaded Successfully!");
      }
   }
   
   //--- Validate all handles
   if(h_kama == INVALID_HANDLE || h_emaFast == INVALID_HANDLE || h_emaSlow == INVALID_HANDLE ||
      h_rsi == INVALID_HANDLE || h_macd == INVALID_HANDLE || 
      h_atr == INVALID_HANDLE || (InpUseMTFFilter && h_emaTrend == INVALID_HANDLE))
   {
      Print("❌ ERROR: Failed to create indicator handles!");
      return(INIT_FAILED);
   }
   
   //--- Set buffer arrays as series (newest data first)
   ArraySetAsSeries(bufKama, true);
   ArraySetAsSeries(bufEmaFast, true);
   ArraySetAsSeries(bufEmaSlow, true);
   ArraySetAsSeries(bufRSI, true);
   ArraySetAsSeries(bufMACD_Main, true);
   ArraySetAsSeries(bufMACD_Signal, true);
   ArraySetAsSeries(bufATR, true);
   ArraySetAsSeries(bufEmaTrend, true);
   
   //--- Initialize daily tracking
   g_dailyStartBalance = m_account.Balance();
   g_currentDay        = iTime(_Symbol, PERIOD_D1, 0);
   g_lastTradeTime     = 0;
   g_totalTradesToday  = 0;
   g_winTrades         = 0;
   g_lossTrades        = 0;
   g_totalProfit       = 0;
   g_dailyLossHit      = false;
   g_maxDailyProfit    = 0.0;
   g_dailyProfitLock   = -999.0;
   g_accountHalted     = false;
   
   //--- Total Drawdown Circuit Breaker: Track initial deposit (persists via GlobalVariable)
   string gvName = "XMBOT_InitialDeposit_" + IntegerToString(InpMagicNumber);
   if(GlobalVariableCheck(gvName))
   {
      g_initialDeposit = GlobalVariableGet(gvName);
      if(m_account.Balance() > g_initialDeposit * 1.5)
      {
         g_initialDeposit = m_account.Balance();
         GlobalVariableSet(gvName, g_initialDeposit);
         Print("🛡️ Circuit Breaker: Balance increased/reset to $", DoubleToString(g_initialDeposit, 2), " — GV updated!");
      }
      else
      {
         Print("🛡️ Circuit Breaker: Loaded initial deposit from GV: $", DoubleToString(g_initialDeposit, 2));
      }
   }
   else
   {
      g_initialDeposit = m_account.Balance();
      GlobalVariableSet(gvName, g_initialDeposit);
      Print("🛡️ Circuit Breaker: Set initial deposit: $", DoubleToString(g_initialDeposit, 2));
   }
   
   //--- Success message
   Print("✅ XM AI Scalping Bot initialized successfully!");
   Print("📊 Symbol: ", _Symbol, " | Timeframe: ", EnumToString(InpTimeframe));
   //--- Add DOM Order Book subscription
   if(InpUseDOM_Filter)
   {
      if(!MarketBookAdd(_Symbol))
         Print("⚠️ Warning: Broker does not support Depth of Market (DOM) for ", _Symbol, ". Sell Wall filter disabled.");
      else
         Print("📊 DOM Order Flow tracking enabled.");
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release indicator handles
   if(h_kama      != INVALID_HANDLE) IndicatorRelease(h_kama);
   if(h_emaFast   != INVALID_HANDLE) IndicatorRelease(h_emaFast);
   if(h_emaSlow   != INVALID_HANDLE) IndicatorRelease(h_emaSlow);
   if(h_rsi       != INVALID_HANDLE) IndicatorRelease(h_rsi);
   if(h_macd      != INVALID_HANDLE) IndicatorRelease(h_macd);
   if(h_atr       != INVALID_HANDLE) IndicatorRelease(h_atr);
   if(h_emaTrend  != INVALID_HANDLE) IndicatorRelease(h_emaTrend);
   if(h_corrEma   != INVALID_HANDLE) IndicatorRelease(h_corrEma);
   if(h_onnx      != INVALID_HANDLE) OnnxRelease(h_onnx);
   
   if(InpUseDOM_Filter) MarketBookRelease(_Symbol);
   
   //--- Remove chart objects
   ObjectsDeleteAll(0, "XMBOT_");
   
   //--- Release Master Chart Ownership
   string gvOwner = "GV_MASTER_CHART_" + _Symbol;
   if(GlobalVariableCheck(gvOwner) && (long)GlobalVariableGet(gvOwner) == ChartID())
   {
      GlobalVariableDel(gvOwner);
   }
   
   //--- Print session summary
   Print("📋 Session Summary: Trades=", g_totalTradesToday, 
         " | Wins=", g_winTrades, " | Losses=", g_lossTrades,
         " | Profit=", DoubleToString(g_totalProfit, 2));
   Print("👋 XM AI Scalping Bot deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function — MAIN TRADING LOGIC                        |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Update symbol info
   if(!m_symbol.RefreshRates())
      return;
      
   //--- LAYER -1: Auto-Duplicate Chart Tab Blocker (Only 1 Master Chart trades per symbol)
   if(!IsMasterChart())
   {
      if(InpShowDashboard) UpdateDashboard("💤 Standby: Duplicate Tab (Master Active)");
      return;
   }
   
   //--- LAYER -2: Auto-Block Low Win Rate Pairs (USDCAD, NZDUSD)
   if(InpAutoFilterLowWinSymbols)
   {
      string symUpper = _Symbol;
      StringToUpper(symUpper);
      if(StringFind(symUpper, "USDCAD") >= 0 || StringFind(symUpper, "NZDUSD") >= 0)
      {
         if(InpShowDashboard) UpdateDashboard("🛡️ Auto-Paused: Low Win Rate (<26%)");
         return;
      }
   }
   
   //--- Check for new day — reset daily counters
   CheckNewDay();
   
   //--- LAYER 0: TOTAL ACCOUNT DRAWDOWN CIRCUIT BREAKER 🚨
   if(g_accountHalted)
   {
      if(InpShowDashboard) UpdateDashboard("🚨 ACCOUNT HALTED — Equity < 50% of Deposit. Remove bot & re-add to reset.");
      return;
   }
   
   if(g_initialDeposit > 0)
   {
      double currentEquity = m_account.Equity();
      if(currentEquity < g_initialDeposit * 0.50) // Equity dropped below 50% of initial deposit
      {
         g_accountHalted = true;
         // Close ALL open positions immediately
         for(int i = PositionsTotal() - 1; i >= 0; i--)
         {
            if(m_position.SelectByIndex(i) && m_position.Magic() == InpMagicNumber)
               m_trade.PositionClose(m_position.Ticket());
         }
         Print("🚨🚨🚨 TOTAL DRAWDOWN CIRCUIT BREAKER TRIGGERED! Equity $", DoubleToString(currentEquity, 2),
               " < 50% of Initial Deposit $", DoubleToString(g_initialDeposit, 2),
               ". ALL TRADING HALTED! Remove and re-add bot to reset.");
         if(InpShowDashboard) UpdateDashboard("🚨 CIRCUIT BREAKER! Equity < 50% — ALL TRADING HALTED!");
         return;
      }
   }
   
   //--- LAYER 1: Daily limit & 5% Equity Shield check
   if(g_dailyLossHit)
   {
      return;
   }
   
   if(CheckDailyLimits() || CheckEquityDrawdown())
   {
      g_dailyLossHit = true;
      Print("⏸️ Daily Target, Loss Limit, or 5% Equity Shield reached! Stopping trading.");
      return;
   }
   
   //--- LAYER 3: Get indicator values BEFORE managing positions!
   if(!UpdateIndicators())
   {
      if(InpShowDashboard) UpdateDashboard("⚠️ Waiting for indicator data...");
      return;
   }
   
    //--- (AI Telemetry Removed)
   
   //--- Manage existing positions (trailing stop, breakeven)
   ManageOpenPositions();
   
   //--- ML LOGGER: Shadow manual user trades and log closed trades
   ShadowManualTrades();
   CheckClosedTradesAndLog();
   
   //--- LAYER 2: Market filter checks
   if(!IsSpreadAcceptable())
   {
      if(InpShowDashboard) UpdateDashboard("⏳ Waiting — Spread too wide: " + DoubleToString(GetCurrentSpreadPoints(), 1) + " pts");
      return;
   }
   
   if(!IsTradingSession())
   {
      if(InpShowDashboard) UpdateDashboard("⏳ Waiting — Outside trading session");
      return;
   }
   
   if(IsNewsTime())
   {
      if(InpShowDashboard) UpdateDashboard("⏳ Waiting — High Impact News 📰");
      return;
   }
   
   //--- Check max open trades (TOTAL max portfolio cap)
   if(CountOpenPositions() >= InpMaxOpenTrades)
   {
      if(InpShowDashboard) UpdateDashboard("⏳ Max trades open: " + IntegerToString(CountOpenPositions()) + "/" + IntegerToString(InpMaxOpenTrades));
      return;
   }

   //--- Check max trades per individual symbol
   if(CountOpenPositionsForSymbol(_Symbol) >= InpMaxTradesPerSymbol)
   {
      if(InpShowDashboard) UpdateDashboard("⏳ Max trade reached on " + _Symbol + " (" + IntegerToString(InpMaxTradesPerSymbol) + ")");
      return;
   }
   
   //--- Check Symbol Loss Cooldown (Prevents whipsaw repeat losses after stopout)
   if(IsSymbolInCooldown(_Symbol))
   {
      datetime cdUntil = (datetime)GlobalVariableGet("COOLDOWN_" + _Symbol);
      int remainingMins = (int)MathMax(1, (cdUntil - TimeCurrent()) / 60);
      if(InpShowDashboard) UpdateDashboard("⏳ Cooldown: " + _Symbol + " (" + IntegerToString(remainingMins) + "m left after loss)");
      return;
   }
   
   //--- Check Global Order Lock (Prevents duplicate charts from firing orders simultaneously)
   if(IsGlobalOrderLockActive())
   {
      if(InpShowDashboard) UpdateDashboard("⏳ Global Order Lock: waiting between chart orders");
      return;
   }
   
   //--- Check Anti-Martingale (Rule 15 - Strict Protection: Never add to losing position on SAME symbol)
   if(CountOpenPositionsForSymbol(_Symbol) > 0 && IsSymbolPositionInLoss(_Symbol))
   {
      if(InpShowDashboard) UpdateDashboard("⏳ Waiting — Anti-Martingale (" + _Symbol + " in Loss)");
      return;
   }
   
   //--- Check minimum bars between trades
   if(!IsMinBarsPassed())
   {
      if(InpShowDashboard) UpdateDashboard("⏳ Waiting — Min bars cooldown");
      return;
   }
   
   //--- Check Yen Exposure Guard (Rule: Max 1 concurrent JPY trade)
   if(InpMaxConcurrentYenTrades > 0)
   {
      string symUpper = _Symbol;
      StringToUpper(symUpper);
      if(StringFind(symUpper, "JPY") >= 0 && CountOpenJPYPositions() >= InpMaxConcurrentYenTrades)
      {
         if(InpShowDashboard) UpdateDashboard("⏳ Yen Exposure Guard: 1 JPY trade active");
         return;
      }
   }
   
    //--- LAYER 5: Generate EA technical signal (Standalone Mode)
    int signal = GetTradeSignal();
    
    //--- LAYER 6: Execute trade if EA signal found
    if(signal == 1) // BUY signal
    {
       ExecuteBuy();
    }
    else if(signal == -1) // SELL signal
    {
       ExecuteSell();
    }
    else
    {
       if(InpShowDashboard) UpdateDashboard("🔍 " + g_signalStatus);
    }
}

//+------------------------------------------------------------------+
//| UPDATE INDICATOR BUFFERS                                         |
//+------------------------------------------------------------------+
bool UpdateIndicators()
{
   int barsNeeded = 26; // Need at least 26 bars for 24-bar EMA crossover lookback
   
   //--- Copy indicator data
   if(CopyBuffer(h_kama,      0, 0, barsNeeded, bufKama)      < barsNeeded) return false;
   if(CopyBuffer(h_emaFast,   0, 0, barsNeeded, bufEmaFast)   < barsNeeded) return false;
   if(CopyBuffer(h_emaSlow,   0, 0, barsNeeded, bufEmaSlow)   < barsNeeded) return false;
   if(CopyBuffer(h_rsi,       0, 0, barsNeeded, bufRSI)       < barsNeeded) return false;
   if(CopyBuffer(h_macd, 0, 0, 2, bufMACD_Main) < 2) return false;
   if(CopyBuffer(h_macd, 1, 0, 2, bufMACD_Signal) < 2) return false;
   if(CopyBuffer(h_atr, 0, 0, 2, bufATR) <= 0) return false;
   
   if(InpUseMTFFilter)
   {
      if(CopyBuffer(h_emaTrend, 0, 0, 1, bufEmaTrend) <= 0) return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| GENERATE TRADE SIGNAL                                            |
//|  Returns: 1 = BUY, -1 = SELL, 0 = No signal                    |
//+------------------------------------------------------------------+
double g_pinBarSL = 0.0; // Store tight stop loss for Pin Bar strategy

int GetTradeSignal()
{
   g_pinBarSL = 0.0; // Reset
   
   //--- PRICE SHOCK FILTER (Rule 5 - Crisis Management): Suspend all new entries during shock (> 5 * ATR)
   if(ArraySize(bufATR) > 0 && bufATR[0] > 0 && CheckPriceShock(bufATR[0])) return 0;
   
   //--- PIN BAR REVERSAL STRATEGY (Counter-Trend) ---
   if(InpUsePinBarReversal)
   {
      double o[], h[], l[], c[];
      ArraySetAsSeries(o, true); ArraySetAsSeries(h, true); ArraySetAsSeries(l, true); ArraySetAsSeries(c, true);
      
      if(CopyOpen(_Symbol, PERIOD_CURRENT, 0, 5, o) == 5 &&
         CopyHigh(_Symbol, PERIOD_CURRENT, 0, 5, h) == 5 &&
         CopyLow(_Symbol, PERIOD_CURRENT, 0, 5, l) == 5 &&
         CopyClose(_Symbol, PERIOD_CURRENT, 0, 5, c) == 5)
      {
         // Analyze Candle 1 (just closed)
         double body = MathAbs(o[1] - c[1]);
         double totalSize = h[1] - l[1];
         double minPinSize = (ArraySize(bufATR) > 0 && bufATR[0] > 0) ? (bufATR[0] * 0.5) : (m_symbol.Point() * 20);
         
         if(totalSize >= minPinSize && body > 0) // Valid, dynamic ATR-sized candle (Rule 5)
         {
            double minBody = MathMin(o[1], c[1]);
            double maxBody = MathMax(o[1], c[1]);
            
            double lowerWick = minBody - l[1];
            double upperWick = h[1] - maxBody;
            
            bool is3Down = (c[2] < o[2] && c[3] < o[3] && c[4] < o[4]);
            bool is3Up = (c[2] > o[2] && c[3] > o[3] && c[4] > o[4]);
            
            // Bullish Pin Bar
            if(lowerWick >= 2.0 * body && upperWick <= body && is3Down)
            {
               if(ArraySize(bufKama) >= 2 && maxBody < bufKama[1]) // Below KAMA
               {
                  if(!CheckOrderBookDOM(1)) return 0; // Check DOM sell walls before buying
                  g_pinBarSL = l[1] - (m_symbol.Point() * 10); // SL slightly below tail
                  Print("📌 BULLISH PIN BAR DETECTED! Counter-Trend Reversal Trade.");
                  return 1;
               }
            }
            
            // Bearish Pin Bar
            if(upperWick >= 2.0 * body && lowerWick <= body && is3Up)
            {
               if(ArraySize(bufKama) >= 2 && minBody > bufKama[1]) // Above KAMA
               {
                  if(!CheckOrderBookDOM(-1)) return 0; // Check DOM buy walls before selling
                  g_pinBarSL = h[1] + (m_symbol.Point() * 10); // SL slightly above tail
                  Print("📌 BEARISH PIN BAR DETECTED! Counter-Trend Reversal Trade.");
                  return -1;
               }
            }
         }
      }
   }

   //--- Get current values
   double kama_curr      = bufKama[0];
   double kama_prev      = bufKama[1];
   
   double rsi_curr       = bufRSI[0];
   
   double macd_main      = bufMACD_Main[0];
   double macd_signal    = bufMACD_Signal[0];
   double macd_hist      = macd_main - macd_signal;
   
   //--- MACD previous bar histogram (for momentum check)
   double macd_hist_prev = 0;
   if(ArraySize(bufMACD_Main) >= 2 && ArraySize(bufMACD_Signal) >= 2)
      macd_hist_prev = bufMACD_Main[1] - bufMACD_Signal[1];
   
   double price          = m_symbol.Ask();
   double priceBid       = m_symbol.Bid();
   
   //--- Calculate Efficiency Ratio (ER)
   double er = CalculateER(InpKAMA_Period);
   
   //--- CANDLE CONFIRMATION: Last closed candle must agree with trade direction or be a micro-pullback/doji
   double lastOpen  = iOpen(_Symbol, PERIOD_CURRENT, 1);
   double lastClose = iClose(_Symbol, PERIOD_CURRENT, 1);
   bool isBullishCandle = (lastClose >= lastOpen || MathAbs(lastClose - lastOpen) <= (m_symbol.Point() * 5));
   bool isBearishCandle = (lastClose <= lastOpen || MathAbs(lastClose - lastOpen) <= (m_symbol.Point() * 5));
   
   //=== BUY CONDITIONS ===
   
   // Filter 1: KAMA 3-Bar Direction + Price Above KAMA + ER Noise Filter
   // OR 24-bar EMA Crossover Trend Surfing (Rule 4)
   bool isBuyKAMA = false;
   if(ArraySize(bufKama) >= 3)
   {
      // Kaufman Rule 5: ER >= 0.20 filter ensures sufficient trend momentum (Hyper-Turbo Trade Frequency)
      bool kamaTrend = (bufKama[0] > bufKama[2]) && (price > bufKama[0]) && (er >= 0.20);
      isBuyKAMA = kamaTrend;
   }
   
   // Check 24-bar EMA Crossover
   bool isBuyEMACross = false;
   if(ArraySize(bufEmaFast) >= 26 && ArraySize(bufEmaSlow) >= 26)
   {
      for(int i = 1; i <= 24; i++)
      {
         if(bufEmaFast[i] > bufEmaSlow[i] && bufEmaFast[i+1] <= bufEmaSlow[i+1])
         {
            if(bufEmaFast[0] > bufEmaSlow[0]) // Ensure still in trend
            {
               isBuyEMACross = true;
               break;
            }
         }
      }
   }
   
   bool isBullishTrend = isBuyKAMA || isBuyEMACross;
   
   // Filter 2: MACD Bullish Momentum (Relaxed)
   //   - Histogram must be positive (growing check removed for frequency)
   bool isMacdBullish = (macd_hist > 0);
   
   // Filter 3: MTF Trend Alignment — H1 EMA50 (Rule 12 - Elder Triple Screen)
   bool isMtfBullish = true;
   if(InpUseMTFFilter) isMtfBullish = (price > bufEmaTrend[0]);
   
   // Filter 4: RSI in BUY zone (35-60) — catch momentum, don't chase extremes
   bool isRsiBuyOk = (rsi_curr < InpRSI_BuyMax && rsi_curr > InpRSI_BuyMin);
   
   // Filter 4.5: Smart RSI Momentum (Micro-Divergence)
   bool isRsiMomentumBuy = true;
   if(ArraySize(bufRSI) >= 3) isRsiMomentumBuy = (bufRSI[0] > bufRSI[1] || bufRSI[0] > bufRSI[2]);
     
   // Filter 5: ATR Volatility Check (Avoid Dead Markets)
   double minAtr = m_symbol.Point() * 5; 
   bool isMarketMoving = (bufATR[0] >= minAtr);
    
   // Filter 5.5: Volume Confirmation (Rule 11)
   bool isVolumeConfirmed = true;
    
   // Filter 6: SMC Fair Value Gap (FVG)
   bool isFvgBuy = CheckBullishFVG();
   
   // Filter 7: Multi-Currency Correlation
   bool isCorrBuy = CheckCorrelation(1);
     
   if(isBullishTrend && isMacdBullish && isRsiBuyOk && isRsiMomentumBuy && isMtfBullish && isMarketMoving && isVolumeConfirmed && isFvgBuy && isCorrBuy && isBullishCandle)
   {
      // Filter 8: ONNX AI Prediction
      double currentSpread = (double)m_symbol.Spread();
      if(!GetAIPrediction(1, rsi_curr, currentSpread, macd_hist, bufATR[0])) return 0;
      
      // Filter 9: DOM Order Book Sell Wall check
      if(!CheckOrderBookDOM(1)) return 0;
      
      Print("📈 BUY Signal! (KAMA or EMA24) + MACD↑ + RSI:", DoubleToString(rsi_curr,1), " + ER:", DoubleToString(er,2));
      return 1;
   }
   
   //=== SELL CONDITIONS ===
   
   // Filter 1: KAMA 3-Bar Direction + Price Below KAMA + ER Noise Filter
   // OR 24-bar EMA Crossover Trend Surfing (Rule 4)
   bool isSellKAMA = false;
   if(ArraySize(bufKama) >= 3)
   {
      // Kaufman Rule 5: ER >= 0.20 filter ensures sufficient trend momentum (Hyper-Turbo Trade Frequency)
      bool kamaTrend = (bufKama[0] < bufKama[2]) && (priceBid < bufKama[0]) && (er >= 0.20);
      isSellKAMA = kamaTrend;
   }
   
   // Check 24-bar EMA Crossover
   bool isSellEMACross = false;
   if(ArraySize(bufEmaFast) >= 26 && ArraySize(bufEmaSlow) >= 26)
   {
      for(int i = 1; i <= 24; i++)
      {
         if(bufEmaFast[i] < bufEmaSlow[i] && bufEmaFast[i+1] >= bufEmaSlow[i+1])
         {
            if(bufEmaFast[0] < bufEmaSlow[0]) // Ensure still in trend
            {
               isSellEMACross = true;
               break;
            }
         }
      }
   }
   
   bool isBearishTrend = isSellKAMA || isSellEMACross;
   
   // Filter 2: MACD Bearish Momentum (Relaxed)
   bool isMacdBearish = (macd_hist < 0);
   
   // Filter 3: MTF Trend Alignment (Rule 12)
   bool isMtfBearish = true;
   if(InpUseMTFFilter) isMtfBearish = (priceBid < bufEmaTrend[0]);
   
   // Filter 4: RSI in SELL zone (40-65) — catch momentum, don't chase extremes
   bool isRsiSellOk = (rsi_curr > InpRSI_SellMin && rsi_curr < InpRSI_SellMax);
   
   // Filter 4.5: Smart RSI Momentum (Micro-Divergence)
   bool isRsiMomentumSell = true;
   if(ArraySize(bufRSI) >= 3) isRsiMomentumSell = (bufRSI[0] < bufRSI[1] || bufRSI[0] < bufRSI[2]);
   
   // Filter 6: SMC Fair Value Gap (FVG)
   bool isFvgSell = CheckBearishFVG();
   
   // Filter 7: Multi-Currency Correlation
   bool isCorrSell = CheckCorrelation(-1);
   
   if(isBearishTrend && isMacdBearish && isRsiSellOk && isRsiMomentumSell && isMtfBearish && isMarketMoving && isVolumeConfirmed && isFvgSell && isCorrSell && isBearishCandle)
   {
      // Filter 8: ONNX AI Prediction
      double currentSpread = (double)m_symbol.Spread();
      if(!GetAIPrediction(-1, rsi_curr, currentSpread, macd_hist, bufATR[0])) return 0;
      
      // Filter 9: DOM Order Book Buy Wall check
      if(!CheckOrderBookDOM(-1)) return 0;
      
      Print("📉 SELL Signal! (KAMA or EMA24) + MACD↓ + RSI:", DoubleToString(rsi_curr,1), " + ER:", DoubleToString(er,2));
      return -1;
   }
   
   //--- Determine exact reason for NO SIGNAL to update Dashboard
   if(!isBullishTrend && !isBearishTrend) g_signalStatus = "Waiting for Trend (EMA Cross or KAMA)";
   else if(isBullishTrend && !isMacdBullish) g_signalStatus = "Trend UP, Waiting for MACD > 0";
   else if(isBearishTrend && !isMacdBearish) g_signalStatus = "Trend DOWN, Waiting for MACD < 0";
   else if((isBullishTrend && !isRsiBuyOk) || (isBearishTrend && !isRsiSellOk)) g_signalStatus = "Waiting for RSI Zone";
   else if((isBullishTrend && !isRsiMomentumBuy) || (isBearishTrend && !isRsiMomentumSell)) g_signalStatus = "Waiting for RSI Momentum";
   else if(!isVolumeConfirmed) g_signalStatus = "Waiting for Volume Confirmation";
   else if(!isMtfBullish && !isMtfBearish) g_signalStatus = "Waiting for MTF Alignment";
   else g_signalStatus = "Scanning criteria...";
   
   return 0; // No signal
}



//+------------------------------------------------------------------+
//| EXECUTE BUY TRADE                                                |
//+------------------------------------------------------------------+
void ExecuteBuy()
{
   m_symbol.RefreshRates();
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(ask <= 0) ask = m_symbol.Ask();
   if(ask <= 0)
   {
      MqlTick tick;
      if(SymbolInfoTick(_Symbol, tick) && tick.ask > 0) ask = tick.ask;
   }
   if(ask <= 0) ask = iClose(_Symbol, PERIOD_CURRENT, 0);
   
   if(ask <= 0)
   {
      Print("❌ Cannot execute BUY: Invalid Ask price (0.00000). Waiting for tick.");
      return;
   }
   
   //--- HYPER SCALPER TP/SL (Tight Risk, Fast Profit)
   double atr = (ArraySize(bufATR) > 0) ? bufATR[0] : 0.0010;
   if(atr <= 0) atr = 0.0010;
   double slDistance = atr * InpSL_ATR_Multi;
   
   // Clamp SL distance for Gold / high volatility pairs to prevent wide ATR losses
   string symUpper = _Symbol; StringToUpper(symUpper);
   if(StringFind(symUpper, "GOLD") >= 0 || StringFind(symUpper, "XAU") >= 0)
   {
      double maxGoldSLDistance = 2.0; // Max $2.00 Gold price distance
      slDistance = MathMin(slDistance, maxGoldSLDistance);
   }
   
   // 🛡️ CRITICAL FIX: Ensure slDistance is at least 3x Spread and meets broker StopLevel BEFORE lot sizing!
   double minStop = m_symbol.StopsLevel() * _Point;
   if(minStop <= 0) minStop = m_symbol.Spread() * _Point * 2.0; // Rule 2
   double minSafeSL = MathMax(minStop + (10 * _Point), m_symbol.Spread() * _Point * 3.0);
   slDistance = MathMax(slDistance, minSafeSL);
   
   double tpDistance = slDistance * (InpTP_ATR_Multi / MathMax(InpSL_ATR_Multi, 0.1));
   
   double sl = 0.0;
   if(g_pinBarSL > 0)
   {
      sl = NormalizeDouble(g_pinBarSL, _Digits);
      double pinSLDist = ask - sl;
      if(pinSLDist >= minSafeSL) slDistance = pinSLDist;
      else sl = NormalizeDouble(ask - slDistance, _Digits);
   }
   else
   {
      sl = NormalizeDouble(ask - slDistance, _Digits);
   }
   
   double tp = NormalizeDouble(ask + tpDistance, _Digits);
   
   //--- Calculate lot size based on REAL validated risk distance
   double lotSize = CalculateLotSize(slDistance, ORDER_TYPE_BUY);
   if(lotSize <= 0) return;
   
   //--- Execute trade
   string comment = StringFormat("XMBOT_BUY_v15.80_AUTO|SL=%.5f", slDistance);
   
   double sendSL = sl;
   double sendTP = tp;
   if(InpUseStealthMode)
   {
      double minStop = m_symbol.StopsLevel() * _Point;
      if(minStop <= 0) minStop = m_symbol.Spread() * _Point * 2.0; // Rule 2
      double disasterSLDist = MathMax(atr * 5.0, minStop + (10 * _Point));
      sendSL = NormalizeDouble(ask - disasterSLDist, _Digits); // Disaster SL
      sendTP = 0;
   }
   
   // 🛡️ RACE CONDITION FIX: Acquire Global Lock BEFORE sending order across network
   SetGlobalOrderLock();
   
   if(m_trade.Buy(lotSize, _Symbol, ask, sendSL, sendTP, comment))
   {
      ulong ticket = m_trade.ResultOrder();
      g_lastTradeTime = TimeCurrent();
      g_totalTradesToday++;
      
      if(InpUseStealthMode)
      {
         GlobalVariableSet("SL_" + IntegerToString(ticket), sl);
         GlobalVariableSet("TP_" + IntegerToString(ticket), tp);
         Print("👻 STEALTH BUY executed! Lot: ", DoubleToString(lotSize, 2), " | Virtual SL: ", DoubleToString(sl, _Digits), " | Virtual TP: ", DoubleToString(tp, _Digits));
      }
      else
      {
         Print("✅ BUY executed! Lot: ", DoubleToString(lotSize, 2),
               " | SL: ", DoubleToString(sl, _Digits),
               " | TP: ", DoubleToString(tp, _Digits));
      }
      
      if(InpShowDashboard) UpdateDashboard("✅ BUY OPENED @ " + DoubleToString(ask, _Digits));
      
      //--- Log Trade for ML Data Collection
      int size = ArraySize(g_activeTrades);
      ArrayResize(g_activeTrades, size + 1);
      g_activeTrades[size].ticket = m_trade.ResultOrder();
      g_activeTrades[size].type = 0; // BUY
      g_activeTrades[size].rsi = (ArraySize(bufRSI) > 0) ? bufRSI[0] : 50.0;
      g_activeTrades[size].macd = (ArraySize(bufMACD_Main) > 0 && ArraySize(bufMACD_Signal) > 0) ? (bufMACD_Main[0] - bufMACD_Signal[0]) : 0.0;
      g_activeTrades[size].atr = atr;
      g_activeTrades[size].spread = m_symbol.Spread();
      g_activeTrades[size].openPrice = ask;
      g_activeTrades[size].openTime = TimeCurrent();
   }
   else
   {
      Print("❌ BUY failed! Error: ", GetLastError(), " | ", m_trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//| EXECUTE SELL TRADE                                               |
//+------------------------------------------------------------------+
void ExecuteSell()
{
   m_symbol.RefreshRates();
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(bid <= 0) bid = m_symbol.Bid();
   if(bid <= 0)
   {
      MqlTick tick;
      if(SymbolInfoTick(_Symbol, tick) && tick.bid > 0) bid = tick.bid;
   }
   if(bid <= 0) bid = iClose(_Symbol, PERIOD_CURRENT, 0);
   
   if(bid <= 0)
   {
      Print("❌ Cannot execute SELL: Invalid Bid price (0.00000). Waiting for tick.");
      return;
   }
   
   //--- HYPER SCALPER TP/SL (Tight Risk, Fast Profit)
   double atr = (ArraySize(bufATR) > 0) ? bufATR[0] : 0.0010;
   if(atr <= 0) atr = 0.0010;
   double slDistance = atr * InpSL_ATR_Multi;
   
   // Clamp SL distance for Gold / high volatility pairs to prevent wide ATR losses
   string symUpper = _Symbol; StringToUpper(symUpper);
   if(StringFind(symUpper, "GOLD") >= 0 || StringFind(symUpper, "XAU") >= 0)
   {
      double maxGoldSLDistance = 2.0; // Max $2.00 Gold price distance
      slDistance = MathMin(slDistance, maxGoldSLDistance);
   }
   
   // 🛡️ CRITICAL FIX: Ensure slDistance is at least 3x Spread and meets broker StopLevel BEFORE lot sizing!
   double minStop = m_symbol.StopsLevel() * _Point;
   if(minStop <= 0) minStop = m_symbol.Spread() * _Point * 2.0; // Rule 2
   double minSafeSL = MathMax(minStop + (10 * _Point), m_symbol.Spread() * _Point * 3.0);
   slDistance = MathMax(slDistance, minSafeSL);
   
   double tpDistance = slDistance * (InpTP_ATR_Multi / MathMax(InpSL_ATR_Multi, 0.1));
   
   double sl = 0.0;
   if(g_pinBarSL > 0)
   {
      sl = NormalizeDouble(g_pinBarSL, _Digits);
      double pinSLDist = sl - bid;
      if(pinSLDist >= minSafeSL) slDistance = pinSLDist;
      else sl = NormalizeDouble(bid + slDistance, _Digits);
   }
   else
   {
      sl = NormalizeDouble(bid + slDistance, _Digits);
   }
   
   double tp = NormalizeDouble(bid - tpDistance, _Digits);
   
   //--- Calculate lot size based on REAL validated risk distance
   double lotSize = CalculateLotSize(slDistance, ORDER_TYPE_SELL);
   if(lotSize <= 0) return;
   
   //--- Execute trade
   string comment = StringFormat("XMBOT_SELL_v15.80_AUTO|SL=%.5f", slDistance);
   
   double sendSL = sl;
   double sendTP = tp;
   if(InpUseStealthMode)
   {
      double minStop = m_symbol.StopsLevel() * _Point;
      if(minStop <= 0) minStop = m_symbol.Spread() * _Point * 2.0; // Rule 2
      double disasterSLDist = MathMax(atr * 5.0, minStop + (10 * _Point));
      sendSL = NormalizeDouble(bid + disasterSLDist, _Digits); // Disaster SL
      sendTP = 0;
   }
   
   // 🛡️ RACE CONDITION FIX: Acquire Global Lock BEFORE sending order across network
   SetGlobalOrderLock();
   
   if(m_trade.Sell(lotSize, _Symbol, bid, sendSL, sendTP, comment))
   {
      ulong ticket = m_trade.ResultOrder();
      g_lastTradeTime = TimeCurrent();
      g_totalTradesToday++;
      
      if(InpUseStealthMode)
      {
         GlobalVariableSet("SL_" + IntegerToString(ticket), sl);
         GlobalVariableSet("TP_" + IntegerToString(ticket), tp);
         Print("👻 STEALTH SELL executed! Lot: ", DoubleToString(lotSize, 2), " | Virtual SL: ", DoubleToString(sl, _Digits), " | Virtual TP: ", DoubleToString(tp, _Digits));
      }
      else
      {
         Print("✅ SELL executed! Lot: ", DoubleToString(lotSize, 2),
               " | SL: ", DoubleToString(sl, _Digits),
               " | TP: ", DoubleToString(tp, _Digits));
      }
      
      if(InpShowDashboard) UpdateDashboard("✅ SELL OPENED @ " + DoubleToString(bid, _Digits));
      
      //--- Log Trade for ML Data Collection
      int size = ArraySize(g_activeTrades);
      ArrayResize(g_activeTrades, size + 1);
      g_activeTrades[size].ticket = m_trade.ResultOrder();
      g_activeTrades[size].type = 1; // SELL
      g_activeTrades[size].rsi = (ArraySize(bufRSI) > 0) ? bufRSI[0] : 50.0;
      g_activeTrades[size].macd = (ArraySize(bufMACD_Main) > 0 && ArraySize(bufMACD_Signal) > 0) ? (bufMACD_Main[0] - bufMACD_Signal[0]) : 0.0;
      g_activeTrades[size].atr = atr;
      g_activeTrades[size].spread = m_symbol.Spread();
      g_activeTrades[size].openPrice = bid;
      g_activeTrades[size].openTime = TimeCurrent();
   }
   else
   {
      Print("❌ SELL failed! Error: ", GetLastError(), " | ", m_trade.ResultRetcodeDescription());
   }
}
//+------------------------------------------------------------------+
//| ML DATA LOGGER: SHADOW MANUAL TRADES (USER DATA FEED)            |
//+------------------------------------------------------------------+
void ShadowManualTrades()
{
   int total = PositionsTotal();
   for(int i = 0; i < total; i++)
   {
      string symbol = PositionGetSymbol(i);
      if(symbol != _Symbol) continue; // Only shadow current pair
      
      long magic = PositionGetInteger(POSITION_MAGIC);
      if(magic != InpMagicNumber) // It's a manual trade (or another bot)
      {
         ulong ticket = PositionGetInteger(POSITION_TICKET);
         
         // Check if we are already tracking this ticket
         bool tracking = false;
         int size = ArraySize(g_activeTrades);
         for(int j = 0; j < size; j++)
         {
            if(g_activeTrades[j].ticket == ticket)
            {
               tracking = true;
               break;
            }
         }
         
         // If not tracking, it's a newly opened manual trade!
         if(!tracking)
         {
            long type = PositionGetInteger(POSITION_TYPE);
            double price = PositionGetDouble(POSITION_PRICE_OPEN);
            
            ArrayResize(g_activeTrades, size + 1);
            g_activeTrades[size].ticket = ticket;
            g_activeTrades[size].type = (type == POSITION_TYPE_BUY) ? 0 : 1;
            
            // Read indicators right now
            if(CopyBuffer(h_rsi, 0, 0, 1, bufRSI) > 0) g_activeTrades[size].rsi = bufRSI[0]; else g_activeTrades[size].rsi = 0;
            if(CopyBuffer(h_macd, 0, 0, 1, bufMACD_Main) > 0 && CopyBuffer(h_macd, 1, 0, 1, bufMACD_Signal) > 0) 
               g_activeTrades[size].macd = bufMACD_Main[0] - bufMACD_Signal[0];
            else g_activeTrades[size].macd = 0;
            if(CopyBuffer(h_atr, 0, 0, 1, bufATR) > 0) g_activeTrades[size].atr = bufATR[0]; else g_activeTrades[size].atr = 0;
            
            g_activeTrades[size].spread = m_symbol.Spread();
            g_activeTrades[size].openPrice = price;
            g_activeTrades[size].openTime = (datetime)PositionGetInteger(POSITION_TIME);
            
            Print("👤 SHADOW MODE: Captured Manual Trade Ticket: ", ticket);
            if(InpShowDashboard) UpdateDashboard("👤 SHADOW MODE: Capturing your trade!");
         }
      }
   }
}

//+------------------------------------------------------------------+
//| ML DATA LOGGER: CHECK CLOSED TRADES AND WRITE TO CSV             |
//+------------------------------------------------------------------+
void CheckClosedTradesAndLog()
{
   int size = ArraySize(g_activeTrades);
   if(size == 0) return;
   
   for(int i = size - 1; i >= 0; i--)
   {
      ulong ticket = g_activeTrades[i].ticket;
      
      // Check if position still exists
      if(!PositionSelectByTicket(ticket))
      {
         // Position is closed. Check history for the deal
         if(HistorySelectByPosition(ticket))
         {
            int dealsTotal = HistoryDealsTotal();
            double profit = 0;
            
            for(int d = 0; d < dealsTotal; d++)
            {
               ulong dealTicket = HistoryDealGetTicket(d);
               if(dealTicket > 0)
               {
                  long dealEntry = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
                  if(dealEntry == DEAL_ENTRY_OUT || dealEntry == DEAL_ENTRY_INOUT)
                  {
                     profit += HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
                  }
               }
            }
            
            // Log to CSV
            int handle = FileOpen("XMBot_ML_Data.csv", FILE_CSV | FILE_READ | FILE_WRITE | FILE_ANSI | FILE_SHARE_READ | FILE_SHARE_WRITE, ',');
            if(handle != INVALID_HANDLE)
            {
               // If file is new, write header
               if(FileSize(handle) == 0)
               {
                  FileWrite(handle, "Ticket,Type,OpenTime,OpenPrice,Spread,RSI,MACD,ATR,Profit");
               }
               
               FileSeek(handle, 0, SEEK_END);
               
               string typeStr = (g_activeTrades[i].type == 0) ? "BUY" : "SELL";
               string row = StringFormat("%I64u,%s,%s,%.5f,%.1f,%.2f,%.6f,%.5f,%.2f",
                                         ticket, typeStr, TimeToString(g_activeTrades[i].openTime),
                                         g_activeTrades[i].openPrice, g_activeTrades[i].spread,
                                         g_activeTrades[i].rsi, g_activeTrades[i].macd,
                                         g_activeTrades[i].atr, profit);
               FileWrite(handle, row);
               FileClose(handle);
               Print("💾 ML Data Logged for Ticket: ", ticket, " | Profit: $", DoubleToString(profit, 2));
            }
            
            // Also Log to trade_log.csv using LogTrade
            LogTrade(_Symbol, g_activeTrades[i].openPrice, m_symbol.Bid(), g_activeTrades[i].spread, profit);
            
            // If closed in loss, activate Loss Cooldown to prevent revenge-trading
            if(profit < 0)
            {
               SetSymbolLossCooldown(_Symbol);
            }
         }
         
         // Cleanup Stealth Mode Global Variables
         if(InpUseStealthMode)
         {
            GlobalVariableDel("SL_" + IntegerToString(ticket));
            GlobalVariableDel("TP_" + IntegerToString(ticket));
         }
         
         // Cleanup Partial Profit Global Variable
         GlobalVariableDel("PARTIAL_" + IntegerToString(ticket));
         
         // Remove from array by shifting elements down
         for(int j = i; j < size - 1; j++)
         {
            g_activeTrades[j] = g_activeTrades[j+1];
         }
         ArrayResize(g_activeTrades, size - 1);
         size--;
      }
   }
}

//+------------------------------------------------------------------+
//| LOG TRADE TO trade_log.csv                                       |
//+------------------------------------------------------------------+
void LogTrade(string symbol, double entry, double exit, double spread, double profit)
{
   int handle = FileOpen("trade_log.csv", FILE_WRITE|FILE_READ|FILE_CSV|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE, ',');
   if(handle != INVALID_HANDLE)
   {
      if(FileSize(handle) == 0)
      {
         FileWrite(handle, "Time", "Symbol", "Entry", "Exit", "Spread", "Profit");
      }
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle, TimeToString(TimeCurrent()), symbol, DoubleToString(entry, 5), DoubleToString(exit, 5), DoubleToString(spread, 1), DoubleToString(profit, 2));
      FileClose(handle);
      Print("📜 Logged trade to trade_log.csv | Symbol: ", symbol, " | Profit: $", DoubleToString(profit, 2));
   }
}


//+------------------------------------------------------------------+
//| CALCULATE LOT SIZE BASED ON RISK                                 |
//+------------------------------------------------------------------+
double CalculateLotSize(double slDistancePrice, ENUM_ORDER_TYPE orderType = ORDER_TYPE_BUY)
{
   if(slDistancePrice <= 0) return 0;
   
   double balance    = m_account.Balance();
   double riskAmount = balance * (InpRiskPercent / 100.0);
   
   //--- Get tick value for 1 lot
   double tickValue = m_symbol.TickValue();
   double tickSize  = m_symbol.TickSize();
   
   if(tickValue <= 0 || tickSize <= 0) return 0;
   
   //--- Calculate lot size
   double slPoints  = slDistancePrice / tickSize;
   double lotSize   = riskAmount / (slPoints * tickValue);
   
   //--- Apply min/max/step constraints
   double minLot  = m_symbol.LotsMin();
   double maxLot  = m_symbol.LotsMax();
   double lotStep = m_symbol.LotsStep();
   
   //--- Round to lot step
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   
   //--- AUTO-COMPOUNDING SIZING ENGINE (Safe Mode - No Forced Minimums)
   if(InpUseCompounding)
   {
      // Only SCALE UP when account is genuinely growing, never force a minimum
      if(balance >= 1000.0)     lotSize = MathMax(lotSize, 0.10);
      else if(balance >= 500.0) lotSize = MathMax(lotSize, 0.05);
      else if(balance >= 300.0) lotSize = MathMax(lotSize, 0.03);
      // Below $300: NO forced minimum — let risk-based sizing decide
      // This prevents forcing 0.02-0.03 lot on tiny $72-$150 accounts
   }
   
   //--- KELLY CRITERION (Dynamic Lot Scaling)
   if(InpUseKellyCriterion && g_totalTradesToday >= 3) // Need at least 3 trades history today
   {
      double winRate = (double)g_winTrades / (double)g_totalTradesToday;
      double R = (InpSL_ATR_Multi > 0) ? (InpTP_ATR_Multi / InpSL_ATR_Multi) : 2.0; // Reward:Risk Ratio
      
      // Basic Kelly Formula: Kelly % = W - ((1 - W) / R)
      double kellyPct = winRate - ((1.0 - winRate) / R);
      
      if(kellyPct > 0)
      {
         // Scale lot size by Kelly fraction (Half-Kelly for safety)
         double kellyMultiplier = kellyPct * 0.5; // Max 50% boost
         double kellyScaledLot = lotSize * (1.0 + kellyMultiplier);
         
         Print("⚖️ Kelly Sizing Active! WinRate: ", DoubleToString(winRate*100,1), "% | R:R = 1:", DoubleToString(R, 1), " | Scaling Lot from ", DoubleToString(lotSize, 2), " to ", DoubleToString(kellyScaledLot, 2));
         
         lotSize = kellyScaledLot;
         lotSize = MathFloor(lotSize / lotStep) * lotStep; // Round again
      }
      else
      {
         // Losing streak -> Reduce lot size by 30% to protect capital
         lotSize = lotSize * 0.70;
         lotSize = MathFloor(lotSize / lotStep) * lotStep;
         Print("⚖️ Kelly Sizing Active! WinRate low (", DoubleToString(winRate*100,1), "%). Reducing Lot Size to protect capital: ", DoubleToString(lotSize, 2));
      }
   }
   
   //--- STRICT RISK GUARD (Protect Small Accounts)
   if(lotSize < minLot)
   {
      double actualRiskAmount = (slPoints * tickValue) * minLot;
      // Allow a small 50% buffer for rounding, but block massive risks
      if(actualRiskAmount > riskAmount * 1.5)
      {
         Print("⚠️ RISK WARNING: Min lot (", minLot, ") risks $", DoubleToString(actualRiskAmount, 2), " which exceeds allowed $", DoubleToString(riskAmount, 2), ". Executing anyway.");
         if(InpShowDashboard) UpdateDashboard("⚠️ Min Lot Risk: $" + DoubleToString(actualRiskAmount, 2));
         // We removed 'return 0' so it allows small accounts to trade the minimum lot size
      }
      lotSize = minLot;
   }
   
   //--- Clamp to limits
   lotSize = MathMax(lotSize, minLot);
   lotSize = MathMin(lotSize, maxLot);
      //--- TIERED HARD SAFETY CAP FOR SMALL ACCOUNTS (Rule 6)
    if(balance < 200.0)
    {
       lotSize = MathMin(lotSize, 0.03); // 🛡️ Rule 6: max 0.03 lot on < $200
    }
    else if(balance < 500.0)
    {
       lotSize = MathMin(lotSize, 0.05); // 🛡️ $200-$500 → max 0.05 lot
    }
   
   //--- Upper balance tier hard caps
   if(balance >= 500.0 && balance < 1000.0)       lotSize = MathMin(lotSize, 0.08); // 🛡️ $500-$1000 → max 0.08 lot
   else if(balance >= 1000.0 && balance < 5000.0) lotSize = MathMin(lotSize, 0.15); // 🛡️ $1000-$5000 → max 0.15 lot (stops 1.73 lot disaster!)
   else if(balance >= 5000.0)                     lotSize = MathMin(lotSize, 0.30); // 🛡️ $5000+ → max 0.30 lot

   //--- Additional safety: don't risk more than free margin allows
   double marginRequired = 0;
   if(!OrderCalcMargin(orderType, _Symbol, lotSize, m_symbol.Ask(), marginRequired))
   {
      Print("⚠️ Cannot calculate margin requirement!");
      return minLot;
   }
   
   if(marginRequired > m_account.FreeMargin() * 0.8) // Use max 80% of free margin
   {
      lotSize = lotSize * (m_account.FreeMargin() * 0.8) / marginRequired;
      lotSize = MathFloor(lotSize / lotStep) * lotStep;
      lotSize = MathMax(lotSize, minLot);
   }
   
   //--- FINAL UNIVERSAL HARD SAFETY CAP (Protects win rate by preventing premature $10 stopouts)
   if(InpMaxAllowedLot > 0)
   {
      lotSize = MathMin(lotSize, InpMaxAllowedLot);
   }
   lotSize = MathMax(lotSize, minLot);
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   
   return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| MANAGE OPEN POSITIONS (Trailing Stop & Breakeven)                |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(!m_position.SelectByIndex(i))
         continue;
      
      //--- Only manage our positions (matching magic number)
      if(m_position.Magic() != InpMagicNumber)
         continue;
      
      //--- Calculate position profit in price distance
      double openPrice    = m_position.PriceOpen();
      double currentPrice = m_position.PriceCurrent();
      double currentSL    = m_position.StopLoss();
      double currentTP    = m_position.TakeProfit();
      double netProfit    = m_position.Profit() + m_position.Swap() + m_position.Commission();
      ulong ticket        = m_position.Ticket();
      
      //--- HARD DOLLAR LOSS SHIELD (Rule 7: Strict Universal Loss Cap per trade)
      // Strictly enforce InpMaxDollarLossPerTrade as the ceiling so trades never exceed safe risk
      double dynamicMaxLoss = InpMaxDollarLossPerTrade;
      
      // Allow trade at least 5 seconds to clear initial broker spread before hard loss shield checks
      if(TimeCurrent() - (datetime)m_position.Time() >= 5)
      {
         if(netProfit < 0 && MathAbs(netProfit) >= dynamicMaxLoss)
         {
            Print("🛡️ HARD DOLLAR LOSS SHIELD TRIGGERED! Floating Loss: $", DoubleToString(netProfit, 2), " >= Max Allowed $", DoubleToString(dynamicMaxLoss, 2), ". Exiting trade instantly!");
            SetSymbolLossCooldown(m_position.Symbol());
            m_trade.PositionClose(ticket);
            continue;
         }
      }
      
      //--- STEALTH MODE (Virtual SL/TP Checks)
      // Coordinated: Primary symbol chart manages its own stealth exits cleanly; InpAutoMultiSymbol handles all
      if(InpUseStealthMode && (m_position.Symbol() == _Symbol || InpAutoMultiSymbol))
      {
         string slName = "SL_" + IntegerToString(ticket);
         string tpName = "TP_" + IntegerToString(ticket);
         if(GlobalVariableCheck(slName)) currentSL = GlobalVariableGet(slName);
         if(GlobalVariableCheck(tpName)) currentTP = GlobalVariableGet(tpName);
         
         if(m_position.PositionType() == POSITION_TYPE_BUY)
         {
            if(currentSL > 0 && currentPrice <= currentSL) { SetSymbolLossCooldown(m_position.Symbol()); m_trade.PositionClose(ticket); Print("👻 Stealth SL Hit (BUY)!"); continue; }
            if(currentTP > 0 && currentPrice >= currentTP) { m_trade.PositionClose(ticket); Print("👻 Stealth TP Hit (BUY)!"); continue; }
         }
         else if(m_position.PositionType() == POSITION_TYPE_SELL)
         {
            if(currentSL > 0 && currentPrice >= currentSL) { SetSymbolLossCooldown(m_position.Symbol()); m_trade.PositionClose(ticket); Print("👻 Stealth SL Hit (SELL)!"); continue; }
            if(currentTP > 0 && currentPrice <= currentTP) { m_trade.PositionClose(ticket); Print("👻 Stealth TP Hit (SELL)!"); continue; }
         }
      }
      
      //--- ONLY apply ATR-based logic (Trailing Stop, Breakeven, Price Shock) to CURRENT chart symbol
      if(m_position.Symbol() == _Symbol)
      {
         //--- Get ATR for dynamic trailing
         if(ArraySize(bufATR) < 1) continue;
         double atr = bufATR[0];
         if(atr <= 0) continue;
         
         //--- WINDFALL PROFIT EXIT (Rule 10 - Price Shocks)
         if(netProfit > 0 && CheckPriceShock(atr))
         {
            Print("⚠️ WINDFALL PROFIT DETECTED during Price Shock. Exiting immediately! Profit: $", DoubleToString(netProfit, 2));
            m_trade.PositionClose(ticket);
            continue;
         }
         
         if(m_position.PositionType() == POSITION_TYPE_BUY)
      {
         double profitDistance = currentPrice - openPrice;
         
         // 1. Dynamic Breakeven (At 1.0 ATR distance) -> Zero Risk Lock
         // Removed '$1.00 choke' so trades have breathing room to reach full profit targets
         if(profitDistance >= atr * 1.0 && currentSL < openPrice)
         {
            double beSL = NormalizeDouble(openPrice + m_symbol.Spread() * _Point, _Digits);
            if(InpUseStealthMode)
            {
               GlobalVariableSet("SL_" + IntegerToString(ticket), beSL);
               Print("👻 🔒 BUY moved to ZERO-RISK Breakeven (Stealth)! SL: ", DoubleToString(beSL, _Digits));
            }
            else if(m_trade.PositionModify(ticket, beSL, m_position.TakeProfit()))
            {
               Print("🔒 BUY moved to ZERO-RISK Breakeven! Net Profit: $", DoubleToString(netProfit, 2), 
                     " | SL: ", DoubleToString(beSL, _Digits));
            }
         }
         
         // 1.5. Partial Profit Taking (50% at 1.5x ATR distance)
         string partialGV = "PARTIAL_" + IntegerToString(ticket);
         if(!GlobalVariableCheck(partialGV) && profitDistance >= atr * 1.5)
         {
            double vol = m_position.Volume();
            if(vol >= m_symbol.LotsMin() * 2) // Need at least 2x min lot to split
            {
               double closeVol = MathFloor((vol / 2.0) / m_symbol.LotsStep()) * m_symbol.LotsStep();
               closeVol = MathMax(closeVol, m_symbol.LotsMin());
               if(m_trade.PositionClosePartial(ticket, closeVol))
               {
                  GlobalVariableSet(partialGV, 1);
                  Print("💰 BUY Partial Profit Taken! Closed ", DoubleToString(closeVol, 2), " lots.");
               }
            }
         }
         
         // 2. Dynamic Trailing Stop to lock increasing profits (At 1.2+ ATR with 0.8 ATR healthy buffer)
         if(InpUseTrailingStop && profitDistance >= atr * InpTrailATR_Multi)
         {
            double newSL = NormalizeDouble(currentPrice - atr * InpTrailStepATR, _Digits);
            if(newSL > currentSL + _Point && newSL > openPrice)
            {
               if(InpUseStealthMode)
               {
                  GlobalVariableSet("SL_" + IntegerToString(ticket), newSL);
                  Print("👻 🔄 BUY Trailing SL (Stealth) locked profit: ", DoubleToString(currentSL, _Digits), " → ", DoubleToString(newSL, _Digits));
               }
               else if(m_trade.PositionModify(ticket, newSL, m_position.TakeProfit()))
               {
                  Print("🔄 BUY Trailing SL locked profit: ", DoubleToString(currentSL, _Digits), 
                        " → ", DoubleToString(newSL, _Digits));
               }
            }
         }
      }
      else if(m_position.PositionType() == POSITION_TYPE_SELL)
      {
         double profitDistance = openPrice - currentPrice;
         
         // 1. Dynamic Breakeven (At 1.0 ATR distance) -> Zero Risk Lock
         // Removed '$1.00 choke' so trades have breathing room to reach full profit targets
         if(profitDistance >= atr * 1.0 && (currentSL > openPrice || currentSL == 0))
         {
            double beSL = NormalizeDouble(openPrice - m_symbol.Spread() * _Point, _Digits);
            if(InpUseStealthMode)
            {
               GlobalVariableSet("SL_" + IntegerToString(ticket), beSL);
               Print("👻 🔒 SELL moved to ZERO-RISK Breakeven (Stealth)! SL: ", DoubleToString(beSL, _Digits));
            }
            else if(m_trade.PositionModify(ticket, beSL, m_position.TakeProfit()))
            {
               Print("🔒 SELL moved to ZERO-RISK Breakeven! Net Profit: $", DoubleToString(netProfit, 2), 
                     " | SL: ", DoubleToString(beSL, _Digits));
            }
         }
         
         // 1.5. Partial Profit Taking (50% at 1.5x ATR distance)
         string partialGV = "PARTIAL_" + IntegerToString(ticket);
         if(!GlobalVariableCheck(partialGV) && profitDistance >= atr * 1.5)
         {
            double vol = m_position.Volume();
            if(vol >= m_symbol.LotsMin() * 2) // Need at least 2x min lot to split
            {
               double closeVol = MathFloor((vol / 2.0) / m_symbol.LotsStep()) * m_symbol.LotsStep();
               closeVol = MathMax(closeVol, m_symbol.LotsMin());
               if(m_trade.PositionClosePartial(ticket, closeVol))
               {
                  GlobalVariableSet(partialGV, 1);
                  Print("💰 SELL Partial Profit Taken! Closed ", DoubleToString(closeVol, 2), " lots.");
               }
            }
         }
         
         // 2. Dynamic Trailing Stop to lock increasing profits (At 1.2+ ATR with 0.8 ATR healthy buffer)
         if(InpUseTrailingStop && profitDistance >= atr * InpTrailATR_Multi)
         {
            double newSL = NormalizeDouble(currentPrice + atr * InpTrailStepATR, _Digits);
            if((newSL < currentSL - _Point || currentSL == 0) && newSL < openPrice)
            {
               if(InpUseStealthMode)
               {
                  GlobalVariableSet("SL_" + IntegerToString(ticket), newSL);
                  Print("👻 🔄 SELL Trailing SL (Stealth) locked profit: ", DoubleToString(currentSL, _Digits), " → ", DoubleToString(newSL, _Digits));
               }
               else if(m_trade.PositionModify(ticket, newSL, m_position.TakeProfit()))
               {
                  Print("🔄 SELL Trailing SL locked profit: ", DoubleToString(currentSL, _Digits),
                        " → ", DoubleToString(newSL, _Digits));
               }
            }
         }
      }
      }
   }
}

//+------------------------------------------------------------------+
//| CHECK IF SPREAD IS ACCEPTABLE                                    |
//+------------------------------------------------------------------+
bool IsSpreadAcceptable()
{
   double spreadPoints = GetCurrentSpreadPoints();
   return (spreadPoints <= g_maxSpreadPoints);
}

//+------------------------------------------------------------------+
//| GET CURRENT SPREAD IN POINTS                                     |
//+------------------------------------------------------------------+
double GetCurrentSpreadPoints()
{
   return (double)m_symbol.Spread();
}

//+------------------------------------------------------------------+
//| CHECK IF WITHIN TRADING SESSION                                  |
//+------------------------------------------------------------------+
bool IsTradingSession()
{
   // Crypto trades 24/7 (including Saturdays and Sundays)
   string symUpper = _Symbol;
   StringToUpper(symUpper);
   if(StringFind(symUpper, "BTC") >= 0 || StringFind(symUpper, "ETH") >= 0) return true;
   
   MqlDateTime timeStruct;
   TimeCurrent(timeStruct);
   int hour = timeStruct.hour;
   int min  = timeStruct.min;
   
   if(InpUseGoldenHoursOnly)
   {
      // Kaufman Rule 7: Intraday breakouts have highest probability in the first 90-120 mins of session open
      // London Open Window: 08:00 - 10:00 GMT
      bool isLondonGolden = (hour >= 8 && hour < 10);
      // New York Open Window: 13:00 - 15:00 GMT
      bool isNYGolden     = (hour >= 13 && hour < 15);
      
      if(isLondonGolden || isNYGolden) return true;
      return false;
   }
   
   //--- Asian Session: 00:00 - 08:00 GMT
   if(InpTradeAsian && hour >= 0 && hour < 8)
      return true;
   
   //--- London Session: 08:00 - 16:00 GMT
   if(InpTradeLondon && hour >= 8 && hour < 16)
      return true;
   
   //--- New York Session: 13:00 - 21:00 GMT
   if(InpTradeNewYork && hour >= 13 && hour < 21)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| CHECK IF MINIMUM BARS HAVE PASSED SINCE LAST TRADE              |
//+------------------------------------------------------------------+
bool IsMinBarsPassed()
{
   if(g_lastTradeTime == 0) return true;
   
   //--- Get number of bars since last trade
   int barsSince = iBarShift(_Symbol, InpTimeframe, g_lastTradeTime);
   if(barsSince < 0) return true;
   return (barsSince >= InpMinBarsBetween);
}

//+------------------------------------------------------------------+
//| COUNT OPEN POSITIONS FOR THIS EA (ALL SYMBOLS COMBINED)           |
//+------------------------------------------------------------------+
int CountOpenPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(m_position.SelectByIndex(i))
      {
         // Count ALL positions with our Magic Number across ALL symbols
         if(m_position.Magic() == InpMagicNumber)
            count++;
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| COUNT OPEN POSITIONS FOR A SPECIFIC SYMBOL                       |
//+------------------------------------------------------------------+
int CountOpenPositionsForSymbol(string symbol)
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(m_position.SelectByIndex(i))
      {
         if(m_position.Magic() == InpMagicNumber && m_position.Symbol() == symbol)
            count++;
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| COUNT OPEN JPY POSITIONS ACROSS ALL SYMBOLS                      |
//+------------------------------------------------------------------+
int CountOpenJPYPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(m_position.SelectByIndex(i))
      {
         if(m_position.Magic() == InpMagicNumber)
         {
            string sym = m_position.Symbol();
            StringToUpper(sym);
            if(StringFind(sym, "JPY") >= 0)
               count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| CHECK 5% EQUITY DRAWDOWN SHIELD (MQL5 Enforcement)               |
//+------------------------------------------------------------------+
bool CheckEquityDrawdown()
{
   double balance = m_account.Balance();
   double equity  = m_account.Equity();
   if(balance <= 0) return false;

   double drawdownPct = (balance > equity) ? (((balance - equity) / balance) * 100.0) : 0.0;
   if(drawdownPct >= InpMaxDrawdownPercent)
   {
      if(InpShowDashboard) UpdateDashboard("⛔ EQUITY SHIELD: " + DoubleToString(drawdownPct, 2) + "% drawdown - HALTED");
      Print("🛡️ Equity Drawdown Shield triggered: ", DoubleToString(drawdownPct, 2), "% >= ", DoubleToString(InpMaxDrawdownPercent, 1), "% limit.");
      
      // Emergency close all active positions
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         if(m_position.SelectByIndex(i))
         {
            if(m_position.Magic() == InpMagicNumber)
               m_trade.PositionClose(m_position.Ticket());
         }
      }
      return true; // Halt trading
   }
   return false;
}

//+------------------------------------------------------------------+
//| CHECK DAILY PROFIT AND LOSS LIMITS                               |
//+------------------------------------------------------------------+
bool CheckDailyLimits()
{
   if(g_dailyStartBalance <= 0)
   {
      g_dailyStartBalance = m_account.Balance();
      if(g_dailyStartBalance <= 0) return false; // Failsafe against uninitialized MT5 state
   }
   
   double currentBalance = m_account.Balance();
   double dailyPnL = currentBalance - g_dailyStartBalance;
   
   //--- Also count floating P&L
   double floatingPnL = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(m_position.SelectByIndex(i))
      {
         if(m_position.Magic() == InpMagicNumber)
            floatingPnL += m_position.Profit() + m_position.Swap() + m_position.Commission();
      }
   }
   
   double totalPnL = dailyPnL + floatingPnL;
   
   //--- Convert percentages to USD amounts based on starting balance
   double targetAmount = g_dailyStartBalance * (InpDailyProfitTargetPercent / 100.0);
   double triggerAmount = g_dailyStartBalance * (InpDailyProfitTrailingTriggerPercent / 100.0);
   double lockStepAmount = g_dailyStartBalance * (InpDailyProfitTrailingLockPercent / 100.0);
   
   //--- Dynamic Daily Profit Trailing Lock
   if(totalPnL > g_maxDailyProfit)
   {
      g_maxDailyProfit = totalPnL;
      if(triggerAmount > 0 && g_maxDailyProfit >= triggerAmount)
      {
         double newLock = g_maxDailyProfit - (triggerAmount - lockStepAmount);
         if(newLock > g_dailyProfitLock) g_dailyProfitLock = newLock;
      }
   }
   
   if(g_dailyProfitLock != -999.0 && totalPnL <= g_dailyProfitLock)
   {
      if(InpShowDashboard) UpdateDashboard("🛡️ DAILY PROFIT LOCKED ($" + DoubleToString(g_dailyProfitLock, 2) + ") - STOPPED");
      return true;
   }
   
   if(InpDailyProfitTargetPercent > 0 && targetAmount > 0 && totalPnL >= targetAmount)
   {
      if(InpShowDashboard) UpdateDashboard("✅ DAILY TARGET HIT (+" + DoubleToString(InpDailyProfitTargetPercent, 1) + "%) - STOPPED");
      return true;
   }
   
   double lossLimitAmount = g_dailyStartBalance * (InpDailyLossLimitPercent / 100.0);
   if(InpDailyLossLimitPercent > 0 && lossLimitAmount > 0 && totalPnL <= -lossLimitAmount)
   {
      if(InpShowDashboard) UpdateDashboard("⛔ DAILY LOSS HIT (-" + DoubleToString(InpDailyLossLimitPercent, 1) + "%) - STOPPED");
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| CHECK FOR NEW TRADING DAY — Reset Counters                      |
//+------------------------------------------------------------------+
void CheckNewDay()
{
   datetime today = iTime(_Symbol, PERIOD_D1, 0);
   if(today != g_currentDay)
   {
      //--- New day detected! Reset everything
      g_currentDay        = today;
      g_dailyStartBalance = m_account.Balance();
      g_totalTradesToday  = 0;
      g_winTrades         = 0;
      g_lossTrades        = 0;
      g_totalProfit       = 0;
      g_dailyLossHit      = false;
      g_maxDailyProfit    = 0.0;
      g_dailyProfitLock   = -999.0;
      
      Print("🌅 New trading day! Balance: ", DoubleToString(g_dailyStartBalance, 2));
   }
}

//+------------------------------------------------------------------+
//| VALIDATE STOP LOSS AND TAKE PROFIT LEVELS                       |
//+------------------------------------------------------------------+
bool ValidateStopLevels(ENUM_ORDER_TYPE orderType, double price, double sl, double tp)
{
   double minStop = m_symbol.StopsLevel() * _Point;
   if(minStop <= 0)
      minStop = m_symbol.Spread() * _Point * 2.0; // Rule 2: Guarantee minimum distance using 2x Spread
   
   if(orderType == ORDER_TYPE_BUY)
   {
      if(price - sl < minStop) return false;
      if(tp - price < minStop) return false;
   }
   else
   {
      if(sl - price < minStop) return false;
      if(price - tp < minStop) return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| UPDATE ON-CHART DASHBOARD                                        |
//+------------------------------------------------------------------+
void UpdateDashboard(string statusMessage)
{
   if(!InpShowDashboard) return;
   
   // Optimize dashboard updates to prevent terminal lag
   static int tickCounter = 0;
   static string lastStatus = "";
   
   bool forceUpdate = false;
   if(statusMessage != "" && statusMessage != lastStatus)
   {
      lastStatus = statusMessage;
      forceUpdate = true;
   }
   
   tickCounter++;
   if(tickCounter % 10 != 0 && !forceUpdate) return;
   
   //--- Colors
   color clrTitle   = clrGold;
   color clrText    = clrWhite;
   color clrProfit  = clrLime;
   color clrLoss    = clrRed;
   color clrStatus  = clrDodgerBlue;
   color clrBg      = clrBlack;
   
   int x = 10;
   int y = 30;
   int lineHeight = 18;
   int fontSize = 9;
   string fontName = "Consolas";
   
   //--- Title
   CreateLabel("XMBOT_Title", x, y, "╔═══════════════════════════════════╗", clrTitle, fontSize, fontName);
   y += lineHeight;
   CreateLabel("XMBOT_Name", x, y, "║ 🧠 XM SCALPER v16.20 TURBO-50 ║", clrTitle, fontSize, fontName);
   y += lineHeight;
   CreateLabel("XMBOT_Sep1", x, y, "╠═══════════════════════════════════╣", clrTitle, fontSize, fontName);
   y += lineHeight;
   
   //--- Symbol & Timeframe
   string symDisplay = InpAutoMultiSymbol ? "PORTFOLIO" : _Symbol;
   CreateLabel("XMBOT_Symbol", x, y, 
      StringFormat("║ Symbol: %-10s TF: %-8s  ║", symDisplay, EnumToString(InpTimeframe)), 
      clrText, fontSize, fontName);
   y += lineHeight;
   
   //--- Spread
   double spread = GetCurrentSpreadPoints();
   color spreadColor = (spread <= g_maxSpreadPoints) ? clrProfit : clrLoss;
   CreateLabel("XMBOT_Spread", x, y,
      StringFormat("║ Spread: %-6.1f pts (Max: %-5.0f)   ║", spread, g_maxSpreadPoints),
      spreadColor, fontSize, fontName);
   y += lineHeight;
   
   //--- Balance & Equity
   CreateLabel("XMBOT_Balance", x, y,
      StringFormat("║ Balance: $%-10.2f             ║", m_account.Balance()),
      clrText, fontSize, fontName);
   y += lineHeight;
   CreateLabel("XMBOT_Equity", x, y,
      StringFormat("║ Equity:  $%-10.2f             ║", m_account.Equity()),
      clrText, fontSize, fontName);
   y += lineHeight;
   
   //--- Daily PnL
   double dailyPnL = m_account.Balance() - g_dailyStartBalance;
   double dailyPnLPct = (g_dailyStartBalance > 0) ? (dailyPnL / g_dailyStartBalance * 100) : 0;
   color pnlColor = (dailyPnL >= 0) ? clrProfit : clrLoss;
   CreateLabel("XMBOT_DailyPnL", x, y,
      StringFormat("║ Daily P&L: %+.2f (%+.2f%%)       ║", dailyPnL, dailyPnLPct),
      pnlColor, fontSize, fontName);
   y += lineHeight;
   
   //--- Open Trades
   int openTrades = CountOpenPositions();
   CreateLabel("XMBOT_Trades", x, y,
      StringFormat("║ Open: %d/%d | Today: %-3d          ║", openTrades, InpMaxOpenTrades, g_totalTradesToday),
      clrText, fontSize, fontName);
   y += lineHeight;
   
   //--- Separator
   CreateLabel("XMBOT_Sep2", x, y, "╠═══════════════════════════════════╣", clrTitle, fontSize, fontName);
   y += lineHeight;
   
   //--- Indicator Values
   if(ArraySize(bufRSI) > 0 && ArraySize(bufMACD_Main) > 0)
   {
      double rsi = bufRSI[0];
      color rsiColor = (rsi > 70) ? clrLoss : (rsi < 30) ? clrProfit : clrText;
      CreateLabel("XMBOT_RSI", x, y,
         StringFormat("║ RSI: %-6.1f  MACD: %+.6f    ║", rsi, bufMACD_Main[0] - bufMACD_Signal[0]),
         rsiColor, fontSize, fontName);
      y += lineHeight;
   }
   
   if(ArraySize(bufATR) > 0)
   {
      CreateLabel("XMBOT_ATR", x, y,
         StringFormat("║ ATR: %-10.5f                  ║", bufATR[0]),
         clrText, fontSize, fontName);
      y += lineHeight;
   }
   
   //--- Separator
   CreateLabel("XMBOT_Sep3", x, y, "╠═══════════════════════════════════╣", clrTitle, fontSize, fontName);
   y += lineHeight;
   
   //--- Status
   CreateLabel("XMBOT_Status", x, y,
      StringFormat("║ %-35s║", statusMessage),
      clrStatus, fontSize, fontName);
   y += lineHeight;
   
   //--- Bottom border
   CreateLabel("XMBOT_Bottom", x, y, "╚═══════════════════════════════════╝", clrTitle, fontSize, fontName);
   
   //--- Force chart redraw
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| CREATE TEXT LABEL ON CHART                                       |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color clr, int fontSize, string fontName)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, fontName);
}

//+------------------------------------------------------------------+
//| TRADE EVENT HANDLER — Track wins/losses                         |
//+------------------------------------------------------------------+
void OnTrade()
{
   //--- Check for recently closed positions in history
   HistorySelect(g_currentDay, TimeCurrent());
   
   //--- Reset daily win/loss accumulators to prevent repeated deal double-counting
   g_winTrades = 0;
   g_lossTrades = 0;
   g_totalProfit = 0;
   
   int totalDeals = HistoryDealsTotal();
   for(int i = totalDeals - 1; i >= 0; i--)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket <= 0) continue;
      
      //--- Only count our deals
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != InpMagicNumber) continue;
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
      
      //--- Only count exit deals
      ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT) continue;
      
      double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT) + 
                      HistoryDealGetDouble(ticket, DEAL_SWAP) + 
                      HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      
      if(profit > 0)
         g_winTrades++;
      else if(profit < 0)
         g_lossTrades++;
      
      g_totalProfit += profit;
   }
}

//+------------------------------------------------------------------+
//| CHECK SMC FAIR VALUE GAPS (FVG)                                  |
//+------------------------------------------------------------------+
bool CheckBullishFVG()
{
   if(!InpUseSMC_FVG) return true; // Bypass if disabled
   
   double high[], low[];
   ArraySetAsSeries(high, true); ArraySetAsSeries(low, true);
   
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, InpFVG_Lookback, high) <= 0) return false;
   if(CopyLow(_Symbol, PERIOD_CURRENT, 0, InpFVG_Lookback, low) <= 0) return false;
   
   double currentPrice = m_symbol.Ask();
   
   for(int i = 1; i < InpFVG_Lookback - 2; i++)
   {
      // Bullish FVG: Low of candle i > High of candle i+2
      if(low[i] > high[i+2])
      {
         double topFVG = low[i];
         double botFVG = high[i+2];
         // Check if current price is inside or just touched this FVG
         if(currentPrice <= topFVG && currentPrice >= botFVG)
            return true;
      }
   }
   return false;
}

bool CheckBearishFVG()
{
   if(!InpUseSMC_FVG) return true; // Bypass if disabled
   
   double high[], low[];
   ArraySetAsSeries(high, true); ArraySetAsSeries(low, true);
   
   if(CopyHigh(_Symbol, PERIOD_CURRENT, 0, InpFVG_Lookback, high) <= 0) return false;
   if(CopyLow(_Symbol, PERIOD_CURRENT, 0, InpFVG_Lookback, low) <= 0) return false;
   
   double currentPrice = m_symbol.Bid();
   
   for(int i = 1; i < InpFVG_Lookback - 2; i++)
   {
      // Bearish FVG: High of candle i < Low of candle i+2
      if(high[i] < low[i+2])
      {
         double botFVG = high[i];
         double topFVG = low[i+2];
         // Check if current price is inside or just touched this FVG
         if(currentPrice >= botFVG && currentPrice <= topFVG)
            return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| CHECK MULTI-CURRENCY CORRELATION                                 |
//+------------------------------------------------------------------+
bool CheckCorrelation(int type) // 1=BUY, -1=SELL
{
   if(!InpUseCorrelation) return true; // Bypass if disabled
   
   double corrEma[];
   ArraySetAsSeries(corrEma, true);
   if(CopyBuffer(h_corrEma, 0, 0, 1, corrEma) <= 0) return true; // Fallback if no data
   
   double corrPrice = iClose(InpCorrSymbol, InpTimeframe, 0);
   
   if(type == 1) // BUY EURUSD -> USDCHF must be dropping (Price < EMA)
   {
      return (corrPrice < corrEma[0]);
   }
   else if(type == -1) // SELL EURUSD -> USDCHF must be rising (Price > EMA)
   {
      return (corrPrice > corrEma[0]);
   }
   return true;
}

//+------------------------------------------------------------------+
//| GET ONNX AI PREDICTION                                           |
//+------------------------------------------------------------------+
bool GetAIPrediction(int type_code, double rsi, double spread, double macd, double atr)
{
   if(!InpUseONNX_AI || h_onnx == INVALID_HANDLE) return true; // Bypass if disabled or missing
   
   float inputs[5];
   inputs[0] = (float)rsi;
   inputs[1] = (float)spread;
   inputs[2] = (float)macd;
   inputs[3] = (float)atr;
   inputs[4] = (float)type_code;
   
   long prediction[1];
   float probabilities[2];
   
   if(OnnxRun(h_onnx, ONNX_NO_CONVERSION, inputs, prediction, probabilities))
   {
      double winProb = probabilities[1];
      if(winProb >= InpONNX_MinProb)
      {
         Print("🧠 AI Approved! Win Probability: ", DoubleToString(winProb * 100, 1), "%");
         return true;
      }
      else
      {
         Print("🚫 AI Rejected! Win Probability: ", DoubleToString(winProb * 100, 1), "% < Target");
         return false;
      }
   }
   
   Print("❌ ONNX Run Error: ", GetLastError());
   return true; // Failsafe pass
}

//+------------------------------------------------------------------+
//| CHECK ORDER BOOK (DOM) FOR SELL/BUY WALLS                        |
//+------------------------------------------------------------------+
bool CheckOrderBookDOM(int type_code) // 1=BUY, -1=SELL
{
   if(!InpUseDOM_Filter) return true;
   
   MqlBookInfo book[];
   if(!MarketBookGet(_Symbol, book)) return true; // Failsafe pass if broker blocks DOM
   
   double totalBuyVol = 0;
   double totalSellVol = 0;
   
   for(int i = 0; i < ArraySize(book); i++)
   {
      if(book[i].type == BOOK_TYPE_SELL) totalSellVol += (double)book[i].volume;
      else if(book[i].type == BOOK_TYPE_BUY) totalBuyVol += (double)book[i].volume;
   }
   
   if(totalBuyVol == 0 || totalSellVol == 0) return true;
   
   if(type_code == 1) // Wants to BUY
   {
      if(totalSellVol >= totalBuyVol * InpDOM_WallRatio)
      {
         Print("🚫 DOM Blocked BUY! Huge Sell Wall Detected! (SellVol: ", totalSellVol, " vs BuyVol: ", totalBuyVol, ")");
         return false;
      }
   }
   else if(type_code == -1) // Wants to SELL
   {
      if(totalBuyVol >= totalSellVol * InpDOM_WallRatio)
      {
         Print("🚫 DOM Blocked SELL! Huge Buy Wall Detected! (BuyVol: ", totalBuyVol, " vs SellVol: ", totalSellVol, ")");
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| CHART EVENT HANDLER                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   //--- Handle chart resize — redraw dashboard
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      if(InpShowDashboard)
         UpdateDashboard("🔍 Scanning for signals...");
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ECONOMIC NEWS FILTER                                             |
//+------------------------------------------------------------------+
bool IsNewsTime()
{
   if(!InpAvoidHighImpactNews) return false;
   
   // Get the two currencies from the symbol (e.g. "EUR" and "USD" from "EURUSD")
   string curr1 = StringSubstr(_Symbol, 0, 3);
   string curr2 = StringSubstr(_Symbol, 3, 3);
   
   datetime timeFrom = TimeCurrent() - (InpNewsPauseBefore * 60);
   datetime timeTo   = TimeCurrent() + (InpNewsPauseAfter * 60);
   
   // Array to hold calendar values
   MqlCalendarValue values[];
   
   // Check Currency 1
   static bool warned = false;
   if(!CalendarValueHistory(values, timeFrom, timeTo, NULL, curr1))
   {
      if(!warned)
      {
         Print("📰 Warning: Calendar data not available – news filter disabled.");
         warned = true;
      }
   }
   else
   {
      for(int i = 0; i < ArraySize(values); i++)
      {
         MqlCalendarEvent event;
         if(CalendarEventById(values[i].event_id, event))
         {
            if(event.importance == CALENDAR_IMPORTANCE_HIGH)
            {
               return true; // High impact news found for Base currency
            }
         }
      }
   }
   
   // Check Currency 2
   if(StringLen(curr2) == 3)
   {
      ArrayFree(values);
      if(CalendarValueHistory(values, timeFrom, timeTo, NULL, curr2))
      {
         for(int i = 0; i < ArraySize(values); i++)
         {
            MqlCalendarEvent event;
            if(CalendarEventById(values[i].event_id, event))
            {
               if(event.importance == CALENDAR_IMPORTANCE_HIGH)
               {
                  return true; // High impact news found for Quote currency
               }
            }
         }
      }
   }
   
   return false;
}
//+------------------------------------------------------------------+
//| Calculate Efficiency Ratio (ER)                                  |
//+------------------------------------------------------------------+
double CalculateER(int period)
{
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyClose(_Symbol, PERIOD_CURRENT, 0, period + 1, close) <= period) return 0.0;
   
   double change = MathAbs(close[0] - close[period]); // Net price change
   double sumVolatility = 0;
   
   for(int i = 0; i < period; i++)
   {
      sumVolatility += MathAbs(close[i] - close[i+1]);
   }
   
   if(sumVolatility == 0) return 0.0;
   return change / sumVolatility;
}

//+------------------------------------------------------------------+
//| Check Price Shock (Range > 5 * ATR)                              |
//+------------------------------------------------------------------+
bool CheckPriceShock(double currentATR)
{
   double open[], close[];
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   if(CopyOpen(_Symbol, PERIOD_CURRENT, 0, 1, open) <= 0) return false;
   if(CopyClose(_Symbol, PERIOD_CURRENT, 0, 1, close) <= 0) return false;
   
   double range = MathAbs(close[0] - open[0]);
   if(currentATR > 0 && range > 5.0 * currentATR)
   {
      Print("⚠️ PRICE SHOCK DETECTED! Bar Range > 5x ATR.");
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Check if position on this symbol is in loss (Anti-Martingale)    |
//+------------------------------------------------------------------+
bool IsSymbolPositionInLoss(string sym)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(m_position.SelectByIndex(i))
      {
         if(m_position.Magic() == InpMagicNumber && m_position.Symbol() == sym)
         {
            double netProfit = m_position.Profit() + m_position.Swap() + m_position.Commission();
            if(netProfit < 0) return true;
         }
      }
   }
   return false;
}

bool IsAnyPositionInLoss()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(m_position.SelectByIndex(i))
      {
         if(m_position.Magic() == InpMagicNumber)
         {
            double netProfit = m_position.Profit() + m_position.Swap() + m_position.Commission();
            if(netProfit < 0) return true;
         }
      }
   }
   return false;
}
//+------------------------------------------------------------------+
//| SYMBOL LOSS COOLDOWN & GLOBAL ORDER LOCK (v15.50)               |
//+------------------------------------------------------------------+
void SetSymbolLossCooldown(string sym)
{
   if(InpLossCooldownMinutes <= 0) return;
   datetime cdUntil = TimeCurrent() + (InpLossCooldownMinutes * 60);
   GlobalVariableSet("COOLDOWN_" + sym, (double)cdUntil);
   Print("⏳ 🛑 LOSS COOLDOWN ACTIVATED for ", sym, "! Pausing trading on this symbol for ", InpLossCooldownMinutes, " minutes until ", TimeToString(cdUntil));
}

bool IsSymbolInCooldown(string sym)
{
   if(InpLossCooldownMinutes <= 0) return false;
   string gvName = "COOLDOWN_" + sym;
   if(GlobalVariableCheck(gvName))
   {
      datetime cdUntil = (datetime)GlobalVariableGet(gvName);
      if(TimeCurrent() < cdUntil)
         return true;
      else
         GlobalVariableDel(gvName); // Expired, clean up
   }
   return false;
}

bool IsGlobalOrderLockActive()
{
   if(InpGlobalOrderBufferSeconds <= 0) return false;
   if(GlobalVariableCheck("GV_GLOBAL_ORDER_LOCK"))
   {
      datetime lastOrderTime = (datetime)GlobalVariableGet("GV_GLOBAL_ORDER_LOCK");
      if(TimeCurrent() - lastOrderTime < InpGlobalOrderBufferSeconds)
         return true;
   }
   return false;
}

void SetGlobalOrderLock()
{
   GlobalVariableSet("GV_GLOBAL_ORDER_LOCK", (double)TimeCurrent());
}

//+------------------------------------------------------------------+
//| Auto-Duplicate Chart Tab Blocker                                 |
//+------------------------------------------------------------------+
bool IsMasterChart()
{
   string gvOwner = "GV_MASTER_CHART_" + _Symbol;
   long currentChartId = ChartID();
   if(GlobalVariableCheck(gvOwner))
   {
      long ownerId = (long)GlobalVariableGet(gvOwner);
      if(ownerId != currentChartId)
      {
         // Verify if the registered owner chart is still alive
         if(ChartSymbol(ownerId) == _Symbol)
         {
            return false; // Another chart owns this symbol! Go to Standby.
         }
      }
   }
   // Claim or renew master ownership
   GlobalVariableSet(gvOwner, (double)currentChartId);
   return true;
}
//+------------------------------------------------------------------+
