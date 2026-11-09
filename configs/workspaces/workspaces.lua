-- Global workspace keybinds. Merge this into the
-- `-- sine's config start --` ... `-- sine's config end --` block in
-- ~/.config/hypr/workspaces.lua.
--
-- The layout itself (monitor -> workspace count, and the global IDs) lives in
-- hypr/monitors.lua. These binds use the global IDs, matching the numbers the
-- bar shows.

-- Omarchy 4.5's default binds call o.workspaces.focus(), which resolves a
-- number against Omarchy's own 10-slot block. Rebind them to the plain global
-- IDs.
--
-- Only ten number keys exist, so this covers workspace IDs 1-10. If your layout
-- goes above 10, those workspaces stay clickable on the bar; add explicit binds
-- if you want keyboard access to them.
for workspace = 1, 10 do
  local key = "SUPER + code:" .. tostring(workspace + 9)
  local id = tostring(workspace)

  o.rebind(key, "Switch to workspace " .. workspace,
    hl.dsp.focus({ workspace = id }))
  o.rebind("SUPER + SHIFT + code:" .. tostring(workspace + 9),
    "Move window to workspace " .. workspace,
    hl.dsp.window.move({ workspace = id, follow = true }))
  o.rebind("SUPER + SHIFT + ALT + code:" .. tostring(workspace + 9),
    "Move window silently to workspace " .. workspace,
    hl.dsp.window.move({ workspace = id, follow = false }))
end
