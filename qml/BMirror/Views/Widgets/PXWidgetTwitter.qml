import "../../JS/PXApp.js" as App
import "../../JS/Controllers/PXController.js" as GenericController
import "../../JS/Controllers/PXWidgetTwitter.js" as TwitterController
import "../../JS/PXNotifications.js" as Notifications
import "../../Views/Rows"
import "../Controls"
import "../"
import QtQuick 1.1

PXWindowWidget {

    // Implementation of the "Row Text Input Delegate Protocol"
    function rowTextInputClicked (rowTextInput) {

        if (rowTextInput.rowTextInputIdentifier === "twitter text input") {

            TwitterController.tweets.addAccount(rowTextInput.text(), function () {

                twitterEditWidget.modelArray().refresh();
                twitterViewModel.refresh();
                rowTextInput.clear();
            });
        }
    }

    // Implementation of the "Array List Model Delegate Protocol"
    function rowsForModel (model, modelIdentifier) {

        if (modelIdentifier === "twitter view model") {

            TwitterController.addCurrentUsersTwitterItemsToModel(model);

        } else if (modelIdentifier === "twitter config model") {

            TwitterController.addCurrentUsersTwitterAccountsToModel(model);

        }
    }

    // Implementation of "Notification Delegate Protocol"
    function receivedNotification (notification, params) {

        if (notification === "edit row delete clicked") {

            if (params.modelIdentifier == "twitter config model") {

                GenericController.removeRowFromModel(
                    params.row,
                    twitterEditWidget.modelArray().getViewModel(),
                    twitterEditWidget.modelArray(),
                    function () {
                        TwitterController.tweets.removeAccount(params.row.identifier());
                        twitterEditWidget.modelArray().refresh();
                        twitterViewModel.refresh();
                    }
                );
            }
        }
    }

    Component.onCompleted: {
        Notifications.registry.registerForNotification(twitterWidget, "edit row delete clicked");
    }

    Component.onDestruction: {
        Notifications.registry.unregisterForAll(twitterWidget);
    }

    id: twitterWidget
    titleKey: "Twitter"

    configurationView: PXEditableSheet {
        id: twitterEditWidget
        rowTextInputDelgate: twitterWidget
        rowTextInputIdentifier: "twitter text input"
        modelIdentifier: "twitter config model"
        arrayResultDelegate: twitterWidget
        viewComponent: Component {
            PXRowTextEdit {}
        }
    }

    contentView: PXListModelArray {
        id: twitterViewModel
        modelIdentifier: "twitter view model"
        arrayResultDelegate: twitterWidget
        viewComponent: Component {
            PXRowTweet {}
        }
    }
}
