# Hyprland 窗口管理脚本

## 功能介绍

本脚本集提供了一系列 Hyprland 窗口管理功能，包括：

- **窗口切换**：在当前工作区或同类窗口中切换
- **工作区管理**：工作区切换和状态管理
- **浮动状态切换**：在平铺和浮动状态之间切换
- **窗口最大化**：支持平铺 -> 浮动 -> 全屏的自动切换
- **窗口最小化**：将窗口移动到特殊工作区

## 脚本列表

### 1. `switch_client.sh`
- **功能**：在当前工作区或同类窗口中切换
- **用法**：`switch_client.sh [mode] [direction]`
  - `mode`：`workspace`（默认）或 `group`
  - `direction`：`next`（默认）或 `prev`

### 2. `switch_workspace.sh`
- **功能**：工作区切换
- **用法**：`switch_workspace.sh [direction]`
  - `direction`：`next`（默认）或 `prev`

### 3. `toggle_floating.sh`
- **功能**：切换窗口的浮动状态
- **用法**：`toggle_floating.sh [maximize]`
  - `maximize`：可选参数，切换后直接最大化

### 4. `toggle_maximize.sh`
- **功能**：切换窗口的最大化状态
- **用法**：`toggle_maximize.sh`

### 5. `window/maximize.sh`
- **功能**：将当前窗口最大化
- **用法**：`window/maximize.sh`

### 6. `window/normalize.sh`
- **功能**：将当前窗口恢复到之前的大小和位置
- **用法**：`window/normalize.sh`

### 7. `window/minimize.sh`
- **功能**：将当前窗口最小化（移动到特殊工作区）
- **用法**：`window/minimize.sh`

## 安装与配置

1. 将脚本文件复制到 `~/.config/hypr/scripts/` 目录
2. 确保脚本具有执行权限：`chmod +x ~/.config/hypr/scripts/*.sh ~/.config/hypr/scripts/window/*.sh`
3. 在 `hyprland.conf` 中添加键位绑定，例如：

```conf
# 窗口切换
bind = SUPER, Tab, exec, ~/.config/hypr/scripts/switch_client.sh workspace next
bind = SUPER_SHIFT, Tab, exec, ~/.config/hypr/scripts/switch_client.sh workspace prev

# 同类窗口切换
bind = ALT, Tab, exec, ~/.config/hypr/scripts/switch_client.sh group next
bind = ALT_SHIFT, Tab, exec, ~/.config/hypr/scripts/switch_client.sh group prev

# 工作区切换
bind = @i3, Left, exec, ~/.config/hypr/scripts/switch_workspace.sh prev
bind = @i3, Right, exec, ~/.config/hypr/scripts/switch_workspace.sh next

# 浮动状态切换
bind = SUPER, space, exec, ~/.config/hypr/scripts/toggle_floating.sh

# 窗口最大化
bind = SUPER, m, exec, ~/.config/hypr/scripts/toggle_maximize.sh

# 窗口最小化
bind = SUPER, n, exec, ~/.config/hypr/scripts/window/minimize.sh
```

## 注意事项

- 脚本使用 `hyprctl` 命令与 Hyprland 通信，请确保 Hyprland 正在运行
- 脚本会在 `/tmp/hypr/clients/` 目录下创建临时文件，用于保存窗口状态
- 如需自定义临时文件路径，请修改脚本中的相关变量

## 故障排除

- 如果脚本执行失败，请检查是否安装了 `jq` 命令（用于解析 JSON 数据）
- 如果窗口状态恢复不正确，请检查临时文件是否存在且权限正确
- 如果快捷键无响应，请检查 `hyprland.conf` 中的键位绑定是否正确
