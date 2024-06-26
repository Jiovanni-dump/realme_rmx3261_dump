#!bin/sh

function logcmd()
{
    echo -e "\n"
}

function exe_cmd()
{
    logcmd "$@";
    eval $@;
}

function create_new_file()
{
    echo -n "YZIPC02"
    echo -n $1
    echo -n $2
    echo -n "20CPIZY"
}

ylogbox_pids=`pidof ylogbox`
for p in ${ylogbox_pids[@]}
do
   kill -9 $p
done

create_new_file "lastlog/kernel.log"
exe_cmd "ylogbox -p 0"

create_new_file "lastlog/android.log"
exe_cmd "ylogbox -p 2"

create_new_file "lastlog/err.log"
exe_cmd "ylogbox -p 1"

