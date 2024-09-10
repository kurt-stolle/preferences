-- https://wezfurlong.org/wezterm/

local wez = require "wezterm"
local config = wez.config_builder()

config:set_strict_mode(true)

-- Utilities
local function get_apperance()
    return "Dark"
end
--[[  -- First check the COLOR_THEME environment variable
    if os.getenv("COLOR_THEME") then
        return os.getenv("COLOR_THEME")
    end
    -- Second check `wez.gui` (not available to the mux server)
    if wez.gui then
        return wez.gui.get_appearance()
    end
    -- Fallback to dark mode
    return "Dark"
end]]


-- OS specific configuration
local is_windows = wez.target_triple == "x86_64-pc-windows-msvc"
local is_light = get_apperance():lower():find "light"

if is_windows then
    config.default_prog       = { "pwsh.exe", "-NoLogo" }
    --config.default_domain = "WSL:Utils"
    --config.ssh_backend = "Ssh2" -- TODO check whether this is more stable than libssh
    config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
else
    config.window_decorations = "NONE"
    config.integrated_title_button_style = "Gnome"
    config.default_prog = { os.getenv("SHELL") or "bash" }
end

-- Appearance
-- "iTerm2 Tango Dark" or "iTerm2 Tango Light" also work well for some themes
local theme = wez.color.get_builtin_schemes()[is_light and "Catppuccin Latte" or "Catppuccin Mocha"]
assert(theme, "Color scheme not found")
if is_light then
    config.window_background_opacity = 1.0
    -- config.foreground_text_hsb = {
    --     hue = 1.0,
    --     saturation = 1.2,
    --     brightness = 0.8,
    -- }
else
    if is_windows then
        config.win32_system_backdrop = "Mica"
        config.window_background_opacity = 0.2
        theme.background = "#000000"
    else
        config.window_background_opacity = 1.0
    end
    -- config.foreground_text_hsb = {
    --     hue = 1.0,
    --     saturation = 1.2,
    --     brightness = 1.5,
    -- }
    --
    theme.tab_bar = {
        background = theme.background,
        inactive_tab_edge = 'rgba(28, 28, 28, 0.9)',
        active_tab = {
            bg_color = theme.background,
            fg_color = '#c0c0c0',
        },
        inactive_tab = {
            bg_color = theme.background,
            fg_color = '#808080',
        },
        inactive_tab_hover = {
            bg_color = theme.background,
            fg_color = '#808080',
        },
    }
end
config.command_palette_font_size = 12.0
config.command_palette_bg_color  = '#000000'
config.color_schemes             = {
    ["User"] = theme
}
config.color_scheme              = "User"

-- Misc
config.enable_wayland            = false
--config.canonicalize_pasted_newlines               = 'None'
--config.term                                       = 'wezterm'
config.font                      = wez.font("JetBrainsMono Nerd Font", { weight = 400 })
config.font_size                 = 10.0
config.default_cursor_style      = "BlinkingBar"

-- Support KITTY features
config.enable_kitty_graphics     = true
--config.enable_kitty_keyboard                      = true

-- Window
--config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = "NeverPrompt"
--[[config.window_padding                             = {
    left = 1,
    right = 1,
    top = 1,
    bottom = 1,
}]]
--config.window_frame                               = {
--    font_size = is_windows and 12.0 or 14.0,
--    active_titlebar_bg = theme.background,
--    inactive_titlebar_bg = theme.background,
--}
-- Tab bar
config.enable_tab_bar               = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar            = false

-- Launch menu
config.launch_menu                  = {}

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

for _, spec in ipairs { DISCRETE_GPU, INTEGRATED_GPU, DISCRETE_GPU } do
    local gpu = find_gpu(spec)
    if gpu then
        config.webgpu_preferred_adapter = gpu
        break
    end
end
--config.webgpu_power_preference = "HighPerformance"
config.max_fps = 120
config.front_end = "OpenGL"
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
return config
