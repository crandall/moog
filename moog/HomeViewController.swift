//
//  HomeViewController.swift
//  moog
//
//  Created by Mike Crandall on 10/19/23.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var foundationLogoIV : UIImageView!
    @IBOutlet weak var schoolLogoIV : UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func onOscillator(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .oscillator
            self.navigationController?.pushViewController(vc, animated: true)
        }
        

    }
    
    @IBAction func onOscillator2(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .oscillator2
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    @IBAction func onDynamic(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .dynamicOscillator
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onVocalTract(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
//            vc.demoType = .vocalTract
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "OscillatorViewController") as? OscillatorViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }

    @IBAction func onInputDeviceDemo(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .inputDevice
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }



}
