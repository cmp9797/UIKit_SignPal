//
//  GameViewController.swift
//  SignTalk
//
//  Created by Celine Margaretha on 25/05/23.
//

import UIKit

class GameViewController: UIViewController {
    
    /// A predictor instance that uses Vision and Core ML to generate prediction strings from a photo.
    let signPoseClassifier = SignPoseClassifier()
    let miniGameManager = GameManager()
    
    var detectedPose = SignPose(classificationName: "")
    var timer: Timer?

    @IBOutlet weak var questionLbl: UILabel!
    
    @IBOutlet weak var popUpIconLbl: UIImageView!
    @IBOutlet weak var popUpTextLbl: UILabel!
    
    @IBAction func takePhotoBtnAction(_ sender: Any) {
        present(cameraPicker, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLbl.text = miniGameManager.question
        detectedPose = signPoseClassifier.signPosePrediction
    }
    
    /// Notifies the view controller when a user selects a photo in the camera picker or photo library picker.
    /// - Parameter photo: A photo from the camera or photo library.
    func validatePhoto(_ photo: UIImage) {
        //DispatchQueue.global(qos: .userInitiated).async {
        self.signPoseClassifier.classifyTheSign(photo)
        
        detectedPose = signPoseClassifier.signPosePrediction
        //}
        showPopup()
    }
    
    func generateNewQuestion() {
        miniGameManager.setRandomQuestion()
        questionLbl.text = miniGameManager.question
    }
    
    func showPopup() {
//        print("quest: \(miniGameManager.question) // label: \(questionLbl.text ?? "nayy")")
//        print("ans: \(detectedPose)")
        
        if miniGameManager.isCorrect(detectedPose: detectedPose.classificationName) {
            popUpIconLbl!.image = UIImage(systemName: "checkmark.circle.fill")
            popUpIconLbl.tintColor = UIColor.green
            
            popUpTextLbl.text = "Yeay, you got it!"
            generateNewQuestion()
            
        } else {
            popUpIconLbl.image = UIImage(systemName: "xmark.circle.fill")
            popUpIconLbl.tintColor = UIColor.red

            popUpTextLbl.text = "Whoops, try again!"
        }
        
        self.popUpIconLbl.backgroundColor = UIColor(named: "White1")
        
        popUpIconLbl.isHidden = false
        popUpTextLbl.isHidden = false
        
        // Start the timer to dismiss the pop-up after a certain duration
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(dismissPopup), userInfo: nil, repeats: false)

    }
    
    @objc func dismissPopup() {
        popUpIconLbl.isHidden = true
        popUpTextLbl.isHidden = true
        timer?.invalidate()
    }
    
    
}
