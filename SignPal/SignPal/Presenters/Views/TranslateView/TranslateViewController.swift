//
//  TranslateViewController.swift
//  SignTalk
//
//  Created by Celine Margaretha on 24/05/23.
//

import UIKit
import AVFoundation /// lower-level control and a wider range of capabilities for advanced media handling -> camera,  voice

//import AVKit
/// higher-level framework that simplifies media playback integration with pre-built components and UI elements


class TranslateViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var identifierLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var voiceBtn: UIButton!
    
    @IBAction func voiceBtnClicked(_ sender: UIButton) {
        speakTheText()
    }
    
    /// voice
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")

    let signPoseClassifier = SignPoseClassifier()
    var detectedPose = SignPose(classificationName: "")

    override func viewDidLoad() {
        super.viewDidLoad()
//        print("Translate view controller")
   
        /// Start Camera
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo /// add top bottom layout guide like photo  format
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        DispatchQueue.global().async {
            captureSession.startRunning() /// start to run/open the camera\
//            print("camera")
        }
       
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds /// other alternative -> view.frame
        previewLayer.videoGravity = .resizeAspectFill
        
        /// Get access to the cameras frame layer
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        view.addSubview(TranslateRectangle(frame: CGRect(x: 0, y: 0, width: 600, height: 100)))
    
        view.addSubview(TranslateRectangle(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height-200, width: 600, height: 200)))

        identifierLbl.text = signPoseClassifier.signPosePrediction.classificationName
//        infoLbl.text = NSLocalizedString("   Invalid alphanumerical sign   ", tableName: nil, bundle: Bundle.main, value: " Halo", comment: "Translate InfoLbl")
        
        view.addSubview(identifierLbl)
        view.addSubview(infoLbl)
        view.addSubview(voiceBtn)
    }
    
    /// this function called everytime the camera is able to capture a frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
//        print("Camera was able to capture a frame:", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        //Convert CIImage into UIImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        ///render CIImage into CGImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        
        /// create UIImage from CGImage
        let photo = UIImage(cgImage: cgImage)

        self.signPoseClassifier.classifyTheSign(photo)
        detectedPose = signPoseClassifier.signPosePrediction
        
        DispatchQueue.main.async { [self] in
            identifierLbl.isHidden = false
            identifierLbl.text = detectedPose.classificationName
        }
        
        if detectedPose.confidencePercentage > 0.999 {
//            print(detectedPose.classificationName, detectedPose.confidencePercentage * 100)

            DispatchQueue.main.async { [self] in
                infoLbl.isHidden = true
                identifierLbl.isHidden = false
                voiceBtn.isHidden = false
                identifierLbl.text = "\(detectedPose.classificationName)"
            }
        }
        else {

            DispatchQueue.main.async { [self] in
                infoLbl.isHidden = false
                identifierLbl.isHidden = true
                voiceBtn.isHidden = true
            }
        }
        
        
    }

    
    func speakTheText() {
        
        // Create an utterance.
        let utterance = AVSpeechUtterance(string: "\(String(describing: identifierLbl.text!))")
        
        // Configure the utterance.
        utterance.rate = 0.45 ///  the speed of speech
        utterance.pitchMultiplier = 1.5 /// the pitch level
        utterance.postUtteranceDelay = 0.2 /// the delay after each speech
        utterance.volume = 0.8

        // Retrieve the British English voice. -> follow default language settings
//        let voice = AVSpeechSynthesisVoice(language: "en-US")
        let voice = AVSpeechSynthesisVoice(language: NSLocale.current.language.languageCode!.identifier)

        // Assign the voice to the utterance.
        utterance.voice = voice

        // Tell the synthesizer to speak the utterance.
        synth.speak(utterance)
    }
}
