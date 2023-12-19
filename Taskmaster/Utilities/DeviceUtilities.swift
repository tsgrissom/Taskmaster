import UIKit

/// Provides a series of methods which shorten accessing information about the current device.
struct DeviceUtilities {
    
    /**
     Fetches the device's screen width as a CGFloat.
     */
    static func getScreenWidth() -> CGFloat {
        UIScreen.main.bounds.width
        // FIXME Deprecated in future iOS
    }
    
    /**
     Fetches the device's screen height as a CGFloat.
     */
    static func getScreenHeight() -> CGFloat {
        UIScreen.main.bounds.height
        // FIXME Deprecation
    }
    
    /**
     Fetches the current device's user interface idiom, enabling the developer to
     determine the type of device (phone, pad, etc.) the context is currently within.
     */
    static func getUIIdiom() -> UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }
    
    /**
     Determines if the UI idiom means that the current context is that of a phone device.
     (uiIdiom == .phone)
     */
    static func isPhone() -> Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /**
     Determines if the UI idiom means that the current context is that of a tablet device.
     (uiIdiom == .pad)
     */
    static func isTablet() -> Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
