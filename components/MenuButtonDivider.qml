import QtQuick 2.9

import "." as CoinComponents
import "effects/" as CoinEffects

Rectangle {
    color: CoinComponents.Style.appWindowBorderColor
    height: 1

    CoinEffects.ColorTransition {
        targetObj: parent
        blackColor: CoinComponents.Style._b_appWindowBorderColor
        whiteColor: CoinComponents.Style._w_appWindowBorderColor
    }
}
