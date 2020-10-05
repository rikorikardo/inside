#!/usr/bin/env bash


VEGA20=$( lspci -vnns $busid | grep VGA -A 2 | grep AMD -A 2 | grep Vega -A 2 | grep "Vega 20" | wc -l )
#NAVI=$( lspci -vnns $busid | grep Navi | wc -l )

NAVI_VDDCI_MIN=750
NAVI_VDDCI_MAX=850
NAVI_MVDD_MIN=1250
NAVI_MVDD_MAX=1350

echo "manual" > /sys/class/drm/card$cardno/device/power_dpm_force_performance_level

if [[ $NAVI_COUNT -ne 0 ]]; then
    args=""
    if [[ ! -z $VDDCI && ${VDDCI[$i]} -ge $NAVI_VDDCI_MIN && ${VDDCI[$i]} -le $NAVI_VDDCI_MAX ]]; then
       vlt_vddci=$((${VDDCI[$i]} * 4 ))
       args+="smcPPTable/MemVddciVoltage/1=${vlt_vddci} smcPPTable/MemVddciVoltage/2=${vlt_vddci} smcPPTable/MemVddciVoltage/3=${vlt_vddci} "
    fi
    if [[ ! -z $MVDD && ${MVDD[$i]} -ge $NAVI_MVDD_MIN && ${MVDD[$i]} -le $NAVI_MVDD_MAX ]]; then
       vlt_mvdd=$((${MVDD[$i]} * 4 ))
       args+="smcPPTable/MemMvddVoltage/1=${vlt_mvdd} smcPPTable/MemMvddVoltage/2=${vlt_mvdd} smcPPTable/MemMvddVoltage/3=${vlt_mvdd} "
    fi
    python /hive/opt/upp/upp.py -i /sys/class/drm/card$cardno/device/pp_table set \
    	smcPPTable/FanStopTemp=0 smcPPTable/FanStartTemp=0 smcPPTable/FanZeroRpmEnable=0 \
    	smcPPTable/MinVoltageGfx=2800 $args \
    	OverDrive8Table/ODSettingsMax/8=960 \
    	OverDrive8Table/ODSettingsMin/3=700 OverDrive8Table/ODSettingsMin/5=700 OverDrive8Table/ODSettingsMin/7=700 \
    	--write
fi
#	smcPPTable/FanTargetTemperature=85 
#	smcPPTable/MemMvddVoltage/3=5200
#	smcPPTable/MemVddciVoltage/3=3200
#	smcPPTable/FanPwmMin=35
#	OverDrive8Table/ODFeatureCapabilities/9=0

function _SetcoreVDDC {
	if [[ $VEGA20 -ne 0 || $NAVI_COUNT -ne 0  ]]; then
		echo "Noop"
	else
		vegatool -i $cardno --volt-state 7 --vddc-table-set $1 --vddc-mem-table-set $1
	fi
}	

#function _SetcoreClock {
#	local vdd=$2
#	if [[ $VEGA20 -ne 0 || $NAVI_COUNT -ne 0 ]]; then
#		echo "s 1 $1" > /sys/class/drm/card$cardno/device/pp_od_clk_voltage
#		[[  -z $vdd  ]] && vdd="1050"
#		[[  -z $vdd  && $NAVI_COUNT -ne 0 ]] && vdd="0"
#		[[ $vdd -gt 725 ]] && echo "vc 1 $(($1-100)) $(($vdd-25))" > /sys/class/drm/card$cardno/device/pp_od_clk_voltage
#		echo "vc 2 $1 $vdd" > /sys/class/drm/card$cardno/device/pp_od_clk_voltage
#		echo c > /sys/class/drm/card$cardno/device/pp_od_clk_voltage
#
#	else
#		vegatool -i $cardno  --core-state 4 --core-clock $(($1-30))
#		vegatool -i $cardno  --core-state 5 --core-clock $(($1-20))
#		vegatool -i $cardno  --core-state 6 --core-clock $(($1-10))
#		vegatool -i $cardno  --core-state 7 --core-clock $1
#	fi
#}	

