#!/bin/bash
# Envía reportes cada semana y cada mes en función del fichero historico
requiredScript="${1}"
 if [ ! -f "${1}" ]; then
  echo ">> SourceNotFoundException << [HistoricReport.sh]: Script CommonUtils.sh not found"
  exit 1
 fi
source $requiredScript

CheckRequiredParam "periodicity" "${2}" "HistoricReport():L10"

SleepMedium

InitLog "HistoricReport"
AddLog "Job Started"

period="${2}"
if [[ "${period}" != "w" && "${period}" != "m" ]]; then
 ThrowException "${invalidArgumentException}" "Only weekly or monthly [w | m] values are admitted" "HistoricReport:L19"
fi

LoadGeneralProperties
LoadGenerateLogProperties
LoadHistoricRegexProperties

CheckRequiredFile "${fileHistoricLog}" 

SleepMedium

lastWeek=""
title="Monthly"

if [ "${period}" == "w" ]; then
 title="Weekly"
 lastWeek=$({ grep -Eo "\[$(date +"%d-%m-%Y" --date='6 day ago')${regexHistory}" \
  ${fileHistoricLog} \
 & grep -Eo "\[$(date +"%d-%m-%Y" --date='5 day ago')${regexHistory}" \
  ${fileHistoricLog} \
 & grep -Eo "\[$(date +"%d-%m-%Y" --date='4 day ago')${regexHistory}" \
  ${fileHistoricLog} \
 & grep -Eo "\[$(date +"%d-%m-%Y" --date='3 day ago')${regexHistory}" \
  ${fileHistoricLog} \
 & grep -Eo "\[$(date +"%d-%m-%Y" --date='2 day ago')${regexHistory}" \
  ${fileHistoricLog} \
 & grep -Eo "\[$(date +"%d-%m-%Y" --date='1 day ago')${regexHistory}" \
  ${fileHistoricLog} \
 & grep -Eo "\[$(date +"%d-%m-%Y")${regexHistory}" \
  ${fileHistoricLog} ;} | sort)
else
  lastWeek=$({ grep -Eo "\[[0-9]+$(date +"-%m-%Y" --date='1 month ago')${regexHistory}" \
  ${fileHistoricLog} ;} | sort)
fi

SleepMedium

read -r -d '' msg <<EOT
<b>${title} report [$(date +"%d-%m-%Y")]</b>
-----------------------------------------------
$(

 max=0
 min=500
 count=0
 total=0

 while read line
 do
  currentDate=$(echo $line | grep -Eo "${regexDate}")
  currentValue=$(echo $line | grep -Eo "${regexMined}")
  currentCrypto=$(echo $line | grep -Eo "${regexMinedCrypto}")
  
  if (( $(echo "${currentValue} > ${max}" | bc -l) )); then
   max=${currentValue}
  else
   if (( $(echo "${currentValue} < ${min}" | bc -l) )); then
    min=${currentValue}
   fi
  fi

  echo "> ${currentDate}: ${currentValue} ${currentCrypto}"

  total=$(echo "$currentValue + $total" | bc -l)
  count=$(echo "${count}+1" | bc -l)
 done <<< "${lastWeek}"

 avg=$(echo "scale=10;${total} / ${count}" | bc -l)

 if (( $(echo "${total} < 1" | bc -l) )); then
  total="0${total}"
 fi

 if (( $(echo "${avg} < 1" | bc -l) )); then
  avg="0${avg}"
 fi

 echo "-----------------------------------------------"
 echo "- <b>MAX</b>: ${max}"
 echo "- <b>MIN</b>: ${min}"
 echo "- <b>AVG</b>: ${avg}"
 echo "- <b>TOTAL</b>: $total"
 echo "-----------------------------------------------"

 newMax=$(echo "scale=10;${max} / ${numberOfGPUs}" | bc -l)
 if (( $(echo "${newMax} < 1" | bc -l) )); then
  newMax="0${newMax}"
 fi

 newMin=$(echo "scale=10;${min} / ${numberOfGPUs}" | bc -l)
 if (( $(echo "${newMin} < 1" | bc -l) )); then
  newMin="0${newMin}"
 fi

 newTotal=$(echo "scale=10;(${total} / ${numberOfGPUs}) / ${count}" | bc -l)
 if (( $(echo "${newTotal} < 1" | bc -l) )); then
  newTotal="0${newTotal}"
 fi

 echo "- <b>MAX/${numberOfGPUs}</b>: ${newMax}"
 echo "- <b>MIN/${numberOfGPUs}</b>: ${newMin}"
 echo "- <b>TOTAL/${numberOfGPUs}</b>: ${newTotal}"
 echo "-----------------------------------------------"
)
EOT

SleepMedium

AddLog "Sending telgram notification..."
SendTelegramNotification "${msg}"

AddLog "Job Finished!"