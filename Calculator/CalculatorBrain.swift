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
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    private var dic : Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "±" : Operation.UnaryOperation({ -$0 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "−" : Operation.BinaryOperation({ $0 - $1 }),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
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
        get{
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperand(operation)
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
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
}