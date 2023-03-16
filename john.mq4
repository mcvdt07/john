int FastEMA = 12; // Fast EMA period
int SlowEMA = 26; // Slow EMA period
int SignalEMA = 9; // Signal EMA period
int RSIperiod = 14; // RSI period
int MACDperiod1 = 12; // MACD Fast EMA period
int MACDperiod2 = 26; // MACD Slow EMA period
int MACDsignal = 9; // MACD Signal EMA period

double Lots = NormalizeDouble(AccountBalance() * 0.01 / 1000.0, 2); // 0.01 lots per $1000 account balance
int MaxTrades = 3;

// Trailing stop loss
double TrailingStop = 20; // in pips
double TrailingStart = 10; // in pips
bool TrailingActivated = false;
double TrailingPrice = 0.0;

// Moving Average (MA)
int MA_Period = 20; // Period for Moving Average
int MA_Method = 0; // Method for Moving Average (0-SMA, 1-EMA, 2-SMMA, 3-LWMA)
int MA_Price = 0; // Price for Moving Average (0-Close, 1-Open, 2-High, 3-Low, 4-Median, 5-Typical, 6-Weighted)

// Relative Strength Index (RSI)
double RSI_Upper = 70;
double RSI_Lower = 30;

// Moving Average Convergence Divergence (MACD)
double MACD_Upper = 0.0;
double MACD_Lower = 0.0;

// Awesome Oscillator (iAO)
int iAO_Fast = 5;
int iAO_Slow = 34;
double iAO_Upper = 0.0;
double iAO_Lower = 0.0;

// Dynamic profit targets
double Account_Balance = AccountBalance();
double TargetRisk = 0.01;
double StopLoss = 50; // in pips
double TakeProfit = 100; // in pips
double TargetProfit = 0.0;

// Magic number for the orders
int MagicNumber = 123456;


void OnInit() {
    // Calculate dynamic profit target based on account balance
    if (Account_Balance < 10000) {
        TargetProfit = 0.3;
    } else if (Account_Balance < 50000) {
        TargetProfit = 0.5;
    } else {
        TargetProfit = 1.0;
    }

    // Activate trailing stop loss
    ActivateTrailingStopLoss();

    // Initialize CurrentPrice and CurrentTime variables
    double CurrentPrice = MarketInfo(Symbol(), MODE_BID);
    double CurrentTime = TimeCurrent();

    // Dashboard feature
    Comment("");
}


void OnTick() {
    // Calculate current market price and time
    CurrentPrice = MarketInfo(Symbol(), MODE_BID);
    CurrentTime = TimeCurrent();

    // Moving Average (MA)
    double MAvalue15 = iMA(NULL, PERIOD_M15, MA_Period, 0, MA_Method, MA_Price, 0);
    double MAvalue30 = iMA(NULL, PERIOD_M30, MA_Period, 0, MA_Method, MA_Price, 0);
    double MAvalue1H = iMA(NULL, PERIOD_H1, MA_Period, 0, MA_Method, MA_Price, 0);
    double MAvalue4H = iMA(NULL, PERIOD_H4, MA_Period, 0, MA_Method, MA_Price, 0);

    // Relative Strength Index (RSI)
    double RSIvalue15 = iRSI(NULL, PERIOD_M15, RSIperiod, PRICE_CLOSE, 0);
    double RSIvalue30 = iRSI(NULL, PERIOD_M30, RSIperiod, PRICE_CLOSE, 0);
    double RSIvalue1H = iRSI(NULL, PERIOD_H1, RSIperiod, PRICE_CLOSE, 0);
    double RSIvalue4H = iRSI(NULL, PERIOD_H4, RSIperiod, PRICE_CLOSE, 0);

    // Moving Average Convergence Divergence (MACD)
    double MACDvalue15 = iMACD(NULL, PERIOD_M15, MACDperiod1, MACDperiod2, MACDsignal, PRICE_CLOSE, MODE_MAIN, 0);
    double MACDvalue30 = iMACD(NULL, PERIOD_M30, MACDperiod1, MACDperiod2, MACDsignal, PRICE_CLOSE, MODE_MAIN, 0);
    double MACDvalue1H = iMACD(NULL, PERIOD_H1, MACDperiod1, MACDperiod2, MACDsignal, PRICE_CLOSE, MODE_MAIN, 0);
    double MACDvalue4H = iMACD(NULL, PERIOD_H4, MACDperiod1, MACDperiod2, MACDsignal, PRICE_CLOSE, MODE_MAIN, 0);

    // Awesome Oscillator (iAO)
    double iAOvalue15 = iAO(NULL, PERIOD_M15, iao_fast, iao_slow, 0, 0);
    double iAOvalue30 = iAO(NULL, PERIOD_M30, iao_fast, iao_slow, 0, 0);
    double iAOvalue1H = iAO(NULL, PERIOD_H1, iao_fast, iao_slow, 0, 0);
    double iAOvalue4H = iAO(NULL, PERIOD_H4, iao_fast, iao_slow, 0, 0);

    // Check for open trades
    int TotalTrades = 0;
    int TotalBuyTrades = 0;
    int TotalSellTrades = 0;
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                TotalTrades++;
                if (OrderType() == OP_BUY) {
                    TotalBuyTrades++;
                } else if (OrderType() == OP_SELL) {
                    TotalSellTrades++;
                }
            }
        }
    }

    // Check for trading conditions
    bool BuyCondition = false;
    bool SellCondition = false;

    // Determine buy and sell conditions based on indicators
