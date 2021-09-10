//
//  ContentView.swift
//  LearningARKit
//
//  Created by raja on 09/09/21.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel : Model?
    @State private var modelConfirmedForPlacement : Model?
    
    
    var models : [Model] = {
        //
        //Dynamically Getting filename
        let fileManager = FileManager.default
        guard let path = Bundle.main.resourcePath, let files = try? fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }

        var availableModel : [Model] = []
        for fileName in files where fileName.hasSuffix("usdz") {
            let modelName = fileName.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availableModel.append(model)
        }
        return availableModel

    }()
    
    var body: some View {
        ZStack(alignment: .bottom){
            ARViewContainer(modelConfirmedForPlacement: $modelConfirmedForPlacement)
            if self.isPlacementEnabled{
                PlacementButtonView(isPlacementEnabled: $isPlacementEnabled,selecedModel: $selectedModel,modelConfirmedForPlacement: $modelConfirmedForPlacement)
            }else{
                ModelPickerView(isPlacementEnabled: $isPlacementEnabled, selecedModel: $selectedModel, models: self.models)
            }
            
            
            
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement : Model?
    
    //var focusSquare : FocusEntity!
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        let focusSquare = FocusEntity(on: arView, style: .classic(color: UIColor.yellow))
            //FocusEntity(on: arView, style: .classic(color: .yellow)
        //focusSquare.delegate = self
        focusSquare.setAutoUpdate(to: true)
        
        arView.session.run(config)
        
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = modelConfirmedForPlacement{
            if let modelEntity = model.modelEntity {
                let anchorEntiry = AnchorEntity(plane: .any)
                anchorEntiry.addChild(modelEntity.clone(recursive: true))
                uiView.scene.addAnchor(anchorEntiry)
            }else{
                print("Unable to load model entity")
            }
            
            
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
    
    
    
}



struct ModelPickerView : View {
    @Binding var isPlacementEnabled : Bool
    @Binding var selecedModel : Model?
    let models : [Model]
    var body: some View{
        ScrollView(.horizontal, showsIndicators: false, content: {
            HStack(spacing : 30){
                ForEach(0..<models.count){index in
                    Button(action: {
                        print("DEBUG selected model with name \(self.models[index])")
                        self.isPlacementEnabled = true
                        self.selecedModel = models[index]
                    }){
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height:80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12.0)
                    }.buttonStyle(PlainButtonStyle())
 
                }
            }
        }).padding(20)
        .background(Color.black.opacity(0.5))
    }
    
    
}

struct PlacementButtonView : View {
    @Binding var isPlacementEnabled : Bool
    @Binding var selecedModel : Model?
    @Binding var modelConfirmedForPlacement : Model?
    var body: some View{
        HStack{
            //Cancel button
            Button(action: {
                print("DEBUG model placement Cancel")
                resetPlacementParam()
            }){
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
                
            }
            
            //Confirm button
            Button(action: {
                print("DEBUG model placement confirm")
                modelConfirmedForPlacement = selecedModel
                resetPlacementParam()
            }){
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
                
            }
        }
    }
    
    func resetPlacementParam(){
        isPlacementEnabled = false
        selecedModel = nil
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad (8th generation)")
    }
}
#endif
