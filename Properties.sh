#!/bin/bash
# Properties file

telegramSendErrors=true # true | false
poolName="Flexpool"

securePath="/miner"
directoryDownloads="${securePath}/downloads"

LoadGeneralProperties() {
 currency="EUR" # EUR | USD
 numberOfGPUs=1 # Change me
 minerCryptoMining="ETH" # ETH | XCH
 minerHash="X" # Change me
}

LoadTelegramProperties() {
 telegramId="X" # Change me
 telegramBotToken="X" # Change me
 telegramUrl="https://api.telegram.org/bot${telegramBotToken}/sendMessage?parse_mode=HTML"
}

LoadCronProperties() {
 dailyReportHour=9
 dailyReportMinute=30
 historyReportDay=7
 historyReportHour=9
 historyReportMinute=35
 historyReportMonthlyDay=1
 historyReportMonthlyHour=9
 historyReportMonthlyMinute=40
 fileCron="/var/spool/cron/crontabs/root"
 fileCronCopy="${fileCron}_original"
}

LoadLogProperties() {
 okLog="[OK]"
 infoLog="[INFO]"
 warnLog="[WARN]"
 errorLog="[ERROR]"
 argumentRequiredException="ArgumentRequiredException"
 invalidArgumentException="InvalidArgumentException"
}

LoadScriptPaths() {
 directoryScripts="${securePath}/scripts"
 scriptLauncher="${securePath}/Launcher.sh"
 scriptCommonUtils="${directoryScripts}/CommonUtils.sh"
 scriptDailyReport="${directoryScripts}/DailyReport.sh"
 scriptHistoricReport="${directoryScripts}/HistoricReport.sh"
 scriptProperties="${directoryScripts}/Properties.sh"
}

LoadGenerateLogProperties() {
 directoryLogs="${securePath}/logs"
 fileHistoricLog="${directoryLogs}/history.log"
}
 
LoadPriceProperties() {
 regexPrice="[0-9]+.[0-9]{0,2}"
 apiCryptoPrice="http://api.coinbase.com/v2/prices/${minerCryptoMining}-${currency}/spot"
}

LoadHistoricRegexProperties() {
 regexHistory=".*[0-9]{10}"
 regexMined="[0-9]+\.[0-9]{10}"
 regexMinedCrypto="[a-Z]+"
 regexDate="[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}"
}

LoadAPIProperties() {
 case $poolName in
  "Flexpool")
    LoadFlexpoolAPIProperties
  ;;

  "HiveOs")
    LoadHiveOsAPIProperties
  ;;

  "Ethermine")
    LoadEthermineAPIProperties
  ;;

  *)
  ;;
 esac
}

LoadFlexpoolAPIProperties() {
 apiMinerInfo="https://api.flexpool.io/v2/miner/balance?coin=${minerCryptoMining}&countervalue=${currency}&address=${minerHash}"
 jqMinerInfo=".result.balance"
 apiMinerPayments="https://api.flexpool.io/v2/miner/payments?page=0&coin=${minerCryptoMining}&countervalue=${currency}&address=${minerHash}"
 jqMinerPayment=".result.data[0].value"
}

LoadHiveOsAPIProperties() {
}

LoadEthermineAPIProperties() {
}