//
//  GameViewController.swift
//  SubmarineGame
//
//  Created by Serhii Kopytchuk on 02.02.2022.
//

import UIKit
import CoreMotion

class GameViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var submarineImageView: UIImageView!
    @IBOutlet weak var sharkImageView: UIImageView!
    @IBOutlet weak var sharkImageSecondView: UIImageView!
    @IBOutlet weak var sharkImageThirdView: UIImageView!
    @IBOutlet weak var sharkImageForthView: UIImageView!
    @IBOutlet weak var boatImageView: UIImageView!
    @IBOutlet weak var upButtonView: UIImageView!
    @IBOutlet weak var downButtonView: UIImageView!
    @IBOutlet weak var ryphFirstImageView: UIImageView!
    @IBOutlet weak var ryphSecondImageView: UIImageView!
    @IBOutlet weak var waterFirstImageView: UIImageView!
    @IBOutlet weak var waterSecondImageView: UIImageView!
    @IBOutlet weak var oxygenView: UIView!
    @IBOutlet weak var airBalloonImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var missileImageView: UIImageView!
    @IBOutlet weak var explosionImageView: UIImageView!
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var blurAllScreen: UIVisualEffectView!
    @IBOutlet weak var leftMenuConstrain: NSLayoutConstraint!
    @IBOutlet weak var leftMenuView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var missileRelloadImageView: UIImageView!
    @IBOutlet weak var amountMissilesLabel: UILabel!
    
    
    
    //MARK: - var/let
    
    var screenWidth = CGFloat(UIScreen.main.fixedCoordinateSpace.bounds.width)
    var screenHeight = CGFloat(UIScreen.main.fixedCoordinateSpace.bounds.height)
    var oxygen = Double(100)
    var canFindOxygen = true
    var canReloadMissiles = true
    var loose = false
    var missileTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in}
    var canShoot = true
    var canShowFailure = true
    var name:String?
    var scoreNum:Int = 0
    var startMissiles = 3
    
    var missiles = 3{
        didSet{
            let missilesText = String(missiles)
            amountMissilesLabel.text = missilesText
        }
    }
    
    let motionManager = CMMotionManager()

    
 
    
    
    
    //MARK: - lifecycle function
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        //button up recognizer
        let upTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(upButtonPressed(_:)))
        upButtonView.isUserInteractionEnabled = true
        upButtonView.addGestureRecognizer(upTapRecognizer)
        
        //button down recognizer
        let downTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(downButtonPressed(_:)))
        downButtonView.isUserInteractionEnabled = true
        downButtonView.addGestureRecognizer(downTapRecognizer)
        
        //shadows
        downButtonView.layer.dropShadow()
        upButtonView.layer.dropShadow()
        amountMissilesLabel.layer.dropShadow()
        
        explosionImageView.isHidden = true
        blurAllScreen.isHidden = true
        
        leftMenuConstrain.constant = -leftMenuView.frame.width
        leftMenuView.rounded(radius: 30)
        
        fonts()
        Localize()
        importSettings()
        startGame()
        moveRyph()
        moveWater()
        oxygenCheck()
        score()
        moveAirBallon()
        moveReloadMissile()
        oxygenToFull()
        reloadMissiles()
        checkMissileTouch()
        checkForShake()
        endGame()
    }
    
    override func viewDidLayoutSubviews() {
        ScoreLabel.font = UIFont(name: "UA_Wadim_Giant", size: 20)
        menuButton.titleLabel?.font = UIFont(name: "UA_Wadim_Giant", size: 20)
        closeButton.titleLabel?.font = UIFont(name: "UA_Wadim_Giant", size: 20)
        exitButton.titleLabel?.font = UIFont(name: "UA_Wadim_Giant", size: 25)
        menuButton.titleLabel?.textColor = .black
        closeButton.titleLabel?.textColor = .black
        exitButton.titleLabel?.textColor = .black
        
    }
    
    
    //MARK: - IBActions
    
    @IBAction private func exitButtonPressed(_ sender: UIButton) {
        self.saveResults()
        self.hideEverything()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction private func toMenuButtonpressed(_ sender: UIButton) {
        canShowFailure = false
        leftMenuConstrain.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.blurAllScreen.alpha = 0.5
        }
        blurAllScreen.isHidden = false
    }
    
    @IBAction private func upButtonPressed(_ sender: UIButton) {
        if self.submarineImageView.frame.origin.y > 50{
            UIView.animate(withDuration: 0.2) {
                self.submarineImageView.frame.origin.y -= 30
            }
        }
    }
    
    
    @IBAction private func downButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.submarineImageView.frame.origin.y += 30
        }
    }
    
    
    @IBAction private func FireButtonPressed(_ sender: UIButton) {
        if canShoot{
            if missiles>0{
                missileFire()
            }
        }
    }
    
    @IBAction private func closeButtonPressed(_ sender: UIButton) {
        
        
        canShowFailure = true
        leftMenuConstrain.constant = -leftMenuView.frame.width
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        blurAllScreen.isHidden = true
        
    }
    
    //MARK: - func
    
    
  

    
    private func startGame(){
        sharkImageView.frame.origin.x  = screenHeight
        sharkImageSecondView.frame.origin.x  = screenHeight
        sharkImageThirdView.frame.origin.x  = screenHeight
        sharkImageForthView.frame.origin.x  = screenHeight
        airBalloonImageView.frame.origin.x  = screenHeight
        missileRelloadImageView.frame.origin.x = screenHeight
        boatImageView.frame.origin.x  = screenHeight
        missileImageView.frame.origin.x = screenHeight+500
        
        
        
        self.moveBoat()
        self.moveSharkSecond()
        self.moveShark()
        self.moveSharkThird()
        self.moveSharkForth()
    }
    
    
    
    
    private func moveAirBallon(){
        self.airBalloonImageView.frame.origin.y = CGFloat.random(in: 100...self.screenWidth-50)
        _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(Int.random(in: 30...55)), repeats: false) { _ in
            _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
                UIView.animate(withDuration: 0.05, delay: 0.0, options: [.curveLinear]) {
                    self.airBalloonImageView.frame.origin.x -= 10
                } completion: { _ in
                }
                if self.airBalloonImageView.frame.origin.x < -200{
                    self.airBalloonImageView.frame.origin.y = CGFloat.random(in: 150...self.screenWidth-100)
                    self.airBalloonImageView.frame.origin.x = self.screenHeight + CGFloat.random(in: 3000...4000)
                }
            })
        }
    }
    
    private func moveReloadMissile(){
        self.missileRelloadImageView.frame.origin.y = CGFloat.random(in: 100...self.screenWidth-50)
        _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(Int.random(in: 30...55)), repeats: false) { _ in
            _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
                UIView.animate(withDuration: 0.05, delay: 0.0, options: [.curveLinear]) {
                    self.missileRelloadImageView.frame.origin.x -= 10
                } completion: { _ in
                }
                if self.missileRelloadImageView.frame.origin.x < -200{
                    self.missileRelloadImageView.frame.origin.y = CGFloat.random(in: 150...self.screenWidth-100)
                    self.missileRelloadImageView.frame.origin.x = self.screenHeight + CGFloat.random(in: 3000...4000)
                }
            })
        }
    }
    
    
    
    private func moveShark(){
        self.sharkImageView.frame.origin.y = CGFloat.random(in: 100...self.screenWidth-50)
        _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
            UIView.animate(withDuration: 0.05, delay: 0.0, options: [.curveLinear]) {
                self.sharkImageView.frame.origin.x -= 11
            } completion: { _ in
            }
            if self.sharkImageView.frame.origin.x < CGFloat.random(in: -200...0){
                self.sharkImageView.frame.origin.y = CGFloat.random(in: 100...self.screenWidth-50)
                self.sharkImageView.frame.origin.x = self.screenHeight + CGFloat.random(in: 0...50)
            }
        })
    }
    
    private func moveSharkSecond(){
        self.sharkImageSecondView.frame.origin.y = CGFloat.random(in: 100...self.screenWidth-150)
        _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(Int32.random(in: 4...8)), repeats: false, block: { _ in
            _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
                UIView.animate(withDuration: 0.05, delay: 0.0, options: [.curveLinear]) {
                    self.sharkImageSecondView.frame.origin.x -= 13
                } completion: { _ in
                }
                if self.sharkImageSecondView.frame.origin.x < CGFloat.random(in: -200...0){
                    self.sharkImageSecondView.frame.origin.y = CGFloat.random(in: 100...self.screenWidth-50)
                    self.sharkImageSecondView.frame.origin.x = self.screenHeight + CGFloat.random(in: 0...50)
                }
            })
        })
    }
    
    private func moveSharkThird(){
        self.sharkImageThirdView.frame.origin.y = CGFloat.random(in: 100...self.screenWidth-150)
        _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(Int32.random(in: 8...16)), repeats: false, block: { _ in
            _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
                UIView.animate(withDuration: 0.05, delay: 0.0, options: [.curveLinear]) {
                    self.sharkImageThirdView.frame.origin.x -= 15
                } completion: { _ in
                }
                if self.sharkImageThirdView.frame.origin.x < CGFloat.random(in: -200...0){
                    self.sharkImageThirdView.frame.origin.y = CGFloat.random(in: 100...self.screenWidth-50)
                    self.sharkImageThirdView.frame.origin.x = self.screenHeight + CGFloat.random(in: 0...50)
                }
            })
        })
    }
    
    private func moveSharkForth(){
        self.sharkImageForthView.frame.origin.y = CGFloat.random(in: 100...self.screenWidth-150)
        _ = Timer.scheduledTimer(withTimeInterval: TimeInterval(Int32.random(in: 1...30)), repeats: false, block: { _ in
            _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
                UIView.animate(withDuration: 0.05, delay: 0.0, options: [.curveLinear]) {
                    self.sharkImageForthView.frame.origin.x -= 20
                } completion: { _ in
                }
                if self.sharkImageForthView.frame.origin.x < CGFloat.random(in: -200...0){
                    self.sharkImageForthView.frame.origin.y = CGFloat.random(in: 100...self.screenWidth-50)
                    self.sharkImageForthView.frame.origin.x = self.screenHeight + CGFloat.random(in: 0...50)
                }
            })
        })
    }
    
    
    private func moveBoat(){
        _ = Timer.scheduledTimer(withTimeInterval: 5 , repeats: false, block: { _ in
            _ = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
                UIView.animate(withDuration: 0.01, delay: 0.0, options: [.curveLinear]) {
                    self.boatImageView.frame.origin.x -= 2
                } completion: { _ in}
            })
            _ = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { _ in
                if self.boatImageView.frame.origin.x < -100 - CGFloat.random(in: 0...300){
                    self.boatImageView.frame.origin.x = self.screenHeight
                }
            })
        })
    }
    
    private func moveRyph(){
        ryphSecondImageView.frame.origin.y = ryphFirstImageView.frame.origin.y
        ryphSecondImageView.frame.origin.x = screenHeight
        let firstPos = self.ryphFirstImageView.frame.origin.x
        
        let ryphWidth = -self.ryphFirstImageView.frame.width
        UIView.animate(withDuration: 5, delay: 0.0, options: [.repeat, .curveLinear]) {
            self.ryphSecondImageView.frame.origin.x = self.ryphFirstImageView.frame.origin.x
        }
        UIView.animate(withDuration: 5, delay: 0.0, options: [.repeat, .curveLinear]) {
            self.ryphFirstImageView.frame.origin.x = firstPos + ryphWidth
        }
    }
    
    private func moveWater(){
        waterSecondImageView.frame.origin.y = waterFirstImageView.frame.origin.y
        waterSecondImageView.frame.origin.x = screenHeight
        let firstPos = self.waterFirstImageView.frame.origin.x
        
        let ryphWidth = -self.waterSecondImageView.frame.width
        UIView.animate(withDuration: 5, delay: 0.0, options: [.repeat, .curveLinear]) {
            self.waterSecondImageView.frame.origin.x = self.waterFirstImageView.frame.origin.x
        }
        UIView.animate(withDuration: 5, delay: 0.0, options: [.repeat, .curveLinear]) {
            self.waterFirstImageView.frame.origin.x = firstPos + ryphWidth
        }
    }
    
    
    private func endGame(){
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {  _ in
            if self.submarineImageView.frame.origin.y > self.screenWidth - 2 * self.ryphFirstImageView.frame.height && self.loose == false{
                self.loose = true
                self.saveResults()
                self.showFailureWindow()
            }
            
            if self.submarineImageView.frame.intersects(self.sharkImageView.frame) && self.loose == false{
                self.sharkImageView.frame.origin.x = 0
                self.saveResults()
                self.showFailureWindow()
            }
            if self.submarineImageView.frame.intersects(self.sharkImageSecondView.frame) && self.loose == false {
                self.sharkImageSecondView.frame.origin.x = 0
                self.saveResults()
                self.showFailureWindow()
            }
            if self.submarineImageView.frame.intersects(self.sharkImageThirdView.frame) && self.loose == false {
                self.sharkImageThirdView.frame.origin.x = 0
                self.saveResults()
                self.showFailureWindow()
            }
            if self.submarineImageView.frame.intersects(self.sharkImageForthView.frame) && self.loose == false {
                self.sharkImageForthView.frame.origin.x = 0
                self.saveResults()
                self.showFailureWindow()
            }
            if self.submarineImageView.frame.intersects(self.boatImageView.frame) && self.loose == false {
                self.boatImageView.frame.origin.x = 0
                self.saveResults()
                self.showFailureWindow()
            }
            if self.oxygen <= 0 && self.loose == false {
                self.saveResults()
                self.showFailureWindow()
            }
        }
    }
    
    private func showFailureWindow(){
        if canShowFailure{
            self.loose = true
            let controller = navigationController?.storyboard?.instantiateViewController(withIdentifier: "FailureViewController") as! FailureViewController
            controller.score = self.ScoreLabel.text
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
    private func score(){
        ScoreLabel.text = "Score: 0"
        _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.scoreNum +=  1
            self.ScoreLabel.text = "score:".localized()
            self.ScoreLabel.text? += String(self.scoreNum)
        }
    }
    
    private func oxygenToFull(){
        if canFindOxygen{
            _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                if self.submarineImageView.frame.intersects(self.airBalloonImageView.frame){
                    self.oxygen = 100
                    self.airBalloonImageView.frame.origin.x = CGFloat.random(in: 3000...4000)
                }
            })
        }
    }
    
    private func reloadMissiles(){
        if canReloadMissiles{
            _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                if self.submarineImageView.frame.intersects(self.missileRelloadImageView.frame){
                    self.missiles = self.startMissiles
                    self.missileRelloadImageView.frame.origin.x = CGFloat.random(in: 3000...4000)
                }
            })
        }
    }
    
    private func oxygenCheck() {
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            if self.submarineImageView.frame.origin.y <= 50{
                if self.oxygen > 100{
                    self.oxygen = 100
                }else{
                    self.oxygen += 2
                    
                }
            }else{
                self.oxygen -= 0.7
            }
        })
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveLinear, .repeat]) {
                self.oxygenView.frame.origin.y = self.screenWidth - self.screenWidth/100 * self.oxygen
            } completion: { _ in
                
            }
            
        })
    }
    
    private func missileFire(){
        missiles -= 1
        canShoot = false
        missileImageView.center = submarineImageView.center
        missileTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true, block: { _ in
            UIView.animate(withDuration: 0.02, delay: 0.0, options: [.curveLinear]) {
                
                self.missileImageView.frame.origin.x += 11
            }
            if self.missileImageView.frame.origin.x > self.screenHeight{
                self.missileTimer.invalidate()
                self.canShoot = true
            }
        })
    }
    
    private func checkMissileTouch(){
        _ = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] _ in
            if missileImageView.frame.intersects(sharkImageView.frame){
                showExplosion()
                missileImageView.frame.origin.x = screenHeight+500
                sharkImageView.frame.origin.x = 2000
            }
            if missileImageView.frame.intersects(sharkImageSecondView.frame){
                showExplosion()
                missileImageView.frame.origin.x = screenHeight+500
                sharkImageSecondView.frame.origin.x = 2000
            }
            if missileImageView.frame.intersects(sharkImageThirdView.frame){
                showExplosion()
                missileImageView.frame.origin.x = screenHeight+500
                sharkImageThirdView.frame.origin.x = 2000
            }
            if missileImageView.frame.intersects(sharkImageForthView.frame){
                showExplosion()
                missileImageView.frame.origin.x = screenHeight+500
                sharkImageForthView.frame.origin.x = 2000
            }
            if missileImageView.frame.intersects(boatImageView.frame){
                showExplosion()
                missileImageView.frame.origin.x = screenHeight+500
            }
        }
    }
    
    private func showExplosion() {
        self.explosionImageView.center = missileImageView.center
        self.explosionImageView.frame.origin.x += explosionImageView.frame.width/2
        self.explosionImageView.isHidden = false
        moveExplotion()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.explosionImageView.isHidden = true
        }
    }
    
    private func moveExplotion(){
        UIView.animate(withDuration: 1.1, delay: 0.0, options: [.repeat, .curveLinear]) {
            self.explosionImageView.frame.origin.x -= 150
        }
    }
    
    private func fonts(){
        ScoreLabel.font = UIFont(name: "UA_Wadim_Giant", size: 20)
        menuButton.titleLabel?.font = UIFont(name: "UA_Wadim_Giant", size: 20)
        closeButton.titleLabel?.font = UIFont(name: "UA_Wadim_Giant", size: 20)
        exitButton.titleLabel?.font = UIFont(name: "UA_Wadim_Giant", size: 30)
        amountMissilesLabel.font = UIFont(name: "UA_Wadim_Giant", size: 30)
        menuButton.titleLabel?.textColor = .black
        closeButton.titleLabel?.textColor = .black
        exitButton.titleLabel?.textColor = .black
        amountMissilesLabel.textColor = .black
    }
    
    private func importSettings(){
        
        guard let settings = UserDefaults.standard.value(Settings.self, forKey: "settings") else {return}

        name = settings.name
        
        switch settings.image{
        case 1:
            let image = UIImage(named: "submarineImage")
            self.submarineImageView.image = image
        case 2:
            let image = UIImage(named: "secondSubmarineImage")
            self.submarineImageView.image = image
        case 3:
            let image = UIImage(named: "thirdSubmarineImage")
            self.submarineImageView.image = image
        default:
            let image = UIImage(named: "submarineImage")
            self.submarineImageView.image = image
        }
        missiles = settings.missilesOnStart
        startMissiles = settings.missilesOnStart
        canFindOxygen = settings.reloadOxygen
        if canFindOxygen == false{
            airBalloonImageView.isHidden = true
        }
        canReloadMissiles = settings.reloadMissiles
        if canReloadMissiles == false{
            missileRelloadImageView.isHighlighted = true
        }
    }
    
    private func saveResults(){
        let result = Result(name: name ?? "", score: scoreNum)
        var resultsArray = UserDefaults.standard.value([Result].self, forKey: "resultArray") ?? [Result]()
        resultsArray.append(result)
//        resultsArray = [Result]()
        UserDefaults.standard.set(encodable: resultsArray, forKey: "resultArray")
    }
    
    
    func hideEverything(){
       submarineImageView.isHidden = true
       sharkImageView.isHidden = true
       sharkImageSecondView.isHidden = true
       sharkImageThirdView.isHidden = true
       sharkImageForthView.isHidden = true
       boatImageView.isHidden = true
       ryphFirstImageView.isHidden = true
       ryphSecondImageView.isHidden = true
       waterFirstImageView.isHidden = true
       waterSecondImageView.isHidden = true
       airBalloonImageView.isHidden = true
       explosionImageView.isHidden = true
       missileRelloadImageView.isHidden = true
   }
    
    
    func Localize(){
        
        closeButton.setTitle("close".localized(), for: .normal)
        exitButton.setTitle("exit".localized(), for: .normal)
        
        
//        fireButton.setTitle("fire".localized(), for: .normal)
        
        menuButton.setTitle("menu".localized(), for: .normal)
    }
    
    private func checkForShake(){
        if motionManager.isDeviceMotionAvailable {
                    motionManager.gyroUpdateInterval = 0.1
                    motionManager.startGyroUpdates(to: .main) { (data, error) in
                        if let rate = data?.rotationRate {
                            if rate.x > 1 || rate.y > 1 || rate.z > 1{
                                self.submarineImageView.frame.origin.y = 45
                            }
                        }
                    }
                }
    }

    
}





//MARK: - extensions



