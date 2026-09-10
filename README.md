# Plant_m6A

Cross-species analysis of RNA structure selectivity of the m6A machinery — **Arabidopsis thaliana** analyses A1 (writers) and A2 (eraser ALKBH10B).

上游：`github.com/jiangxun0758/Plant_m6A`；Fork：`github.com/yuesixxi/Plant_m6A`。
科学交接见 `Plant_m6A_Codex_handover.md`；执行计划见 `PLAN.md`。

## 环境（本机适配）
- conda base：`/home/xi/tmp/miniforge3`；bio 环境：`m6a`（fastp/HISAT2/subread/samtools/pigz/FastQC/MultiQC/aria2c/ViennaRNA）
- R：exomePeak2、data.table、sandwich、BSgenome(TAIR10/IRGSP forge)；Python：numpy/pandas/pyarrow/Bio
- 重数据目录：`/home/xi/tmp/plant_m6A_data/`（rig1 本地快盘，跑完即删）

## 进度日志

> 每次完成一个动作后在下方追加（做了什么 / 结果 / 时间）。

### 2026-09-10
- [x] 只读核查交接文档；确认仓库已公开；查询 ENA 得 Phase1 主 fastq ≈ 125 GB（GSE174573 33 / GSE79523 20 / GSE227150 51 / PRJCA005164 20–25）。
- [x] 磁盘/写入评估（NFS 207T 可用，5GiB 实测写入正常）。
- [x] GitHub 认证（gh 登录 yuesixxi，scope 含 repo）；Kilo 经 VS Code Remote-SSH 在 rig1 运行（断连可恢复）。
- [x] 建 PLAN.md、README.md。
- [x] 代码落地（Step 1）：
  - 克隆 fork → 设为项目根；upstream 同步确认（0/0）。
  - 脚本硬编码 PI 路径全部清除（`/home/jxun`、`/mnt/j`、`/mnt/e`、env `sra`/`colabfold`→`m6a`）；HISAT2 index 默认改到 `/home/xi/tmp/plant_m6A_data/ref/hisat2_index/TAIR10`。
  - 建 `.gitignore`（排除 fastq/bam/sra/ref/data 及交接文档）。
  - 建目录 `results/phase0..5`、`figures`、`logs`。
  - git 本地身份：`yuesixxi` / `yuesixxi@users.noreply.github.com`（可改）。
- [x] 环境搭建（Step 2）：`m6a`（工具+python）与 `rm6a`（R 4.3.3 + exomePeak2/BSgenome/data.table/sandwich/lmtest/rtracklayer）两个 conda env 建成并通过验证。修正：`aria2c`→`aria2` 包名、`r-rtracklayer`→`bioconductor-rtracklayer`、R 独立成 `rm6a` 规避 python=3.14 求解死锁。
- [x] 参考源核实：ensemblgenomes 官方 host 不可达，改用 EBI 镜像 `ftp.ebi.ac.uk/ensemblgenomes/pub/plants/release-63`（4 文件均可用）。
- [x] 参考+索引（Step 3）：下载 TAIR10 基因组/GTF 与 IRGSP-1.0 基因组/GTF，**hisat2 index（TAIR10 179M / IRGSP1.0 556M）构建成功**（移至 `/home/xi/tmp/plant_m6A_data/ref/`；注：`/phys` 下全为 root 属不可写，重数据改放 NFS home）。
- [x] 冒烟自检（Step 4）：fastp ✓、RNAplfold（lunp 格式与 p2_collect_structure.py 匹配）✓、exomePeak2 1.14.3 加载+签名与管线用法匹配 ✓（完整算法在 Phase 1 真实数据验证）。
- [x] Phase 0（Step 5）：`data_inventory.md` + `go_no_go.md` 已写；GEO 三数据集样本构成核实与文档一致（GO）。
- [x] Phase 1 输入：经 ENA 构建 SRR↔基因型/IP-Input 映射，生成 `results/phase1/sample_table_{GSE174573,GSE79523,GSE227150}.csv`（计数符合预期）。
- [ ] Phase 1 流式下载+比对：GSE174573（24 runs, ~33GB）已启动（persistent, 14 线程）。

### 待办
- [ ] Phase 1：GSE174573 下完→peak calling（3 对比）+ featureCounts 表达 → 验证链
- [ ] Phase 1：GSE79523、GSE227150、PRJCA005164 依次处理
- [ ] Phase 2+ 结构注释与回归（视 Phase 1 结果）
