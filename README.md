# Bible Verse Replacer

选中一段经文引用，按下快捷键，自动替换成完整经文。

作者：大侠请留步

Bible Verse Replacer 是一个常驻 macOS 菜单栏的小工具。它适合写讲章、笔记、灵修记录、Markdown 文档、聊天消息时使用：你只需要输入或选中 `创世记 1:1`、`创3：2-5`、`Genesis 4:1` 这样的引用，按下快捷键，它就会把引用替换成离线经文。

默认输出效果：

```text
创世记 1:1 起初，神创造天地。
```

多节经文默认逐节换行：

```text
创世记 3:2 女人对蛇说：「园中树上的果子，我们可以吃，
创世记 3:3 惟有园当中那棵树上的果子，神曾说：『你们不可吃，也不可摸，免得你们死。』」
创世记 3:4 蛇对女人说：「你们不一定死；
创世记 3:5 因为神知道，你们吃的日子眼睛就明亮了，你们便如神能知道善恶。」
```

## 下载

请到 [Releases](https://github.com/maxiaovo/Bible-Verse-Replacer/releases) 下载最新版本的 `BibleVerseReplacer-v0.1.6.zip`。

当前版本是早期预览版：

- macOS：下载 `BibleVerseReplacer-v0.1.6.zip`，支持 macOS 13 Ventura 及以上。
- Windows：下载 `BibleVerseReplacer-Windows-v0.1.6.zip`，支持 Windows 7 SP1 及以上，需要 .NET Framework 4.8。
- 当前成品尚未做 Apple notarization 公证或 Windows 代码签名。
- 如果 macOS 提示无法打开，请在 Finder 中右键 App，选择“打开”，再确认打开。

## 第一次使用

### macOS

1. 下载并解压 `BibleVerseReplacer-v0.1.6.zip`。
2. 打开 `BibleVerseReplacer.app`，菜单栏会出现一个「经」字图标。
3. 按提示授予“辅助功能”权限。这个权限用于模拟复制和粘贴。
4. 在任意 App 中选中经文引用，比如 `创世记 1:1`。
5. 按默认快捷键 `⌃⌥⌘B`。

如果权限没有打开，可以点击菜单栏「经」图标，进入设置或打开辅助功能设置。
菜单栏里的辅助功能权限状态会在每次打开菜单时重新读取系统状态。

### Windows

1. 确认系统是 Windows 7 SP1 或更新版本，并已安装 [.NET Framework 4.8](https://support.microsoft.com/topic/microsoft-net-framework-4-8-offline-installer-for-windows-9d23f658-3b97-68ab-d013-aa3c3e7495e0)。
2. 下载并解压 `BibleVerseReplacer-Windows-v0.1.6.zip`。
3. 运行 `BibleVerseReplacer.exe`，系统托盘会出现应用图标。
4. 在任意 App 中选中经文引用，比如 `创世记 1:1`。
5. 按默认快捷键 `Ctrl + Alt + Win + B`。

Windows 版可以在托盘菜单里打开设置窗口，修改快捷键、输出格式和开机自启动。

## 支持的引用

支持单段、组合、跨章、整章和多处经文：

```text
创世记 3:2
创世记 3:2-5
创世记 3:2,5,7-9
创世记 3:2、5，7-9
创世记 3:2-4:3
创世记第3章
约 3:16，罗 8:28
创世记 3:2-5，4:1
Genesis 3:2-5, 4:1
```

兼容：

- 中文书卷名和常见简称。
- 英文书卷名和常见缩写。
- 全角/半角冒号：`：` / `:`
- 全角/半角数字：`３` / `3`
- 分隔符：`,`、`，`、`、`、`;`、`；`、`|`、`｜`、`\`
- 范围符号：`-`、`－`、`–`、`—`、`——`、`--`、`～`、`~`、`至`、`到`、`to`、`...`、`……`、`^`

示例：

```text
约三1:1到3
约三1: 1～3
约三1:1to3
约三1:1...3
约三1:1\1:2|1:3
```

暂不支持中文数字和半节写法，例如：

```text
创世记三章二节
约 3:16上
```

## 设置

菜单栏「经」图标里可以打开设置窗口。当前支持：

- 修改全局快捷键。
- 切换输出格式：
  - `书卷 章:节 经文`
  - 连续正文
  - 首行引用 + 分节经文
  - 每节带节号
- 设置引用标签：
  - 改写为完整标签，例如 `创 1:1` 输出为 `创世记 1:1`
  - 保留输入标签，例如 `Genesis 1:1` 原样保留
  - 不保留标签，只输出正文
- 设置组合显示：
  - 合并为一段（默认），例如 `创1:1-3，7` 输出为 `创世记 1:1-3,7 前段正文……后段正文`
  - 按片段分行，例如 `创世记 1:1-3` 和 `创世记 1:7` 各占一行
- 自动检查更新：
  - 默认开启，启动后会自动检查 GitHub 最新 Release
  - 如果发现新版本，会提示是否打开下载页面
  - 也可以在菜单栏或托盘菜单里手动点击“检查更新”
- 查看辅助功能权限状态。
- 开启或关闭开机自启动。
- 查看经文库来源。

## 离线与隐私

Bible Verse Replacer 的经文替换不需要联网。经文库已经离线内置在 App 里。

如果开启自动检查更新，App 启动后会请求 GitHub Releases 获取最新版本号；关闭该选项后不会自动联网检查更新。手动点击“检查更新”时也会访问 GitHub Releases。

为了跨 App 替换选中文字，它会使用剪贴板作为中转：

1. 临时复制当前选中文字。
2. 解析经文引用。
3. 写入经文并粘贴。
4. 尽量恢复原来的剪贴板内容。

如果解析失败或找不到经文，App 不会替换原文。

## 经文来源

当前内置经文来自 eBible 的 [Chinese Union Version (Simplified) / `cmn-cu89s`](https://ebible.org/Scriptures/details.php?id=cmn-cu89s)，通过 eBible 提供的 VPL SQL 数据导入。

## 从源码构建

### macOS

需要 macOS 13+、Xcode Command Line Tools 或 Xcode。

```sh
make app
```

构建产物会生成在：

```text
.build/BibleVerseReplacer.app
```

运行：

```sh
make run
```

测试：

```sh
make test
```

更新内置经文数据：

```sh
make update-data
```

普通构建会复用 `.build/downloads/` 里的下载缓存。

### Windows

需要 Visual Studio Build Tools 或 Visual Studio，并安装 .NET Framework 4.8 Developer Pack。

```powershell
msbuild BibleVerseReplacer.sln /restore /p:Configuration=Release /p:Platform="Any CPU"
```

运行自测：

```powershell
.\Windows\BibleVerseReplacer.Windows\bin\Release\BibleVerseReplacer.exe --self-test
```

## 发布规则

仓库已经开启自动发布：

- 所有产品相关改动必须推送到 GitHub 的 `main` 分支。
- 修改功能、图标、资源、源码或 Windows 工程时，必须同步更新 README。
- 产品相关改动必须提升版本号：
  - `Info.plist` 的 `CFBundleShortVersionString` 和 `CFBundleVersion`
  - `Windows/BibleVerseReplacer.Windows/Properties/AssemblyInfo.cs`
- `Release Policy` 工作流会检查 README 和版本号是否同步。
- `Release` 工作流会在发现新版本号时自动构建 macOS/Windows 成品，并创建对应的 GitHub Release。

## 路线图

- 支持更多中文圣经版本。
- 增加自定义输出模板。
- 增加正式签名、公证和安装包。
