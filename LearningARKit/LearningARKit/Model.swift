//
//  Model.swift
//  LearningARKit
//
//  Created by raja on 10/09/21.
//

import UIKit
import RealityKit
import Combine

class Model{
    var modelName : String
    var image : UIImage
    var modelEntity : ModelEntity?
    
    private var cancellable : AnyCancellable? = nil
    
    init(modelName : String) {
        self.modelName = modelName
        self.image = UIImage(named: modelName)!
        let fileName = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: fileName)
            .sink(receiveCompletion: { loadCompletion in
                //Handle Error
                print("Unable to load ModelEntity")
            }, receiveValue: { modelEntity in
                self.modelEntity = modelEntity
                print("Debug sucessfully loaded")
            })
    }
    
}
