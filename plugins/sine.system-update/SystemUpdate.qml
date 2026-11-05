import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.system-update"

  // Glyph scale for the bar button; the slot keeps its width. Read from
  // ~/.config/omarchy/bar-sizes.json: "systemUpdate": { "scale": 0.75 }.
  property var sizeConfig: ({})
  readonly property real iconScale: {
    var cfg = root.sizeConfig.systemUpdate || ({})
    var v = Number(cfg.scale)
    if (!(isFinite(v) && v > 0)) v = Number(setting("iconScale", 0))
    return (isFinite(v) && v > 0) ? v : 1
  }

  FileView {
    path: Quickshell.env("HOME") + "/.config/omarchy/bar-sizes.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        var parsed = JSON.parse(text())
        root.sizeConfig = (parsed && typeof parsed === "object") ? parsed : ({})
      } catch (e) {
        root.sizeConfig = ({})
      }
    }
    onLoadFailed: root.sizeConfig = ({})
  }

  property bool updateAvailable: false

  function refresh() {
    if (!updateProc.running) updateProc.running = true
  }

  function clear() { updateAvailable = false }

  function runUpdate() {
    if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation omarchy-update")
  }

  visible: updateAvailable
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  ShellIpc {
    target: "omarchy.system-update"

    function refresh(): void {
      root.broadcast("refresh")
    }

    function clear(): void {
      root.broadcast("clear")
    }
  }

  Process {
    id: updateProc
    command: ["omarchy-update-available"]
    onExited: function(exitCode) {
      root.updateAvailable = exitCode === 0
    }
  }

  Timer {
    interval: 21600000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf021"
    slotSize: Style.bar.statusSlot
    scale: root.iconScale
    tooltipText: I18n.t("bar.pendingUpdates")
    onPressed: root.runUpdate()
  }
}
