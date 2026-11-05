import QtQuick
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  property bool dnd: false

  function sync() {
    var h = IpcRegistry.handlerFor("notifications")
    if (!h || typeof h.isDnd !== "function") return
    try { root.dnd = h.isDnd() === "on" } catch (e) {}
  }

  Timer { interval: 1000; running: true; repeat: true; onTriggered: root.sync() }
  Component.onCompleted: root.sync()

  active: dnd
  activeText: "󰂛"
  inactiveText: "󰂛"
  activeTooltipText: I18n.t("bar.allowNotifications")
  inactiveTooltipText: I18n.t("bar.silenceNotifications")

  onPressed: function() {
    var h = IpcRegistry.handlerFor("notifications")
    if (h && typeof h.toggleDnd === "function") { h.toggleDnd(); root.sync() }
  }
}
