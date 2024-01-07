//
//  ShareViewController.swift
//  SnowCountry-Share-Extension
//
//  Created by Ryan Potter on 1/6/24.
//

import UIKit
import SLComposeServiceViewController
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        if let extensionItems = extensionContext?.inputItems as? [NSExtensionItem],
           let attachment = extensionItems.first?.attachments?.first as? NSItemProvider {
            if attachment.hasItemConformingToTypeIdentifier(kUTTypeJSON as String) ||
               attachment.hasItemConformingToTypeIdentifier("com.snowcountry.gpx") {
                return true
            }
        }
        return false
    }

    override func didSelectPost() {
        if let extensionItems = extensionContext?.inputItems as? [NSExtensionItem],
           let attachment = extensionItems.first?.attachments?.first as? NSItemProvider {
            if attachment.hasItemConformingToTypeIdentifier(kUTTypeJSON as String) {
                // Handle .json file
                attachment.loadItem(forTypeIdentifier: kUTTypeJSON as String, options: nil) { item, error in
                    if let data = item as? Data {
                        // Process the JSON data here
                        // You can save, parse, or perform any other necessary actions
                    }
                    
                    // Complete the request after processing
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
            } else if attachment.hasItemConformingToTypeIdentifier("com.snowcountry.gpx") {
                // Handle .gpx file
                attachment.loadItem(forTypeIdentifier: "com.snowcountry.gpx", options: nil) { item, error in
                    if let data = item as? Data {
                        // Process the GPX data here
                        // You can save, parse, or perform any other necessary actions
                    }
                    
                    // Complete the request after processing
                    self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                }
            }
        }
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
}