function _SetcoreClock {
        local vdd=$2
        if [[ $VEGA20 -ne 0 ]]; then
        echo "s 1 $1" > /sys/class/drm/card$cardno/device/pp_od_clk_voltage
         [[  -z $vdd  ]] && vdd="1050"
        echo "vc 2 $1 $vdd" > /sys/class/drm/card$cardno/device/pp_od_clk_voltage
        echo c > /sys/class/drm/card$cardno/device/pp_od_clk_voltage

        else
           if      [[ $1 -eq 1401 ]]; then
             vegatool -i $cardno  --core-state 2 --core-clock $(($1-30))
             vegatool -i $cardno  --core-state 3 --core-clock $(($1-20))
             vegatool -i $cardno  --core-state 4 --core-clock $(($1-10))
             vegatool -i $cardno  --core-state 5 --core-clock $1
           elif    [[ $1 -eq 1200 ]]; then
             vegatool -i $cardno  --core-state 1 --core-clock $(($1-30))
             vegatool -i $cardno  --core-state 2 --core-clock $(($1-20))
             vegatool -i $cardno  --core-state 3 --core-clock $(($1-10))
             vegatool -i $cardno  --core-state 4 --core-clock $1
           elif    [[ $1 -eq 1312 ]]; then
             vegatool -i $cardno  --core-state 1 --core-clock $(($1-30))
             vegatool -i $cardno  --core-state 2 --core-clock $(($1-20))
             vegatool -i $cardno  --core-state 3 --core-clock $(($1-10))
             vegatool -i $cardno  --core-state 4 --core-clock $1
           elif    [[ $1 -eq 1474 ]]; then
             vegatool -i $cardno  --core-state 1 --core-clock $(($1-30))
             vegatool -i $cardno  --core-state 2 --core-clock $(($1-20))
             vegatool -i $cardno  --core-state 3 --core-clock $(($1-10))
             vegatool -i $cardno  --core-state 4 --core-clock $1
           elif    [[ $1 -eq 1536 ]]; then
             vegatool -i $cardno  --core-state 2 --core-clock $(($1-30))
             vegatool -i $cardno  --core-state 3 --core-clock $(($1-20))
             vegatool -i $cardno  --core-state 4 --core-clock $(($1-10))
             vegatool -i $cardno  --core-state 5 --core-clock $1
           elif    [[ $1 -ge 992  &&  $1 -le 1199 ]]; then
             vegatool -i $cardno  --core-state 0 --core-clock 852
             vegatool -i $cardno  --core-state 1 --core-clock 991
             vegatool -i $cardno  --core-state 2 --core-clock 991
             vegatool -i $cardno  --core-state 3 --core-clock 991
             vegatool -i $cardno  --core-state 4 --core-clock 991
             vegatool -i $cardno  --core-state 5 --core-clock 991
             vegatool -i $cardno  --core-state 6 --core-clock 991
             vegatool -i $cardno  --core-state 7 --core-clock $1
           else
             vegatool -i $cardno  --core-state 4 --core-clock $(($1-30))
             vegatool -i $cardno  --core-state 5 --core-clock $(($1-20))
             vegatool -i $cardno  --core-state 6 --core-clock $(($1-10))
             vegatool -i $cardno  --core-state 7 --core-clock $1
           fi
         fi
}

function _SetmemClock {
	if [[ $VEGA20 -ne 0 || $NAVI_COUNT -ne 0 ]]; then
		echo "m 1 $1" > /sys/class/drm/card$cardno/device/pp_od_clk_voltage
		echo c > /sys/class/drm/card$cardno/device/pp_od_clk_voltage
	else
		vegatool -i $cardno --mem-state 3 --mem-clock $1
	fi
}	


if [[ ! -z $MEM_CLOCK && ${MEM_CLOCK[$i]} -gt 0 ]]; then
	_SetmemClock ${MEM_CLOCK[$i]}
fi

if [[ ! -z $CORE_CLOCK && ${CORE_CLOCK[$i]} -gt 0 ]]; then
	_SetcoreClock ${CORE_CLOCK[$i]} ${CORE_VDDC[$i]}
fi

if [[ ! -z $CORE_VDDC && ${CORE_VDDC[$i]} -gt 0 ]]; then
	_SetcoreVDDC ${CORE_VDDC[$i]}
fi

[[ ! -z $REF && ${REF[$i]} -gt 0 ]] && amdmemtweak --gpu $card_idx --REF ${REF[$i]}

	echo 1 > /sys/class/drm/card$cardno/device/hwmon/hwmon*/pwm1_enable
	echo "manual" > /sys/class/drm/card$cardno/device/power_dpm_force_performance_level
	echo 5 > /sys/class/drm/card$cardno/device/pp_power_profile_mode
	#vegatool -i $cardno --set-fanspeed 50
	if [[ $VEGA20 -ne 0 || $NAVI_COUNT -ne 0 ]]; then
		rocm-smi -d $cardno --setfan 50%
	else	
		vegatool -i $cardno  --set-fanspeed 50
	fi


[[ ! -z $FAN && ${FAN[$i]} -gt 0 ]] &&
	if [[ $VEGA20 -ne 0 || $NAVI_COUNT -ne 0 ]]; then
		rocm-smi -d $cardno --setfan ${FAN[$i]}%
	else	
		vegatool -i $cardno  --set-fanspeed ${FAN[$i]}
	fi


if [[ ! -z $PL && ${PL[$i]} -gt 0 ]]; then
	hwmondir=`realpath /sys/class/drm/card$cardno/device/hwmon/hwmon*/`
	if [[ -e ${hwmondir}/power1_cap_max ]] && [[ -e ${hwmondir}/power1_cap ]]; then
#		echo Power Limit set to ${PL[$i]} W
		rocm-smi -d $cardno --autorespond=y --setpoweroverdrive ${PL[$i]} # --loglevel error 
	fi
fi
