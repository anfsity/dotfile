-- Smart multi-monitor workspace switching
-- Since we can't edit the rice's hyprland/keybinds.lua, we unbind and override here

local numberkeys = {10,11,12,13,14,15,16,17,18,19}
local numpadkeys = {87,88,89,83,84,85,79,80,81,90}
local workspaceTargets = {1,2,3,4,5,6,7,8,9,10}
local function smartWorkspaceAction(dispatcher, target)
    return hl.dsp.exec_cmd(string.format(
        "bash -lc 'curr=$(hyprctl activeworkspace -j | jq -r \".id\"); if ! [[ \"$curr\" =~ ^-?[0-9]+$ ]]; then exit 1; fi; if (( curr <= 0 )); then curr=1; fi; target=$((((curr - 1) / 10) * 10 + %d)); if [[ \"%s\" == \"workspace\" ]]; then hyprctl dispatch \"hl.dsp.focus({ workspace = $target })\"; elif [[ \"%s\" == \"movetoworkspacesilent\" ]]; then hyprctl dispatch \"hl.dsp.window.move({ workspace = $target, follow = false })\"; else exit 1; fi'",
        target
        ,
        dispatcher,
        dispatcher
    ))
end

for i = 1, 10 do
    local focusKeys = {
        "SUPER + code:" .. numberkeys[i],
        "SUPER + code:" .. numpadkeys[i],
    }
    local moveKeys = {
        "SUPER + ALT + code:" .. numberkeys[i],
        "SUPER + ALT + code:" .. numpadkeys[i],
    }
    local target = workspaceTargets[i]

    for _, key in ipairs(focusKeys) do
        hl.unbind(key)
        hl.bind(key, smartWorkspaceAction("workspace", target))
    end

    for _, key in ipairs(moveKeys) do
        hl.unbind(key)
        hl.bind(key, smartWorkspaceAction("movetoworkspacesilent", target))
    end
end

-- Your other custom binds
hl.bind("CTRL + SUPER + Slash", hl.dsp.exec_cmd("xdg-open ~/.config/illogical-impulse/config.json"), {description = "Edit shell config"} )
hl.bind("CTRL + SUPER + ALT + Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )
