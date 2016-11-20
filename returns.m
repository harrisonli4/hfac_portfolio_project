data = importdata('values.csv');
portvalues = data.data;
dates = datetime(data.rowheaders);

t_days = 252;

dailyreturns = diff(portval)./portval(1:(end-1)); 
dailylogreturns = log(dailyreturns + 1);
yearlyreturns = t_days*mean(dailylogreturns);

logstd = sqrt(t_days)*std(dailylogreturns);
rfr = log(1+0.0186); %risk free rate for October 28, 2016

simplsharpe = (yearlyreturns-rfr)/logstd

%% Sortino
downdailyreturns = dailylogreturns(dailylogreturns < mean(dailylogreturns));
ndwnsidvar = sum((downdailyreturns - mean(dailylogreturns)).^2);
ndwnsid = length(downdailyreturns);
dwnsidstdv = sqrt(t_days*ndwnsidvar/(ndwnsid - 1));
sortino = (yearlyreturns-rfr)/dwnsidstdv;

% Output
simplsharpe
sortino

% dwnsidsharpesens = zeros([7 1]);
% 
% for i = 1:7
%     dwnsidsharpesens(i) = (yearlyreturns - (0.014 + 0.001*i))/dwnsidstdv;
% end
% dwnsidsharpesens

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