#!/usr/bin/env bash
# Isaac Sim 5.1.0 + Pegasus Simulator (+ optional PX4-Autopilot) setup
# Usage: ./setup_isaacsim.sh [--with-px4]

set -euo pipefail

ISAACSIM_VERSION="5.1.0"
ISAACSIM_ZIP="isaac-sim-standalone-${ISAACSIM_VERSION}-linux-x86_64.zip"
ISAACSIM_URL="https://download.isaacsim.omniverse.nvidia.com/${ISAACSIM_ZIP}"

export ISAACSIM_PATH="${HOME}/isaacsim"
export ISAACSIM_PYTHON="${ISAACSIM_PATH}/python.sh"
export ISAACSIM="${ISAACSIM_PATH}/isaac-sim.sh"

WITH_PX4=false
[[ "${1:-}" == "--with-px4" ]] && WITH_PX4=true

# ---------- Isaac Sim ----------
echo ">>> Installing Isaac Sim ${ISAACSIM_VERSION}"
mkdir -p "${ISAACSIM_PATH}"
cd "${ISAACSIM_PATH}"

if [[ ! -f "${ISAACSIM_PATH}/post_install.sh" ]]; then
    wget -c "${ISAACSIM_URL}"
    unzip -q "${ISAACSIM_ZIP}"
    rm -f "${ISAACSIM_ZIP}"
else
    echo "Isaac Sim already extracted, skipping download."
fi

./post_install.sh

# ---------- Environment variables (added once) ----------
add_to_bashrc() {
    grep -qxF "$1" ~/.bashrc || echo "$1" >> ~/.bashrc
}
add_to_bashrc 'export ISAACSIM_PATH="${HOME}/isaacsim"'
add_to_bashrc 'export ISAACSIM_PYTHON="${ISAACSIM_PATH}/python.sh"'
add_to_bashrc 'export ISAACSIM="${ISAACSIM_PATH}/isaac-sim.sh"'

# ---------- Pegasus Simulator ----------
echo ">>> Installing Pegasus Simulator"
cd ~
if [[ ! -d PegasusSimulator ]]; then
    git clone https://github.com/PegasusSimulator/PegasusSimulator.git
fi
cd ~/PegasusSimulator/extensions
"${ISAACSIM_PYTHON}" -m pip install --editable pegasus.simulator

# ---------- PX4 Autopilot (optional) ----------
if [[ "${WITH_PX4}" == true ]]; then
    echo ">>> Installing PX4-Autopilot v1.14.3"
    cd ~
    if [[ ! -d PX4-Autopilot ]]; then
        git clone https://github.com/PX4/PX4-Autopilot.git --recursive
    fi
    cd PX4-Autopilot
    git checkout v1.14.3
    git submodule update --init --recursive
    bash ./Tools/setup/ubuntu.sh
    make px4_sitl_default none
fi

echo
echo ">>> Done. Open a new terminal (or run: source ~/.bashrc), then launch with:"
echo "    \$ISAACSIM          # run Isaac Sim directly"
echo "    ${ISAACSIM_PATH}/isaac-sim.selector.sh   # or use the app selector GUI"
