//
//  ContentView.swift
//  plcrashreporterusage
//
//  Created by Eidinger, Marco on 3/18/20.
//  Copyright © 2020 Eidinger, Marco. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Button(action: {
            fatalError("Generated crash for testing")
        }) {
            Text("Generate Crash")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
