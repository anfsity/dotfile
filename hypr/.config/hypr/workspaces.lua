-- Bind workspaces 1-10 (group 1) to primary monitor
for i = 1, 9 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1", default = true })
end
hl.workspace_rule({ workspace = "0", monitor = "eDP-1", default = true })

-- Bind workspaces 11-20 (group 2) to secondary monitor
for i = 11, 20 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1", default = true })
end
