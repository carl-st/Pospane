//
//  SlidingWindow.swift
//  Pospane
//
//  Created by Karol Stępień on 30/10/2018.
//  Copyright © 2018 Carste IT. All rights reserved.
//

import Foundation
import SigmaSwiftStatistics

public struct Queue<T> {
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
    
    public var front: T? {
        return array.first
    }
}

func nn(diff: Double, array: [Double]) -> Double {
    var sum = 0.0
    for (index, value) in array.enumerated() {
        if index != 0 {
            if abs(value - array[index - 1]) >= diff {
                sum = sum + 1
            }
        }
    }
    return sum
}

func diff(array: [Double]) -> [Double] {
    var newArray: [Double] = []
    for i in 1..<array.count {
        newArray.append(array[i] - array[i-1])
    }
    return newArray
}

func slidingWindowFeatures(rr: Double, values: [Double], width: Int) -> (output: Int64, values: [Double]) {
    var queue = Queue(array: values)
    queue.enqueue(rr)
    if queue.count < 2 {
        return (0, queue.array)
    }
    if queue.count > width {
        queue.dequeue()
        print(queue)
    }
    let array = queue.array
    print("New array \(array)")
    let mRR = Sigma.average(array) ?? 1
    let hr = 60000 / mRR
    let sdnn = Sigma.standardDeviationSample(array) ?? 0
    let cvrr = sdnn / mRR
    let rmssd = sqrt(pow(Sigma.sum(diff(array: array)), 2.0))
    let pnn50 = nn(diff: 50.0, array: array)
    let pnn20 = nn(diff: 20.0, array: array)
    let sdsd = Sigma.standardDeviationSample(diff(array: array)) ?? 0
    let medRR = Sigma.median(array) ?? 0
    let minRR = Sigma.min(array) ?? 0
    let maxRR = Sigma.max(array) ?? 0
    let skewRR = Sigma.skewnessA(array) ?? 0
    let kurtRR = Sigma.kurtosisA(array) ?? 0
    let varRR = Sigma.varianceSample(array) ?? 0
    let diffMaxMin = maxRR - minRR
    let diffSum = Sigma.sum(diff(array: array))
    let diffMean = Sigma.average(diff(array: array)) ?? 0
    let diffMed = Sigma.median(diff(array: array)) ?? 0
    
    let model = TrainedModel70()
    guard let modelOutput = try? model.prediction(mRR: mRR, SDNN: sdnn, HR: hr, CVRR: cvrr, RMSSD: rmssd, PNN50: pnn50, PNN20: pnn20, SDSD: sdsd, medRR: medRR, minRR: minRR, maxRR: maxRR, skewRR: skewRR, kurtRR: kurtRR, varRR: varRR, diffMaxMin: diffMaxMin, diffSum: diffSum, diffMean: diffMean, diffMed: diffMed) else {
        fatalError("Model runtime error")
    }
    print("Y class: \(modelOutput.Y) Y probability: \(modelOutput.YProbability)")
    return (modelOutput.Y, array)
};
