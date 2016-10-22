import numpy as np
from yahoo_finance import Share
import copy
import transaction
import datetime
from dateutil import parser
import pprint

def try5times(func, tries = 0):
    if tries >= 5:
        raise "We fucked up"
    try:
        return func()
    except:
        tries += 1
        try5times(func, tries)

# TODO: modify to allow initial portfolio to contain stocks
class Portfolio:
    """
    t = type Transaction
    
    Create new portfolio given old portfolio and a Transaction object. When
    last_portfolio is None, it means that our old portfolio was empty. Also,
    keep an instance variable start_date with the date of the transaction.
    """

    def __init__(self, t=None, last_portfolio=None, init_cash=None):
        if t is not None: 
            # dictionary self.holdings: map from symbol (string) to qty (# shares)
            if last_portfolio is not None:
                self.holdings = copy.deepcopy(last_portfolio.holdings)
                if t.direction is not None:
                    qty = t.direction * t.quantity
                    if t.symbol in self.holdings:
                        self.holdings[t.symbol] += qty
                        if self.holdings[t.symbol] == 0:
                            del self.holdings[t.symbol]
                    else:
                        self.holdings[t.symbol] = qty
                        print("Shorting stock: {}".format(t.symbol) if t.direction == -1 else "Setting stock: {}".format(t.symbol))
                else:
                    self.holdings['cash'] += t.amt
            else:
                print(t.direction, t.quantity, t.date)
                self.holdings = {}
                qty = t.direction * t.quantity
                self.holdings[t.symbol] = qty
                self.holdings['cash'] = init_cash
            if t.direction:
                comm = 0
                if t.comm:
                    comm = t.comm
                self.holdings['cash'] -= (qty * t.price + comm)
            self.start_date = t.date
        else:
            self.holdings = {}
            start = open('2015_start.csv', 'r')
            start_lines = start.readlines()
            for starts in start_lines:
                info = starts.split(',')
                self.holdings[info[0]] = float(info[1])
            self.start_date = self.date = parser.parse('12/31/2014')
            print(self.holdings)


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
                    print(string_today)
                    price_list = stock.get_historical(date, string_today)
                    # pprint.PrettyPrinter(depth = 6).pprint(price_list)
                    # Prices is a dictionary of dictionaries; each inner dictionary consists of (date, value) pairs for a ticker
                    prices[sym] = {item['Date']: float(item['Close']) for item in price_list}

                # find price for the date of interest
                if date in prices[sym]:
                    close_price = prices[sym][date]
                    value += close_price * qty
                else:
                    print(date, sym)
                    return (None, None)
        return (value, prices)