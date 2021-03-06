#!/bin/bash
# Common utilities

scriptProperties=/miner/scripts/Properties.sh
if [ ! -f $scriptProperties ]; then
 echo ">> SourceNotFoundException << [LogUtils.sh]: Script not found -> Properties.sh"
 exit 1
fi
source $scriptProperties

LoadLogProperties
LoadTelegramProperties

InitLog() {
 CheckRequiredParam "logName" "${1}" "InitLog():L15"
 okLog="[${1}.OK]"
 infoLog="[${1}.INFO]"
 warnLog="[${1}.WARN]"
 errorLog="[${1}.ERROR]"
 SleepLow
}

AddLog() {
 CheckRequiredParam "logMsg" "${1}" "AddLog():L24"
 local msg=" $(date +'%H:%M:%S %d-%m-%Y') -"
 if [ "${2}" ]; then
  echo "${msg} ${2}: ${1}"
  if [ "${2}" == "${errorLog}" ]; then
   SendTelegramNotification "<b>${msg} ${2}:</b> ${1}"
   exit 1
  fi
 else
  echo "${msg} ${infoLog}: ${1}"
 fi
 SleepSuperLow
}

SendTelegramNotification() {
 local chatId="${telegramId}"
 local url="${telegramUrl}"
 local telegramMsg="${1}"

 if [ ! "${1}" ]; then
  telegramMsg="<b>EmptyMsg???</b>"
  AddLog "Empty message. Sending empty report..." $warnLog
 fi
 
 if [ "${2}" ]; then
  chatId="${2}"
  AddLog "Replaced parameter -> telegramId=${telegramId}/${2}" $warnLog
 fi
 
 if [ "${3}" ]; then
  url="${3}"
  AddLog "Replaced parameter -> telegramUrl=${telegramUrl}/${3}" $warnLog
 fi

 if [ $telegramSendErrors == true ]; then
  sudo curl -s -X POST $url -d chat_id=$chatId -d text="${telegramMsg}"
 else
  AddLog "Telegram messages deactivated" $warnLog
 fi
}

CheckRequiredParam() {

 local method="${3}"

 if [ ! "${1}" ]; then
  if [ ! "${3}" ]; then
   method="CheckRequiredParam():L71"
  fi

  ThrowException "${argumentRequiredException}" "Required param (parameterName)" "${method}"
 fi

 if [ ! "${2}" ]; then
  if [ ! "${3}" ]; then
   method="CheckRequiredParam():L79"
  fi

  ThrowException "${argumentRequiredException}" "Required param (${1})" "${method}"
 fi
}

ThrowException() {
 CheckRequiredParam "exception" "${1}" "ThrowException():L87"
 CheckRequiredParam "msg" "${2}" "ThrowException():L88"

 local msg=">> ${1} <<"
 if [ "${3}" ]; then
  echo "${msg} [${3}]: ${2}"
  SendTelegramNotification "<b>${1} [${3}]:</b> ${2}"
 else
  echo "${msg} ${2}"
  SendTelegramNotification "<b>${1}</b> ${2}"
 fi
 exit 1
}

DeleteFileIfExists() {
 CheckRequiredParam "filePath" "${1}" "DeleteFileIfExists():L101"
 if [ -f "${1}" ]; then
  AddLog "Eliminando fichero -> ${1}" $warnLog
  rm $1
 fi
 SleepLow
}

CheckRequiredFile() {
 CheckRequiredParam "filePath" "${1}" "CheckRequiredFile():L111"
 if [ ! -f "${1}" ]; then
  AddLog "Required file not exists -> ${1}" $errorLog
 fi
 local num=$(cat $1 | wc -l)
 if (( $(echo "${num} < 1" | bc -l) )); then
  AddLog "Empty file -> ${1}" $errorLog
 fi
 AddLog "File found -> ${1}" $okLog
 SleepLow
}

SleepMedium() {
 sleep 0.25
}

SleepCustom() {
 sleep "${1}"
}