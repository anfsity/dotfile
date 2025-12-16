#!/usr/bin/env bash

# === 配置区域 ===
# 屏幕分辨率 (Waydroid 内部分辨率)
# 如果你是 2560x1440 的屏幕但 Waydroid 锁了 1080P，保持 1920 1080
WIDTH=2560
HEIGHT=1440
SOCKET="$HOME/.ydotool_socket"

export YDOTOOL_SOCKET="$SOCKET"

# === 坐标计算函数 ===
# 使用 LC_ALL=C 防止不同语言环境下小数点解析错误
get_x() { echo "$1 * $WIDTH" | LC_ALL=C bc | cut -d. -f1; }
get_y() { echo "$1 * $HEIGHT" | LC_ALL=C bc | cut -d. -f1; }

# 获取当前鼠标位置 (去除空格)
get_cur_pos() { hyprctl cursorpos | tr -d ' '; }

# === 基础动作封装 ===
click_at() {
    # 1. 保存当前鼠标位置 (用于归位)
    local cur=$(get_cur_pos)
    local cx=${cur%,*}
    local cy=${cur#*,}
    
    # 2. 移动并点击
    ydotool mousemove --absolute -x $1 -y $2
    ydotool click 0xC0 # 左键单击 (按下+松开)
    
    # 3. 瞬间归位
    ydotool mousemove --absolute -x $cx -y $cy
}

# 预计算常用坐标 (减少运行时计算延迟)
PAUSE_X=$(get_x 0.93)
PAUSE_Y=$(get_y 0.07)

# === 核心逻辑实现 ===
action=$1

case "$action" in
    # --- 基础功能 ---
    "pause") # 对应 JSON: Space (0.93, 0.07)
        click_at $PAUSE_X $PAUSE_Y
        ;;
    "speed") # 对应 JSON: D (0.86, 0.07)
        click_at $(get_x 0.86) $(get_y 0.07)
        ;;
    "bullet_time") # 对应 JSON: Z (0.96, 0.90)
        click_at $(get_x 0.96) $(get_y 0.90)
        ;;
    
    # --- 时间控制 (高难核心) ---
    "step_12ms") # 对应 JSON: R (前进12ms)
        click_at $PAUSE_X $PAUSE_Y # 解除暂停
        sleep 0.012                # 等待 12ms
        click_at $PAUSE_X $PAUSE_Y # 再次暂停
        ;;
    "step_33ms") # 对应 JSON: T (前进33ms)
        click_at $PAUSE_X $PAUSE_Y
        sleep 0.033
        click_at $PAUSE_X $PAUSE_Y
        ;;
    "step_166ms") # 对应 JSON: Y (前进166ms)
        click_at $PAUSE_X $PAUSE_Y
        sleep 0.166
        click_at $PAUSE_X $PAUSE_Y
        ;;

    # --- 撤退与技能 ---
    "instant_retreat") # 对应 JSON: Q (一键撤退)
        # 逻辑：点击当前选中干员 -> 点撤退图标 -> 点红色确认
        ydotool click 0xC0 # 点击当前鼠标位置
        sleep 0.05
        # 点击撤退图标 (JSON: 0.13, 0.08)
        click_at $(get_x 0.13) $(get_y 0.08)
        sleep 0.05
        # 点击确认撤退 (右侧红色按钮)
        # ⚠️注意：如果实战中点不到确认，请微调下面这个坐标
        click_at $(get_x 0.73) $(get_y 0.65)
        ;;
    
    "instant_skill") # 对应 JSON: E (一键技能)
        ydotool click 0xC0 
        sleep 0.05
        # 点击技能图标 (JSON: 0.23, 0.08)
        click_at $(get_x 0.23) $(get_y 0.08)
        ;;

    "manual_retreat") # 对应 JSON: A (手动撤退)
        # 假设你已经点开了干员面板，直接点撤退图标
        click_at $(get_x 0.13) $(get_y 0.08)
        ;;

    "manual_skill") # 对应 JSON: S (手动技能)
        click_at $(get_x 0.65) $(get_y 0.55)
        ;;

    # --- 特殊操作 ---
    "matchstick") # 对应 JSON: 右键/划火柴
        # 逻辑：从干员列表区 (0.86, 0.2) 向右下拖拽
        
        # 1. 记录位置
        local cur=$(get_cur_pos)
        local cx=${cur%,*}
        local cy=${cur#*,}
        
        # 2. 移动到起始点
        ydotool mousemove --absolute -x $(get_x 0.86) -y $(get_y 0.2)
        
        # 3. 执行拖拽 (0帧子弹时间核心)
        ydotool click 0x40 # 按下左键
        sleep 0.02         # 极短延迟
        ydotool mousemove --absolute -x $(get_x 0.95) -y $(get_y 0.5)
        sleep 0.02
        ydotool click 0x80 # 松开左键
        
        # 4. 归位
        ydotool mousemove --absolute -x $cx -y $cy
        ;;
        
    "view_switch") # 对应 JSON: Tab (0.33, 0.56)
        click_at $(get_x 0.33) $(get_y 0.56)
        ;;

    "pause_select") # 对应 JSON: W (0.94, 0.2)
        click_at $(get_x 0.94) $(get_y 0.2)
        ;;
        
    "loop_pause") # 对应 JSON: C (连点暂停)
        click_at $PAUSE_X $PAUSE_Y
        sleep 0.1
        click_at $PAUSE_X $PAUSE_Y
        ;;
esac
