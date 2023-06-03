//
//  SignPoseClassifier.swift
//  SignTalk
//
//  Created by Celine Margaretha on 25/05/23.
//

import Vision // for image classification
import UIKit // for UIImage

/// A  class that makes image classification predictions.

class SignPoseClassifier {
    
    // MARK: Create an instance of a CoreML image classifier
    /// Create one reuseable ``VNCoreMLModel`` instance for each Core ML model file (.mlmodel)
    /// each Core ML model file only needs to be created once  to reduce time and resource usage
    private static let imageClassifier = createImageClassifier()
    
    private static func createImageClassifier() -> VNCoreMLModel {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()

        // Create an instance of the image classifier's wrapper class.
        // Note: You can replace "MySign" with your CoreML model name
        let imageClassifierWrapper = try? MySign(configuration: defaultConfig)

        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create the model instance")
        }

        // Get the underlying model instance.
        let imageClassifierModel = imageClassifier.model

        // Create a Vision instance using the image classifier's model instance.
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance")
        }

        return imageClassifierVisionModel
    }

    
    
    // MARK: Create and initialize handlers for prediction process
    /// The function signature the caller must provide as a completion handler.
    typealias ImagePredictionHandler = (_ predictions: [SignPose]?) -> Void

    /// A dictionary of prediction handler functions, each keyed by its Vision request.
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()

    
    
    // MARK: Create a `VNImageRequestHandler` with an image input that want to be predicted
    
    /// Generates an image classification prediction for a photo.
    /// - Parameter photo: An image, typically of an object or a scene.

    /// Note: Add an `CGImagePropertyOrientation` extension to make converting between the image orientations defined by UIKit (UIImage.Orientation) and Core Graphics (CGImagePropertyOrientation) easier.
    
    private func makePredictions(for photo: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        let orientation = CGImagePropertyOrientation(photo.imageOrientation)

        guard let photoImage = photo.cgImage else {
            fatalError("Photo doesn't have underlying CGImage.")
        }

        let imageClassificationRequest = createImageClassificationRequest()
        predictionHandlers[imageClassificationRequest] = completionHandler

        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let requests: [VNRequest] = [imageClassificationRequest]

        // Start the image classification request.
        try handler.perform(requests)
    }
    
    
    
    // MARK: Starts an image classification request for inputed image
    /// Generates a new request instance that uses the image classifier model.
    private func createImageClassificationRequest() -> VNImageBasedRequest {
        // Create an image classification request with an image classifier model.
        let imageClassificationRequest = VNCoreMLRequest(model: SignPoseClassifier.imageClassifier, completionHandler: visionRequestHandler)

        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }

    

    // MARK: Converts the prediction results in a completion handler and Updates the delegate's `predictions` property
    /// - Parameters:
    ///   - request: A Vision request.
    ///   - error: An error if the request produced an error; otherwise `nil`.
  
    /// Note: The method checks for errors and validates the request's results.
    
    private var signPosePredictionResults: [SignPose]? = nil

    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        // Remove the caller's handler from the dictionary and keep a reference to it.
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Every request must have a prediction handler.")
        }

        // Start with a `nil` value in case there's a problem.
        signPosePredictionResults = nil

        // Call the client's completion handler after the method returns.
        defer {
            // Send the predictions back to the client.
            predictionHandler(signPosePredictionResults)
        }

        // Check for an error first.
        if let error = error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }

        // Check that the results aren't `nil`.
        if request.results == nil {
            print("Vision request had no results.")
            return
        }

        // Cast the request's results as an `VNClassificationObservation` array.
        guard let observations = request.results as? [VNClassificationObservation] else {
            /// Image classifiers, like MyImageClassifierModel, only produce classification observations.
            /// However, other Core ML model types can produce other observations.
            /// For example, a style transfer model produces `VNPixelBufferObservation` instances.
            print("VNRequest produced the wrong result type: \(type(of: request.results)).")
            return
        }

        // Create a prediction array from the observations.
        signPosePredictionResults = observations.map { observation in
            /// Convert each observation into an `ImagePredictor.Prediction` instance.
            SignPose(classificationName: observation.identifier,
                       confidencePercentage: observation.confidence)
        }
    }
    

    
    // MARK: Create Cmethods

    /// Create public variable that stores a classification name and confidence for an image classifier's prediction.
    var signPosePrediction = SignPose(classificationName: "")
    
    /// Sends a photo input to the Image Predictor to get a prediction of its content.
    /// - Parameter image: A photo.
    func classifyTheSign(_ image: UIImage) {
        do {
            try self.makePredictions(for: image, completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }

    /// The method the Image Predictor calls when its image classifier model generates a prediction.
    /// - Parameter predictions: An array of predictions.
    private func imagePredictionHandler(_ predictions: [SignPose]?){
        guard let predictions = predictions else {
            print("No Prediction")
            return
        }
        
        /// update signPosePrediction value if prediction exist
        signPosePrediction = predictions.first!
    }
    
    
}