if (MAvalue15 > MAvalue30 && RSIvalue15 > rsi_upper && MACDvalue15 > MACDvalue15 && iAOvalue15 > iao_upper) {
    BuyCondition = true;
}
if (MAvalue15 < MAvalue30 && RSIvalue15 < rsi_lower && MACDvalue15 < MACDvalue15 && iAOvalue15 < iao_lower) {
    SellCondition = true;
}
if (MAvalue30 > MAvalue1H && RSIvalue30 > rsi_upper && MACDvalue30 > MACDvalue30 && iAOvalue30 > iao_upper) {
    BuyCondition = true;
}
if (MAvalue30 < MAvalue1H && RSIvalue30 < rsi_lower && MACDvalue30 < MACDvalue30 && iAOvalue30 < iao_lower) {
    SellCondition = true;
}
if (MAvalue1H > MAvalue4H && RSIvalue1H > rsi_upper && MACDvalue1H > MACDvalue1H && iAOvalue1H > iao_upper) {
    BuyCondition = true;
}
if (MAvalue1H < MAvalue4H && RSIvalue1H < rsi_lower && MACDvalue1H < MACDvalue1H && iAOvalue1H < iao_lower) {
    SellCondition = true;
}

// Close existing losing trades
CloseLosingTrades();

// Open new trades based on buy and sell conditions
OpenNewTrades(BuyCondition, SellCondition);  

// Activate trailing stop loss
ActivateTrailingStopLoss();

// Check and adjust trailing stop loss
if (TrailingActivated) {
    TrailStopLoss(CurrentPrice, EntryPrice, MagicNumber);
    CheckTrailingStopLoss(CurrentPrice, MagicNumber);
}

// Update dashboard
Comment("Account balance: " + DoubleToStr(AccountBalance(), 2) + "\n" +
        "Current price: " + DoubleToStr(CurrentPrice, Digits) + "\n" +
        "Current time: " + TimeToString(CurrentTime) + "\n" +
        "Total trades: " + TotalTrades + "\n" +
        "Total buy trades: " + TotalBuyTrades + "\n" +
        "Total sell trades: " + TotalSellTrades);

}




