//
//  ViewController.swift
//  FacialExpressions
//
//  Created by EmotivLifeSciences.
//  Copyright (c) 2013 EmotivLifeSciences. All rights reserved.
//

import UIKit

class FE_ViewController: UIViewController, FE_EngineWidgetDelegate {

    @IBOutlet weak var viewFacialExpression: UIView!
    @IBOutlet weak var viewCube: UIView!
    
    @IBOutlet weak var btClearData: UIButton!
    @IBOutlet weak var btTraining: UIButton!
    @IBOutlet weak var btFacialAction: UIButton!
    @IBOutlet weak var btMentalAction: UIButton!
    @IBOutlet weak var btSensitivity: UIButton!

    @IBOutlet weak var tableFacialAction: UITableView!
    @IBOutlet weak var tableMentalAction: UITableView!

    @IBOutlet weak var sliderSensitivity: UISlider!
    @IBOutlet weak var constraintCenterX: NSLayoutConstraint!
    @IBOutlet weak var constraintCenterY: NSLayoutConstraint!
    
    var dictionaryMentalAction : [String:MentalAction_enum] = ["Neutral":Mental_Neutral, "Push":Mental_Push, "Pull":Mental_Push, "Left":Mental_Left, "Right":Mental_Right, "Lift":Mental_Lift, "Drop":Mental_Drop]
    
    var dictionaryMapping : [String:String] = ["Neutral":"Neutral", "Smile":"Push", "Clench":"Right"]
    
    var currentPow: CGFloat!
    var currentAct: MentalAction_t!
    var isTraining: Bool!

    let engineWidget: FE_EngineWidget = FE_EngineWidget()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        engineWidget.delegate = self
        btTraining.layer.borderColor = UIColor.white.cgColor
        
        currentPow = 0.0
        currentAct = Mental_Neutral
        isTraining = false

        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(FE_ViewController.updateCubePosition), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showFacialTableAction(_ sender: UIButton) {
        self.tableMentalAction.isHidden = true
        self.sliderSensitivity.isHidden = true;
        self.tableFacialAction.isHidden = !self.tableFacialAction.isHidden
        
    }
    
    @IBAction func showMentalTableAction(_ sender: UIButton) {
        self.tableFacialAction.isHidden = true
        self.sliderSensitivity.isHidden = true;
        self.tableMentalAction.isHidden = !self.tableMentalAction.isHidden
    }
    
    @IBAction func updateSensitivity(_ sender: UIButton) {
        self.tableFacialAction.isHidden = true
        self.tableMentalAction.isHidden = true
        self.sliderSensitivity.isHidden = !self.sliderSensitivity.isHidden
    }
    
    @IBAction func trainingAction(_ sender: UIButton) {
        if !isTraining
        {
            let action = self.btFacialAction.title(for: UIControlState())!
            engineWidget.setTrainingAction(action)
            engineWidget.setTrainingControl(Facial_Start)
            isTraining = true
        }
    }
    
    @IBAction func clearData(_ sender: UIButton) {
        let action = self.btFacialAction.title(for: UIControlState())
        engineWidget.clearTrainingData(action)
    }
    
    @IBAction func updateSlider(_ sender: AnyObject) {
        let action = self.btFacialAction.title(for: UIControlState())
        self.btSensitivity.setTitle("\(Int32(self.sliderSensitivity.value))", for: UIControlState())
        engineWidget.setSensitivity(action, value: Int32(self.sliderSensitivity.value))
    }
    
