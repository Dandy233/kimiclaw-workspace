# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## 当前配置

### 定时任务（5个）
- daily-it-news: 每天 9:00 发送 IT 新闻简报
- daily-task-review: 每天 18:00 任务回顾日报
- weekly-system-check: 每周一 10:00 系统健康检查
- auto-git-sync: 每小时自动 Git 同步
- delayed-surprise: 2026-03-02 9:00 知识更新调研

### 脚本
- scripts/health-check.sh: 系统健康检查脚本
- scripts/auto-sync.sh: Git 自动同步脚本

### 目录结构
- memory/: 每日日志和长期记忆
- diary/: 私人日记
- scripts/: 自动化脚本
- archive/: 归档文件（大会话文件等）
- docs/: 文档和报告

---

## 技能使用指南

### 🌤️ Weather (天气查询)
- **状态**: ✅ 已就绪
- **来源**: openclaw-bundled
- **依赖**: curl
- **API**: wttr.in / Open-Meteo

**使用示例**:
```bash
# 快速查询（北京）
curl -s "wttr.in/Beijing?format=3"
# 输出: Beijing: ⛅️ +8°C

# 紧凑格式（位置+天气+温度+湿度+风力）
curl -s "wttr.in/Beijing?format=%l:+%c+%t+%h+%w"
# 输出: Beijing: ⛅️ +8°C 71% ↙5km/h

# 完整预报（无广告）
curl -s "wttr.in/Beijing?T"

# 当前天气（今天）
curl -s "wttr.in/Beijing?0"
```

**格式代码**:
| 代码 | 含义 |
|------|------|
| %c | 天气状况图标 |
| %t | 温度 |
| %h | 湿度 |
| %w | 风力 |
| %l | 位置名称 |
| %m | 月相 |

**高级用法**:
```bash
# 机场代码查询
curl -s "wttr.in/JFK?format=3"

# 公制单位
curl -s "wttr.in/Beijing?m"

# 英制单位
curl -s "wttr.in/New+York?u"

# 生成PNG图片
curl -s "wttr.in/Beijing.png" -o /tmp/weather.png
```

### 🧾 Summarize (内容摘要)
- **状态**: ⏳ 安装中（ClawHub速率限制，等待下次重试）
- **来源**: clawhub (summarize)
- **功能**: 从URL、PDF、音频、视频提取文本和转录
- **用途**: 快速阅读文章、视频内容转录

**安装方式**: 
```bash
clawhub install summarize --no-input
```

**安装日志**:
- 2026-03-02 01:30: 第1次尝试失败 ❌ ClawHub 速率限制
- 下次重试: 2026-03-04 01:30 (任务ID: install-summarize-retry-v2)

**使用场景**:
- 快速了解长文章内容
- 视频内容转录（YouTube等）
- 播客文字稿提取
- PDF文档自动摘要

**使用场景**:
- 快速了解长文章内容
- 视频内容转录（YouTube等）
- 播客文字稿提取
- PDF文档自动摘要

### 🎨 Frontend Design (前端设计技能集)
- **状态**: ⏳ 安装中（ClawHub速率限制，分批重试）
- **来源**: clawhub
- **任务ID**: install-frontend-skills

**待安装技能清单**:
| 技能名 | 状态 | 备注 |
|--------|------|------|
| frontend | ❌ 待重试 | 速率限制 |
| ui-ux-design | ❌ 待重试 | 速率限制 |
| tailwind-design-system | ✅ 已安装 | v1.0.0 |
| web-design | ✅ 已安装 | v1.0.0 |
| responsive-design | ❌ 待重试 | 速率限制 |
| design-system-components | ✅ 已安装 | v1.0.0 |
| ui-ux-pro-max | ❌ 待重试 | 速率限制 |

**安装日志**:
- 2026-03-03 20:50: 第1次尝试，全部失败 ❌ ClawHub 速率限制
- 2026-03-03 21:01: 第2次尝试 ✅ design-system-components 安装成功
- 已安装: tailwind-design-system, web-design, design-system-components
- 待重试: frontend, ui-ux-design, responsive-design, ui-ux-pro-max

### 📦 ClawHub 技能管理

**搜索技能**:
```bash
clawhub search <关键词>
```

**安装技能**:
```bash
clawhub install <技能名> --no-input
```

**列出已安装**:
```bash
clawhub list
```

**更新技能**:
```bash
clawhub update <技能名>
```
