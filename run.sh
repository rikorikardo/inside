#!/usr/bin/env bash

# [[ `ps aux | grep "./xpmclient" | grep -v grep | wc -l` != 0 ]] &&
#   echo -e "${RED}$MINER_NAME miner is already running${NOCOLOR}" &&
#   exit 1

miner_run_dir="/run/hive/miners/$MINER_NAME"
ln -sfn $MINER_DIR/$MINER_FORK/$MINER_VER/miner $miner_run_dir/miner
ln -sfn $MINER_DIR/$MINER_FORK/$MINER_VER/xpm $miner_run_dir/xpm
ln -sf $MINER_DIR/$MINER_FORK/$MINER_VER/xpmclientnv $miner_run_dir/xpmclient
if [[ $MINER_FORK =~ "cuda" ]]; then
  ln -sf $MINER_DIR/$MINER_FORK/$MINER_VER/libnvrtc-builtins.so.11.8.89 $miner_run_dir/libnvrtc-builtins.so.11.8.89
  ln -sf $MINER_DIR/$MINER_FORK/$MINER_VER/libnvrtc.so.11.2 $miner_run_dir/libnvrtc.so.11.2
  ln -sF $MINER_DIR/$MINER_FORK/$MINER_VER/libnvrtc-builtins.so.11.8 $miner_run_dir/libnvrtc-builtins.so.11.8
fi

cd $miner_run_dir
if [[ -f version ]]; then
  if [[ `cat version` != $MINER_FORK\\$MINER_VER ]]; then
    #remove *.bin becouse it had been created with other miner version
    rm -f *.bin
    echo $MINER_FORK\\$MINER_VER > version
  fi
else
  rm -f *.bin
  echo $MINER_FORK\\$MINER_VER > version
fi

# Miner run here
./xpmclient 2>&1 | tee --append $MINER_LOG_BASENAME.log
