# MinerDailyReport

## (ES) Introducción
Estos scripts crean un nuevo servicio que se ejecuta cada vez que el pc se enciende o reinicia.

El servicio se encarga de programar las siguientes tareas:
* Un mensaje diario a las 9:30h que contiene los beneficios diarios de tu minero.
* Un mensaje semanal cada domingo a las 9:35h calculando media, máximos y mínimos semanales.
* Un mensaje mensual el día 1 de cada mes a las 9:40h calculando media, máximos y mínimos mensuales.

## Requisitos previos
* Hay que crear un bot de Telegram y añadir sus datos al fichero de propiedades Properties.sh
* Hay que añadir el hash que identifica a tu minero dentro de la pool*
* Se puede cambiar la hora a la que se ejecuta el reporte dentro del método 'LoadCronProperties' de Properties.sh
* Todas las propiedades que se deben cambiar están marcadas con un comentario 'Change me'

(*) Actualmente los scripts solo sirven para Flexpool.

## Pasos a seguir
* Configurar las propiedades necesarias.
* Ejecutar como administrador el fichero run.sh
> sudo ./run.sh

Tras una ejecución correcta, todos los ficheros, logs y scripts habrán quedado copiados y funcionando dentro de la carpeta /miner, todos los ficheros fuera de esa ruta pueden eliminarse sin problema.
