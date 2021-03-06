import "../../JS/PXApp.js" as App
import "../Controls"
import "../"
import QtQuick 1.1
import QtWebKit 1.0

/**
 * @file
 * This file creates a draggable, placeable window that displays information about
 * a given stock.  This window is intended to be reused for all stocks.
 */

PXWindowDraggable {

    function setParams (params) {

        newsWindow.titleKey = params.title;
        webView.url = params.url;
    }

    id: newsWindow
    uniqueIdentifier: "news window draggable"

    contentView: Rectangle {
        id: contentView
        color: "black"
        anchors.fill: parent

        PXWebView {
            id: webView
            anchors.fill: parent
        }
    }
}
