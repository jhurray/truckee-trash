import WidgetKit
import SwiftUI

@main
struct TruckeeTrashWidgetBundle: WidgetBundle {
    var body: some Widget {
        TruckeeTrashWidget()
        
        if #available(iOS 16.1, *) {
            TruckeeTrashLiveActivity()
        }
    }
}