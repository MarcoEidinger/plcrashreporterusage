//
//  UnstableAppApi.swift
//  plcrashreporterusage
//
//  Created by Eidinger, Marco on 8/12/20.
//  Copyright © 2020 Eidinger, Marco. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class UnstableAppApi {

    private var items: [String] = []
    private let concurrentQueue = DispatchQueue(label: "concurrent.queue", attributes: .concurrent)

    func lotsOfData() {
        var baseString = "Please concatenate me"
        for _ in 0...300000 {
            baseString = baseString + baseString
        }
        print(baseString)
    }

    func tryToAccessVariable() {
        var view: UIView!
        print(view.alpha)
    }

    func tryToAccessVariableAsync() {
        concurrentQueue.asyncAfter(deadline: .now() + 1) {
            var player: AVPlayer!
            print(player.currentTime())
        }
    }

    func fatalFlow() {
        fatalError("Forced Crash")
    }

    func mathIsComplicated() {
        var sum = 10;
        for i in 0...2 {
            sum /= i; // Error: division by zero on the first iteration
        }
    }

    func outOfBounds() {
        let myArray = [1,1,1]
        print(myArray[11])
    }

    func floatUntilCrash() {
        let a:Float = 9999999999999999999999.9
        let b = "0.000000000000000000001"
        let c:Float = a/Float(b)!
        let x = Int(c)
    }

    static func handleCustomUrl(_ url: URL) {
        let instance = UnstableAppApi()
        let number = Int.random(in: 0 ..< 7)
        switch number {
        case 0:
            instance.mathIsComplicated()
        case 1:
            instance.outOfBounds()
        case 2:
            instance.floatUntilCrash()
        case 3:
            instance.lotsOfData()
        case 4:
            instance.tryToAccessVariable()
        case 5:
            instance.tryToAccessVariableAsync()
        default:
            instance.fatalFlow()
        }
    }

    static func handleMemoryWarning() {
        let instance = UnstableAppApi()
        let number = Int.random(in: 0 ..< 7)
        switch number {
        case 0:
            instance.mathIsComplicated()
        case 1:
            instance.outOfBounds()
        case 2:
            instance.floatUntilCrash()
        case 3:
            instance.lotsOfData()
        case 4:
            instance.tryToAccessVariable()
        case 5:
            instance.tryToAccessVariableAsync()
        default:
            instance.fatalFlow()
        }
    }

    func handleShake() {
        let number = Int.random(in: 0 ..< 7)
        switch number {
        case 0:
            self.mathIsComplicated()
        case 1:
            self.outOfBounds()
        case 2:
            self.floatUntilCrash()
        case 3:
            self.lotsOfData()
        case 4:
            self.tryToAccessVariable()
        case 5:
            self.tryToAccessVariableAsync()
        default:
            self.fatalFlow()
        }
    }

}
