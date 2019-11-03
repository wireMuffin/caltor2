//
//  ViewController.swift
//  caltor2
//
//  Created by Kevin on 22/4/2018.
//  Updated by Kevin on 1/11/2019.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import MathParser

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var processDisplay: UITextField!
    @IBOutlet weak var resultDisplay: UILabel!
    
    var ans = 0.0
//    var isExec = false
    var openBracketNo = 0
    var closeBracketNo = 0
    
    func translate(processString: String) -> String{
        var outputString = ""
        for c in (processString){
            //counting the number of open and close brackets,
            //if number of open brackets > number of close brackets
            //it means the user forgot to input some close bracket
            //so the program we automatically add the missing close bracket for the user in the background
            if c == "("{
                openBracketNo += 1
            } else if c == ")"{
                closeBracketNo += 1
            }
            
            if c == "^"{ //** means "to the power of" in DDMathParser
                outputString += "**"
            } else if c == "%"{
                outputString += "%"
            } else if c == "@"{
                outputString = outputString + "(" + String(ans) + ")"
            } else {
                outputString += String(c)
            }
        }
        //print(outputString)
        return outputString
    }
    
    func calculate(_: String) -> Double? {
        var processString = translate(processString: processDisplay.text!)
        if openBracketNo > closeBracketNo { //calculating numbers of bracket, details can be found in the translate() section
            for _ in 1...(openBracketNo-closeBracketNo){
                processString += ")"
            }
        }
        openBracketNo = 0
        closeBracketNo = 0
        //print(processString)
        do{
            let operatorSet = OperatorSet(interpretsPercentSignAsModulo: false)
            let expression = try Expression(string: processString, operatorSet: operatorSet)
            let value = try Evaluator.default.evaluate(expression)
            return value
        } catch {
            print("Error!")
        }
        return nil
    }
    
    @IBAction func processDisplayChanged(_ sender: Any) {
        if let tempAns = calculate(processDisplay.text!){
            let numberFormatter = NumberFormatter()
            if String(tempAns).count < 12{
                numberFormatter.usesSignificantDigits = true
                numberFormatter.maximumSignificantDigits = 12
            } else{
                numberFormatter.positiveFormat = "0.#########E+0"
            }
            resultDisplay.text = numberFormatter.string(from: NSNumber(value: tempAns))
        } else{
            resultDisplay.text = ""
        }
    }
    
    @IBAction func processDisplayEditingEnd(_ sender: Any) {
        dismissKeyboard()
    }
    
    
    @IBAction func decimalDot(_ sender: Any) { // . button
        processDisplay.text = processDisplay.text! + "."
        processDisplayChanged((Any).self);
    }
    
    @IBAction func numbers(_ sender: UIButton) {
//        if(isExec){
//            processDisplay.text = ""
//            isExec = false
//        }
        processDisplay.text = processDisplay.text! + String(sender.tag-1)   //sender.tag is 1 larger than the button value
        processDisplayChanged((Any).self);
    }
    
    @IBAction func acButton(_ sender: UIButton) {   //reset the processDisplay after AC is pressed
        processDisplay.text = ""
        resultDisplay.text = "0"
    }
    
    @IBAction func delButton(_ sender: UIButton) {
//        if(isExec){
//            return
//        }
        if (processDisplay.text != ""){ //delete the last character from processDisplay.text
            processDisplay.text = String((processDisplay.text?.dropLast())!)
        }
        processDisplayChanged((Any).self);
    }
    
    @IBAction func operations(_ sender: UIButton) {
//        if(isExec){
//            processDisplay.text = ""
//            isExec = false
//        }
        if(sender.tag == 10){   //+
            processDisplay.text = processDisplay.text! + "+"
        }
        else if(sender.tag == 11){   //-
            processDisplay.text = processDisplay.text! + "-"
        }
        else if(sender.tag == 12){   //×
            processDisplay.text = processDisplay.text! + "×"
        }
        else if(sender.tag == 13){   // ÷
            processDisplay.text = processDisplay.text! + "÷"
        }
        else if(sender.tag == 14){   //Ans
            processDisplay.text = processDisplay.text! + "@"
            processDisplayChanged((Any).self);
        }
        else if(sender.tag == 20){   //sin
            processDisplay.text = processDisplay.text! + "sin("
        }
        else if(sender.tag == 21){   //cos
            processDisplay.text = processDisplay.text! + "cos("
        }
        else if(sender.tag == 22){   //tan
            processDisplay.text = processDisplay.text! + "tan("
        }
        else if(sender.tag == 24){   //(
            processDisplay.text = processDisplay.text! + "("
        }
        else if(sender.tag == 25){   //)
            processDisplay.text = processDisplay.text! + ")"
        }
        else if(sender.tag == 26){  //log
            processDisplay.text = processDisplay.text! + "log("
        }
        else if(sender.tag == 27){  //ln
            processDisplay.text = processDisplay.text! + "ln("
        }
        else if(sender.tag == 30){  //^
            processDisplay.text = processDisplay.text! + "^("
        }
        else if(sender.tag == 31){  //^-1
            processDisplay.text = processDisplay.text! + "^-1"
        }
        else if(sender.tag == 32){  //^2
            processDisplay.text = processDisplay.text! + "^2"
        }
        else if(sender.tag == 40){  //%
            processDisplay.text = processDisplay.text! + "%"
            processDisplayChanged((Any).self);
        }
        else if(sender.tag == 50){  //sqrt
            processDisplay.text = processDisplay.text! + "√("
        }
    }
    
    @IBAction func exeButton(_ sender: Any) {
        if let tempAns = calculate(processDisplay.text!){
            ans = tempAns
            let numberFormatter = NumberFormatter()
            if String(ans).count < 12{
                numberFormatter.usesSignificantDigits = true
                numberFormatter.maximumSignificantDigits = 12
            } else{
                numberFormatter.positiveFormat = "0.###########E+0"
            }
            processDisplay.text = numberFormatter.string(from: NSNumber(value: ans))
            resultDisplay.text = ""
        } else{
            if (processDisplay.text == ""){
                resultDisplay.text = "0"
            }else{
                resultDisplay.text = "ERROR"
            }
        }
//        isExec = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//         Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
    }

}

