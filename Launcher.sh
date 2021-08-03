#!/bin/bash
# Prepares environment
CheckRequiredSources() {
 if [ ! -f "${2}" ]; then
  echo ">> SourceNotFoundException << [Launcher.sh]: Script not found -> ${1}"
  exit 1
 fi
}

ModifyCron() {
 CheckRequiredParam "cronFile" "${1}" "ModifyCron():L62"

 if [ -f "${fileCronCopy}" ]; then
  AddLog "Restoring previous cron file -> ${fileCronCopy}" $warnLog
  sudo cp "${fileCronCopy}" $1
 else
  if [ ! -f "${1}" ]; then
   sudo touch $1
  fi
 fi

 echo "" >> ./newCron
 echo "# Miner daily report" >> ./newCron
 echo "${dailyReportMinute} ${dailyReportHour} */1 * * ${scriptDailyReport} ${requiredScript}" >> ./newCron
 echo "" >> ./newCron
 echo "# Miner history report" >> ./newCron
 echo "${historyReportMinute} ${historyReportHour} * * ${historyReportDay} ${scriptHistoricReport} ${requiredScript} w" >> ./newCron
 echo "${historyReportMonthlyMinute} ${historyReportMonthlyHour} ${historyReportMonthlyDay} * * ${scriptHistoricReport} ${requiredScript} m" >> ./newCron
 echo "" >> ./newCron

 AddLog "Copying cron file-> ${fileCronCopy}"
 aux=$(cat ./newCron | sudo tee $1)
 sudo rm ./newCron
 sudo cp $1 "${fileCronCopy}"

 SleepMedium

 RefreshCron
}

RefreshCron() {
 AddLog "Initializing cron refresh..."
 sudo /etc/init.d/cron restart
}

requiredScript=/miner/scripts/CommonUtils.sh
CheckRequiredSources "CommonUtils.sh" $requiredScript
source $requiredScript

SleepCustom 5

InitLog "Launcher"
AddLog "START!"

LoadScriptPaths
LoadCronProperties

SleepMedium

CheckRequiredFile "${scriptDailyReport}"
CheckRequiredFile "${scriptHistoricReport}"

SleepMedium

AddLog "Modifying cron file..."
ModifyCron "${fileCron}"

AddLog "Cron file modified properly" $okLog

msg="<b>LauncherService</b> finished!"
SendTelegramNotification "${msg}"

AddLog "FINISHED!"
