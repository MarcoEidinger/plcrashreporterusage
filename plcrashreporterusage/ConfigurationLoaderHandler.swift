//
//  ConfigurationLoaderHandler.swift
//  plcrashreporterusage
//
//  Created by Eidinger, Marco on 8/12/20.
//  Copyright © 2020 Eidinger, Marco. All rights reserved.
//

import Foundation
import SAPFoundation

class ConfigurationLoaderHandler: ConfigurationLoaderDelegate {
    func configurationProvider(_ provider: ConfigurationProviding?, didCompleteWith result: Bool) {
        fatalError("Generated crash for testing")
    }

    func configurationProvider(_ provider: ConfigurationProviding, didEncounter error: Error) {
        print("N/A")
    }

    func configurationProvider(_ loader: ConfigurationLoader, requestedInput: [String : [String : Any]], completionHandler: @escaping ([String : [String : Any]]) -> Void) {
        print("N/A")
    }

    private var loader: SAPFoundation.ConfigurationLoader!

    func load() {
        self.loader = SAPFoundation.ConfigurationLoader(delegate: self, providers: [ManagedConfigurationProvider()], outputHandler: nil)
        self.loader.loadConfiguration()
    }
}
