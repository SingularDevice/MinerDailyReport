#!/bin/bash
# Prepares environment
CheckRequiredSources() {
 if [ ! -f "${2}" ]; then
  echo ">> SourceNotFoundException << [Launcher.sh]: Script no encontrado -> ${1}"
  exit 1
 fi
}

CheckLauncherRequiredEnvironment() {
 CheckRequiredFile "${scriptDailyReport}"
 CheckRequiredFile "${scriptHistoricReport}"
 CheckRequiredFile "${scriptGenerateLogs}"
}

ModifyCron() {
 CheckRequiredParam "cronFile" "${1}" "ModifyCron():L76"

 if [ -f "${fileCronCopy}" ]; then
  AddLog "Restoring previous cron file -> ${fileCronCopy}" $warnLog
  cp "${fileCronCopy}" $1
 else
  AddLog "Copying cron file-> ${fileCronCopy}"
  cp $1 "${fileCronCopy}"
 fi

 echo "" >> $1
 echo "# Miner daily report" >> $1
 echo "${dailyReportMinute} ${dailyReportHour} */1 * * ${scriptDailyReport} ${requiredScript}" >> $1
 echo "" >> $1
 echo "# Miner history report" >> $1
 echo "${historyReportMinute} ${historyReportHour} * * ${historyReportDay} ${scriptHistoricReport} ${requiredScript} w" >> $1
 echo "${historyReportMonthlyMinute} ${historyReportMonthlyHour} ${historyReportMonthlyDay} * * ${scriptHistoricReport} ${requiredScript} m" >> $1
 echo "" >> $1

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

SleepCustom 10

InitLog "Launcher"
AddLog "START!"

LoadScriptPaths
LoadGenerateLogProperties
LoadCronProperties

SleepMedium

CheckLauncherRequiredEnvironment

SleepMedium

CheckRequiredFile "${fileMinerOriginalLog}"

SleepMedium

CheckRequiredFile "${fileCron}"

AddLog "Modifying cron file..."
ModifyCron "${fileCron}"

CheckRequiredFile "${fileCronCopy}"

AddLog "Cron file modified properly" $okLog

msg="<b>LauncherService</b> finished!"
SendTelegramNotification "${msg}"

AddLog "FINISHED!"
