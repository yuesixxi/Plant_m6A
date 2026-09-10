#!/bin/bash
# setup_env_rm6a.sh — dedicated R/Bioconductor env for exomePeak2 + regression
set -e
MAMBA=/home/xi/tmp/miniforge3/bin/mamba
LOG=/home/xi/tmp/plant_m6A/logs/setup_env_rm6a.log
exec > >(tee -a "$LOG") 2>&1
echo "=== startup $(date) ==="
$MAMBA create -n rm6a -y -c conda-forge -c bioconda -c defaults \
  r-base r-data.table r-sandwich r-lmtest r-argparse \
  bioconductor-rtracklayer bioconductor-exomepeak2 bioconductor-bsgenome \
  bioconductor-genomicfeatures \
  || { echo "STEP FAILED rc=$?"; exit 1; }
echo "=== DONE $(date) ==="
