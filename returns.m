data = load('values.csv');
dates = data(:,1);
portval = data(:,2);

dailyreturns = zeros([length(portval)-1 1]);

for i = 2:length(portval)
    dailyreturns(i-1) = (portval(i)-portval(i-1))/portval(i-1);
end %populating vector of daily returns

dailylogreturns = log(dailyreturns + 1);

yearlyreturns = 0;

for i = 1:length(dailylogreturns)
    yearlyreturns = yearlyreturns + dailylogreturns(i);
end %calculating years returns from daily returns for 2015

meandailyreturn = yearlyreturns/(length(dailylogreturns));

nsimplvar = 0;

for i = 1:length(dailylogreturns)
    nsimplvar = nsimplvar + (dailylogreturns(i) - meandailyreturn)^2;
end %calculating simple variance of returns

simplstdv = (nsimplvar/(length(dailylogreturns)-1))^(1/2);

rfr = 0.0186; %risk free rate for October 28, 2016

simplsharpe = (meandailyreturn-rfr)/simplstdv;

ndwnsidvar = 0;

for i = 1:length(dailylogreturns)
    if dailylogreturns(i) < meandailyreturn
        ndwnsidvar = ndwnsidvar + (dailylogreturns(i) - meandailyreturn)^2;
    else 
        ndwnsidvar = ndwnsidvar;
    end
end %calculating downside variance for returns lower than mean

ndwnsid = 0;

for i = 1:length(dailylogreturns)
    if dailylogreturns(i) < meandailyreturn
        ndwnsid = ndwnsid + 1;
    else 
        ndwnsid = ndwnsid;
    end
end %finding the number of days with returns below the mean


dwnsidstdv = (ndwnsidvar/(ndwnsid - 1))^(1/2);

dwnsidsharpe = (meandailyreturn-rfr)/dwnsidstdv;

dwnsidsharpesens = zeros([7 1]);

for i = 1:7
    dwnsidsharpesens(i) = (meandailyreturn - (0.014 + 0.001*i))/dwnsidstdv;
end

simplsharpe
dwnsidsharpe
dwnsidsharpesens

%% Treynor Ratio
sp500 = load('YAHOO-INDEX_GSPC.csv');
spval = sp500(:,5);

dailyspreturns = zeros([length(spval)-1 1]);

for i = 2:length(spval)
    dailyspreturns(i-1) = (spval(i)-spval(i-1))/spval(i-1);
end %populating vector of daily returns

dailysplogreturns = log(dailyspreturns + 1);

cov_mat = cov(dailylogreturns, dailysplogreturns);
cov_port = cov_mat(1,2);
var_port = cov_mat(2,2);

beta = cov_port / var_port;

treynor = (yearlyreturns - rfr)/beta

%%

plot(dates, portval);
xlabel('Date');
ylabel('Portfolio Value');
title('HFAC Portfolio Value During 2015');
