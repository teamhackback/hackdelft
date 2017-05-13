module stock.algorithms.greedy;

import stock.framework;

import std.array;
import std.algorithm;
import std.datetime;
import std.math;
import std.path;
import std.random;
import std.stdio;
import std.format;
import std.file;

class GreedyTrader : Trader
{
    double shoppingPrice;
    int stockSize;
    double greedyRatio;

    this(int _stockSize = 100, double _greedyRatio = 0.95)
    {
        stockSize = _stockSize;
        greedyRatio = _greedyRatio;
    }

    override void onNewPrice(Price price)
    {
        if (!tradingIsOpen || finalPriceIsNext) return;

        if (currentStock == 0)
        {
            makeOrder(price.date + 1.seconds, stockSize);
            shoppingPrice = price.price;
        }
        else if (currentStock == stockSize)
        {
            bool isGreedySatisfied = (price.price / shoppingPrice).pow(sgn(stockSize)) < greedyRatio;
            if (isGreedySatisfied)
            {
                makeOrder(price.date + 1.seconds, -stockSize);
            }
        }
    }

    override string name()
    {
        return "stockSize:%d-ratio:%.2f".format(stockSize, greedyRatio);
    }
}

version(GreedyTrader)
void main(string[] args)
{
    import std.typecons;
    import std.array;
    import std.parallelism;
    import std.range;
    auto ns = iota(3000, 50000, 1000);
    auto ms = iota(100, 2000, 100);

    Appender!(Trader[]) app;

    //foreach(n; ns)
    //foreach(m; ms)
        //app ~= new SimpleAverageTrader(n, m);
    app ~= new GreedyTrader(100, 0.999);
    app ~= new GreedyTrader(100, 0.95);
    app ~= new GreedyTrader(100, 0.9);
    app ~= new GreedyTrader(100, 0.8);
    app ~= new GreedyTrader(100, 0.7);
    app ~= new GreedyTrader(-100, 1.3);
    app ~= new GreedyTrader(-100, 1.2);
    app ~= new GreedyTrader(-100, 1.1);
    app ~= new GreedyTrader(-100, 1.05);
    app ~= new GreedyTrader(-100, 1.01);

    app.data.analyzeTraders(buildPath("out", "greedy.csv"));
}