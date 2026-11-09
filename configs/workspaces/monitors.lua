-- Per-monitor workspace layout. Merge this into the
-- `-- sine's config start --` ... `-- sine's config end --` block in
-- ~/.config/hypr/monitors.lua. That file is required early, before the
-- workspace keybinds and before config.reloaded fires.
--
-- Hyprland workspace IDs are global, so each monitor gets a contiguous range
-- and the bar shows those IDs. Edit the counts here; the order decides the
-- ranges. Add another row for a third or fourth monitor.
--
-- For example, 6 on the laptop and 12 on the external gives eDP-1 1-6 and
-- HDMI-A-1 7-18.
local workspace_layout = {
  { monitor = "eDP-1", count = 3 },
  { monitor = "HDMI-A-1", count = 6 },
}

local next_workspace = 1
for _, entry in ipairs(workspace_layout) do
  for slot = 1, entry.count do
    hl.workspace_rule({
      workspace = tostring(next_workspace),
      monitor = entry.monitor,
      default = slot == 1,
      persistent = true,
    })
    next_workspace = next_workspace + 1
  end
end

-- Omarchy 4.5's monitor-workspaces.lua renumbers occupied workspaces into fixed
-- 10-slot blocks on reload and monitor changes (4 becomes 14). The layout above
-- is authoritative, so stop it before it can reconcile.
if o.workspaces then
  o.workspaces.reconcile = function() end
end
