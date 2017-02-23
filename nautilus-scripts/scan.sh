################################################################################
# Project name   :
# File name      : scan.sh
# Created date   : Wed 16 Nov 2016 05:16:59 PM ICT
# Author         : Ngoc-Sinh Nguyen
# Last modified  : Thu 29 Dec 2016 04:47:08 PM ICT
# Guide          :
###############################################################################
#!/bin/bash

command -v yad > /dev/null 2>&1 || {zenity -error --text "Please install yad"}
command -v scanimage > /dev/null 2>&1 || {zenity -error --text "Please install scanimage"}


opts=$(yad --width=400 --title="" --text="Please enter your details:" \
	--form --date-format="%-d %B %Y" --item-separator="," \
	--field="Mode":CB \
	--field="Resolution":CB \
	--field="Email Client":CB \
	--field="Email address":CBE \
	--field="File Name" \
	--field="start number" \
	'Color,Gray,Lineart' \
	'150,200,300'  \
	'Thunderbird,Mailx,None' \
	'sinhnn.92@gmail.com,tranxuantu' \
	"$(date +%y%m%d)" \
	"1"
)
[ $? -ne 0 ] && exit 1

mode="${opts%%|*}"
opts=${opts:${#mode} + 1}

res="${opts%%|*}"
opts=${opts:${#res} + 1}

mail_client="${opts%%|*}"
opts=${opts:${#mail_client} + 1}

email="${opts%%|*}"
opts=${opts:${#email} + 1}

prefix="${opts%%|*}"
opts=${opts:${#prefix} + 1}

num="${opts%%|*}"
opts=${opts:${#num} + 1}

scaned_file=()
cmd="scanimage --mode=$mode --resolution=$res"

function scan_convert() {
	of=$(printf "%s_p%04d.pnm" "${prefix}" $1)
	(
		echo 0
		echo "# ${of}"
		${cmd} > ${of}
		echo 100
	)  | yad --title "$0" --progress --pulsate --auto-close --no-buttons
}

SCRIPT_DIR=`dirname $(readlink -f $0)`
i=${num}
while [[ 1 ]]; do
	scan_convert $i
	zenity --question --timeout 15 --text "Stop Scan"
	if [[ $? -eq 0 ]]; then
		break
	fi
	i=$(expr $i + 1)
	#num=$(expr $i - 1)
done

${SCRIPT_DIR}/pdf/convert_pdf ${prefix}_p[0-9][0-9][0-9][0-9].pnm
pdf=$(ls ${prefix}_p[0-9][0-9][0-9][0-9]-merged.pdf | head --lines=1)

[ -f "${pdf}" ] && evince  ${pdf}

if [[ ! "${mail_client}" = "None" ]]; then
	echo "Send to ${email}"
	if [[ "${mail_client}" = "Thunderbird" ]]; then
		${SCRIPT_DIR}/sendto_email.sh -e ${email} -a "${pdf}"
	else
		${SCRIPT_DIR}/sendto_email.sh -e ${email} -a "${pdf}" -c
	fi
fi


