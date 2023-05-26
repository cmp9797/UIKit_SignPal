//
//  MainViewController.swift
//  SignTalk
//
//  Created by Celine Margaretha on 23/05/23.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("View Controller")
        startRotationAnimation()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("yoww")
        startRotationAnimation()
    }
    
    func startRotationAnimation() {
            UIView.animate(
                withDuration: 1,
                delay: 1,
                options: [.curveEaseInOut, .autoreverse, .repeat],
                animations: {
                    // Rotate the image view to the left
                    let leftRotationTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 32)
                    self.logoImageView.transform = leftRotationTransform
                },
                completion: nil
            )
        }

}

