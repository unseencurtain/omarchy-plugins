-- Terminal glass (Ghostty only). Copy to ~/.config/hypr/terminal-glass.lua and
-- require it from ~/.config/hypr/hyprland.lua AFTER
-- require("default.hypr.toggles"):
--
--   require("default.hypr.toggles")
--   require("hypr.terminal-glass")
--
-- The position matters: Omarchy's glassy mode writes its own blur values from
-- the toggles, so this module has to run after them to win. The rest of the
-- look and feel stays in ~/.config/hypr/looknfeel.lua, required with the other
-- standard user modules at the top of hyprland.lua.
--
-- Hyprland owns the 0.75 window opacity and the blur; Ghostty keeps its own
-- background opaque (see glass.conf in this directory).
hl.window_rule({
  match = { class = "com\\.mitchellh\\.ghostty" },
  -- Fades the whole window, text included, exactly like before the update.
  opacity = "0.75 override 0.75 override",
})

hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = 2,
      passes = 2,
      ignore_opacity = true,
      popups = true,
      popups_ignorealpha = 0.2,
      -- Reset everything Omarchy's glass.lua adds, so the colour stays plain
      -- (no reddish vibrancy or darkening) whichever mode is active.
      new_optimizations = true,
      xray = false,
      contrast = 1.0,
      brightness = 1.0,
      noise = 0.0,
      vibrancy = 0.0,
      vibrancy_darkness = 0.0,
      special = false,
    },
  },
})
