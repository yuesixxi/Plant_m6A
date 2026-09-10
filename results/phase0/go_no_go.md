# Phase 0 — go/no-go 判定

> 日期：2026-09-10。红线依据交接文档 §2.0。

## 主数据集可用性判定（GEO 已核实）
| 数据集 | 用途 | 样本构成 | 判定 |
|---|---|---|---|
| GSE174573 | A1 writer 主 | WT/fip37/vir/hakai ×3 + Input ✓ | **GO** |
| GSE79523 | A2 ALKBH10B | WT/alkbh10b-/- ×2 + Input ✓ | **GO** |
| GSE227150（meRIP 子集）| A1 mta + A3 fio1 | WT/fio1/mta，Blue/Dark ×2 + Input ✓ | **GO** |
| PRJCA005164 | A2 ABA 臂 | 8 runs, PE150（GSA）| **待下载时复核** |

## 前置条件状态
- [x] 环境：`m6a`（工具+python）、`rm6a`（R/Bioconductor）已建成并验证。
- [x] 参考/注释源已确认（EBI release-63，4 文件可下载）。
- [ ] hisat2 index 构建中（后台）。
- [ ] 参考基因组 TAIR10 验证序列完整性（构建后抽查）。
- [ ] PRJCA005164 样本构成复核（下载前）。

## 功效红线预告（结果阶段判定，非现在）
- A1 可用位点 < 2000 → 暂停（交接文档红线）。
- A3 FIO1 依赖位点 < 500 → 降级为描述性分析。

## 结论
**GO（有条件）**：三个 GEO 主数据集样本构成与文档一致，先行启动 Phase 1 下载与处理；
PRJCA005164 与水稻等留后。下载/比对失败率 >20% 或样本构成不符时立即暂停并回报。
