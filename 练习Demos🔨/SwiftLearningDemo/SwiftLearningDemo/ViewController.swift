//
//  ViewController.swift
//  SwiftLearningDemo
//
//  Created by MichaelMao on 2019/3/21.
//  Copyright © 2019 MichaelMao. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.green
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.pushToRxPracticeVC()
    }

}

extension ViewController {
    
    func pushToRxPracticeVC() {
        let practice = RxPractice()
        self.navigationController?.pushViewController(practice, animated: true)
    }
}

