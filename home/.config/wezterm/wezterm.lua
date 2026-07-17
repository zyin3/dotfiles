local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
-- Hack Nerd Font has no CJK glyphs; fall back to Hiragino Sans GB (ships with
-- macOS) so Chinese text like "获取指定产品的当前值班人" renders correctly.
config.font = wezterm.font_with_fallback({
	"Hack Nerd Font",
	"Hiragino Sans GB",
})
config.font_size = 14.0
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

config.keys = {
	-- Opt+B: send Meta-b (ESC b) so shells/Claude Code move back one word.
	{ key = "b", mods = "OPT", action = wezterm.action.SendString("\x1bb") },
	-- Opt+F: send Meta-f (ESC f) to move forward one word.
	{ key = "f", mods = "OPT", action = wezterm.action.SendString("\x1bf") },
	-- Opt+D: send Meta-d (ESC d) to delete the word ahead of the cursor.
	{ key = "d", mods = "OPT", action = wezterm.action.SendString("\x1bd") },
}

return config
