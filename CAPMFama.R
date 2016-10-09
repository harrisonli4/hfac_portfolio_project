#install.packages('fts')
require(quantmod)
require(xts)
require(fts)

stocks <- c("ORM","CTO","PKTEF","USAK","PW","AXLE")

# SHFKcsv = "/Users/lawrencekim/Documents/HarvardJunior/HFAC/SHFK.csv"
# SHFKdf <- read.csv(blah,header=TRUE)
# GSPCcsv = "/Users/lawrencekim/Documents/HarvardJunior/HFAC/GSPC.csv"
# GSPCdf <- read.csv(GSPCcsv,header=TRUE)
# GSPCpx <- GSPCdf$Close[order(as.Date(GSPCdf$Date,format="%m/%d/%Y"))]
# numdays_GSPC <- length(GSPCpx)
# GSPCrets <- (GSPCpx[-1]-GSPCpx[-numdays_GSPC])/GSPCpx[-numdays_GSPC]
# GSPClogrets <- log(GSPCpx[-1]/GSPCpx[-numdays_GSPC])

CAPM <- function(sym, csv=NULL){
  if(is.null(csv))
  {
    getSymbols(sym)
    symdata <- get(sym)
    logrets <- dailyReturn(symdata, type='log')
    getSymbols("GSPC")
    gspclogrets <- dailyReturn(GSPC, type='log')
    stockdates <- logrets[,0]
    gspcdates <- gspclogrets[,0]
    # Considers only dates where we have data for both GSPC and sym
    dates <- intersect.all(stockdates, gspcdates) 
    intersectlogrets <- logrets[dates]*252
    intersectgspclogrets <- gspclogrets[dates]*252
    reg <- lm(intersectlogrets ~ intersectgspclogrets)
    alpha <- reg$coef[1]
    beta <- reg$coef[2]
    results <- c(alpha, beta)
    print(summary(reg))
    return(results)
  }
  else
  {
    logrets <- diff(log(csv[,2]))
    portfoliodates = as.Date(as.character(csv[,1]),format="%Y-%m-%d")
    getSymbols("GSPC");
    gspclogrets <- dailyReturn(GSPC, type='log');
    gspcdates <- gspclogrets[,0];
    dates <- intersect.all(gspcdates, portfoliodates);
    print(dates)
    intersectlogrets <- logrets[dates]*252;
    intersectgspclogrets <- gspclogrets[dates]*252;
    reg <- lm(intersectlogrets ~ intersectgspclogrets);
    alpha <- reg$coef[1];
    beta <- reg$coef[2];
    results <- c(alpha, beta)
    print(summary(reg))
    return(results)
  }
}

FAMA <- function(sym, location){
  getSymbols(sym)
  symdata = get(sym)
  famafrenchcsv <- location
  famadf <- read.csv(famafrenchcsv, header=TRUE, sep= ",");
  famadf$Date <- as.Date(as.character(famadf$Date),format="%Y%m%d")
  logrets <- dailyReturn(symdata, type='log');
  getSymbols("GSPC");
  gspclogrets <- dailyReturn(GSPC, type='log');
  stockdates <- logrets[,0];
  gspcdates <- gspclogrets[,0];
  famadfx <- xts(famadf, order.by=famadf$Date)
  dates <- intersect.all(stockdates, gspcdates,famadfx[,0]);
  print(date)
  intersectlogrets <- logrets[dates]*252
  intersectgspclogrets <- gspclogrets[dates]*252
  intersectfama <- famadf[famadf$Date %in% dates,]
  smblogrets <- (intersectfama$SMB/100)*252
  hmllogrets <- (intersectfama$HML/100)*252
  numdays <- length(dates)
  meansmb <- mean(smblogrets)
  meanhml <- mean(hmllogrets)
  #rv_ff_smb <- sqrt(sum(smblogrets**2)/(numdays-1));
  #rv_ff_hml <- sqrt(sum(hmllogrets**2)/(numdays-1));
  fit <- lm(intersectlogrets ~ intersectgspclogrets + smblogrets + hmllogrets);
  alpha <- fit$coef[1];
  beta_m <- fit$coef[2];
  beta_smb <- fit$coef[3];
  beta_hml <- fit$coef[4];
  print(summary(fit))
  return (c(alpha, beta_m, beta_smb, beta_hml))
}

