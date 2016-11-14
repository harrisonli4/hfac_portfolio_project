import numpy as np
import datetime
from dateutil import parser


class Transaction:
    def my_init(self,date,direction,symbol,quantity,price,comm):
        # datetime.date
        self.date      = date
        # 1 = Buy, -1 = Sell
        self.direction = direction
        # string
        self.symbol    = symbol
        # int
        self.quantity  = quantity
        # float 
        self.price     = price
        # float
        self.comm      = comm
    
    """
    Convert line (string) to a transaction object. Calls my_init above
    with appropriate parameters.
    """

    def __init__(self, line):
        info_arr = line.split(',')
        self.date = parser.parse(info_arr[0])
        if (info_arr[2][0] == 'B' or info_arr[2][0] == 'b'):
            self.direction = 1
        elif (info_arr[2][0] == 'S' or info_arr[2][0] == 's'):
            self.direction = -1
        else:
            raise ValueError('Check column 3. Each transaction must be either buy or sell.')
        self.quantity = int(info_arr[3])
        self.symbol = info_arr[4]
        self.price = float(info_arr[5])
        self.comm = float(info_arr[6])
        # self.my_init(date, direction, symbol, quantity, price, comm)
        # print "self.price " + str(self.price)
        # print "self.date " + str(self.date)
        # print "self.symbol" + self.symbol


