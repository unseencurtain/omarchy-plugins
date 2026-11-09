-- Per-monitor workspace layout. Merge this into the
-- `-- sine's config start --` ... `-- sine's config end --` block in
-- ~/.config/hypr/monitors.lua. That file is required early, before the
-- workspace keybinds and before config.reloaded fires.
--
-- Hyprland workspace IDs are global, so each monitor gets a contiguous range.
-- The bar labels each monitor's own range 1..count. Edit the counts here; the
-- order decides the ranges. Add another row for a third or fourth monitor.
--
-- For example, 6 on the laptop and 12 on the external gives eDP-1 1-6 and
-- HDMI-A-1 7-18, labelled 1-6 and 1-12 on their respective bars.
local workspace_layout = {
  { monitor = "eDP-1", count = 3 },
  { monitor = "HDMI-A-1", count = 6 },
}

local workspace_ranges = {}
local next_workspace = 1
for _, entry in ipairs(workspace_layout) do
  workspace_ranges[entry.monitor] = {
    first = next_workspace,
    count = entry.count,
  }

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

-- Resolve a monitor-local slot (1..count) to the global Hyprland workspace ID.
-- hypr/workspaces.lua uses this so Super+1 means slot 1 on the focused monitor.
function o.workspace_id(monitor_name, slot)
  local range = workspace_ranges[monitor_name]
  if not range or slot < 1 or slot > range.count then
    return nil
  end

  return range.first + slot - 1
end

-- Omarchy 4.5's monitor-workspaces.lua renumbers occupied workspaces into fixed
-- 10-slot blocks on reload and monitor changes (4 becomes 14). The layout above
-- is authoritative, so stop it before it can reconcile.
if o.workspaces then
  o.workspaces.reconcile = function() end
end
