#!/bin/bash 



banner(){
    echo "*******************************"
    echo "This is a simple backup script."
    echo "*******************************"
}


get_backup(){
    
    general_title=$1
    title=$2
    src=$3
    dst=$4
    ip=$5
    username=$6
    port=$7

    echo "********************************"
    echo "[*] Starting Backup for $general_title [$title]"
    echo "[*] IP:PORT -> $ip:$port"
    echo "[*] User name -> $username"
    echo "[*] src-> $src"
    echo "[*] dst-> $dst"

    # Starting backup

    rsync -av --progress -e 'ssh -p 1111' ${username}@${ip}:${src} $dst


    if [ $? -eq 0 ]; then
        echo "[✓] Backup completed successfully for [$title]"
        return 0
    else
        echo "[✗] ERROR: Backup FAILED for [$title]" >&2
        return 1
    fi

}

process_configs(){
    
    local config_file=$1
    echo "[*] Proccessing [$1]"

    general_title=$(jq -r '.title' $config_file )
    titles=$(jq -r 'to_entries[] | select(.value | type == "object") | .key' $config_file)
    ip=$(jq -r '.ip' $config_file)
    username=$(jq -r '.username' $config_file)
    port=$(jq -r '.port' $config_file)

    for title in ${titles[@]};do
        
        src=$(jq -r ".\"$title\".src" $config_file)
        dst=$(jq -r ".\"$title\".dst" $config_file)
        get_backup $general_title $title $src $dst $ip $username $port
    done
}

read_config(){
    
    shopt -s nullglob

    local json_files=( *.json )
    
    if [ ${#json_files[@]} -eq 0 ];then
        echo "[0] Json file found."
        shopt -u nullglob
        exit 1
    else
        echo "[*] Found ${#json_files[@]} file"
    fi

    for name in ${json_files[@]};do
       process_configs "$name"
    done



    shopt -u nullglob
}


main(){
    
    banner
    read_config


}


main