void TrailStopLoss(double CurrentPrice, double EntryPrice, int MagicNumber) {
    if (TrailingActivated) {
        for (int i = 0; i < OrdersTotal(); i++) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
                if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
                    if (OrderType() == OP_BUY) {
                        if (OrderCloseTime() != 0) {
                            continue; // Skip closed orders
                        }
                        if ((CurrentPrice - EntryPrice) > (TrailingPrice + TrailingStart)) {
                            TrailingPrice += TrailingStart;
                            double StopLossPrice = EntryPrice + TrailingPrice;
                            if (StopLossPrice > OrderOpenPrice()) {
                                OrderModify(OrderTicket(), 0, StopLossPrice, 0, 0, Green);
                            } else {
                                OrderModify(OrderTicket(), 0, StopLossPrice, 0, 0, Red);
                            }
                        }
                    } else if (OrderType() == OP_SELL) {
                        if (OrderCloseTime() != 0) {
                            continue; // Skip closed orders
                        }
                        if ((EntryPrice - CurrentPrice) > (TrailingPrice + TrailingStart)) {
                            TrailingPrice += TrailingStart;
                            double StopLossPrice = EntryPrice - TrailingPrice;
                            if (StopLossPrice < OrderOpenPrice()) {
                                OrderModify(OrderTicket(), 0, StopLossPrice, 0, 0, Green);
                            } else {
                                OrderModify(OrderTicket(), 0, StopLossPrice, 0, 0, Red);
                            }
                        }
                    }
                }
            }
        }
    }
}


void CheckTrailingStopLoss()
{
    for (int i = 0; i < PositionsTotal(); i++)
    {
        if (PositionSelect(i))
        {
            if (Positions[i].Type == POSITION_TYPE_BUY)
            {
                if (Bid <= (Positions[i].OpenPrice - TrailingStopLoss * Point))
                {
                    Positions[i].TrailingStopLossActivated = true;
                    ActivateTrailingStopLoss(i);
                }
            }
            else if (Positions[i].Type == POSITION_TYPE_SELL)
            {
                if (Ask >= (Positions[i].OpenPrice + TrailingStopLoss * Point))
                {
                    Positions[i].TrailingStopLossActivated = true;
                    ActivateTrailingStopLoss(i);
                }
            }
        }
    }
}

void OpenNewTrades(bool BuyCondition, bool SellCondition) {
    // Check if there are open trades
    int TotalTrades = 0;
    int TotalBuyTrades = 0;
    int TotalSellTrades = 0;
    for (int i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                TotalTrades++;
                if (OrderType() == OP_BUY) {
                    TotalBuyTrades++;
                } else if (OrderType() == OP_SELL) {
                    TotalSellTrades++;
                }
            }
        }
    }

    // Determine order direction and send order
    if (BuyCondition && TotalBuyTrades < MaxTradesPerDirection && TotalTrades < MaxTradesTotal) {
        double NewLotSize = NormalizeDouble(AccountBalance() * 0.001 * TargetRisk, 2);
        if (NewLotSize * MarketInfo(Symbol(), MODE_TICKVALUE) * StopLoss > AccountBalance() * TargetRisk) {
            return;
        }
        if (NewLotSize <= 0) {
    return; // Skip orders with zero or negative lot size
}
        if (OrderSend(Symbol(), OP_BUY, NewLotSize, Ask, 3, Bid - StopLoss * MarketInfo(Symbol(), MODE_POINT), Bid + TakeProfit * MarketInfo(Symbol(), MODE_POINT), "Buy", MagicNumber, 0, Green)) {
            TotalBuyTrades++;
        }
    } else if (SellCondition && TotalSellTrades < MaxTradesPerDirection && TotalTrades < MaxTradesTotal) {
        double NewLotSize = NormalizeDouble(AccountBalance() * 0.001 * TargetRisk, 2);
        if (NewLotSize * MarketInfo(Symbol(), MODE_TICKVALUE) * StopLoss > AccountBalance() * TargetRisk) {
            return;
        }
        if (NewLotSize <= 0) {
    return; // Skip orders with zero or negative lot size
}
        if (OrderSend(Symbol(), OP_SELL, NewLotSize, Bid, 3, Ask + StopLoss * MarketInfo(Symbol(), MODE_POINT), Ask - TakeProfit * MarketInfo(Symbol(), MODE_POINT), "Sell", MagicNumber, 0, Red)) {
            TotalSellTrades++;
        }
    }
}

