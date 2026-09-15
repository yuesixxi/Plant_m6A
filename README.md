# Plant_m6A

Cross-species analysis of RNA structure selectivity of the m6A machinery — **Arabidopsis thaliana** analyses A1 (writers) and A2 (eraser ALKBH10B).

- 上游：`github.com/jiangxun0758/Plant_m6A`；Fork：`github.com/yuesixxi/Plant_m6A`（结果推送至此）
- 科学交接：`Plant_m6A_Codex_handover.md`（"Codex" 为 agent 代称）；执行计划：`PLAN.md`
- 执行进展汇总见下方"状态总览"，明细到 `logs/phaseN_log.md` 与 `results/`

## 状态总览（2026-09-15）
| 阶段 | 状态 |
|---|---|
| 环境（m6a + rm6a）/ 参考 + hisat2 index / Phase 0 / 冒烟 | ✅ 完成 |
| **GSE174573（A1）下载+比对+peak+表达** | ✅ **完成** |
| GSE79523（A2）下载+比对 | 🔄 进行中 |
| GSE227150（A1 补充 + A3）、PRJCA005164（A2 胁迫）| ⏳ 待处理 |
| Phase 2 结构注释 / Phase 3 回归 | ⏳ 未开始 |

## 环境
- conda base：`/home/xi/tmp/miniforge3`；`m6a`（fastp/HISAT2/subread/samtools/pigz/FastQC/MultiQC/aria2/ViennaRNA/python）；`rm6a`（R 4.3.3 + exomePeak2/BSgenome/data.table/sandwich/lmtest/rtracklayer）
- 参考：TAIR10 + Ensembl Plants release-63 GTF；IRGSP-1.0（Phase 4 用）；hisat2 index 在 `/home/xi/tmp/plant_m6A_data/ref/hisat2_index/`
- 重数据：`/home/xi/tmp/plant_m6A_data/`（流式下载+即删，峰值 ~单个数据集 ~30GB）
- 关键适配：forge `BSgenome.Athaliana.TAIR10`（自制装入 rm6a）；exomePeak2 用 `txdb` 参数 + BSgenome 名；`parallel=8` 且单 dataset 运行

## 进度日志

### Phase 0 / 准备
- [x] 只读核查交接文档；仓库已公开；ENA 查得 Phase1 主 fastq ≈ 125 GB。
- [x] 磁盘/写入评估（/home NFS 207T，5GiB 实测写入正常；/phys 全为 root 属不可写）。
- [x] GitHub 认证（gh → yuesixxi）；Kilo 经 VS Code Remote-SSH 在 rig1 运行（断连可恢复）。
- [x] 代码落地：克隆 fork→项目根；清硬编码路径；.gitignore；目录结构；git 身份。
- [x] 环境 m6a + rm6a（修正 aria2c→aria2、r-rtracklayer→bioconductor-rtracklayer、R 独立 env）。
- [x] 参考+index（TAIR10 179M / IRGSP1.0 556M）；冒烟（fastp/RNAplfold/exomePeak2）。
- [x] Phase 0：`results/phase0/data_inventory.md` + `go_no_go.md`（GO）。
- [x] Phase 1 输入：ENA 构建 SRR↔基因型/IP-Input 映射 → `results/phase1/sample_table_{GSE174573,GSE79523,GSE227150}.csv`。

### Phase 1 — GSE174573（A1，已完成）
- [x] 下载+fastp+HISAT2：24/24 BAM（avg ~83%；低对齐 run 经剪接 index 对比确认为文库自身质量）。
- [x] SRR14570256 补全（ENA mate2 空目录 → NCBI SRA）。
- [x] forge BSgenome.Athaliana.TAIR10；exomePeak2 适配并经真实数据跑通。
- [x] Peak calling：fip37 23165 / vir 18962 / hakai 27810 受检；**A1 丢失位点 fip37 10464 / vir 12058 / hakai 3547**（≥2000，功效充足）。
- [x] featureCounts 表达：`results/phase1/expr/GSE174573_gene_counts.txt`。
- [x] 明细：`logs/phase1_log_GSE174573.md`；重数据已清理（32GB→14M）。

### Phase 1 — GSE79523（A2，进行中）
- [ ] 下载+fastp+HISAT2（8 runs）进行中 → peak（WT vs alkbh10b）+ 表达 → GSE227150、PRJCA005164。

### Phase 1 — 对比设计确认（2026-09-15）
- **GSE227150**（24 runs）：mta vs WT（蓝光/黑暗分做）+ fio1 vs WT（蓝光为主、黑暗敏感性）→ 共 4 个对比。
- **PRJCA005164**（CRA004192，8 runs，PE）：BioProject 页核实＝Col0/alkbh10b × IP/Input × 2 重复（均 ABA 处理）→ 单一对比 alkbh10b(ABA) vs Col0(ABA)；下载经 `download.cncb.ac.cn/gsa2/CRA004192`（CRR283802–809）；run↔样本映射下载时核对。

## 运行保障
- rig1 常开联网；长任务用 persistent 后台进程（断 VS Code 不中断）。
- 每次完成动作更新此 README；commit+push 到 `yuesixxi/Plant_m6A`（遵循 AGENTS.md）。
