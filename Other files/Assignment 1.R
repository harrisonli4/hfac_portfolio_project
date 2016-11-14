## Summary of Equity Returns
cat("SUMMARY OF EQUITY RETURNS");
# Read in file of GSPC prices
fname_gspc <- "C:/Users/harri_000/Documents/HFAC/Quant_Fall_2015/spy_prices.csv";
raw_gspc <- read.csv(fname_gspc,header=TRUE);
gspcpx <- raw_gspc$Close[order(as.Date(raw_gspc$Date,format="%m/%d/%Y"))];
numdays_gspc <- length(gspcpx);
gspcrets <- (gspcpx[-1]-gspcpx[-numdays_gspc])/gspcpx[-numdays_gspc];
# Sample mean returns
meanret <- mean(gspcrets);
cat("Mean return: ",meanret);
# Calculate log returns, sample mean logrets
gspclogrets <- log(gspcpx[-1]/gspcpx[-numdays_gspc]);
meanlogret <- mean(gspclogrets);
cat("Mean log return: ",meanlogret);
# Calculate sample variance, sd
varret <- var(gspclogrets);
sdret <- sqrt(varret);
cat("Variance of log returns: ",varret);
cat("Standard deviation of log returns: ",sdret);
# Calculate sample realized variance, volatility
rvar <- sum(gspclogrets^2)/(numdays_gspc-1);
rvol <- sqrt(rvar);
cat("Realized variance of log returns: ",rvar);
cat("Realized volatility of log returns: ",rvol);
# We might calculate the annualized variance by 252*daily variance; for standard deviation/volatility
# we could multiply the daily value by sqrt(252)
# Plot of date over time
dates <- sort(as.Date(raw_gspc$Date,"%m/%d/%Y"));
plot(dates,gspcpx,type="l",main="S&P 500 Closing Prices",xlab="Dates",ylab="Price");
# Sample trailing 1-year realized volatility 

## Capital Asset Pricing Model
cat("CAPITAL ASSET PRICING MODEL")
# Get AAPL data
fname_aapl <- "C:/Users/harri_000/Documents/HFAC/Quant_Fall_2015/aapl_prices.csv";
raw_aapl <- read.csv(fname_aapl,header=TRUE);
aaplpx <- raw_aapl$Close[order(as.Date(raw_aapl$Date,format="%m/%d/%Y"))];
numdays_aapl <- length(aaplpx);
aapllogrets <- log(aaplpx[-1]/aaplpx[-numdays_aapl]);
# Fit linear model
reg <- lm(aapllogrets ~ gspclogrets);
alpha <- reg$coef[1];
beta <- reg$coef[2];
cat("Alpha: ",alpha);
cat("Beta: ",beta);
plot(dates[-1],aapllogrets-beta*gspclogrets,type="l",main="Alpha",xlab="Date");

## Fama-French Three Factor Model
cat("FAMA-FRENCH THREE FACTOR MODEL")
fname_ff <- "C:/Users/harri_000/Documents/HFAC/Quant_Fall_2015/fama_french.csv";
# Divide by 100 to convert to decimals
raw_ff <- read.csv(fname_ff,header=TRUE)/100;
numdays_ff <- length(raw_ff$Date);
# Compute sample mean, realized volatility
smblogrets <- raw_ff$SMB;
hmllogrets <- raw_ff$HML;
mean_ff_smb <- mean(raw_ff$SMB);
mean_ff_hml <- mean(raw_ff$HML);
rv_ff_smb <- sqrt(sum(raw_ff$SMB)/(numdays_ff-1));
rv_ff_hml <- sqrt(sum(raw_ff$HML)/(numdays_ff-1));
cat("Mean SMB return: ",mean_ff_smb);
cat("Mean HML return: ",mean_ff_hml);
cat("SMB realized volatility: ",rv_ff_smb);
cat("HML realized volatility: ",rv_ff_hml);
# Calculate Fama-French betas
fit <- lm(aapllogrets[1:numdays_ff] ~ gspclogrets[1:numdays_ff] + smblogrets + hmllogrets);
alpha <- fit$coef[1];
beta_m <- fit$coef[2];
beta_smb <- fit$coef[3];
beta_hml <- fit$coef[4];
cat("Alpha: ",alpha);
cat("Market beta: ",beta_m);
cat("SMB beta: ",beta_smb);
cat("HML beta: ",beta_hml);
# Get vector of sorted dates
dates <- sort(as.Date(raw_aapl$Date,format="%m/%d/%Y"));
# Set cut date for analysis of betas in different periods
cut_date <- "1995-01-01";
cut_date_index <- which(dates>cut_date)[1];
# Calculate Fama-French betas for period 1
fit_1 <- lm(aapllogrets[1:(cut_date_index-2)] ~ gspclogrets[1:(cut_date_index-2)] + smblogrets[1:(cut_date_index-2)] + hmllogrets[1:(cut_date_index-2)]);
alpha_1 <- fit_1$coef[1];
beta_m_1 <- fit_1$coef[2];
beta_smb_1 <- fit_1$coef[3];
beta_hml_1 <- fit_1$coef[4];
cat("Period 1 alpha: ",alpha_1);
cat("Period 1 market beta: ",beta_m_1);
cat("Period 1 SMB beta: ",beta_smb_1);
cat("Period 1 HML beta: ",beta_hml_1);
# Period 2
fit_2 <- lm(aapllogrets[(cut_date_index-1):numdays_ff] ~ gspclogrets[(cut_date_index-1):numdays_ff] + smblogrets[(cut_date_index-1):numdays_ff] + hmllogrets[(cut_date_index-1):numdays_ff]);
alpha_2 <- fit_2$coef[1];
beta_m_2 <- fit_2$coef[2];
beta_smb_2 <- fit_2$coef[3];
beta_hml_2 <- fit_2$coef[4];
cat("Period 2 alpha: ",alpha_2);
cat("Period 2 market beta: ",beta_m_2);
cat("Period 2 SMB beta: ",beta_smb_2);
cat("Period 2 HML beta: ",beta_hml_2);





