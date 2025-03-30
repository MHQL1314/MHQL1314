
NC='\033[0m'         
LRED='\033[1;31m'
LGREEN='\033[1;32m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
LBLUE='\033[1;36m'
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'



banner() {
    clear
            figlet "   MH TOOL" | lolcat
 echo -e " ${YELLOW}===================================================${NC}"
      echo -e " ${BLUE}MH工具自动美化${NC}"
      echo -e " ${BLUE}作者沐涵千凌${NC}"
 echo -e " ${YELLOW}===================================================${NC}"
}


cache_pak="/sdcard/缓存/"

edit_hex_value() {
    local decimal_value=$1
    local new_decimal_value=$2

  
    if ! [[ $decimal_value =~ ^[0-9]+$ ]]; then
        echo -e "${LGREEN}十进制数值无效:  $decimal_value${NC}"
        return 1
    fi

    local hex_value=$(printf "%08X" $decimal_value)
    local reversed_hex=$(echo "$hex_value" | sed 's/../& /g' | awk '{for(i=NF;i>0;i--) printf $i; print ""}')
    local formatted_hex=$(echo "$reversed_hex" | sed 's/../\\x&/g')

    if [ -z "$(ls -A "$soucre_pak")" ]; then
        echo -e "${LIGHTCYAN}没有找到资源! ${NC}"
        exit 1
    fi

    local search_result=$(LANG=C grep -robUaP "$formatted_hex" "$soucre_pak" | tr -d '\0' | head -n 1)
    if [ -z "$search_result" ]; then
        echo -e "${LGREEN}没有找到皮肤id的文件 ${NC}"
        return 1
    fi

    local file_path=$(echo "$search_result" | cut -d: -f1)
    local user_hex_offset=$(echo "$search_result" | cut -d: -f2)

    cp "$file_path" "$cache_pak"
    [ ! -f "$result_pak/$(basename "$file_path")" ] && cp "$file_path" "$result_pak"

    local pattern_hex=$(echo "FFFFFF" | sed 's/../\\x&/g')
    local last_match=$(LANG=C grep -robUaP "$pattern_hex" "$cache_pak" | tr -d '\0' | awk -v max_offset="$user_hex_offset" -F: '$2 <= max_offset' | tail -n 1)

    if [ -n "$last_match" ]; then
        local last_offset=$(echo "$last_match" | cut -d: -f2)
        local new_offset=$((last_offset - 9))
        local extracted_bytes=$(dd if="$file_path" bs=1 skip="$new_offset" count=2 2>/dev/null | xxd -p)
  echo -e " ${YELLOW}=================================================== ${NC}"
  echo -e " ${PURPLE} 工具频道： @MHQL1314${NC}"
  
        echo -e "${LRED} 偏移量字节:${NC} ${LBLUE}$new_offset${NC} 修改 ${LBLUE}$extracted_bytes${NC}"
    fi

    rm -rf "$cache_pak"/*

    if ! [[ $new_decimal_value =~ ^[0-9]+$ ]]; then
        echo -e "${LIGHTCYAN}新数值无效:  $new_decimal_value${NC}"
        return 1
    fi

    local new_hex_value=$(printf "%08X" $new_decimal_value)
    local new_reversed_hex=$(echo "$new_hex_value" | sed 's/../& /g' | awk '{for(i=NF;i>0;i--) printf $i; print ""}')
    local new_formatted_hex=$(echo "$new_reversed_hex" | sed 's/../\\x&/g')

    local new_search_result=$(LANG=C grep -robUaP "$new_formatted_hex" "$soucre_pak" | tr -d '\0' | head -n 1)
    if [ -z "$new_search_result" ]; then
        echo -e "${LIGHTCYAN}没有找到皮肤id的文件${NC}"
        return 1
    fi

    local new_file_path=$(echo "$new_search_result" | cut -d: -f1)
    local new_user_hex_offset=$(echo "$new_search_result" | cut -d: -f2)
    local new_pattern_hex=$(echo "FFFFFF" | sed 's/../\\x&/g')

    cp "$new_file_path" "$cache_pak"
    local new_last_match=$(LANG=C grep -robUaP "$new_pattern_hex" "$cache_pak" | tr -d '\0' | awk -v max_offset="$new_user_hex_offset" -F: '$2 <= max_offset' | tail -n 1)

    if [ -n "$new_last_match" ]; then
        local new_last_offset=$(echo "$new_last_match" | cut -d: -f2)
        local new_new_offset=$((new_last_offset - 9))
        local new_extracted_bytes=$(dd if="$new_file_path" bs=1 skip="$new_new_offset" count=2 2>/dev/null | xxd -p)

        echo -e "${LRED} 偏移量字节:${NC} ${GREEN}$new_new_offset${NC} 修改 ${GREEN}$new_extracted_bytes${NC}"
        echo -n -e "\\x${new_extracted_bytes:0:2}\\x${new_extracted_bytes:2:2}" | dd of="$result_pak/$(basename "$file_path")" bs=1 seek="$new_offset" conv=notrunc 2>/dev/null
  echo -e "${LRED} 已在偏移量  ${LBLUE}$new_offset${NC} 处更改字节 ${LGREEN}修改 ${NC}${GREEN}$new_extracted_bytes${NC}"
   echo -e " ${PURPLE} 工具额外功能${NC}"
  echo -e " ${YELLOW}===================================================${NC}"

    fi

    rm -rf "$cache_pak"/*
}


function mainskin() {
toilet " MH TOOL SKIN " -f term -F border --gay  | pv -qL 3000
   echo -e "${LIGHTCYAN}输入配置文件的路径${NC}"
      read -r id_skin
    if [ ! -s "$id_skin" ]; then
        echo -e "${LIGHTCYAN}配置文件为空${NC}"
        exit 1
    fi
       echo -e "${LIGHTPURPLE}输入要修改文件的路径${NC}"
      read -r soucre_pak
     echo -e "${YELLOW}请输入输出路径(一般为你的打包路径)${NC}"
      read -r result_pak
      
    while IFS= read -r line || [[ -n "$line" ]]; do
        decimal_value=$(echo "$line" | cut -d' ' -f1)
        new_decimal_value=$(echo "$line" | cut -d' ' -f2)
        edit_hex_value "$decimal_value" "$new_decimal_value"
    done < "$id_skin"
     echo -e "${LIGHTCYAN}制作完成${NC}"
    sleep 5
    menu
}


function menu {
banner
    while true; do
        echo -e "${YELLOW}[1] 全自动美化"
        echo -e "[2] 退出${NC}"
        read -p "请输入选项: " choice
        case $choice in
            1)
             mainskin
                ;;
            2)
                exit 0
                ;;
            *)
                echo -e "${LRED}无效选择，请重新输入。${NC}"
                ;;
        esac
    done
}

menu
