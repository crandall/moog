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
    @IBOutlet weak var waveformButton: UIButton!
    @IBOutlet weak var multiviewButton: UIButton!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var buildLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureViews()
    }

    private
    func configureViews(){
        thereScopeButton.setTitle("ThereScope", for: .normal)
        waveformButton.setTitle("Waveform (demo only)", for: .normal)
        multiviewButton.setTitle("MultiView (demo only)", for: .normal)

        thereScopeButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        waveformButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        multiviewButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)

        buildLabel.font = UIFont.systemFont(ofSize: 15)
        buildLabel.textColor = .black

        thereScopeButton.isHidden = false
        waveformButton.isHidden = false
        multiviewButton.isHidden = false
        testButton.isHidden = true
        
        // get the build number:
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildLabel.text = "(build: \(buildNumber))"
        }


    }
    
    @IBAction func onThereScope(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .thereScope
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
