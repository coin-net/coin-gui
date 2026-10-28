pragma Singleton

import QtQuick 2.5

QtObject {
    property bool blackTheme: true
    property QtObject fontMedium: FontLoader { id: _fontMedium; source: "qrc:/fonts/Roboto-Medium.ttf"; }
    property QtObject fontBold: FontLoader { id: _fontBold; source: "qrc:/fonts/Roboto-Bold.ttf"; }
    property QtObject fontLight: FontLoader { id: _fontLight; source: "qrc:/fonts/Roboto-Light.ttf"; }
    property QtObject fontRegular: FontLoader { id: _fontRegular; source: "qrc:/fonts/Roboto-Regular.ttf"; }

    property QtObject fontMonoMedium: FontLoader { id: _fontMonoMedium; source: "qrc:/fonts/RobotoMono-Medium.ttf"; }
    property QtObject fontMonoBold: FontLoader { id: _fontMonoBold; source: "qrc:/fonts/RobotoMono-Bold.ttf"; }
    property QtObject fontMonoLight: FontLoader { id: _fontMonoLight; source: "qrc:/fonts/RobotoMono-Light.ttf"; }
    property QtObject fontMonoRegular: FontLoader { id: _fontMonoRegular; source: "qrc:/fonts/RobotoMono-Regular.ttf"; }

    property string grey: "#404040"
    property string orange: blackTheme ? "#6AA9FF" : "#000080"
    property string white: "#FFFFFF"
    property string green: "#168A57"
    property string coinGrey: "#4C4C4C"
    property string warningColor: "#C78C1A"

    property string defaultFontColor: blackTheme ? _b_defaultFontColor : _w_defaultFontColor
    property string dimmedFontColor: blackTheme ? _b_dimmedFontColor : _w_dimmedFontColor
    property string lightGreyFontColor: blackTheme ? _b_lightGreyFontColor : _w_lightGreyFontColor
    property string errorColor: blackTheme ? _b_errorColor : _w_errorColor
    property string textSelectionColor: blackTheme ? _b_textSelectionColor : _w_textSelectionColor
    property string textSelectedColor: blackTheme ? _b_textSelectedColor : _w_textSelectedColor

    property string inputBoxBackground: blackTheme ? _b_inputBoxBackground : _w_inputBoxBackground
    property string inputBoxBackgroundDisabled: blackTheme ? _b_inputBoxBackgroundDisabled : _w_inputBoxBackgroundDisabled
    property string inputBoxBackgroundError: blackTheme ? _b_inputBoxBackgroundError : _w_inputBoxBackgroundError
    property string inputBoxColor: blackTheme ? _b_inputBoxColor : _w_inputBoxColor
    property string legacy_placeholderFontColor: blackTheme ? _b_legacy_placeholderFontColor : _w_legacy_placeholderFontColor
    property string inputBorderColorActive: blackTheme ? _b_inputBorderColorActive : _w_inputBorderColorActive
    property string inputBorderColorInActive: blackTheme ? _b_inputBorderColorInActive : _w_inputBorderColorInActive
    property string inputBorderColorInvalid: blackTheme ? _b_inputBorderColorInvalid : _w_inputBorderColorInvalid

    property string buttonBackgroundColor: blackTheme ? _b_buttonBackgroundColor : _w_buttonBackgroundColor
    property string buttonBackgroundColorHover: blackTheme ? _b_buttonBackgroundColorHover : _w_buttonBackgroundColorHover
    property string buttonBackgroundColorDisabled: blackTheme ? _b_buttonBackgroundColorDisabled : _w_buttonBackgroundColorDisabled
    property string buttonBackgroundColorDisabledHover: blackTheme ? _b_buttonBackgroundColorDisabledHover : _w_buttonBackgroundColorDisabledHover
    property string buttonInlineBackgroundColor: blackTheme ? _b_buttonInlineBackgroundColor : _w_buttonInlineBackgroundColor
    property string buttonInlineBackgroundColorHover: blackTheme ? _b_buttonInlineBackgroundColorHover : _w_buttonInlineBackgroundColorHover
    property string buttonTextColor: blackTheme ? _b_buttonTextColor : _w_buttonTextColor
    property string buttonTextColorDisabled: blackTheme ? _b_buttonTextColorDisabled : _w_buttonTextColorDisabled
    property string buttonSecondaryBackgroundColor: blackTheme ? _b_buttonSecondaryBackgroundColor : _w_buttonSecondaryBackgroundColor
    property string buttonSecondaryBackgroundColorHover: blackTheme ? _b_buttonSecondaryBackgroundColorHover : _w_buttonSecondaryBackgroundColorHover
    property string buttonSecondaryTextColor: blackTheme ? _b_buttonSecondaryTextColor : _w_buttonSecondaryTextColor
    property string dividerColor: blackTheme ? _b_dividerColor : _w_dividerColor
    property real dividerOpacity: blackTheme ? _b_dividerOpacity : _w_dividerOpacity

    property string titleBarBackgroundGradientStart: blackTheme ? _b_titleBarBackgroundGradientStart : _w_titleBarBackgroundGradientStart
    property string titleBarBackgroundGradientStop: blackTheme ? _b_titleBarBackgroundGradientStop : _w_titleBarBackgroundGradientStop
    property string titleBarBackgroundBorderColor: blackTheme ? _b_titleBarBackgroundBorderColor : _w_titleBarBackgroundBorderColor
    property string titleBarLogoSource: blackTheme ? _b_titleBarLogoSource : _w_titleBarLogoSource
    property string titleBarMinimizeSource: blackTheme ? _b_titleBarMinimizeSource : _w_titleBarMinimizeSource
    property string titleBarFullscreenSource: blackTheme ? _b_titleBarFullscreenSource : _w_titleBarFullscreenSource
    property string titleBarCloseSource: blackTheme ? _b_titleBarCloseSource : _w_titleBarCloseSource
    property string titleBarButtonHoverColor: blackTheme ? _b_titleBarButtonHoverColor : _w_titleBarButtonHoverColor

    property string wizardBackgroundGradientStart: blackTheme ? _b_wizardBackgroundGradientStart : _w_wizardBackgroundGradientStart
    property string middlePanelBackgroundGradientStart: blackTheme ? _b_middlePanelBackgroundGradientStart : _w_middlePanelBackgroundGradientStart
    property string middlePanelBackgroundGradientStop: blackTheme ? _b_middlePanelBackgroundGradientStop : _w_middlePanelBackgroundGradientStop
    property string middlePanelBackgroundColor: blackTheme ? _b_middlePanelBackgroundColor : _w_middlePanelBackgroundColor
    property string menuButtonFallbackBackgroundColor: blackTheme ? _b_menuButtonFallbackBackgroundColor : _w_menuButtonFallbackBackgroundColor
    property string menuButtonGradientStart: blackTheme ? _b_menuButtonGradientStart : _w_menuButtonGradientStart
    property string menuButtonGradientStop: blackTheme ? _b_menuButtonGradientStop : _w_menuButtonGradientStop
    property string menuButtonTextColor: blackTheme ? _b_menuButtonTextColor : _w_menuButtonTextColor
    property string menuButtonImageRightColorActive: blackTheme ? _b_menuButtonImageRightColorActive : _w_menuButtonImageRightColorActive
    property string menuButtonImageRightColor: blackTheme ? _b_menuButtonImageRightColor : _w_menuButtonImageRightColor
    property string menuButtonImageRightSource: blackTheme ? _b_menuButtonImageRightSource : _w_menuButtonImageRightSource
    property string menuButtonImageDotArrowSource: blackTheme ? _b_menuButtonImageDotArrowSource : _w_menuButtonImageDotArrowSource
    property string inlineButtonTextColor: blackTheme ? _b_inlineButtonTextColor : _w_inlineButtonTextColor
    property string inlineButtonBorderColor: blackTheme ? _b_inlineButtonBorderColor : _w_inlineButtonBorderColor
    property string appWindowBackgroundColor: blackTheme ? _b_appWindowBackgroundColor : _w_appWindowBackgroundColor
    property string appWindowBorderColor: blackTheme ? _b_appWindowBorderColor : _w_appWindowBorderColor
    property bool progressBarProgressTextBold: blackTheme ? _b_progressBarProgressTextBold : _w_progressBarProgressTextBold
    property string progressBarBackgroundColor: blackTheme ? _b_progressBarBackgroundColor : _w_progressBarBackgroundColor
    property string leftPanelBackgroundGradientStart: blackTheme ? _b_leftPanelBackgroundGradientStart : _w_leftPanelBackgroundGradientStart
    property string leftPanelBackgroundGradientStop: blackTheme ? _b_leftPanelBackgroundGradientStop : _w_leftPanelBackgroundGradientStop
    property string historyHeaderTextColor: blackTheme ? _b_historyHeaderTextColor : _w_historyHeaderTextColor
    property var accountColors: blackTheme ? _b_accountColors : _w_accountColors

    property string _b_defaultFontColor: "#F3F4F6"
    property string _b_dimmedFontColor: "#B8C0CE"
    property string _b_lightGreyFontColor: "#D2D9E3"
    property string _b_errorColor: "#EF7F78"
    property string _b_textSelectionColor: "#315B9A"
    property string _b_textSelectedColor: "#FFFFFF"

    property string _b_inputBoxBackground: "#101929"
    property string _b_inputBoxBackgroundDisabled: "#242C3B"
    property string _b_inputBoxBackgroundError: "#5E2731"
    property string _b_inputBoxColor: "#F5F5F5"
    property string _b_legacy_placeholderFontColor: "#AAB4C7"
    property string _b_inputBorderColorActive: "#88B1FF"
    property string _b_inputBorderColorInActive: "#667489"
    property string _b_inputBorderColorInvalid: "#D78577"

    property string _b_buttonBackgroundColor: "#2056A5"
    property string _b_buttonBackgroundColorHover: "#326BC3"
    property string _b_buttonBackgroundColorDisabled: "#576072"
    property string _b_buttonBackgroundColorDisabledHover: "#626E83"
    property string _b_buttonInlineBackgroundColor: "#535C6B"
    property string _b_buttonInlineBackgroundColorHover: "#697789"
    property string _b_buttonTextColor: "#FFFFFF"
    property string _b_buttonTextColorDisabled: "#D3D6DA"
    property string _b_buttonSecondaryBackgroundColor: "#3D4759"
    property string _b_buttonSecondaryBackgroundColorHover: "#526177"
    property string _b_buttonSecondaryTextColor: "#FFFFFF"
    property string _b_dividerColor: "#71809B"
    property real _b_dividerOpacity: 0.30

    property string _b_titleBarBackgroundGradientStart: "#071761";
    property string _b_titleBarBackgroundGradientStop: "#001040"
    property string _b_titleBarBackgroundBorderColor: "#8294C6"
    property string _b_titleBarLogoSource: "qrc:///images/titlebarLogo.png"
    property string _b_titleBarMinimizeSource: "qrc:///images/minimize.svg"
    property string _b_titleBarFullscreenSource: "qrc:///images/fullscreen.svg"
    property string _b_titleBarCloseSource: "qrc:///images/close.svg"
    property string _b_titleBarButtonHoverColor: "#335C9C"

    property string _b_wizardBackgroundGradientStart: "#202939"
    property string _b_middlePanelBackgroundGradientStart: "#202733"
    property string _b_middlePanelBackgroundGradientStop: "#161B26"
    property string _b_middlePanelBackgroundColor: "#1B2230"
    property string _b_menuButtonFallbackBackgroundColor: "#384B69"
    property string _b_menuButtonGradientStart: "#2F466A"
    property string _b_menuButtonGradientStop: "#17253B"
    property string _b_menuButtonTextColor: "#FFFFFF"
    property string _b_menuButtonImageRightColorActive: "#F8F9FA"
    property string _b_menuButtonImageRightColor: "#B4C3D8"
    property string _b_menuButtonImageRightSource: "qrc:///images/right.svg"
    property string _b_menuButtonImageDotArrowSource: "qrc:///images/arrow-right-medium-white.png"
    property string _b_inlineButtonTextColor: "#D6E0F2"
    property string _b_inlineButtonBorderColor: "#6F7E9C"
    property string _b_appWindowBackgroundColor: "white"
    property string _b_appWindowBorderColor: "#60708B"
    property bool _b_progressBarProgressTextBold: true
    property string _b_progressBarBackgroundColor: "#33415B"
    property string _b_leftPanelBackgroundGradientStart: "#2C3443"
    property string _b_leftPanelBackgroundGradientStop: "#222A39"
    property string _b_historyHeaderTextColor: "#CBD4E2"
    property var _b_accountColors: ["#315A92"]

    property string _w_defaultFontColor: "#101010"
    property string _w_dimmedFontColor: "#4F4F4F"
    property string _w_lightGreyFontColor: "#545454"
    property string _w_errorColor: "#A53218"
    property string _w_textSelectionColor: "#000080"
    property string _w_textSelectedColor: "#FFFFFF"

    property string _w_inputBoxBackground: "#FFFFFF"
    property string _w_inputBoxBackgroundDisabled: "#D4D4D4"
    property string _w_inputBoxBackgroundError: "#FFE9E2"
    property string _w_inputBoxColor: "#101010"
    property string _w_legacy_placeholderFontColor: "#767676"
    property string _w_inputBorderColorActive: "#000080"
    property string _w_inputBorderColorInActive: "#7F7F7F"
    property string _w_inputBorderColorInvalid: "#B14029"

    property string _w_buttonBackgroundColor: "#000080"
    property string _w_buttonBackgroundColorHover: "#1749A6"
    property string _w_buttonBackgroundColorDisabled: "#A0A0A0"
    property string _w_buttonBackgroundColorDisabledHover: "#AEAEAE"
    property string _w_buttonInlineBackgroundColor: "#C0C0C0"
    property string _w_buttonInlineBackgroundColorHover: "#D5D5D5"
    property string _w_buttonTextColor: "#FFFFFF"
    property string _w_buttonTextColorDisabled: "#666666"
    property string _w_buttonSecondaryBackgroundColor: "#C0C0C0"
    property string _w_buttonSecondaryBackgroundColorHover: "#D6D6D6"
    property string _w_buttonSecondaryTextColor: "#111111"
    property string _w_dividerColor: "#666666"
    property real _w_dividerOpacity: 0.32

    property string _w_titleBarBackgroundGradientStart: "#000080"
    property string _w_titleBarBackgroundGradientStop: "#0C3B9B"
    property string _w_titleBarBackgroundBorderColor: "#F6F6F6"
    property string _w_titleBarLogoSource: "qrc:///images/themes/white/titlebarLogo.png"
    property string _w_titleBarMinimizeSource: "qrc:///images/themes/white/minimize.svg"
    property string _w_titleBarFullscreenSource: "qrc:///images/themes/white/fullscreen.svg"
    property string _w_titleBarCloseSource: "qrc:///images/themes/white/close.svg"
    property string _w_titleBarButtonHoverColor: "#2255AB"

    property string _w_wizardBackgroundGradientStart: "#C0C0C0"
    property string _w_middlePanelBackgroundGradientStart: "#D5D5D5"
    property string _w_middlePanelBackgroundGradientStop: "#C0C0C0"
    property string _w_middlePanelBackgroundColor: "#C0C0C0"
    property string _w_menuButtonFallbackBackgroundColor: "#DBDBDB"
    property string _w_menuButtonGradientStart: "#EAEAEA"
    property string _w_menuButtonGradientStop: "#C0C0C0"
    property string _w_menuButtonTextColor: "#202020"
    property string _w_menuButtonImageRightSource: "qrc:///images/right.svg"
    property string _w_menuButtonImageRightColorActive: "#000080"
    property string _w_menuButtonImageRightColor: "#555555"
    property string _w_menuButtonImageDotArrowSource: "qrc:///images/arrow-right-medium-white.png"
    property string _w_inlineButtonTextColor: "#000080"
    property string _w_inlineButtonBorderColor: "#707070"
    property string _w_appWindowBackgroundColor: "black"
    property string _w_appWindowBorderColor: "#808080"
    property bool _w_progressBarProgressTextBold: false
    property string _w_progressBarBackgroundColor: "#999999"
    property string _w_leftPanelBackgroundGradientStart: "#C0C0C0"
    property string _w_leftPanelBackgroundGradientStop: "#B5B5B5"
    property string _w_historyHeaderTextColor: "#333333"
    property var _w_accountColors: ["#000080"]
}
