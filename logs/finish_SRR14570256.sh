#!/bin/bash
# finish SRR14570256 alignment (GSE174573)
set -e
E=/home/xi/tmp/miniforge3/envs/m6a/bin
BASE=/home/xi/tmp/plant_m6A_data/GSE174573
export PATH=$E:$PATH
"$E/hisat2" -p 14 -x /home/xi/tmp/plant_m6A_data/ref/hisat2_index/TAIR10 \
  -1 "$BASE/fastq_trim/SRR14570256_1.fq.gz" -2 "$BASE/fastq_trim/SRR14570256_2.fq.gz" --dta \
  2>"$BASE/logs/SRR14570256.hisat2.log" \
  | "$E/samtools" sort -m 2G -@ 4 -o "$BASE/bam/SRR14570256.sorted.bam" -
"$E/samtools" index "$BASE/bam/SRR14570256.sorted.bam"
grep -o '[0-9.]*% overall alignment rate' "$BASE/logs/SRR14570256.hisat2.log"
rm -f "$BASE/fastq_trim/SRR14570256_1.fq.gz" "$BASE/fastq_trim/SRR14570256_2.fq.gz"
echo "DONE_SRR14570256"
