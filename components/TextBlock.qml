import QtQuick 2.9

import "../components" as CoinComponents

TextEdit {
    color: CoinComponents.Style.defaultFontColor
    font.family: CoinComponents.Style.fontRegular.name
    selectionColor: CoinComponents.Style.textSelectionColor
    wrapMode: Text.Wrap
    readOnly: true
    selectByMouse: true
    // Workaround for https://bugreports.qt.io/browse/QTBUG-50587
    onFocusChanged: {
        if(focus === false)
            deselect()
    }
}
