#!/bin/bash
# exomePeak2 peak calling for one GSE174573 comparison
# Usage: bash peak.sh <treat> <gff> <genome> <outdir>
set -e
R=/home/xi/tmp/miniforge3/envs/rm6a/bin/Rscript
S=/home/xi/tmp/plant_m6A/results/phase1/gse174573_tables
TREAT="$1"; GFF="$2"; GENOME="$3"; OUT="$4"
mkdir -p "$OUT"
"$R" /home/xi/tmp/plant_m6A/p1_exomepeak2.R "$S/sample_table_$TREAT.csv" "$GFF" "$GENOME" WT "$TREAT" "$OUT" > "$OUT/peak_$TREAT.out" 2>&1
echo "EXIT_$TREAT=$?"
tail -20 "$OUT/peak_$TREAT.out"
echo "=== $TREAT DONE ==="
