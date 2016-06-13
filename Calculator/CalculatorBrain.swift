//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Hung-Yun Liao on 5/24/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

// This is a Model file

import Foundation

class CalculatorBrain { // it is a base class. No superclass
    
    private var inputString = [String]()
    private let inputStringPending: String = "..."
    private let inputStringNotPending: String = "="
    private var isSetOperand = false
    
    func addUnaryOperation(symbol: String, operation: (Double) -> Double) {
        dic[symbol] = Operation.UnaryOperation(operation)
    }
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()  // an anyobject array storing a series of operands and operation symbols
    
    func setOperand(operand: Double) {
        isSetOperand = true
        accumulator = operand
        internalProgram.append(operand)
        inputString.append(String(operand))
    }
    
    private var dic : Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "tan" : Operation.UnaryOperation(tan),
        "±" : Operation.UnaryOperation({ -$0 }),
        "10^" : Operation.UnaryOperation({ pow(10, $0) }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "−" : Operation.BinaryOperation({ $0 - $1 }),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "pow" : Operation.BinaryOperation({ pow($0, $1) }),
        "=" : Operation.Equals,
        "C" : Operation.Clear
    ]
    
    enum Operation {  // collection of datatypes
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
    }
    
    func performOperand(symbol: String) {
        // let constant = dic[symbol]
        // accumulator = constant! (has to wrapped since the dic might not contain the symbol, so it might be nil. But it is risky to crash, so use "if")
        /*if let constant = dic[symbol] {
         accumulator = constant
         }*/
//        var reversedInputString = [String]()
//        var index = 0
        
        
        
//        if inputString.contains("=") && (inputString.reverse().indexOf("=")! - 1) >= 0 {
//            
//            let reversedInputString = inputString.reverse()
//            let index = reversedInputString.indexOf("=")! - 1
//            if Double(reversedInputString[index]) != nil {
//                let operand = Double(reversedInputString[index])!
//                inputString.removeAll()
//                inputString.append(String(operand))
//            }
//        }
        
        if inputString.contains("=") && pending == nil {
            if let lastNum = Double(inputString.last!) {
                inputString.removeAll()
                inputString.append(String(lastNum))
            }
        }
        
        if symbol == "=" && !isSetOperand {
            inputString.append(String(accumulator))
        }
        
        internalProgram.append(symbol)
        inputString.append(symbol)
        
        isSetOperand = false
        
        if let operation = dic[symbol] {
            switch operation {
            case Operation.Constant(let value):
                accumulator = value
                isSetOperand = true
            case Operation.UnaryOperation(let foo):
                accumulator = foo(accumulator)
                isSetOperand = true
            case Operation.BinaryOperation(let foo):
                executePendingOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: foo, firstOperand: accumulator)
            case .Equals:
                executePendingOperation()
            case .Clear:
                clearAll()
            }
        }
        
        
    }
    
    func executePendingOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    var pending: PendingBinaryOperationInfo?
    
    struct PendingBinaryOperationInfo {
        var binaryFunction : (Double, Double) -> Double
        var firstOperand: Double
    }
    
    typealias PropertyList = AnyObject
    
    var program : PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let number = op as? Double {
                        setOperand(number)
                    } else if let symbol = op as? String {
                        performOperand(symbol)
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    func clearAll() {
        clear()
        inputString.removeAll()
    }
    
    var description: String {
        get {
            let displayedDiscreption: String = descriptionStringProcessing(inputString)
            
            if isPartialResult {
                return displayedDiscreption + inputStringPending
            } else {
                return displayedDiscreption + inputStringNotPending
            }
        }
    }
    
    var isPartialResult: Bool {
        get {
            if pending == nil {
                return false
            } else {
                return true
            }
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
    private func descriptionStringProcessing(arr: [String]) -> String {
        var retString = ""
        var storedUnaryOperator = [String]()
        var closeLength = [Int]()
        var reversedArr = [String]()
        var i = arr.count - 1
        
        while(i >= 0) {
            
            if !storedUnaryOperator.isEmpty && closeLength.contains(0) {
                var indexOfTheOperatorNeedsToBeShown = 0
                for element in 0..<closeLength.count {
                    if closeLength[element] == 0 {
                        indexOfTheOperatorNeedsToBeShown = element
                        closeLength.removeAtIndex(element)
                    }
                }
                
                reversedArr.append("(")
                reversedArr.append(storedUnaryOperator[indexOfTheOperatorNeedsToBeShown])
                storedUnaryOperator.removeAtIndex(indexOfTheOperatorNeedsToBeShown)
            }
            
            for element in 0..<closeLength.count {
                if closeLength[element] > 0 {
                    closeLength[element] -= 1
                }
            }

            switch arr[i] {
            case "√", "🔴√", "cos", "sin", "tan" :
                reversedArr.append(")")
                storedUnaryOperator.append(arr[i])
                
                if arr[i-1] != "=" {
                    closeLength.append(1)
                } else {
                    closeLength.append(i)
                }
                
            default :
                reversedArr.append(arr[i])
            }
            i -= 1
        }
        
        while !storedUnaryOperator.isEmpty {
            reversedArr.append("(")
            reversedArr.append(storedUnaryOperator.last!)
            storedUnaryOperator.removeLast()
        }
        
        for element in reversedArr.reverse() {
            if element != "=" {
                retString += element
            }
        }
        
        return retString
    }
}