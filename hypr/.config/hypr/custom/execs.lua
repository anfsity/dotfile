hl.on("hyprland.start", function()
    -- Input method
    hl.exec_cmd("fcitx5")

    -- Network
    hl.exec_cmd("clash-verge --hide")

    -- Core components
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1 || /usr/libexec/polkit-kde-authentication-agent-1  || /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 || /usr/libexec/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("nm-applet --indicator")
end)
