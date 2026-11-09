-- Monitor-local workspace keybinds. Merge this into the
-- `-- sine's config start --` ... `-- sine's config end --` block in
-- ~/.config/hypr/workspaces.lua.
--
-- The layout itself (monitor -> workspace count, and the global IDs) lives in
-- hypr/monitors.lua. These binds resolve a slot against the focused monitor,
-- so Super+1 is the first workspace on whichever monitor is focused. That
-- matches the numbers the bar shows.

local function workspace_id(slot)
  local monitor = hl.get_active_monitor()
  if not monitor or not o.workspace_id then
    return nil
  end

  return o.workspace_id(monitor.name, slot)
end

local function focus_slot(slot)
  return function()
    local id = workspace_id(slot)
    if id then
      hl.dispatch(hl.dsp.focus({ workspace = tostring(id) }))
    end
  end
end

local function move_window_to_slot(slot, follow)
  return function()
    local id = workspace_id(slot)
    if id then
      hl.dispatch(hl.dsp.window.move({ workspace = tostring(id), follow = follow }))
    end
  end
end

-- Omarchy 4.5's default binds call o.workspaces.focus(), which resolves a
-- number against Omarchy's own 10-slot block. Rebind them to our layout.
-- Slots above 10 stay clickable on the bar; add explicit binds if you need
-- keyboard access to them.
for slot = 1, 10 do
  local key = "SUPER + code:" .. tostring(slot + 9)

  o.rebind(key, "Switch to workspace " .. slot, focus_slot(slot))
  o.rebind("SUPER + SHIFT + code:" .. tostring(slot + 9),
    "Move window to workspace " .. slot, move_window_to_slot(slot, true))
  o.rebind("SUPER + SHIFT + ALT + code:" .. tostring(slot + 9),
    "Move window silently to workspace " .. slot, move_window_to_slot(slot, false))
end
