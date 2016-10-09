import numpy as np
from yahoo_finance import Share
import copy
import transaction
import datetime
import pprint


class Portfolio:
    """
    t = type Transaction
    
    Create new portfolio given old portfolio and a Transaction object. When
    last_portfolio is None, it means that our old portfolio was empty. Also,
    keep an instance variable start_date with the date of the transaction.
    """

    def __init__(self, t, last_portfolio=None, init_cash=None):

        # dictionary self.holdings: map from symbol (string) to qty (# shares)
        qty = t.direction * t.quantity
        if last_portfolio:
            self.holdings = copy.deepcopy(last_portfolio.holdings)
            if t.symbol in self.holdings:
                self.holdings[t.symbol] += qty
            else:
                self.holdings[t.symbol] = qty
        else:
            self.holdings = {}
            self.holdings[t.symbol] = qty
            self.holdings['cash'] = init_cash

        self.holdings['cash'] -= (qty * t.price + t.comm)

        self.start_date = t.date

    """
    Given date, calculate the value of the portfolio. Verifies that the
    date is after the start_date. 
    """

    def calculateValue(self, date, prices):
        value = 0.
        date = date.strftime('%Y-%m-%d')
        for sym,qty in self.holdings.items():
            if sym == 'cash':
                value += qty
            else:
                if sym not in prices:
                    stock = Share(sym)
                    # get prices until today
                    string_today = datetime.date.today().strftime('%Y-%m-%d')
                    price_list = stock.get_historical(date, string_today)
                    # pprint.PrettyPrinter(depth = 6).pprint(price_list)
                    # Prices is a dictionary of dictionaries; each inner dictionary consists of (date, value) pairs for a ticker
                    prices[sym] = {item['Date']: float(item['Adj_Close']) for item in price_list}

                # find price for the date of interest
                if date in prices[sym]:
                    close_price = prices[sym][date]
                    value += close_price * qty
                else:
                    print(date)
                    print(sym)
                    return (None, None)
        return (value, prices)



