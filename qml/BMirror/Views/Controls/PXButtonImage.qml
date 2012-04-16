import "../"
import QtQuick 1.1

Rectangle {

    property string buttonIdentifier;
    property bool isBackButton: false;
    property alias textKey: buttonLabel.textKey

    id: button
    width: 120
    height: 50
    radius: 5
    color: "white"
    border.width: 1
    border.color: "black"

    PXText {
        id: buttonLabel
        color: "#000000"
        horizontalAlignment: Text.AlignLeft
        textKey: "Next"
        anchors.left: isBackButton ? nextImage.right : parent.left
        anchors.leftMargin: 10
        anchors.right: isBackButton ? parent.right : nextImage.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }

    Image {
        id: nextImage
        height: 18
        anchors.right: isBackButton ? undefined : parent.right
        anchors.rightMargin: 10
        anchors.left: isBackButton ? parent.left : undefined
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        sourceSize.width: 22
        sourceSize.height: 18
        source: isBackButton ? "../../Images/backwards-icon.png" : "../../Images/forward-icon.png"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (button.onClick) {
                button.onClick(button);
            }
        }
    }
}
