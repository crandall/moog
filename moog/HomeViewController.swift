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
    @IBOutlet weak var thereScopeButton: UIButton!
    @IBOutlet weak var sineOnlyButton: UIButton!
    @IBOutlet weak var swiftButton: UIButton!
    @IBOutlet weak var buildLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        self.configureViews()
    }
    
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }


    private
    func configureViews(){
        sineOnlyButton.setTitle("Sine/Noise only", for: .normal)
        thereScopeButton.setTitle("ThereScope", for: .normal)
        swiftButton.setTitle("Swift", for: .normal)

        thereScopeButton.layer.cornerRadius = 5
        thereScopeButton.layer.borderWidth = 1
        thereScopeButton.layer.borderColor = UIColor.black.cgColor
        
        sineOnlyButton.layer.cornerRadius = 5
        sineOnlyButton.layer.borderWidth = 1
        sineOnlyButton.layer.borderColor = UIColor.black.cgColor
        
        swiftButton.layer.cornerRadius = 5
        swiftButton.layer.borderWidth = 1
        swiftButton.layer.borderColor = UIColor.black.cgColor
        swiftButton.setTitleColor(.black, for: .normal)

        
        buildLabel.font = UIFont.systemFont(ofSize: 15)
        buildLabel.textColor = .black

        thereScopeButton.isHidden = false
        sineOnlyButton.isHidden = false

        // get the build number:
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildLabel.text = "(build: \(buildNumber))"
        }
    }
    
    @IBAction func onSwift(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "TherescopeController", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TherescopeController") as? TherescopeController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onThereScope(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .thereScope
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onSineOnly(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .sineOnly
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onWaveform(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .waveform
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onMultiview(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .multiview
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onTest(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .test
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func onOscillator(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .oscillator
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
//    @IBAction func onDynamic(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
//            vc.demoType = .dynamicOscillator
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//
//    @IBAction func onTuner(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
//            vc.demoType = .tuner
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//
//    @IBAction func onMultiView(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
//            vc.demoType = .multiview
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
    
}
