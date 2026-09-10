#!/bin/bash
# setup_env.sh — create conda env m6a (bio tools + python + R/Bioconductor + ViennaRNA)
# Run as persistent background job on rig1. Log to logs/setup_env.log
set -e
MAMBA=/home/xi/tmp/miniforge3/bin/mamba
LOG=/home/xi/tmp/plant_m6A/logs/setup_env.log
exec > >(tee -a "$LOG") 2>&1
echo "=== startup $(date) ==="
echo "mamba: $($MAMBA --version 2>/dev/null || echo missing)"

echo "--- [2a] core bio tools + python (viennaRNA) ---"
if [ -d /home/xi/tmp/miniforge3/envs/m6a ]; then
  echo "2a already done; skipping"
else
  $MAMBA create -n m6a -y -c conda-forge -c bioconda -c defaults \
    fastp hisat2 subread samtools pigz fastqc multiqc aria2 sra-tools viennarna \
    numpy pandas pyarrow biopython ruff \
    || { echo "STEP 2a FAILED rc=$?"; exit 1; }
fi

echo "--- [2b] R + Bioconductor (exomePeak2, BSgenome, data.table, sandwich) ---"
$MAMBA install -n m6a -y -c conda-forge -c bioconda -c defaults \
  r-base r-data.table r-sandwich r-lmtest r-argparse \
  bioconductor-rtracklayer bioconductor-exomepeak2 bioconductor-bsgenome bioconductor-genomicfeatures \
  || { echo "STEP 2b FAILED rc=$?"; exit 1; }

echo "=== DONE $(date) ==="
