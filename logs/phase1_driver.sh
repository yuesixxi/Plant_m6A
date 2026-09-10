#!/bin/bash
# phase1_driver.sh — streaming download + fastp + HISAT2 align for one dataset (ENA direct)
# Usage: bash phase1_driver.sh <DATASET> <SRR1> [SRR2 ...]
# Data base: /home/xi/tmp/plant_m6A_data/<DATASET>/{fastq,fastq_trim,bam,qc,logs}
# Per-run cleanup: raw fastq deleted after fastp; trim deleted after BAM. BAMs kept for peak calling.
set -u
M=/home/xi/tmp/miniforge3/envs/m6a/bin
DATASET="$1"; shift
BASE=/home/xi/tmp/plant_m6A_data/$DATASET
IDX=/home/xi/tmp/plant_m6A_data/ref/hisat2_index/TAIR10
THREADS="${THREADS:-16}"
LOG=/home/xi/tmp/plant_m6A/logs/phase1_$DATASET.log
mkdir -p "$BASE/fastq" "$BASE/fastq_trim" "$BASE/bam" "$BASE/qc/fastp" "$BASE/qc/fastqc" "$BASE/logs"
exec > >(tee -a "$LOG") 2>&1
echo "=== startup $(date) DATASET=$DATASET runs=$# threads=$THREADS ==="

ena_url() { # acc -> base url dir
  local acc=$1
  local prefix=${acc:0:6}
  local digits=${acc:3}
  local nd=${#digits}
  local sub=""
  if [ "$nd" -eq 7 ]; then sub="/00${digits: -1}"; fi
  if [ "$nd" -eq 8 ]; then sub="/0${digits: -2}"; fi
  if [ "$nd" -ge 9 ]; then sub="/0${digits: -2}"; fi
  echo "https://ftp.sra.ebi.ac.uk/vol1/fastq/${prefix}${sub}/${acc}"
}

dl() { # acc
  local acc=$1 base
  base=$(ena_url "$acc")
  ( cd "$BASE/fastq" || return 1
    for m in 1 2; do
      local out="${acc}_$m.fastq.gz"
      if [ -s "$out" ] && gzip -t "$out" 2>/dev/null; then continue; fi
      rm -f "$out.part"
      if "$M/aria2c" -x 16 -s 16 -k 8M -c --max-tries=5 --retry-wait=10 --console-log-level=warn \
           -o "$out.part" "$base/${acc}_$m.fastq.gz"; then
        gzip -t "$out.part" 2>/dev/null && mv "$out.part" "$out" || { echo "$acc $m corrupt" >> "$BASE/logs/failed.log"; rm -f "$out.part"; }
      else
        echo "$acc $m dl" >> "$BASE/logs/failed.log"; rm -f "$out.part"
      fi
    done )
}

fail=0; ok=0
for acc in "$@"; do
  if [ -s "$BASE/bam/${acc}.sorted.bam" ]; then echo "[skip] $acc bam exists"; continue; fi
  # 1. download
  if [ ! -s "$BASE/fastq/${acc}_1.fastq.gz" ] || [ ! -s "$BASE/fastq/${acc}_2.fastq.gz" ]; then
    echo "=== $acc download ==="; dl "$acc"
  fi
  [ -s "$BASE/fastq/${acc}_1.fastq.gz" ] && [ -s "$BASE/fastq/${acc}_2.fastq.gz" ] || { echo "$acc noload" >> "$BASE/logs/failed.log"; continue; }
  # 2. fastp trim
  if [ ! -s "$BASE/fastq_trim/${acc}_1.fq.gz" ]; then
    echo "=== $acc fastp ==="
    "$M/fastp" -w 4 -i "$BASE/fastq/${acc}_1.fastq.gz" -I "$BASE/fastq/${acc}_2.fastq.gz" \
      -o "$BASE/fastq_trim/${acc}_1.fq.gz" -O "$BASE/fastq_trim/${acc}_2.fq.gz" \
      -j "$BASE/qc/fastp/${acc}.json" -h "$BASE/qc/fastp/${acc}.html" >"$BASE/logs/${acc}.fastp.log" 2>&1 \
      || { echo "$acc fastp" >> "$BASE/logs/failed.log"; continue; }
    rm -f "$BASE/fastq/${acc}_1.fastq.gz" "$BASE/fastq/${acc}_2.fastq.gz"
  fi
  # 3. align
  echo "=== $acc hisat2 ==="
  if "$M/hisat2" -p "$THREADS" -x "$IDX" \
        -1 "$BASE/fastq_trim/${acc}_1.fq.gz" -2 "$BASE/fastq_trim/${acc}_2.fq.gz" \
        --dta 2>"$BASE/logs/${acc}.hisat2.log" \
      | "$M/samtools" sort -m 2G -@ 4 -o "$BASE/bam/${acc}.sorted.bam" -; then
    "$M/samtools" index "$BASE/bam/${acc}.sorted.bam"
    rm -f "$BASE/fastq_trim/${acc}_1.fq.gz" "$BASE/fastq_trim/${acc}_2.fq.gz"
    grep -o 'overall alignment rate[^)]*)' "$BASE/logs/${acc}.hisat2.log" | sed "s/^/$acc /" >> "$BASE/logs/align_rates.txt"
    ok=$((ok+1))
  else
    echo "$acc hisat2" >> "$BASE/logs/failed.log"
  fi
done

echo "=== done $(date) ok=$ok fail=$fail ==="
echo "--- alignment rates ---"; cat "$BASE/logs/align_rates.txt" 2>/dev/null
echo "--- failed ---"; cat "$BASE/logs/failed.log" 2>/dev/null || echo "(none)"
