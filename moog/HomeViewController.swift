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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func configureViews(){
        thereScopeButton.setTitle("ThereScope", for: .normal)
        waveformButton.setTitle("Waveform", for: .normal)
        multiviewButton.setTitle("Multi View Sampler", for: .normal)

        thereScopeButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        waveformButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        multiviewButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)

    }
    
    @IBAction func onThereScope(){
        print("onThereScope")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .oscillator
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func onWaveform(){
        print("onWaveform")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .waveform
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onMultiview(){
        print("onMultiview")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
            vc.demoType = .multiview
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }


//    @IBAction func onOscillator(){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let vc = storyboard.instantiateViewController(withIdentifier: "StageViewController") as? StageViewController {
//            vc.demoType = .oscillator
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//    
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
