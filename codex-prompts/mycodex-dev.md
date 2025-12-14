---
description: MyCodex /dev 工作流（Codex 负责规划，Claude 负责执行），适用于在 Codex CLI 中编排并将实现委托给 Claude Code
argument-hint: "<任务描述>"
# examples:
#   - /mycodex-dev "实现 JWT 登录"
#   - /mycodex-dev "为现有模块补齐单测并把覆盖率提高到 90%"
---

# MyCodex Dev Workflow（Codex 规划 / Claude 执行）

## 目标

你在 **Codex CLI** 中扮演 **编排者（Planner）**：负责需求澄清、代码库分析、任务拆分与验收。
代码实现与测试执行委托给 **Claude 执行者**（通过 `codeagent-wrapper --backend claude`）。

## 输入

- 任务描述：$ARGUMENTS

## 工作流（固定 6 步）

### 1) 需求澄清

- 若需求不够明确，最多问 2-3 个关键问题（范围/边界、验收标准、测试要求、兼容性/性能约束）。
- 若需求足够明确，直接进入下一步。

### 2) 代码库分析（Codex 自己做）

- 通过读取关键文件与搜索（Read/Grep/Glob）理解现状、约束与已有模式。
- 识别复用点与风险点，给出技术决策（保持 KISS/DRY/YAGNI）。

### 3) 生成开发计划（必须可执行）

- 输出 2-5 个可并行任务（task-1..task-n），每个任务包含：
  - 目标、文件范围、依赖、测试命令、验收点
- 如适用，在项目根目录写入：`.codex/specs/<feature>/dev-plan.md`

### 4) 委托 Claude 执行实现（强制）

- 对每个任务使用 `codeagent-wrapper --backend claude` 下发实现与测试要求。
- 独立任务优先并行执行：
  - 使用 `codeagent-wrapper --parallel`，并在每个 `---TASK---` 中设置 `backend: claude`。
- 当 `codeagent-wrapper` 不在 PATH 时，先定位：
  - `command -v codeagent-wrapper`；若不存在，尝试 `~/.claude/bin/codeagent-wrapper`。

### 5) 验证与回归

- 以项目约定的测试命令为准；若未提供，优先选择最小可验证集合。
- 只修复与本任务相关的问题；不做无关重构与“顺手修”。
- 不执行 `git commit` / `git push`（除非用户明确要求）。

### 6) 收尾总结

- 汇总：完成的任务、关键变更文件、测试结果/覆盖率、已知限制与后续建议。

## 委托模板（参考）

```bash
codeagent-wrapper --backend claude - <<'EOF'
Task: task-1
Goal: ...
Scope: ...
Constraints: ...
Tests: ...
Acceptance:
- [ ] ...
EOF
```
