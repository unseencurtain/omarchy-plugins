import QtQuick
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  property bool stayAwake: false

  function sync() {
    var h = IpcRegistry.handlerFor("idle")
    if (!h || typeof h.status !== "function") return
    try { root.stayAwake = !!JSON.parse(h.status()).stayAwake } catch (e) {}
  }

  Timer { interval: 1000; running: true; repeat: true; onTriggered: root.sync() }
  Component.onCompleted: root.sync()

  active: stayAwake
  // A mug without a saucer, which drew a line under the cup.
  activeText: ""
  inactiveText: ""
  activeTooltipText: I18n.t("bar.allowIdleLock")
  inactiveTooltipText: I18n.t("bar.stayAwake")

  function toggle() {
    var h = IpcRegistry.handlerFor("idle")
    if (h && typeof h.toggle === "function") { h.toggle(); root.sync() }
  }

  onPressed: function() { root.toggle() }
}
