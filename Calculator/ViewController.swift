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
    
    private var typing = false
    
    @IBAction private func digitInput(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if typing {
            let textCurrentlyInDisplayed = display.text!
            display.text = textCurrentlyInDisplayed + digit
        } else {
            display.text = digit
        }
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
        if typing {
            brain.setOperand(displayedValue)
            typing = false
        }
        if let operation = sender.currentTitle {
            brain.performOperand(operation)
        }
        displayedValue = brain.result
    }
    
    var savedProgram : CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }

    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayedValue = brain.result
        }
    }

    
}

