# Hyprland 脚本集

> ⚠️ 自从迁移到 `hyprland.lua`（Hyprland 0.55+）后，**大部分窗口/工作区相关脚本已废弃**，
> 逻辑全部移到 `~/.config/hypr/hyprland.lua` 里以 `hl.dsp.*` dispatcher 实现。
> 本目录**只保留两个纯 CLI 包装脚本**：`backlight.sh` 和 `screenshot.sh`。
> 它们做的事是调外部二进制（`ddcutil`、`hyprshot`、`satty`），lua 没有等价 API。

## 当前保留的脚本

### 1. `backlight.sh`

通过 `ddcutil` 控制外接显示器的 OSD 背光（VCP code 10）。

**调用方**：`~/.config/hypr/hypridle.conf`

```conf
listener {
    timeout = 150                                # 2.5 分钟空闲
    on-timeout = $HOME/.config/hypr/scripts/backlight.sh off
    on-resume  = $HOME/.config/hypr/scripts/backlight.sh on
}
```

**用法**：

```sh
backlight.sh on   # 恢复到上次保存的亮度（/tmp/monitor/backlight 不存在则用 65）
backlight.sh off  # 把当前值存到 /tmp/monitor/backlight，然后把背光降到 1（不全关屏）
```

**依赖**：`ddcutil`，且显示器必须支持 DDC/CI。

### 2. `screenshot.sh`

区域截图 → 调 `satty` 做标注 → 保存到 `~/Pictures/screenshot/` 并复制到剪贴板。

**调用方**：`~/.config/hypr/hyprland.lua` 里的

```lua
hl.bind("ALT + A", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screenshot.sh"))
```

**依赖**：`hyprshot`、`satty`、`wl-copy`。

---

## 已迁移到 `hyprland.lua` 的功能（不再需要 shell 脚本）

| 原脚本                | 现在用                                                                |
| --------------------- | --------------------------------------------------------------------- |
| `switch_client.sh`    | `hl.dsp.window.cycle_next()` + 自定义 class 过滤                      |
| `switch_workspace.sh` | `hl.dsp.focus({ workspace = ... })`                                   |
| `toggle_floating.sh`  | `hl.dsp.window.float({ action = "toggle" })`                          |
| `toggle_maximize.sh`  | `hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })` |
| `window/maximize.sh`  | 同上                                                                  |
| `window/normalize.sh` | Hyprland 内部 fullscreen state machine                                |
| `window/minimize.sh`  | `hl.dsp.window.move({ workspace = "special:minimize" })`              |

原因详见 `hyprland.lua` 顶部的注释 + 当时迁移 Hyprland 0.55+ 的 wiki（hyprlang → lua）。

## 安装与权限

```sh
chmod +x ~/.config/hypr/scripts/*.sh
```

（迁移后脚本数减少，`window/` 子目录也已经被清理掉。）

## 故障排除

- **`backlight.sh` 无效**：先跑 `ddcutil detect` 看是否能看到显示器；外接屏默认 DDC/CI 是关的，部分显示器要在 OSD 里打开。
- **`screenshot.sh` 没反应**：`hyprshot` 需要 `xdg-desktop-portal-hyprland` 在跑；`satty` 是单独的包，不在 Hyprland 默认依赖里。
- **其他快捷键不响应**：现在 99% 的快捷键都在 `hyprland.lua` 里，去那里改。
