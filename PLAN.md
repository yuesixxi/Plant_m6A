# Plant_m6A 执行计划（交接笔记）

> 建立日期：2026-09-10
> 执行者：Kilo agent（运行在 rig1）
> 对应交接文档：`/home/xi/tmp/plant_m6A/Plant_m6A_Codex_交接文档.md`（该文档中的 "Codex" 仅为 agent 代称）

## 1. 目标
从零开始，完成植物 m6A 结构偏好分析的全部剩余工作，产出可直接支撑论文手稿的所有数据、数字与结论记录（`MANUSCRIPT_DATA.md` 是最重要交付物）。最终交付给 PI（江循）。

## 2. 仓库
- **上游**：`https://github.com/jiangxun0758/Plant_m6A`（现已公开，12 个脚本，仅代码 ~15KB）
- **Fork**：`https://github.com/yuesixxi/Plant_m6A`（本机通过 gh 推送结果）
- 使用方式：克隆 fork → `git pull` 同步上游 → 把脚本中 PI 机器硬编码路径（`/mnt/e`、`/mnt/j`、`/home/jxun/...`、env `m6a`/`sra`/`colabfold`）改为环境变量/本机路径。
- 注意：文档说"私有需授权"已不成立（现公开）。

## 3. 目录规划
- **永久/可 push（放 /home，NFS）**：`/home/xi/tmp/plant_m6A/`
  - `code/` 适配后脚本；`results/phase0..5/`；`figures/`；`logs/`；`MANUSCRIPT_DATA.md`；`PLAN.md`；`README.md`（进度日志）
- **重数据（放 /phys，rig1 本地快盘，可删）**：`/home/xi/tmp/plant_m6A_data/`
  - `ref/`（TAIR10+Araport11、IRGSP-1.0、hisat2 index）
  - `data/<dataset>/`（sra/fastq/trim/bam，跑完即删）

## 4. 磁盘/下载策略（流式 + 即删）
- 总下载：Phase1 主 fastq ≈ 125 GB；加 Phase4/验证 ≈ 175–215 GB fastq.gz。
- 流式：按"一个数据集"为单位——下载→fastp→比对→peak→删 fastq/trim/BAM，仅保留小体积结果表。
- 峰值 ≈ 单个最大数据集（GSE227150 ≈ 90–100 GB），而非全量叠加（250–350 GB）。
- 大文件不进 git（fastq/bam/trim/*.sra 均 .gitignore）；只 push results/figures/scripts 等小体积产物。

## 5. 环境（需新建）
- conda：`/home/xi/tmp/miniforge3`（已有 codex/pearl 等 env，但无 bioinfo 工具，需新 env `m6a`）
- 工具：fastp、HISAT2、featureCounts(subread)、samtools、pigz、FastQC、MultiQC、aria2c、ViennaRNA(RNAplfold)、python(numpy/pandas/pyarrow/Bio)
- R/Bioconductor：exomePeak2、data.table、sandwich；**BSgenome 需自行 forge TAIR10 与 IRGSP-1.0**（联网）
- 参考：TAIR10+Araport11、IRGSP-1.0+Ensembl Plants；构建 hisat2 index

## 6. 并行
- RNAplfold（结构预测）：按转录本分 chunk + `xargs -P N`（脚本已支持，加大核数）
- exomePeak2（peak calling）：按数据集并行（多 R 进程）+ 内部 BiocParallel 若支持；比对 hisat2 `-p`
- 前提：按 rig1 核数配置并行度

## 7. Phase 计划（依据交接文档）
| Phase | 内容 | 估时 |
|---|---|---|
| 0 | 数据核实（GEO/SRA/ENA/GSA）+ go/no-go | ~0.5 天 |
| 1 | 下载+fastp+HISAT2+exomePeak2+表达（主数据 ~125GB） | ~1 周 |
| 2 | 结构注释（RNAplfold -u5 -W70 -L40，channel u1/local_pm5）+平行验证 | 2–3 天 |
| 3 | A1(writer)/A2(ALKBH10B)/A3(FIO1) 回归 | ~1 周 |
| 4 | 体内结构验证（GSE135711）+ 水稻线（PRJNA1125654） | ~1 周 |
| 5 | 跨物种综合 + Forest plot + MANUSCRIPT_DATA.md | 2–3 天 |
- 串行依赖：0→1→2→3→4→5（A3 与 Phase4 可并行）

## 8. 红线（命中即暂停并记录，不自行变通）
- 数据集实际内容与文档描述不符；下载/比对失败率 >20%
- A1 可用位点 <2000 或 A3 可用位点 <500
- 需更换基因组版本/peak caller/统计模型
- 全程记录 `logs/phaseN_log.md`，所有论文数字落盘

## 9. 运行保障（重点）
- **rig1 常开且联网**（所有执行与联网都在 rig1 上）
- 用户经 **VS Code Remote-SSH** 接入；本机检测到 Kilo 由 VSCode 扩展服务器（`kilo serve`）在 rig1 上运行 → 服务器端常驻，用户电脑断网/关 VS Code 不影响 rig1 运行，重连 VS Code 可恢复会话。
- 长任务（下载/比对/建环境）用 `persistent` 后台进程在 rig1 上运行，独立于用户连接，断连不中断。
- 进度同步到 README.md；上下文由 PLAN.md 承接。

## 10. 认证
- GitHub：本机 `gh` 已登录 `yuesixxi`，协议 https，scope 含 `repo`/`workflow`。
- git 全局身份尚未配置（user.name/email），推送前设置。
