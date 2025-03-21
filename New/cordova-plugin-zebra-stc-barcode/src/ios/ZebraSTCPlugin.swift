import Foundation
import UIKit
import ZebraScannerSDK
@objc(ZebraSTCPlugin) class ZebraSTCPlugin: CDVPlugin {
    var activeScannerId: Int32?
    // Existing method to generate STC barcode
    @objc(generateSTCBarcode:)
    func generateSTCBarcode(command: CDVInvokedUrlCommand) {
        // Implementation as previously defined
        let scannerApi = SbtSdkFactory.createSbtSdkApiInstance()
        scannerApi.sbtSetOperationalMode(Int32(SBT_OPMODE_ALL))
        scannerApi.sbtEnableAvailableScannersDetection(true)
        // Generate STC barcode for HID Bluetooth Classic pairing
        scannerApi.sbtGetPairingBarcode(
            BARCODE_TYPE_STC,
            withComProtocol: SBT_HID,
            setFactoryDefaults: false,
            completionHandler: { barcodeImage, error in
                if let barcode = barcodeImage,
                   let imageData = barcode.pngData() {
                   let base64String = imageData.base64EncodedString()
                   let pluginResult = CDVPluginResult(status: .ok, messageAs: base64String)
                   self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                } else {
                    let errorMessage = error?.localizedDescription ?? "Unknown error generating barcode."
                    let pluginResult = CDVPluginResult(status: .error, messageAs: error?.localizedDescription ?? "Unknown error")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                }
            })
        }
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
