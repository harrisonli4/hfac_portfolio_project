import numpy as np
import transaction
from portfolio import Portfolio
import pandas as pd
import datetime as dt
from dateutil import parser
import csv 
import copy

# if qty of any stock is negative (check in calculate value function) throw error

if __name__ == '__main__':
    # read in transactions file and construct list of transactions
    transactions = []
    f = open('2015_transactions.csv', 'r')
    lines = f.readlines()
    for line in lines:
        transactions.append(transaction.Transaction(line))

    # turn transaction objects into portfolio objects
    portfolios = [] # list of portfolio objects for each date
    init_port = Portfolio();
    portfolios.append(init_port);
    for t in transactions:
        portfolios.append(Portfolio(t, portfolios[-1]))


    # get all trading days as a list
    bizdates = pd.bdate_range(portfolios[0].start_date, parser.parse('11/1/2016'))
    print(bizdates)

    
    # get portfolio values
    portfolios_length = len(portfolios)
    idx = 0
    values = {}
    cpy_bizdates = copy.deepcopy(bizdates)
    for date in bizdates:
        # advance to next portfolio on dates with transactions
        if idx + 1 < portfolios_length and portfolios[idx + 1].start_date <= date.to_datetime():
            idx += 1
        value = portfolios[idx].calculateValue(date)
        if value != None:
            values[date.to_datetime().strftime('%Y-%m-%d')] = value
        # if portfolio doesn't exist on that day, remove date from bizdates
        else: 
            cpy_bizdates = cpy_bizdates.drop(date)

    print('Number of values:', len(values))
    print('Number of dates:', len(cpy_bizdates))

    print('Latest holdings:')
    final_portfolio = portfolios[-1]
    for sym,shares in final_portfolio.holdings.items():
        print('Symbol:',sym,'Number of shares:',shares)

    currents = open('current_holdings.csv','w')
    current = csv.writer(currents)
    for sym,shares in final_portfolio.holdings.items():
        current.writerow([sym,shares])
    currents.close()

    # stringify dates
    # string_dates = [date.to_datetime().strftime('%Y-%m-%d') for date in cpy_bizdates]

    # export to CSV file
    my_csv = open('values.csv','w')
    #valuelist = {value for date,value in sorted(values).items()}
    #data = zip(string_dates, valuelist)

    a = csv.writer(my_csv)
    for date,value in values.items():
        if date == '2016-11-01':
            print ("End value:",value)
        if date == '2014-12-31':
            print ("Start value:",value)
        a.writerow([date,value])
    my_csv.close()


