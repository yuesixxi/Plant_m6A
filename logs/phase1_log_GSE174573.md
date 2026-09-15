# Phase 1 Log — GSE174573（A1 writer 主数据集）

日期：2026-09-10~15。参考基因组 TAIR10 + Ensembl Plants release-63 GTF。

## 样本
WT / fip37-4 / vir-1 / hakai-2 各 3 生物学重复，每重复 IP + paired Input，共 24 runs，PE（paired）；文库非链特异（unstrand）。

## 下载与比对
- 下载：ENA 直接 fastq（aria2c）。仅 SRR14570256 的 mate2 在 ENA 为**空目录**，改用 NCBI SRA（prefetch+fasterq-dump）取全。
- 比对：fastp 去接头 → HISAT2（TAIR10 index）→ sorted BAM。24/24 成功（失败率 0 < 20% 红线）。
- 对齐率：平均 ~83%，分布 54–94%。低对齐 run（54–65%：SRR14570265/67/70/71 等）为文库本身特性——用**剪接感知 index 对比测试无改善**（54.46% vs 54.53%），判定非 index/流程问题，保留普通 index（与管线/PI 一致）。

## Peak calling（exomePeak2 1.14.3，diff_p_cutoff=1 保留全部受检位点）
| 对比 | 受检 peak | 丢失位点 (fdr<0.05, log2FC≤-1) | 升高位点 (fdr<0.05, log2FC≥1) |
|---|---|---|---|
| WT vs fip37 | 23165 | **10464** | 208 |
| WT vs vir | 18962 | **12058** | 213 |
| WT vs hakai | 27810 | **3547** | 1535 |

- **A1 可用位点均 ≥2000 红线**（go/no-go 通过，功效充足）。
- 关键适配（本机 vs 原 WSL）：
  - genome 改传 **forge 的 BSgenome.Athaliana.TAIR10**（Bioconductor 无现成，已自制安装到 rm6a）；
  - 预建 **TxDb**（`makeTxDbFromGFF(...,format="auto")`）经 `txdb` 参数传入，绕开 exomePeak2 对 Ensembl GTF 的自动探测失败；
  - `parallel=8`（377GB RAM，原 1 核）；**仅同时运行一个对比**（并发多个致 BiocParallel worker 崩：SIGPIPE/serialize）。

## 表达定量（featureCounts，-s 0 -p --countReadPairs，exon/gene_id）
- 输出：`results/phase1/expr/GSE174573_gene_counts.txt`（全部 24 BAM 计数，后续用 Input 列做协变量）。

## 产物
- `results/phase1/gse174573_peaks{,_vir,_hakai}/exomePeak2_output/diffPeaks.{bed,csv,rds}`（每位点 chr, chromStart, chromEnd, geneID, diff.log2FC, pvalue, fdr）。
- 供 Phase 2 结构注释 + Phase 3 A1 回归使用。

## 备注
- 大文件（fastq/BAM）已按流式策略清理，仅保留小体积结果表。