# location = path to file of Fama French returns
performance <- function(sym, location){
  CAPMcoefs <- CAPM(sym)
  FAMAcoefs <- FAMA(sym, location)
  getSymbols(sym)
  symdata = get(sym)
  len = length(symdata[,4])
  getSymbols("GSPC");
  gspclogrets <- dailyReturn(GSPC, type='log');
  todaydate = index(symdata[len,])
  gspctodaylogret = as.numeric(gspclogrets[todaydate])
  todayprice = as.numeric(symdata[len,4])
  lastweekprice = as.numeric(symdata[len-5,4])
  blahreturn = (todayprice -lastweekprice)/lastweekprice
  cat("Return from previous week to today: ", blahreturn)
  logreturn = log(todayprice) - log(lastweekprice)
  estimatedcapmreturn = CAPMcoefs[1] + CAPMcoefs[2]*gspctodaylogret
  cat("Estimated return from CAPM: ", estimatedcapmreturn)
  #just using most recentfama available
  famadf <- read.csv(famafrenchcsv, header=TRUE, sep= ",");
  lenfama <- length(famadf$Date)
  smbrets <- famadf$SMB[lenfama]/100
  hmlrets <- famadf$HML[lenfama]/100
  estimatedfamareturn = FAMAcoefs[1] + FAMAcoefs[2]*gspctodaylogret + FAMAcoefs[3]*smbrets + FAMAcoefs[4]*hmlrets
  cat("Estimated return from FAMA: ", estimatedfamareturn)
}


# performance("SHFK", "/Users/lawrencekim/Documents/HarvardJunior/HFAC/Fama-french.csv")
# getSymbols("SHFK")
# symdata = get("SHFK")
# len = length(symdata[,4])
# todayprice = as.numeric(symdata[len,4])
# lastweekprice = as.numeric(symdata[len-5,4])
# blahreturn = (todayprice -lastweekprice)/lastweekprice
# logreturn = log(todayprice) - log(lastweekprice)

# Get performance of individual stocks in portfolio
lapply(stocks, function(x) { FAMA(x, location="C:/Users/harri_000/Documents/HFAC/Quant_Fall_2015/fama_french.csv")})
lapply(stocks, CAPM)

# Get performance of entire portfolio
port <- "C:/Users/harri_000/Documents/HFAC/Quant_Fall_2015/values.csv"


getSymbols("SHFK")
symdata = get("SHFK")
famafrenchcsv <- "C:/Users/harri_000/Documents/HFAC/Quant_Fall_2015/fama_french.csv"
famadf <- read.csv(famafrenchcsv, header=TRUE, sep= ",");
famadf$Date <- as.Date(as.character(famadf$Date),format="%Y%m%d")
logrets <- dailyReturn(symdata, type='log');
getSymbols("GSPC");
gspclogrets <- dailyReturn(GSPC, type='log');
stockdates <- logrets[,0];
gspcdates <- gspclogrets[,0];
famadfx <- xts(famadf, order.by=famadf$Date)
dates <- intersect.all(stockdates, gspcdates,famadfx[,0]);
intersectlogrets <- logrets[dates]
intersectgspclogrets <- gspclogrets[dates]
intersectfama <- famadf[famadf$Date %in% dates,]
smblogrets <- intersectfama$SMB/100
hmllogrets <- intersectfama$HML/100
numdays <- length(dates)
meansmb <- mean(smblogrets)
meanhml <- mean(hmllogrets)
rv_ff_smb <- sqrt(sum(smblogrets)/(numdays-1))
rv_ff_hml <- sqrt(sum(hmllogrets)/(numdays-1))
fit <- lm(intersectlogrets ~ intersectgspclogrets + smblogrets + hmllogrets)
alpha <- fit$coef[1]
beta_m <- fit$coef[2]
beta_smb <- fit$coef[3]
beta_hml <- fit$coef[4]