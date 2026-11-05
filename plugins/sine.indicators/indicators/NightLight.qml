import QtQuick
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  property bool nightlightEnabled: false

  function sync() {
    var h = IpcRegistry.handlerFor("nightlight")
    if (!h || typeof h.status !== "function") return
    try { root.nightlightEnabled = !!JSON.parse(h.status()).enabled } catch (e) {}
  }

  Timer { interval: 1000; running: true; repeat: true; onTriggered: root.sync() }
  Component.onCompleted: root.sync()

  active: nightlightEnabled
  activeText: "󰔎"
  inactiveText: "󰔎"
  activeTooltipText: I18n.t("bar.dayLight")
  inactiveTooltipText: I18n.t("bar.nightLight")

  function toggle() {
    var h = IpcRegistry.handlerFor("nightlight")
    if (h && typeof h.toggle === "function") { h.toggle(); root.sync() }
  }

  onPressed: function() { root.toggle() }
}
