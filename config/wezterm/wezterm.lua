-- Wez's Terminal Emulator
-- https://wezfurlong.org/wezterm/

local wez = require 'wezterm'
local config = wez.config_builder()

config:set_strict_mode(true)

local function get_appearance()
    -- First check `wez.gui` (not available to the mux server)
    if wez.gui then
        return wez.gui.get_appearance()
    end
    -- Second, check the COLOR_THEME environment variable
    if os.getenv('COLOR_THEME') then
        return os.getenv('COLOR_THEME')
    end
    -- Fallback to dark mode
    return 'Dark'
end

-- Appearance

if get_appearance():lower():find 'light' then
    --config.win32_system_backdrop = "Mica"
    config.color_scheme = 'Catppuccin Latte'-- 'iTerm2 Tango Light'
    config.window_background_opacity = 1.0
    config.foreground_text_hsb = {
        hue = 1.0,
        saturation = 1.2,
        brightness = 0.8,
    }
else
    local theme = wez.color.get_builtin_schemes()["Catppuccin Mocha"]
    theme.background = "#000000"
    --custom.tab_bar.background = "#040404"
    --custom.tab_bar.inactive_tab.bg_color = "#0f0f0f"
    --custom.tab_bar.new_tab.bg_color = "#080808"

    config.win32_system_backdrop = 'Acrylic'
    config.color_schemes = {
        ["Catppuccin Mocha Dark"] = theme
    }
    config.color_scheme = 'Catppuccin Mocha Dark'-- 'iTerm2 Tango Dark'
    config.window_background_opacity = 1.0--0.2
    config.foreground_text_hsb = {
        hue = 1.0,
        saturation = 1.2,
        brightness = 1.5,
    }
end
config.font = wez.font('JetBrainsMono Nerd Font', { weight = 500 })
config.font_size = 10.0
config.default_cursor_style = 'BlinkingBar'
config.enable_kitty_graphics = true
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}
config.hide_tab_bar_if_only_one_tab = false
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- Launch menu
config.launch_menu = {}

-- Rendering
local function find_gpu(spec)
	for _, gpu in ipairs(wez.gui.enumerate_gpus()) do
	    if gpu.backend:find (spec.backend) and gpu.device_type:find (spec.device_type) then
		return gpu
	    end
	end
	return nil
end

for _, spec in ipairs {{backend="Vulkan", device_type="IntegratedGpu"}, {backend="Vulkan", device_type="DiscreteGpu"}} do
	local gpu = find_gpu( spec)
	if gpu then
		config.webgpu_preferred_adapter = gpu
		break
	end
end

config.max_fps = 60
config.front_end = 'WebGpu'
config.webgpu_power_preference = "HighPerformance"


-- Keybindings
config.disable_default_key_bindings = true
config.keys = {
    -- Show launcher
    {
        key = 'Space',
        mods = 'CTRL|SHIFT',
        action = wez.action.ShowLauncherArgs {
            flags = 'LAUNCH_MENU_ITEMS|DOMAINS|WORKSPACES',
        }
    },
    -- Show tab switcher
    {
        key = 'Tab',
        mods = 'CTRL|SHIFT',
        action = wez.action.ShowTabNavigator,
    },
    -- Show command palette
    {
        key = 'Space',
        mods = 'CTRL',
        action = wez.action.ActivateCommandPalette,
    },
    -- Copy/Paste
    { key = 'C', mods = 'CTRL|SHIFT', action = wez.action.CopyTo 'Clipboard' },
    { key = 'V', mods = 'CTRL|SHIFT', action = wez.action.PasteFrom 'Clipboard' },

}
config.mouse_bindings = {
    {
        event = { Down = { streak = 3, button = 'Left' } },
        action = wez.action.SelectTextAtMouseCursor 'SemanticZone',
        mods = 'NONE',
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
-- OS specific configuration
if wez.target_triple == "x86_64-pc-windows-msvc" then
    config.default_prog = { "pwsh.exe", "-NoLogo" }
    -- config.default_domain = 'WSL:Utils'
else
    config.default_prog = { "bash" }
end

return config
