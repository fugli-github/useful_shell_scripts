#!/usr/bin/env bash 

############################################################
# Check and set color codes
############################################################

bold=${FORCE_COLOR_BOLD:-""}
underline=${FORCE_COLOR_UNDERLINE:-""}
standout=${FORCE_COLOR_STANDOUT:-""}
normal=${FORCE_COLOR_NORMAL:-""}
black=${FORCE_COLOR_BLACK:-""}
red=${FORCE_COLOR_RED:-""}
green=${FORCE_COLOR_GREEN:-""}
yellow=${FORCE_COLOR_YELLOW:-""}
blue=${FORCE_COLOR_BLUE:-""}
magenta=${FORCE_COLOR_MAGENTA:-""}
cyan=${FORCE_COLOR_CYAN:-""}
white=${FORCE_COLOR_WHITE:-""}
# check if stdout is a terminal...
if test -t 1 && [[ -z ${normal} ]]; then
    # see if it supports colors...
    ncolors=$(tput colors)
    if test -n "${ncolors}" && test ${ncolors} -ge 8; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi


while true; do
	files_extracted=0

	while read file; do
		printf "*** ${magenta}Unzipping${normal} %s " "${file} ****"
		unzip -- "${file}" -d "$(dirname "${file}")" &>/dev/null || printf " ${bold}${red}error occured!${normal}"
		rm "${file}"
		files_extracted=$((files_extracted + 1))
		printf "*** ${blue}done${normal} ****\n"
	done < <(find . -type f -name "*.zip" | sort)

    while read file; do
        printf "${magenta}Unzipping${normal} %s" "${file}"
        tar xJf "${file}" -C "$(dirname "${file}")" &>/dev/null || printf " ${bold}${red}error occured!${normal}"
        rm "${file}"
        files_extracted=$((files_extracted + 1))
        printf " ${green}done${normal}\n"
    done < <(find . -type f -name '*.txz' | sort)

    while read file; do
        printf "${magenta}Unzipping${normal} %s" "${file}"
        tar xzf "${file}" -C "$(dirname "${file}")" &>/dev/null || printf " ${bold}${red}error occured!${normal}"
        rm  "${file}"
        files_extracted=$((files_extracted + 1))
        printf " ${green}done${normal}\n"
    done < <(find . -type f -name '*.tgz' | sort)

    while read file; do
        printf "${magenta}Unzipping${normal} %s" "${file}"
        tar xJf "${file}" -C "$(dirname "${file}")" &>/dev/null || printf " ${bold}${red}error occured!${normal}"
        rm "${file}"
        files_extracted=$((files_extracted + 1))
        printf " ${green}done${normal}\n"
    done < <(find . -type f -name '*.tar.xz' | sort)

    while read file; do
        printf "${magenta}Unzipping${normal} %s" "${file}"
        tar xzf "${file}" -C "$(dirname "${file}")" &>/dev/null || printf " ${bold}${red}error occured!${normal}"
        rm "${file}"
        files_extracted=$((files_extracted + 1))
        printf " ${green}done${normal}\n"
    done < <(find . -type f -name '*.tar.gz' | sort)

    while read file; do
        printf "${magenta}Unzipping${normal} %s" "${file}"
        tar xf "${file}" -C "$(dirname "${file}")" &>/dev/null || printf " ${bold}${red}error occured!${normal}"
        rm  "${file}"
        files_extracted=$((files_extracted + 1))
        printf " ${green}done${normal}\n"
    done < <(find . -type f -name '*.tar' | sort)

    while read file; do
        printf "${magenta}Unzipping${normal} %s" "${file}"
        file_target="${file%.*}"
        gzip -d "${file}" &>/dev/null || printf " ${bold}${red}error occured!${normal}"
        rm "${file}"
        files_extracted=$((files_extracted + 1))
        printf " ${green}done${normal}\n"
    done < <(find . -type f -name '*.gz' | sort)

    while read file; do
        printf "${magenta}Unzipping${normal} %s" "${file}"
        xz -d  "${file}" &>/dev/null || printf " ${bold}${red}error occured!${normal}"
        rm "${file}"
        files_extracted=$((files_extracted + 1))
        printf " ${green}done${normal}\n"
    done < <(find . -type f -name '*.xz' | sort)

    if [[ ${files_extracted} == 0 ]]; then
        break
    fi

done


printf "${bold}${green}All files are extracted.${normal}\n"
