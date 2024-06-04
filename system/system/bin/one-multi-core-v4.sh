#!/system/bin/sh
if [ $# != 2 ]; then
	echo "测试脚本执行需要输入执行轮数和是否需要打印单core阶段的变频信息，例如："
	echo "$0 2 log 代表脚本执行2轮，打印变频信息log"
	echo "$0 2 nolog 代表脚本执行2轮，不打印变频信息log"
	exit 2
fi
if [ $1 -lt 1 ]; then
	echo "输入的测试次数不能小于1..."
	exit 2
fi
if [ $2 == "log" ]; then
	enablelog="Y"
elif [ $2 == "nolog" ]; then
	enablelog="N"
else
	echo "控制是否打印变频信息请输入log或者nolog！"
	exit 2
fi

echo 0 > /sys/devices/system/cpu/cpuhotplug/qos_core_ctl

little_core_set() {
	echo $1 > /sys/devices/system/cpu/cpufreq/policy0/scaling_fix_freq
	echo $2 > /sys/kernel/debug/DCDC_CPU/voltage
	echo $3 > /sys/kernel/debug/DCDC_SRAM/voltage
	if [ $enablelog == "Y" ]; then
		cpufreq=`cat /sys/devices/system/cpu/cpufreq/policy0/cpuinfo_cur_freq`
		cpuvolt=`cat /sys/kernel/debug/DCDC_CPU/voltage`
		sramvolt=`cat /sys/kernel/debug/DCDC_SRAM/voltage`
		echo "Freq-${cpufreq}KHz, VDDCPU0-${cpuvolt}mV, VDDSRAM-${sramvolt}mV"
	fi
	sleep 0.1;
}

little_core_dvfs(){
	for i in $(seq 1 $1)
	do
		little_core_set 614400 1180 950
		little_core_set 1820000 1180 950
		little_core_set 614400 1150 950
		little_core_set 1820000 1150 950
		little_core_set 614400 1150 900
		little_core_set 1820000 1150 900
		little_core_set 614400 816 900
		little_core_set 768000 816 900
		little_core_set 962000 816 900
		little_core_set 1144000 816 900
		little_core_set 1228800 847 900
		little_core_set 1482000 935 900
		little_core_set 1536000 954 900
		little_core_set 1716000 1016 900
		little_core_set 1820000 1050 900
	done
}

big_core_set() {
	echo $1 > /sys/devices/system/cpu/cpufreq/policy6/scaling_fix_freq
	echo $2 > /sys/kernel/debug/DCDC_GPU/voltage
	if [ $enablelog == "Y" ]; then
		cpufreq=`cat /sys/devices/system/cpu/cpufreq/policy6/cpuinfo_cur_freq`
		cpuvolt=`cat /sys/kernel/debug/DCDC_GPU/voltage`
		echo "Freq-${cpufreq}KHz, VDDCPU1-${cpuvolt}mV"
	fi
	sleep 0.1;
}

big_core_dvfs(){
	for i in $(seq 1 $1)
	do
		big_core_set 1228800 1050
		big_core_set 1820000 1100
	done
}

for count in $(seq 1 $1)
do
	date "+loop-$count begin: %Y-%m-%d %H:%M:%S"

	echo 1 > /sys/devices/system/cpu/cpu0/online
	for corenum in $(seq 1 7)
	do
		echo 0 > /sys/devices/system/cpu/cpu$corenum/online
	done
	
	online=`cat /sys/devices/system/cpu/online`
	echo "cpu$online online, test..."
	little_core_dvfs 2

	for corenum in $(seq 1 5)
	do
		echo 1 > /sys/devices/system/cpu/cpu$corenum/online
		plugcore=`expr $corenum - 1`
		echo 0 > /sys/devices/system/cpu/cpu$plugcore/online
		online=`cat /sys/devices/system/cpu/online`
		echo "cpu$online online, test..."
		little_core_dvfs 2
	done

	for corenum in $(seq 6 7)
	do
		echo 1 > /sys/devices/system/cpu/cpu$corenum/online
		plugcore=`expr $corenum - 1`
		echo 0 > /sys/devices/system/cpu/cpu$plugcore/online
		online=`cat /sys/devices/system/cpu/online`
		echo "cpu$online online, test..."
		big_core_dvfs 2
	done

	for corenum in $(seq 0 6)
	do
		echo 1 > /sys/devices/system/cpu/cpu$corenum/online
		online=`cat /sys/devices/system/cpu/online`
		echo "cpu$online online, test..."
		echo 0 > /sys/devices/system/cpu/cpufreq/policy0/scaling_fix_freq
		echo 0 > /sys/devices/system/cpu/cpufreq/policy6/scaling_fix_freq
		sleep 180
	done
	date "+loop-$count done: %Y-%m-%d %H:%M:%S"
done

echo 1 > /sys/devices/system/cpu/cpuhotplug/qos_core_ctl
echo "****************************************************"
echo "*******************TEST PASS************************"
echo "****************************************************"


