# Phase 0 — 数据清单（data_inventory）

> 核实日期：2026-09-10。来源：GEO series matrix（NCBI）+ 交接文档。
> 本项目 Phase 1 只处理 4 个主 MeRIP 数据集（按用户决策），其余留后。

## 1. 已核实的主数据集（GEO，样本构成与文档比对）

### GSE174573 — writer 减效突变体 MeRIP（A1 主分析）
- 24 个样本 = WT / fip37 / vir / hakai 各 3 生物学重复，每重复 IP + paired Input。
- ecotype Columbia；2-week old seedlings；m6A 抗体：Epimark Monoclonal anti-m6A（NEB）。
- 标题示例：`wt_5 IP`、`fip37_4 IP`、`vir_1 input`、`hakai_2 IP`。
- **与文档一致**（WT vs fip37-4/vir-1/hakai-2，PE）。

### GSE79523 — ALKBH10B eraser MeRIP（A2 主分析）
- 8 个样本 = WT / atalkbh10b-/- 各 2 生物学重复，每重复 IP + paired Input。
- 14-day seedlings；m6A 抗体：Synaptic Systems #202003。
- 标题：`WT-IP-rep1/2`、`MUT-IP-rep1/2`（+ INPUT）。
- **与文档一致**（alkbh10b-1，2 重复）。注：GEO 基因型为 `atalkbh10b -/-`。

### GSE227150 — FIO1 / MTA MeRIP（A1 补充 + A3 主分析）
- 该 GEO 含两类assay：ribotag（翻译组，48 样本，**本项目不用**）与 m6A meRIP（48 样本）。
- meRIP 部分：Col(WT) / cry1cry2 / fio1 / mta / spa134，每基因型 Blue/Dark 两条件 × 2 重复 + paired Input。
- 下载脚本子集取 **WT / fio1 / mta 的 meRIP（24 runs）**（排除 cry1cry2/spa134）。
- 抗体：EpiMark m6A antibody；6-day seedlings。
- m6A meRIP 每基因型×条件为 **2 重复**，与文档"各 2 重复+配对 Input"一致。

### PRJCA005164 (= CRA004192) — alkbh10b + ABA MeRIP（A2 胁迫臂）
- 来源：NGDC GSA（download.cncb.ac.cn），**8 runs（CRR283802–809），均 PE（f1/r2）**。
- **BioProject 页已核实**（2026-09-15）：8 个 BioSample = Col0_input_1/2、Col0_IP_1/2、alkbh10b_input_1/2、alkbh10b_IP_1/2（`alkbh10b_*` 样本名即 GSA 上 alkbh10b 基因型），全部为 ABA 处理下的 m6A-seq（论文 34386031, Front Plant Sci 2021）。
- 摘要表明：ABA 下 alkbh10b 中 ABA 信号基因（PYR1/PYL7/PYL9/ABI1/SnRK2.2）m6A 高甲基化 → **单一对比 alkbh10b(ABA) vs Col0(ABA)**，符合文档 A2 胁迫臂。
- 下载途径：`https://download.cncb.ac.cn/gsa2/CRA004192/CRR*/CRR*_f1.fastq.gz|_r2.fastq.gz`（已连通 200）。
- **待办（下载时）**：GSA 浏览页为 JS 应用 curl 取不到，CRR283802–809↔样本顺序映射需下载时核对（先探 run 内含 md5/样本清单文件；必要时按论文方法与 run 大小匹配，勿臆测）。

## 2. 参考基因组 / 注释（Phase 3 使用）
- 拟南芥：TAIR10 + Araport11（Ensembl Plants release-63 GTF）。
- 水稻：IRGSP-1.0 + Ensembl Plants release-63 GTF（Phase 4 用）。
- 下载源：EBI 镜像 `ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-63`。

## 3. 备注 / 风险
- GSE227150 ribotag 数据存在但不在本期范围，勿误用。
- GSE79523 与文档基因型表述略有出入（`-/-` 敲除 vs `alkbh10b-1` 命名），不影响分析（同为 alkbh10b 缺失），归入手稿方法学说明。
- PRJCA005164 需在下载启动时从 GSA 复核样本构成。
