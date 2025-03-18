import Foundation
import UIKit
import ZebraScannerSDK
@objc(ZebraSTCPlugin) class ZebraSTCPlugin: CDVPlugin {
    var activeScannerId: Int32?
    // Existing method to generate STC barcode
    @objc(generateSTCBarcode:)
    func generateSTCBarcode(command: CDVInvokedUrlCommand) {
        // Implementation as previously defined
    }
    // New method to disconnect from the scanner
    @objc(disconnectScanner:)
    func disconnectScanner(command: CDVInvokedUrlCommand) {
        guard let scannerId = activeScannerId else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: “No active scanner to disconnect.“)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        let scannerApi = SbtSdkFactory.createSbtSdkApiInstance()
        let result = scannerApi?.sbtTerminateCommunicationSession(scannerId)
        if result == SBT_RESULT_SUCCESS {
            let pluginResult = CDVPluginResult(status: .ok, messageAs: “Disconnected from scanner ID \(scannerId).“)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            activeScannerId = nil
        } else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: “Failed to disconnect from scanner ID \(scannerId).“)
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        }
    }
    // Implement delegate method to track active scanner
    func sbtEventCommunicationSessionEstablished(_ activeScanner: SbtScannerInfo!) {
        activeScannerId = activeScanner.getScannerId()
    }
    func sbtEventCommunicationSessionTerminated(_ scannerID: Int32) {
        if activeScannerId == scannerID {
            activeScannerId = nil
        }
    }
}
