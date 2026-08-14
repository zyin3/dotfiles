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

-- Dim unfocused windows so the focused one is obvious at a glance.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

-- get_config_overrides() hands back a copy, so the current value is never the
-- same table we last stored; compare the fields instead of the identity.
local function same_text_hsb(actual, expected)
	if actual == nil or expected == nil then
		return actual == expected
	end
	return actual.hue == expected.hue
		and actual.saturation == expected.saturation
		and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}
	local text_hsb, opacity
	if not window:is_focused() then
		text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
		opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
	end

	-- Only write when one of the two values we own actually changes; a redundant
	-- set_config_overrides() call would trigger another config reload.
	if same_text_hsb(overrides.foreground_text_hsb, text_hsb) and overrides.window_background_opacity == opacity then
		return
	end

	overrides.foreground_text_hsb = text_hsb
	overrides.window_background_opacity = opacity
	window:set_config_overrides(overrides)
end)

-- Make Option a Meta key: Opt+<key> sends ESC+<key> instead of composing a
-- special character. This gives all readline word bindings (Opt+B/F back/forward
-- a word, Opt+D delete-word, etc.) for free in shells and Claude Code.
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.keys = {
	-- Opt+Enter: send Meta-Enter (ESC + CR) to the pane instead of WezTerm's
	-- default ToggleFullScreen, so apps like Claude Code get a newline signal.
	{ key = "Enter", mods = "OPT", action = wezterm.action.SendString("\x1b\r") },
	-- Cmd+Enter: toggle fullscreen (replaces the default Opt+Enter binding above).
	{ key = "Enter", mods = "CMD", action = wezterm.action.ToggleFullScreen },
}

return config
