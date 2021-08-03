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
  curl -s -X POST $url -d chat_id=$chatId -d text="${telegramMsg}"
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

CreateDirectoryIfNotExists() {
 CheckRequiredParam "dirPath" "${1}" "CreateDirectoryIfNotExists():L102"
 if [ ! -d "${1}" ]; then
  AddLog "Creating directory -> ${1}"
  mkdir $1
 fi
 SleepLow
}

CheckRequiredDirectory() {
 CheckRequiredParam "dirPath" "${1}" "CheckRequiredDirectory():L111"
 if [ ! -d "${1}" ]; then
  AddLog "Required directory not exists -> ${1}" $errorLog
 fi
 AddLog "Directory found -> ${1}" $okLog
 SleepLow
}

DeleteFileIfExists() {
 CheckRequiredParam "filePath" "${1}" "DeleteFileIfExists():L120"
 if [ -f "${1}" ]; then
  AddLog "Deleted file -> ${1}" $warnLog
  rm $1
 fi
 SleepLow
}

CheckRequiredFile() {
 CheckRequiredParam "filePath" "${1}" "CheckRequiredFile():L129"
 if [ ! -f "${1}" ]; then
  AddLog "Required directory not exists -> ${1}" $errorLog
 fi
 local num=$(cat $1 | wc -l)
 if (( $(echo "${num} < 1" | bc -l) )); then
  AddLog "Empty file -> ${1}" $errorLog
 fi
 AddLog "File found -> ${1}" $okLog
 SleepLow
}

# Sleep tras cada nuevo log
SleepSuperLow() {
 sleep 0.05
}

# Sleep tras cada comprobación de un fichero/directorio
SleepLow() {
 sleep 0.15
}

# Sleep entre elementos de la lógica
SleepMedium() {
 sleep 0.25
}

# Sleep tras la ejecución de un script
SleepHigh() {
 sleep 2
}

SleepCustom() {
 sleep "${1}"
}

# $?: Es la variable donde se alamacena lo que ha devuelto la última funcion
# Cada script tiene su propia salida (exit), si llama a otro se crea un nuevo "hilo" que depende de un nuevo exit
# En el caso de las funciones, equivalen a código que se ejecuta dentro de ese hilo y por lo tanto si hay un exit finaliza el hilo
