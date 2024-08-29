-- https://wezfurlong.org/wezterm/

local wez = require "wezterm"
local config = wez.config_builder()

config:set_strict_mode(true)

local function get_appearance()
    -- First check the COLOR_THEME environment variable
    if os.getenv("COLOR_THEME") then
        return os.getenv("COLOR_THEME")
    end
    -- Second check `wez.gui` (not available to the mux server)
    if wez.gui then
        return wez.gui.get_appearance()
    end
    -- Fallback to dark mode
    return "Dark"
end

-- Appearance

if get_appearance():lower():find "light" then
    --config.win32_system_backdrop = "Mica"
    config.color_scheme = "Catppuccin Latte" -- "iTerm2 Tango Light"
    config.window_background_opacity = 1.0
    -- config.foreground_text_hsb = {
    --     hue = 1.0,
    --     saturation = 1.2,
    --     brightness = 0.8,
    -- }
else
    local theme = wez.color.get_builtin_schemes()["Catppuccin Mocha"]
    --theme.background = "#000000"
    --theme.tab_bar.background = "#040404"
    --theme.tab_bar.inactive_tab.bg_color = "#000000"
    --theme.tab_bar.new_tab.bg_color = "#080808"

    config.color_schemes = {
        ["Catppuccin Mocha Dark"] = theme
    }
    config.color_scheme = "Catppuccin Mocha Dark" -- "iTerm2 Tango Dark"
    -- config.foreground_text_hsb = {
    --     hue = 1.0,
    --     saturation = 1.2,
    --     brightness = 1.5,
    -- }
end
config.font = wez.font("JetBrainsMono Nerd Font", { weight = 400 })
config.font_size = 10.0
config.default_cursor_style = "BlinkingBar"
config.enable_kitty_graphics = true
config.window_padding = {
    left = 2,
    right = 2,
    top = 2,
    bottom = 2,
}
config.hide_tab_bar_if_only_one_tab = false
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- Launch menu
config.launch_menu = {}

-- Rendering
local function find_gpu(spec)
    for _, gpu in ipairs(wez.gui.enumerate_gpus()) do
        if gpu.backend:find(spec.backend) and gpu.device_type:find(spec.device_type) then
            return gpu
        end
    end
    return nil
end

INTEGRATED_GPU = { backend = "Vulkan", device_type = "IntegratedGpu" }
DISCRETE_GPU = { backend = "Vulkan", device_type = "DiscreteGpu" }

for _, spec in ipairs { INTEGRATED_GPU, DISCRETE_GPU } do
    local gpu = find_gpu(spec)
    if gpu then
        config.webgpu_preferred_adapter = gpu
        break
    end
end
config.front_end = "WebGpu"
--config.webgpu_power_preference = "HighPerformance"
--config.max_fps = 120

-- Bindings
config.mouse_bindings = {
    {
        event = { Down = { streak = 3, button = "Left" } },
        action = wez.action.SelectTextAtMouseCursor "SemanticZone",
        mods = "NONE",
    },
    {
        event = { Down = { streak = 1, button = "Right" } },
        mods = "NONE",
        action = wez.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ""
            if has_selection then
                window:perform_action(wez.action.CopyTo("ClipboardAndPrimarySelection"), pane)
                window:perform_action(wez.action.ClearSelection, pane)
            else
                window:perform_action(wez.action({ PasteFrom = "Clipboard" }), pane)
            end
        end),
    },
}

config.leader = { key = "b", mods = "CTRL" }
config.disable_default_key_bindings = true
config.keys = {
    -- Passthrough double LEADER (CTRL-B)
    { key = config.leader.key, mods = "LEADER|CTRL",  action = wez.action.SendString("\x02") },
    -- Copy/Paste
    { key = "c",               mods = "CTRL|SHIFT",   action = wez.action.CopyTo "Clipboard" },
    { key = "v",               mods = "CTRL|SHIFT",   action = wez.action.PasteFrom "Clipboard" },
    -- Show launcher
    { key = "c",               mods = "LEADER|CTRL",  action = wez.action.ShowLauncherArgs { flags = "LAUNCH_MENU_ITEMS|DOMAINS|WORKSPACES", } },
    -- Show tab switcher
    { key = "Tab",             mods = "LEADER",       action = wez.action.ShowTabNavigator },
    -- Show command palette
    { key = "Space",           mods = "LEADER",       action = wez.action.ActivateCommandPalette },
    -- Tmux-like Keybindings
    -- https://gist.github.com/quangIO/556fa4abca46faf40092282d0c11a367
    { key = "\"",              mods = "LEADER|SHIFT", action = wez.action { SplitVertical = { domain = "CurrentPaneDomain" } } },
    { key = "%",               mods = "LEADER|SHIFT", action = wez.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
    { key = "z",               mods = "LEADER",       action = "TogglePaneZoomState" },
    { key = "c",               mods = "LEADER",       action = wez.action { SpawnTab = "CurrentPaneDomain" } },
    { key = "h",               mods = "LEADER",       action = wez.action { ActivatePaneDirection = "Left" } },
    { key = "j",               mods = "LEADER",       action = wez.action { ActivatePaneDirection = "Down" } },
    { key = "k",               mods = "LEADER",       action = wez.action { ActivatePaneDirection = "Up" } },
    { key = "l",               mods = "LEADER",       action = wez.action { ActivatePaneDirection = "Right" } },
    { key = "H",               mods = "LEADER|SHIFT", action = wez.action { AdjustPaneSize = { "Left", 5 } } },
    { key = "J",               mods = "LEADER|SHIFT", action = wez.action { AdjustPaneSize = { "Down", 5 } } },
    { key = "K",               mods = "LEADER|SHIFT", action = wez.action { AdjustPaneSize = { "Up", 5 } } },
    { key = "L",               mods = "LEADER|SHIFT", action = wez.action { AdjustPaneSize = { "Right", 5 } } },
    { key = "1",               mods = "LEADER",       action = wez.action { ActivateTab = 0 } },
    { key = "2",               mods = "LEADER",       action = wez.action { ActivateTab = 1 } },
    { key = "3",               mods = "LEADER",       action = wez.action { ActivateTab = 2 } },
    { key = "4",               mods = "LEADER",       action = wez.action { ActivateTab = 3 } },
    { key = "5",               mods = "LEADER",       action = wez.action { ActivateTab = 4 } },
    { key = "6",               mods = "LEADER",       action = wez.action { ActivateTab = 5 } },
    { key = "7",               mods = "LEADER",       action = wez.action { ActivateTab = 6 } },
    { key = "8",               mods = "LEADER",       action = wez.action { ActivateTab = 7 } },
    { key = "9",               mods = "LEADER",       action = wez.action { ActivateTab = 8 } },
    { key = "&",               mods = "LEADER|SHIFT", action = wez.action { CloseCurrentTab = { confirm = true } } },
    { key = "x",               mods = "LEADER",       action = wez.action { CloseCurrentPane = { confirm = true } } },

}
-- OS specific configuration
local is_windows = wez.target_triple == "x86_64-pc-windows-msvc"

if is_windows then
    config.default_prog = { "pwsh.exe", "-NoLogo" }
    --config.default_domain = "WSL:Utils"
    --config.ssh_backend = "Ssh2" -- TODO check whether this is more stable than libssh
    config.win32_system_backdrop = "Mica" -- "Mica" -- "Mica"
    config.window_background_opacity = 0.2        --0.2
else
    config.default_prog = { "bash" }
end

return config
