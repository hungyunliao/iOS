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
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()  // an anyobject array storing a series of operands and operation symbols
    
    func setOperand(operand: Double) {
        
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
        "=" : Operation.Equals
    ]
    
    enum Operation {  // collection of datatypes
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func performOperand(symbol: String) {
        // let constant = dic[symbol]
        // accumulator = constant! (has to wrapped since the dic might not contain the symbol, so it might be nil. But it is risky to crash, so use "if")
        /*if let constant = dic[symbol] {
         accumulator = constant
         }*/
        internalProgram.append(symbol)
        inputString.append(String(symbol))
        if let operation = dic[symbol] {
            switch operation {
            case Operation.Constant(let value):
                accumulator = value
            case Operation.UnaryOperation(let foo):
                accumulator = foo(accumulator)
            case Operation.BinaryOperation(let foo):
                executePendingOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: foo, firstOperand: accumulator)
            case .Equals:
                executePendingOperation()
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
    
    var description: String {
        get {
            let displayedDiscreption: String = descriptionStringProcessing(inputString)
            
            if pending != nil {
                return displayedDiscreption + inputStringPending
            } else {
                return displayedDiscreption
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
            //inputString.removeAll()
            return accumulator
        }
    }
    
    private func descriptionStringProcessing(arr: [String]) -> String {
        var retString = ""
        var hasLeft: Bool = false
        var closeLength = 0
        var reversedArr = [String]()
        var i = arr.count - 1
        
        while(i >= 0) {
            
            if hasLeft && closeLength == 0 {
                reversedArr.append("(")
                reversedArr.append("√")
                hasLeft = false
            }
            
            if closeLength > 0 {
                closeLength -= 1
            }
            if arr[i] == "√" {
                reversedArr.append(")")
                hasLeft = true

                if arr[i-1] != "=" {
                    closeLength = 1
                } else {
                    closeLength = i
                }
                
            } else {
                reversedArr.append(arr[i])
            }
            
            if hasLeft && i == 0 {
                reversedArr.append("(")
                reversedArr.append("√")
                hasLeft = false
            }
            
            i -= 1
            
        }
        
        
        
        
        for element in reversedArr.reverse() {
            if element != "=" {
                retString += element
            }
        }
        if (arr[arr.count - 1] == "=") {
            retString += "="
        }
        return retString
    }
    
}