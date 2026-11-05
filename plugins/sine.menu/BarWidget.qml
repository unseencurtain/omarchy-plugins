import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.menu"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  property var sizeConfig: ({})
  readonly property real iconScale: {
    var cfg = root.sizeConfig.menu || ({})
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

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    scale: root.iconScale
    text: "\ue900"
    fontFamily: "omarchy"
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("omarchy-shell shell toggle omarchy.menu '{\"menu\":\"root\"}'")
    }
  }
}
