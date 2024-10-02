#!/bin/bash

echo -n "enter directory name: "
read dirName

if  [ -d "$dirName" ]; then
	cd "$dirName"
else
	mkdir "$dirName"
	cd "$dirName"
fi

contents=($(ls))
ls | nl

file_scroll(){
	if [ -f "$1" ]; then
		head "$1"
		num=10
		total=$(wc -l < "$1")
		while [ $num -lt "$total" ]; do
			echo -n "Do you want to display more? [Y/N]: "
			read ans
                	if [ "$ans" = "Y" ]; then
                        	head -n $((num + 10)) "$1"| tail
                        	num=$((num + 10))
			else
				break
                	fi
        	done
	fi

	echo -n "Exit? [Y/N]: "
	read a
	
	if [ $a = "N" ]; then
		cd ~/$dirName

		contents=($(ls))
		ls | nl
		overall_scroll
	else
		exit 0
	fi
}
overall_scroll(){
	echo -n "please select a file/subdirectory by number: "
	read select

	if [ "$select" -gt 0 ] && [ "$select" -le "${#contents[@]}" ]; then
		if [ -f "${contents[$((select - 1))]}" ]; then
			file_scroll "${contents[$((select -1))]}"
		elif [ -d "${contents[$((select - 1))]}" ]; then 
			cd "${contents[$((select - 1))]}"
			c=()
			temp=$(mktemp)
			mc=$(ls -l --time-style=+"%m" "$temp" | cut -d ' ' -f 6 | tr -d '0' | tr -s ' ')
			dc=$(ls -l --time-style=+"%d" "$temp" | cut -d ' ' -f 6 | tr -d '0' | tr -s ' ')
			yc=$(ls -l --time-style=+"%Y" "$temp" | cut -d ' ' -f 6 | tr -d '0' | tr -s ' ')

			for f in *; do
				if [ -f "$f" ]; then
					yf=$(ls -l --time-style=+"%Y" "$f" | cut -d ' ' -f 6 | tr -d '0' | tr -s ' ')
					mf=$(ls -l --time-style=+"%m" "$f" | cut -d ' ' -f 6 | tr -d '0' | tr -s ' ')
					df=$(ls -l --time-style=+"%d" "$f" | cut -d ' ' -f 6 | tr -d '0' | tr -s ' ')
					ydif=$((yc - yf))
					mdif=$((mc - mf))
					ddif=$((dc - df))

					if [ "$ydif" -eq 0 ] && [ "$mdif" -le 1 ] && [ "$ddif" -le 1 ] && [ "$ddif" -ge 0 ] ; then
						c+=("$f")
					fi
				fi
			done
			rm "$temp"
			for i in ${!c[@]}; do
				echo "$((i + 1)) ${c[$i]}"
			done   

			echo -n "please select by number: "
			read choice

			if [ "$choice" -gt 0 ] && [ "$choice" -le ${#c[@]} ];then
				file_scroll "${c[$((choice -1))]}"
			else
				echo "Invalid"
				overall_scroll
			fi
		else
			echo "Invalid"
			overall_scroll
		fi
	else
		echo "Invalid"
		overall_scroll
	fi
}
overall_scroll
