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
    let miniGameManager = MiniGameManager()
    
    var detectedPose = ""
    var timer: Timer?

    @IBOutlet weak var questionLbl: UILabel!
    
    @IBOutlet weak var popUpIconLbl: UIImageView!
    @IBOutlet weak var popUpTextLbl: UILabel!
    
    @IBAction func takePhotoBtnAction(_ sender: Any) {
        present(cameraPicker, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLbl.text = miniGameManager.question
    }
    
}


extension GameViewController {
    // MARK: Main storyboard updates
    /// Updates the storyboard's image view.

    /// Notifies the view controller when a user selects a photo in the camera picker or photo library picker.
    /// - Parameter photo: A photo from the camera or photo library.
    func validatePhoto(_ photo: UIImage) {
//        DispatchQueue.global(qos: .userInitiated).async {
            self.classifyTheSign(photo)

//        }
        showPopup()
    }
    
    func showPopup() {
        print("quest: \(miniGameManager.question) // label: \(questionLbl.text ?? "nayy")")
        print("ans: \(detectedPose)")
        
        if miniGameManager.isCorrect(detectedPose: detectedPose) {
            popUpIconLbl!.image = UIImage(systemName: "checkmark.circle.fill")
            popUpIconLbl.tintColor = UIColor.green
            
            popUpTextLbl.text = "Yeay, you got it!"
            
        } else {
            popUpIconLbl.image = UIImage(systemName: "xmark.circle.fill")
            popUpIconLbl.tintColor = UIColor.red

            popUpTextLbl.text = "Whoops, try again!"
        }
        
        self.popUpIconLbl.backgroundColor = UIColor(named: "White1")
        
//        view.addSubview(popUpIconLbl)
//        view.addSubview(popUpTextLbl)
        
        popUpIconLbl.isHidden = false
        popUpTextLbl.isHidden = false
        
        // Start the timer to dismiss the pop-up after a certain duration
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(dismissPopup), userInfo: nil, repeats: false)

        
//        dismissPopup()
    }
    
    @objc func dismissPopup() {
        popUpIconLbl.isHidden = true
        popUpTextLbl.isHidden = true
//        popUpIconLbl?.removeFromSuperview()
//        popUpTextLbl?.removeFromSuperview()
        timer?.invalidate()
    }
    
    func generateNewQuestion() {
        miniGameManager.setRandomQuestion()
        questionLbl.text = miniGameManager.question
    }
    
}

extension GameViewController {
    // MARK: Image prediction methods
    /// Sends a photo to the Image Predictor to get a prediction of its content.
    /// - Parameter image: A photo.
    private func classifyTheSign(_ image: UIImage) {
        do {
            try self.signPoseClassifier.makePredictions(for: image,
                                                    completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }

    /// The method the Image Predictor calls when its image classifier model generates a prediction.
    /// - Parameter predictions: An array of predictions.
    /// - Tag: imagePredictionHandler
    private func imagePredictionHandler(_ predictions: [SignPoseClassifier.Prediction]?){
        guard let predictions = predictions else {
            print("No Prediction")
            return
        }
        
        detectedPose = String(describing: predictions.first!.classification)
    }

}
