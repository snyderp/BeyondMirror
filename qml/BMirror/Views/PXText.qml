import QtQuick 1.1
import "../JS/PXNotifications.js" as Notifications
import "../JS/PXLang.js" as Lang

Text {

    /**
      * The untranslated version of the string this element displays.  Whenever
      * the application's language changes, this key will be used to decide
      * what localized string should be used to replace the current one.
      */
    property string textKey;

    // If this property is set to false, the text represented will be
    // displayed to be exactly as the provided textKey, not translated
    // to the current application language
    property bool shouldTranslate: true;

    /* Notifications Protocol Methods */
    function receivedNotification (notification, params) {
        if (textElement.shouldTranslate) {
            textElement.text = Lang.translateTerm(textElement.textKey, params.code);
        } else {
            textElement.text = textElement.textKey;
        }
    }

    onTextKeyChanged: {
        if (textElement.shouldTranslate) {
            textElement.text = Lang.translateTerm(textElement.textKey, globalVariables.currentLangCode);
        } else {
            textElement.text = textElement.textKey;
        }
    }

    Component.onCompleted: {
        Notifications.registry.registerForNotification(textElement, "language changed");
    }

    Component.onDestruction: {
        Notifications.registry.unregisterForAll(textElement);
    }

    id: textElement
    font.family: "Futura"
    font.pixelSize: 20
    lineHeight: 28;
    wrapMode: Text.WordWrap;
    maximumLineCount: 2;
    lineHeightMode: Text.FixedHeight;
    verticalAlignment: Text.AlignVCenter;
    horizontalAlignment: Text.AlignLeft;
    elide: Text.ElideRight;
    color: "white"
    visible: parent.height > 10
}
