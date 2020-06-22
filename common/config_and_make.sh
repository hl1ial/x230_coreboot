#!/bin/bash
# SPDX-License-Identifier: GPL-3.0+
# Copyright (C) 2018, Tom Hiller <thrilleratplay@gmail.com>

# shellcheck disable=SC1091
source /home/coreboot/common_scripts/variables.sh

################################################################################
## Copy config and run make
################################################################################
function configAndMake() {
  ######################
  ##   Copy config   ##
  ######################
  if [ -f "$DOCKER_COREBOOT_DIR/.config" ]; then
    echo "Using existing config"

    # clean config to regenerate
   make savedefconfig

   if [ -s "$DOCKER_COREBOOT_DIR/defconfig" ]; then
     mv "$DOCKER_COREBOOT_DIR/defconfig" "$DOCKER_COREBOOT_CONFIG_DIR/"
   fi
  else
    if [ -f "$DOCKER_SCRIPT_DIR/defconfig-$COREBOOT_COMMIT" ]; then
      cp "$DOCKER_SCRIPT_DIR/defconfig-$COREBOOT_COMMIT" "$DOCKER_COREBOOT_CONFIG_DIR/defconfig"
      echo "Using config-$COREBOOT_COMMIT"
    elif [ -f "$DOCKER_SCRIPT_DIR/defconfig-$COREBOOT_TAG" ]; then
      cp "$DOCKER_SCRIPT_DIR/defconfig-$COREBOOT_TAG" "$DOCKER_COREBOOT_CONFIG_DIR/defconfig"
      echo "Using config-$COREBOOT_TAG"
    else
      cp "$DOCKER_SCRIPT_DIR/defconfig" "$DOCKER_COREBOOT_CONFIG_DIR/defconfig"
      echo "Using default config"
    fi
  fi

  #################################
  ##  Copy in the X230 VGA BIOS  ##
  #################################
  if [ -f "$DOCKER_SCRIPT_DIR/pci8086,0166.rom" ]; then
    cp "$DOCKER_SCRIPT_DIR/pci8086,0166.rom" "$DOCKER_COREBOOT_DIR/pci8086,0166.rom"
  fi

  ###############################
  ##  Copy in bootsplash image ##
  ###############################
  if [ -f "$DOCKER_SCRIPT_DIR/bootsplash.jpg" ]; then
    cp "$DOCKER_SCRIPT_DIR/bootsplash.jpg" "$DOCKER_COREBOOT_DIR/bootsplash.jpg"
  fi


  cd "$DOCKER_COREBOOT_DIR" || exit;

  ################
  ##  Config   ##
  ###############
  make defconfig

  if [ "$COREBOOT_CONFIG" ]; then
    make nconfig
  fi

  ##############
  ##   make   ##
  ##############
  make
}
