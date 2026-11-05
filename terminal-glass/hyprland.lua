-- >>> terminal-glass (managed by omarchy-plugins/terminal-glass) >>>
-- Exact pre-update terminal glass. This block is re-applied to the end of
-- ~/.config/hypr/hyprland.lua by ~/.config/omarchy/terminal-glass/apply.sh,
-- so no Omarchy transparency/glassy toggle can override it.
hl.window_rule({
  match = { class = "com\\.mitchellh\\.ghostty" },
  -- Fades the whole window, text included, exactly like before the update.
  opacity = "0.75 override 0.75 override",
})
-- Only the terminal is glassy. "Glassy Windows" mode fades Nautilus to 0.75;
-- this keeps every other app solid.
hl.window_rule({
  match = { class = "org\\.gnome\\.Nautilus" },
  opacity = "1 override 1 override",
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
      -- Reset everything Omarchy's glass.lua adds, so the colour is exactly
      -- as it was before the update (no reddish vibrancy / darkening).
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
-- <<< terminal-glass (managed by omarchy-plugins/terminal-glass) <<<