    @objc func updateCubePosition() {
        
        UIView.animate(withDuration: 0.2, animations: ({
            let range = self.currentPow * 4
            
            //move cube to left or right direction
            if (self.currentAct.rawValue == Mental_Left.rawValue || self.currentAct.rawValue == Mental_Right.rawValue) && range > 0
            {
                self.constraintCenterX.constant = self.currentAct.rawValue == Mental_Left.rawValue ? min(70, self.constraintCenterX.constant + range) : max(-70, self.constraintCenterX.constant - range)
            }
            else if self.constraintCenterX.constant != 0
            {
                self.constraintCenterX.constant = self.constraintCenterX.constant > 0 ? max(0, self.constraintCenterX.constant - 4) : min(0, self.constraintCenterX.constant + 4)
            }
            
            //move cube to up or down direction
            if (self.currentAct.rawValue == Mental_Lift.rawValue || self.currentAct.rawValue == Mental_Drop.rawValue) && range > 0
            {
                self.constraintCenterY.constant = self.currentAct.rawValue == Mental_Lift.rawValue ? min(70, self.constraintCenterY.constant + range) : max(-70, self.constraintCenterY.constant - range)
            }
            else if self.constraintCenterY.constant != 0
            {
                self.constraintCenterY.constant = self.constraintCenterY.constant > 0 ? max(0, self.constraintCenterY.constant - 4) : min(0, self.constraintCenterY.constant + 4)
            }
            
            //move cube to forward or backward direction
            if (self.currentAct.rawValue == Mental_Pull.rawValue || self.currentAct.rawValue == Mental_Push.rawValue) && range > 0
            {
                self.viewCube.transform = self.currentAct.rawValue == Mental_Push.rawValue ? CGAffineTransform.identity.scaledBy(x: max(0.3, self.viewCube.transform.a - self.currentPow/4), y: max(0.3, self.viewCube.transform.d - self.currentPow/4)) : CGAffineTransform.identity.scaledBy(x: min(2.3, self.viewCube.transform.a + self.currentPow/4), y: min(2.3, self.viewCube.transform.d + self.currentPow/4))
            }
            else if self.viewCube.transform.a != 1
            {
                let scale : CGFloat! = self.viewCube.transform.a < 1 ? 0.05 : -0.05
                self.viewCube.transform = CGAffineTransform.identity.scaledBy(x: max(1, self.viewCube.transform.a + scale), y: max(1, self.viewCube.transform.d + scale))
            }
        }))
    }
}

extension FE_ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableFacialAction
        {
            return dictionaryMapping.keys.count
        }
        else
        {
            return dictionaryMentalAction.keys.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellString")
        if tableView == self.tableFacialAction
        {
            cell.textLabel?.text = Array(dictionaryMapping.keys)[indexPath.row]
            if engineWidget.isActionTrained(Array(dictionaryMapping.keys)[indexPath.row])
            {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        else
        {
            cell.textLabel?.text = Array(dictionaryMentalAction.keys)[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableFacialAction
        {
            self.tableFacialAction.isHidden = true
            self.btFacialAction.setTitle(Array(dictionaryMapping.keys)[indexPath.row], for: UIControlState())
            let action = dictionaryMapping[Array(dictionaryMapping.keys)[indexPath.row]]
            self.btMentalAction.setTitle(action, for: UIControlState())
            let value = engineWidget.getSensitivity(Array(dictionaryMapping.keys)[indexPath.row])
            btSensitivity.setTitle("\(value)", for: UIControlState())
            sliderSensitivity.setValue(Float(value), animated: true)
        }
        else
        {
            self.tableMentalAction.isHidden = true
            let newAction = Array(self.dictionaryMentalAction.keys)[indexPath.row]
            let alert = UIAlertController(title: "Message", message:"Do you want map \(newAction) to " + self.btFacialAction.currentTitle! , preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:nil))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ action in
                self.dictionaryMapping[self.btFacialAction.currentTitle!] = newAction
                self.btMentalAction.setTitle(newAction, for: UIControlState())
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension FE_ViewController {
    
    func updateLowerFaceAction(_ currentAction: String!, power: Float) {
        currentAct = dictionaryMentalAction[dictionaryMapping[currentAction]!]
        currentPow = CGFloat(power)
    }
    
    func onFacialExpressionTrainingStarted() {
        
    }
    
    func onFacialExpressionTrainingCompleted() {
        isTraining = false
        let alert = UIAlertController(title: "Training Completed", message: "Action was trained completed", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.tableFacialAction.reloadData()
    }
    
    func onFacialExpressionTrainingSuccessed() {
        let alert = UIAlertController(title: "Training Successed", message: "Do you want to accept this training?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Reject", style: UIAlertActionStyle.default, handler: { action in
            self.engineWidget.setTrainingControl(Facial_Reject)
        }))
        alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: { action in
            self.engineWidget.setTrainingControl(Facial_Accept)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onFacialExpressionTrainingFailed() {
        isTraining = false;
    }
    
    func onFacialExpressionTrainingDataErased() {
        let alert = UIAlertController(title: "Erase Completed", message: "Action was erased completed", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.tableFacialAction.reloadData()
    }
    
    func onFacialExpressionTrainingRejected() {
        isTraining = false;
    }
    
    func onFacialExpressionTrainingSignatureUpdated() {
        self.tableFacialAction.reloadData()
    }
}

