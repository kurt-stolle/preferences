local wezterm = require 'wezterm'
local config = {}

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function get_appearance()
    if wezterm.gui then
        return wezterm.gui.get_appearance()
    end
    return 'Dark'
end

function scheme_for_appearance(appearance)
    if appearance:find 'Dark' then
        return 'Builtin Dark'
    else
        return 'Builtin Light'
    end
end

config.color_scheme = scheme_for_appearance(get_appearance())
config.font = wezterm.font 'JetBrainsMono Nerd Font'
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

-- OS specific configuration
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    config.default_prog = { "pwsh.exe", "-NoLogo" }

    -- Launch options
    table.insert(config.launch_menu, { label = "Powershell", args = { "pwsh.exe", "-NoLogo" } })

    config.win32_system_backdrop = "Mica"
    config.window_background_opacity= 0

else
    config.default_prog = { "bash" }

    -- Launch options
    table.insert(config.launch_menu, { label = "Bash", args = { "bash" } })
end

-- Rendering
for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
  if gpu.backend == 'Vulkan' and gpu.device_type == 'DiscreteGpu' then
    config.webgpu_preferred_adapter = gpu
    config.front_end = 'WebGpu'
    break
  end
end


return config
