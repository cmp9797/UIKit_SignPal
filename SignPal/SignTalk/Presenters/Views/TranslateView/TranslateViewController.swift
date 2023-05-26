//
//  TranslateViewController.swift
//  SignTalk
//
//  Created by Celine Margaretha on 24/05/23.
//

import UIKit
import AVKit /// audio-visual library to start camera
import Vision
import AVFoundation /// add voice

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

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Translate view controller")
   
        /// Start Camera
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo /// add top bottom layout guide like photo  format
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        DispatchQueue.global().async {
            captureSession.startRunning() /// start to run/open the camera\
            print("camera")
        }
       
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill

//        previewLayer.frame = view.bounds
//        previewLayer.videoGravity = .resizeAspectFill
        
        /// Get access to the cameras frame layer
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        view.addSubview(TranslateRectangle(frame: CGRect(x: 0, y: 0, width: 600, height: 100)))
    
        view.addSubview(TranslateRectangle(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height-200, width: 600, height: 200)))

        ///reposition the label infront of the camera (preview layer)
        view.addSubview(identifierLbl)
        view.addSubview(infoLbl)

        /// add speaker
        view.addSubview(voiceBtn)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) { /// called everytime the camera is able to capture a frame
        
//        print("Camera was able to capture a frame:", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let model = try? VNCoreMLModel(for: MySign2().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            //perhaps check the err
            
//            print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            if firstObservation.confidence > 0.999 {
                print(firstObservation.identifier, firstObservation.confidence)
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 5) {
                        
    //                    self.identifierLbl.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
                        self.infoLbl.isHidden = true
                        self.identifierLbl.isHidden = false
                        self.voiceBtn.isHidden = false
                        self.identifierLbl.text = "\(firstObservation.identifier)"
                    }
                }
            }
            else {
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 5) {
                        //                    self.identifierLbl.text = "undefined"
                        self.infoLbl.isHidden = false
                        self.identifierLbl.isHidden = true
                        self.voiceBtn.isHidden = true
                        
                    }
                }
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }

    
    func speakTheText() {
        
        // Create an utterance.
        let utterance = AVSpeechUtterance(string: "\(String(describing: identifierLbl.text!))")
        
        // Configure the utterance.
        utterance.rate = 0.45 ///  the speed of speech
        utterance.pitchMultiplier = 1.6 /// the pitch level
        utterance.postUtteranceDelay = 0.2 /// the delay after each speech
        utterance.volume = 0.8

        // Retrieve the British English voice.
        let voice = AVSpeechSynthesisVoice(language: "en-US")

        // Assign the voice to the utterance.
        utterance.voice = voice

        // Tell the synthesizer to speak the utterance.
        synth.speak(utterance)
    }
}



