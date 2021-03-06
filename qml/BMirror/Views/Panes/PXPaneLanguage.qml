import "../"
import "../Rows"
import "../../JS/Controllers/PXController.js" as Controller
import "../../JS/Controllers/PXPaneLanguage.js" as LanguageController
import "../../JS/PXNotifications.js" as Notifications
import "../../JS/PXApp.js" as App
import QtQuick 1.1

PXPane {

    // Implementation of "Array List Model Delegate Protocol"
    function rowsForModel (model, modelIdentifier) {

        var current_index = -1;

        if (modelIdentifier === "language selection pane") {

            LanguageController.addLanguagesToModel(model);
            current_index = languagePane.updateCheckmarks(LanguageController.languages.language(globalVariables.currentUserId));
            lanugageListView.getListView().positionViewAtIndex(current_index, ListView.Center);
        }
    }

    function updateCheckmarks (currentCode) {
        return Controller.updateCheckmarks(lanugageListView.getViewModel(), "rowLanguageCode", currentCode);
    }

    function model () {
        return lanugageListView;
    }

    id: languagePane

    PXListModelArray {

        id: lanugageListView
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: 280

        modelIdentifier: "language selection pane"
        arrayResultDelegate: languagePane
        viewComponent: Component {
            PXRowLanguage {
                function mouseAreaEvent (mouseArea) {
                    LanguageController.languages.setLanguage(globalVariables.currentUserId, rowLanguageCode);
                    globalVariables.setCurrentLangCode(rowLanguageCode);
                    languagePane.updateCheckmarks(rowLanguageCode);
                }
            }
        }
    }
}
