//
//  TherescopeController.swift
//  moog
//
//  Created by Mike Crandall on 7/23/26.
//

import UIKit

class TherescopeController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureViews()
    }
    
    func configureViews(){
        print("configureViews")
        titleLabel.text = "TherescopeController"
    }
    

}
