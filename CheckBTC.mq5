//+------------------------------------------------------------------+
//| CheckBTC.mq5 - Diagnose BTCUSD trading state on XM              |
//+------------------------------------------------------------------+
#property script_show_inputs

void OnStart()
{
   string sym = "BTCUSD";
   bool selected = SymbolSelect(sym, true);
   
   long tradeMode = SymbolInfoInteger(sym, SYMBOL_TRADE_MODE);
   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   double spread = SymbolInfoInteger(sym, SYMBOL_SPREAD);
   datetime time = (datetime)SymbolInfoInteger(sym, SYMBOL_TIME);
   
   Print("=== BTCUSD DIAGNOSTIC ===");
   Print("Selected: ", selected);
   Print("Trade Mode: ", tradeMode, " (0=Disabled, 1=CloseOnly, 2=Partial, 3=Full, 4=Undefined)");
   Print("Bid: ", bid, " | Ask: ", ask, " | Spread: ", spread);
   Print("Last Quote Time: ", TimeToString(time, TIME_DATE|TIME_SECONDS));
   
   // Check session for Saturday (Day 6)
   datetime fromTime, toTime;
   bool session = SymbolInfoSessionTrade(sym, (ENUM_DAY_OF_WEEK)6, 0, fromTime, toTime);
   Print("Saturday Trade Session: ", session, " | From: ", TimeToString(fromTime, TIME_MINUTES), " To: ", TimeToString(toTime, TIME_MINUTES));
   
   datetime qFromTime, qToTime;
   bool qSession = SymbolInfoSessionQuote(sym, (ENUM_DAY_OF_WEEK)6, 0, qFromTime, qToTime);
   Print("Saturday Quote Session: ", qSession, " | From: ", TimeToString(qFromTime, TIME_MINUTES), " To: ", TimeToString(qToTime, TIME_MINUTES));
}

