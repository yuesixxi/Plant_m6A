#!/bin/bash
# setup_ref.sh — download reference genomes + annotations, build HISAT2 index (TAIR10, IRGSP-1.0)
set -e
REF=/home/xi/tmp/plant_m6A_data/ref
BASE="https://ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-63"
ARIA=/home/xi/tmp/miniforge3/envs/m6a/bin/aria2c
HB=/home/xi/tmp/miniforge3/envs/m6a/bin/hisat2-build
LOG=/home/xi/tmp/plant_m6A/logs/setup_ref.log
mkdir -p "$REF"
exec > >(tee -a "$LOG") 2>&1
echo "=== startup $(date) ==="

cd "$REF"
dl() { # url outname
  local u="$1" o="$2"
  [ -s "$o" ] && { echo "[skip] $o"; return; }
  "$ARIA" -x 8 -s 8 -k 4M --max-tries=5 --retry-wait=5 --console-log-level=error -o "$o.part" "$u"
  mv "$o.part" "$o"
}

echo "--- download genomes + gtf ---"
dl "$BASE/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz" ath_TAIR10.fa.gz
dl "$BASE/gtf/arabidopsis_thaliana/Arabidopsis_thaliana.TAIR10.63.gtf.gz" ath_TAIR10.gtf.gz
dl "$BASE/fasta/oryza_sativa/dna/Oryza_sativa.IRGSP-1.0.dna.toplevel.fa.gz" osa_IRGSP1.0.fa.gz
dl "$BASE/gtf/oryza_sativa/Oryza_sativa.IRGSP-1.0.63.gtf.gz" osa_IRGSP1.0.gtf.gz

echo "--- decompress ---"
gzip -dkf ath_TAIR10.fa.gz ath_TAIR10.gtf.gz osa_IRGSP1.0.fa.gz osa_IRGSP1.0.gtf.gz
ls -lh "$REF"

echo "--- build HISAT2 index: TAIR10 ---"
mkdir -p "$REF/hisat2_index"
"$HB" -p 8 "$REF/ath_TAIR10.fa" "$REF/hisat2_index/TAIR10" 2>&1 | tail -5

echo "--- build HISAT2 index: IRGSP-1.0 ---"
"$HB" -p 8 "$REF/osa_IRGSP1.0.fa" "$REF/hisat2_index/IRGSP1.0" 2>&1 | tail -5

echo "=== DONE $(date) ==="
ls -lh "$REF/hisat2_index"
