// Copyright (c) 2014-2024, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.9
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.2

import FontAwesome 1.0
import "." as CoinComponents
import "effects/" as CoinEffects

Rectangle {
    id: root
    property int mouseX: 0
    property bool customDecorations: persistentSettings.customDecorations
    property bool showMinimizeButton: true
    property bool showMaximizeButton: true
    property bool showCloseButton: true
    property string walletName: ""

    height: {
        if(!persistentSettings.customDecorations) return 0;
        return 50;
    }

    z: 1
    color: "transparent"

    signal closeClicked
    signal maximizeClicked
    signal minimizeClicked
    signal languageClicked
    signal closeWalletClicked
    signal lockWalletClicked

    state: "default"
    states: [
        State {
            name: "default";
            PropertyChanges { target: btnCloseWallet; visible: true}
            PropertyChanges { target: btnLockWallet; visible: true}
            PropertyChanges { target: btnLanguageToggle; visible: true}
        }, State {
            // show only theme switcher and window controls
            name: "essentials";
            PropertyChanges { target: btnCloseWallet; visible: false}
            PropertyChanges { target: btnLockWallet; visible: false}
            PropertyChanges { target: btnLanguageToggle; visible: false}
        }
    ]

    CoinEffects.GradientBackground {
        anchors.fill: parent
        duration: 300
        fallBackColor: CoinComponents.Style.middlePanelBackgroundColor
        initialStartColor: CoinComponents.Style.titleBarBackgroundGradientStart
        initialStopColor: CoinComponents.Style.titleBarBackgroundGradientStop
        blackColorStart: CoinComponents.Style._b_titleBarBackgroundGradientStart
        blackColorStop: CoinComponents.Style._b_titleBarBackgroundGradientStop
        whiteColorStart: CoinComponents.Style._w_titleBarBackgroundGradientStart
        whiteColorStop: CoinComponents.Style._w_titleBarBackgroundGradientStop
        start: Qt.point(width, 0)
        end: Qt.point(0, 0)
    }

    RowLayout {
        z: parent.z + 2
        spacing: 0
        anchors.fill: parent

        // lock wallet
        Rectangle {
            id: btnLockWallet
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Text {
                text: FontAwesome.lock
                font.family: FontAwesome.fontFamilySolid
                font.pixelSize: 16
                color: CoinComponents.Style.defaultFontColor
                font.styleName: "Solid"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            CoinComponents.Tooltip {
                id: btnLockWalletTooltip
                anchors.fill: parent
                text: qsTr("Lock this wallet") + translationManager.emptyString
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = CoinComponents.Style.titleBarButtonHoverColor
                    btnLockWalletTooltip.tooltipPopup.open()
                }
                onExited: {
                    parent.color = "transparent"
                    btnLockWalletTooltip.tooltipPopup.close()
                }
                onClicked: root.lockWalletClicked()
            }
        }

        // collapse sidebar
        Rectangle {
            id: btnCloseWallet
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height


            Text {
                text: FontAwesome.signOutAlt
                font.family: FontAwesome.fontFamilySolid
                font.pixelSize: 16
                color: CoinComponents.Style.defaultFontColor
                font.styleName: "Solid"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            CoinComponents.Tooltip {
                id: btnCloseWalletTooltip
                anchors.fill: parent
                text: qsTr("Close this wallet and return to main menu") + translationManager.emptyString
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = CoinComponents.Style.titleBarButtonHoverColor
                    btnCloseWalletTooltip.tooltipPopup.open()
                }
                onExited: {
                    parent.color = "transparent"
                    btnCloseWalletTooltip.tooltipPopup.close()
                }
                onClicked: root.closeWalletClicked()
            }
        }

        // language selection
        Rectangle {
            id: btnLanguageToggle
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Text {
                text: FontAwesome.globe
                font.family: FontAwesome.fontFamilySolid
                font.pixelSize: 16
                color: CoinComponents.Style.defaultFontColor
                font.styleName: "Solid"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            CoinComponents.Tooltip {
                id: btnLanguageToggleTooltip
                anchors.fill: parent
                text: qsTr("Change language") + translationManager.emptyString
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = CoinComponents.Style.titleBarButtonHoverColor
                    btnLanguageToggleTooltip.tooltipPopup.open()
                }
                onExited: {
                    parent.color = "transparent"
                    btnLanguageToggleTooltip.tooltipPopup.close()
                }
                onClicked: root.languageClicked()
            }
        }

        // switch theme
        Rectangle {
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Text {
                text: FontAwesome.moonO
                font.family: CoinComponents.Style.blackTheme ? FontAwesome.fontFamilySolid : FontAwesome.fontFamily
                font.styleName: CoinComponents.Style.blackTheme ? "Solid" : "Regular"
                font.pixelSize: 15
                color: CoinComponents.Style.defaultFontColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.75
            }

            CoinComponents.Tooltip {
                id: btnSwitchThemeTooltip
                anchors.fill: parent
                text: CoinComponents.Style.blackTheme ? qsTr("Switch to light theme") : qsTr("Switch to dark theme") + translationManager.emptyString
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    parent.color = CoinComponents.Style.titleBarButtonHoverColor
                    btnSwitchThemeTooltip.tooltipPopup.open()
                }
                onExited: {
                    parent.color = "transparent"
                    btnSwitchThemeTooltip.tooltipPopup.close()
                }
                onClicked: {
                    CoinComponents.Style.blackTheme = !CoinComponents.Style.blackTheme;
                }
            }
        }

        Item {
            // make dummy space when hiding buttons when titlebar
            // state is 'essentials' in order for the
            // COIN logo to still be centered
            Layout.preferredWidth: parent.height * 2  // amount of buttons we hide
            Layout.preferredHeight: parent.height
            visible: root.state == "essentials"
        }

        // COIN logo
        Item {
            visible: walletName.length === 0
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height

            Text {
                anchors.centerIn: parent
                text: "COIN"
                font.bold: true
                font.pixelSize: 24
                font.letterSpacing: 2
                color: CoinComponents.Style.defaultFontColor
            }

        }

        Item {
            visible: walletName.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height

            CoinComponents.TextPlain {
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                width: parent.width
                height: parent.height
                elide: Text.ElideRight
                text: walletName
            }
        }

        // minimize
        Rectangle {
            color: "transparent"
            visible: root.showMinimizeButton
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            CoinEffects.ImageMask {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 18
                anchors.horizontalCenter: parent.horizontalCenter
                height: 3
                width: 15
                image: CoinComponents.Style.titleBarMinimizeSource
                color: CoinComponents.Style.defaultFontColor
                fontAwesomeFallbackIcon: FontAwesome.minus
                fontAwesomeFallbackSize: 18
                fontAwesomeFallbackOpacity: CoinComponents.Style.blackTheme ? 0.8 : 0.6
                opacity: 0.75
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.color = CoinComponents.Style.titleBarButtonHoverColor
                onExited: parent.color = "transparent"
                onClicked: root.minimizeClicked();
            }
        }

        // maximize
        Rectangle {
            id: test
            visible: root.showMaximizeButton
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: CoinComponents.Style.titleBarFullscreenSource
                sourceSize.width: 16
                sourceSize.height: 16
                smooth: true
                mipmap: true
                opacity: 0.75
                rotation: appWindow.visibility === Window.Maximized ? 180 : 0
            }

            MouseArea {
                id: buttonArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.color = CoinComponents.Style.titleBarButtonHoverColor
                onExited: parent.color = "transparent"
                onClicked: root.maximizeClicked();
            }
        }

        // close
        Rectangle {
            visible: root.showCloseButton
            color: "transparent"
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height

            CoinEffects.ImageMask {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                height: 16
                width: 16
                image: CoinComponents.Style.titleBarCloseSource
                color: CoinComponents.Style.defaultFontColor
                fontAwesomeFallbackIcon: FontAwesome.times
                fontAwesomeFallbackSize: 21
                fontAwesomeFallbackOpacity: CoinComponents.Style.blackTheme ? 0.8 : 0.6
                opacity: 0.75
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.color = CoinComponents.Style.titleBarButtonHoverColor
                onExited: parent.color = "transparent"
                onClicked: root.closeClicked();
            }
        }
    }

    Rectangle {
        z: parent.z + 3
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: CoinComponents.Style.blackTheme ? 1 : 1
        color: CoinComponents.Style.titleBarBackgroundBorderColor

        CoinEffects.ColorTransition {
            targetObj: parent
            blackColor: CoinComponents.Style._b_titleBarBackgroundBorderColor
            whiteColor: CoinComponents.Style._w_titleBarBackgroundBorderColor
        }
    }

    MouseArea {
        enabled: persistentSettings.customDecorations
        property var previousPosition
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: previousPosition = globalCursor.getPosition()
        onDoubleClicked: root.maximizeClicked()
        onPositionChanged: {
            if (pressedButtons == Qt.LeftButton) {
                var pos = globalCursor.getPosition()
                var dx = pos.x - previousPosition.x
                var dy = pos.y - previousPosition.y

                appWindow.x += dx
                appWindow.y += dy
                previousPosition = pos
            }
        }
    }
}
