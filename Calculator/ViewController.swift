//
//  ViewController.swift
//  Calculator
//
//  Created by Hung-Yun Liao on 5/23/16.
//  Copyright © 2016 Hung-Yun Liao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var discreption: UILabel!
    
    private var typing = false
    
    @IBAction private func digitInput(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if typing {
            
            let textCurrentlyInDisplayed = display.text!
            display.text = textCurrentlyInDisplayed + digit
            
        } else {
            display.text = digit
        }
        //discreption.text = brain.description
        typing = true
    }
    
    private var displayedValue: Double { // get: get the value from the display; set: set the value to the display
        get {
            return Double(display.text!)! // will crash if you put string in the display (cannot be converted to Double)
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain: CalculatorBrain = CalculatorBrain() // big green arrow in the MVC diagram
    
    @IBAction private func performOperation(sender: UIButton) {
        var isErrorNumber: Bool = false
        
        if sender.currentTitle == "C" {
            
            brain.performOperand("C")
            typing = false
            displayedValue = 0
            discreption.text = ""
            
        } else {
            if typing {
                
                let numericalValue: Double? = Double(display.text!)
                
                if numericalValue != nil {
                    brain.setOperand(numericalValue!)
                    //discreption.text = brain.description
                } else {
                    display.text = "Error: number contains too many dots"
                    isErrorNumber = true
                }
                
                typing = false
            }
            
            if !isErrorNumber {
                if let operation = sender.currentTitle {
                    
                    brain.performOperand(operation)
                    //discreption.text = brain.description
                    
                }
                displayedValue = brain.result
                discreption.text = brain.description
            }
        }
        
    }
    
    var savedProgram : CalculatorBrain.PropertyList?
    /* also works: var savedProgram : [CalculatorBrain.PropertyList]? */
    
    @IBAction func save() {
        savedProgram = brain.program
        /* also works: savedProgram = brain.program as? [CalculatorBrain.PropertyList]*/
    }

    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayedValue = brain.result
        }
    }

    
}

