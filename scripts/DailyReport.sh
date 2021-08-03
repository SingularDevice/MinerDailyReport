#!/bin/bash
# Descarga el precio de la criptomoneda indicada
# Descarga el total minado para esa criptomoneda
requiredScript="${1}"
 if [ ! -f "${1}" ]; then
  echo ">> SourceNotFoundException << [DailyReport.sh]: Script CommonUtils.sh not found"
  exit 1
 fi
source $requiredScript

SleepMedium

InitLog "DailyReport"
AddLog "Job Started"

SleepMedium

LoadGeneralProperties
LoadGenerateLogProperties
LoadPriceProperties
LoadAPIProperties

SleepMedium

dataFile="$directoryDownloads/${minerCryptoMining}_data"
priceFile="$directoryDownloads/${minerCryptoMining}_price"
minerFile="$directoryDownloads/${minerCryptoMining}_miner"
minedFile="$directoryDownloads/${minerCryptoMining}_mined"
benefitFile="$directoryDownloads/${minerCryptoMining}_benefit"
paidDataFile="$directoryDownloads/${minerCryptoMining}_paidData"
lastPaidFile="$directoryDownloads/${minerCryptoMining}_lastPaid"
unpaidFile="$directoryDownloads/${minerCryptoMining}_unpaid_$(date +'%Y%m%d')"
yesterdayUnpaidFile="$directoryDownloads/${minerCryptoMining}_unpaid_$(date +'%Y%m%d' --date='1 day ago')"
dayBeforeYesterdayUnpaidFile="$directoryDownloads/${minerCryptoMining}_unpaid_$(date +'%Y%m%d' --date='2 day ago')"

SleepMedium

DeleteFileIfExists $dayBeforeYesterdayUnpaidFile
DeleteFileIfExists $dataFile
DeleteFileIfExists $priceFile
DeleteFileIfExists $minerFile
DeleteFileIfExists $minedFile
DeleteFileIfExists $benefitFile
DeleteFileIfExists $paidDataFile
DeleteFileIfExists $lastPaidFile
DeleteFileIfExists $unpaidFile

SleepMedium

wget -O $dataFile "${apiCryptoPrice}" ; cat $dataFile \
 | jq .data.amount \
 | grep -Eo $regexPrice > $priceFile

CheckRequiredFile "${priceFile}"
price=$(cat $priceFile)

SleepMedium

wget -O $minerFile "${apiMinerInfo}" ; cat $minerFile \
 | jq .totalUnpaid  > $unpaidFile

CheckRequiredFile "${unpaidFile}"
totalUnpaid=$(cat $unpaidFile)
todayUnpaid=$totalUnpaid

if [ ! -f $yesterdayUnpaidFile ]; then
 yesterdayUnpaid=0
else
 yesterdayUnpaid=$(cat $yesterdayUnpaidFile)
fi

todayUnpaid=$(printf %.10f $(echo "scale=10;($totalUnpaid-$yesterdayUnpaid)/1" | bc -l))
checkNegative=$(echo $todayUnpaid | grep -Eo "-")

if [ "${checkNegative}" = '-' ]; then

 wget -O $paidDataFile "${apiMinerPayments}" ; cat $paidDataFile \
  | jq .items[0].amount > $lastPaidFile

 if [ -f "${lastPaidFile}" ]; then
  lastPaid=$(cat $lastPaidFile)
  todayUnpaid=$(printf %.10f $(echo "scale=10;($totalUnpaid+($lastPaid-$yesterdayUnpaid))/1" | bc -l))
 else
  echo "[WARN]: Fichero no encontrado -> ${lastPaidFile}"
  todayUnpaid=$totalUnpaid
 fi
fi

benefits=$(printf %.2f $(echo "scale=10;$price*$todayUnpaid/1" | bc -l))

SleepMedium

echo $benefits > $benefitFile
echo $todayUnpaid > $minedFile
echo "[$(date +'%d-%m-%Y %H:%M')] ${minerCryptoMining}: $todayUnpaid - ${benefits}€" >> $fileHistoricLog

SleepMedium

read -r -d '' msg <<EOT
<b>Daily report [$(date +"%d-%m-%Y")]</b>
-----------------------------------------------
> ${todayUnpaid} ${minerCryptoMining}
-----------------------------------------------
- Today's price: [${price}€]
- Benefit: [${benefits}€]
$(
 benefInd=$(echo "scale=3;(${benefits} / ${numberOfGPUs})" | bc -l)
 if (( $(echo "${benefInd} < 1" | bc -l) )); then
  benefInd="0${benefInd}"
 fi
 echo "- Benefit/GPU.: [${benefInd}€]"
)
-----------------------------------------------
$(
 newTotal=$(echo "scale=10;(${todayUnpaid} / ${numberOfGPUs})" | bc -l)
 if (( $(echo "${newTotal} < 1" | bc -l) )); then
  newTotal="0${newTotal}"
 fi
 echo "- <b>Mined/GPU</b>: ${newTotal}"
)
-----------------------------------------------
EOT

SleepMedium

SendTelegramNotification "${msg}"

AddLog "Job Finished!"