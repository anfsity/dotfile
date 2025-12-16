#!/usr/bin/env bash

# ================= 你的实测坐标 =================
# ydotool socket 路径
export YDOTOOL_SOCKET="$HOME/.ydotool_socket"

# 1. 暂停键
POS_PAUSE="3089 59"

# 2. 倍速键
POS_SPEED="2970 67"

# 3. 技能图标
POS_SKILL="2696 517"

# 4. 撤退图标 (兼确认键)
POS_RETREAT_ICON="2355 250"

# 5. 部署终点 (划火柴把你鼠标拖到的位置)
# 默认拖到屏幕中间偏下，方便你接手调整方向
POS_DEPLOY_END="2600 550"

# ================= 逻辑区域 =================

get_cur_pos() { hyprctl cursorpos | tr -d ' '; }

click_pos() {
    local target=$1
    local tx=$(echo $target | awk '{print $1}')
    local ty=$(echo $target | awk '{print $2}')
    local cur=$(get_cur_pos); local cx=${cur%,*}; local cy=${cur#*,}
    ydotool mousemove --absolute -x "$tx" -y "$ty"
    ydotool click 0xC0
    ydotool mousemove --absolute -x "$cx" -y "$cy"
}

action=$1

case "$action" in
    # --- 基础功能 ---
    "pause"|"pause_space") click_pos "$POS_PAUSE" ;;
    "speed") click_pos "$POS_SPEED" ;;
    "step_12ms") click_pos "$POS_PAUSE"; sleep 0.012; click_pos "$POS_PAUSE" ;;
    "step_33ms") click_pos "$POS_PAUSE"; sleep 0.033; click_pos "$POS_PAUSE" ;;
    "step_166ms") click_pos "$POS_PAUSE"; sleep 0.166; click_pos "$POS_PAUSE" ;;

    # --- 🔥 0帧部署 / 划火柴 (右键) ---
    # 场景：暂停状态下，鼠标指着干员列表里的干员
    # 逻辑：解暂停 -> 按下左键拖出 -> 再次暂停 -> (脚本结束，你手里正拽着干员，游戏是暂停的)
    "matchstick")
        cur=$(get_cur_pos); cx=${cur%,*}; cy=${cur#*,}
        ex=$(echo $POS_DEPLOY_END | awk '{print $1}')
        ey=$(echo $POS_DEPLOY_END | awk '{print $2}')

        # 1. 解除暂停 (让游戏动起来以便拖拽)
        click_pos "$POS_PAUSE"
        
        # 2. 瞬间按下左键并拖拽
        ydotool click 0x40 # 按下
        sleep 0.02         # 极短延迟让游戏识别拖拽
        ydotool mousemove --absolute -x "$ex" -y "$ey"
        
        # 3. 立刻暂停 (卡住时间)
        click_pos "$POS_PAUSE"
        
        # 4. 松开左键 (干员落下)
        # 注意：这里松开后，游戏是暂停的，干员处于“落地未结算”状态
        # 你可以这时候手动再点一下干员调整方向，或者解暂停让他落地
        ydotool click 0x80
        
        # 5. 归位
        ydotool mousemove --absolute -x "$cx" -y "$cy"
        ;;

    # --- 🔥 0帧撤退 (侧键上/前进) ---
    # 场景：暂停状态下，鼠标指着场上干员
    "retreat_0frame")
        # 1. 选中干员
        ydotool click 0xC0
        sleep 0.02
        # 2. 点击撤退
        click_pos "$POS_RETREAT_ICON"
        sleep 0.02
        # 3. 确认撤退
        click_pos "$POS_RETREAT_ICON"
        # 结果：游戏依然暂停，但撤退指令已下达，解暂停瞬间消失
        ;;

    # --- 🔥 0帧技能 (侧键下/后退) ---
    # 场景：暂停状态下，鼠标指着场上干员
    "skill_0frame")
        # 1. 选中干员
        ydotool click 0xC0
        sleep 0.02
        # 2. 点击技能
        click_pos "$POS_SKILL"
        # 结果：游戏依然暂停，技能预开启，解暂停瞬间释放
        ;;

    # --- 其他常规操作 ---
    "instant_retreat") # Q: 运行中一键撤退
        ydotool click 0xC0; sleep 0.05
        click_pos "$POS_RETREAT_ICON"; sleep 0.05; click_pos "$POS_RETREAT_ICON"
        ;;
    "instant_skill") # E: 运行中一键技能
        ydotool click 0xC0; sleep 0.05; click_pos "$POS_SKILL"
        ;;
    "manual_retreat") click_pos "$POS_RETREAT_ICON" ;;
    "manual_skill") click_pos "$POS_SKILL" ;;
    "loop_pause") click_pos "$POS_PAUSE"; sleep 0.1; click_pos "$POS_PAUSE" ;;
    "view_switch"|"bullet_time") click_pos "$POS_PAUSE" ;;
esac
