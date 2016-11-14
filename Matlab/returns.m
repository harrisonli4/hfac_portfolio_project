data = load('values.csv');
portval = data(:,2);

dailyreturns = zeros([length(portval)-1 1]);

for i = 2:length(portval)
    dailyreturns(i-1) = (portval(i)-portval(i-1))/portval(i-1);
end %populating vector of daily returns

dailylogreturns = log(dailyreturns + 1);
yearlyreturns = 252*mean(dailylogreturns);

logstd = sqrt(252)*std(dailylogreturns);
rfr = log(1+0.0186); %risk free rate for October 28, 2016

simplsharpe = (yearlyreturns-rfr)/logstd

%% 
ndwnsidvar = 0;

for i = 1:length(dailylogreturns)
    if dailylogreturns(i) < mean(dailylogreturns)
        ndwnsidvar = ndwnsidvar + (dailylogreturns(i) - mean(dailylogreturns))^2;
    else 
        ndwnsidvar = ndwnsidvar;
    end
end %calculating downside variance for returns lower than mean

ndwnsid = 0;

for i = 1:length(dailylogreturns)
    if dailylogreturns(i) < mean(dailylogreturns)
        ndwnsid = ndwnsid + 1;
    else 
        ndwnsid = ndwnsid;
    end
end %finding the number of days with returns below the mean


dwnsidstdv = sqrt(252)*(ndwnsidvar/(ndwnsid - 1))^(1/2);

dwnsidsharpe = (yearlyreturns-rfr)/dwnsidstdv;

dwnsidsharpesens = zeros([7 1]);

for i = 1:7
    dwnsidsharpesens(i) = (yearlyreturns - (0.014 + 0.001*i))/dwnsidstdv;
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

plot(dates, portvalues);
x = xlabel('Date');
y = ylabel('Portfolio Value');
t = title('HFAC Portfolio Value Over 2015 and 2016');
set(t, 'FontSize', 20);
set(x, 'FontSize', 16);
set(y, 'FontSize', 16);

%%
plot(dates, 100*portvalues/portvalues(1)-100);
hold on
plot(dates, 100*spval/spval(1)-100);
x = xlabel('Date');
y = ylabel('Percent Change (%)');
t = title('HFAC vs SP500');
set(t, 'FontSize', 16);
set(x, 'FontSize', 16);
set(y, 'FontSize', 16);
legend('HFAC', 'SP500');