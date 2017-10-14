//
//  ViewController.swift
//  ArchOS
//
//  Created by digid on 10/6/17.
//  Copyright © 2017 digid. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion


class ViewController: UIViewController, SCNSceneRendererDelegate {

    @IBOutlet weak var leftView: SCNView!
    @IBOutlet weak var rightView: SCNView!
    
    var motionManager : CMMotionManager?
    var cameraRollNode : SCNNode?
    var cameraPitchNode : SCNNode?
    var cameraYawNode : SCNNode?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Set bg color based on TIME OF DAY
        leftView?.backgroundColor = UIColor.black
        rightView?.backgroundColor = UIColor.black
        
        
        
        // Create Scene
        let scene = SCNScene()
        
        leftView?.scene = scene
        rightView?.scene = scene
        
        // Create cameras
        let leftCamera = SCNCamera()
        let rightCamera = SCNCamera()
        
        let leftCameraNode = SCNNode()
        leftCameraNode.camera = leftCamera
        leftCameraNode.position = SCNVector3(x: -0.5, y: 0, z: 0)
        
        let rightCameraNode = SCNNode()
        rightCameraNode.camera = rightCamera
        rightCameraNode.position = SCNVector3(x: 0.5, y: 0, z: 0)
        
        let camerasNode = SCNNode()
        camerasNode.position = SCNVector3(x: 0, y: 0, z: -3)
        camerasNode.addChildNode(leftCameraNode)
        camerasNode.addChildNode(rightCameraNode)
        
        // The user will be holding their device up (i.e. 90 degrees roll from a flat orientation)
        // so roll the cameras by -90 degrees to orient the view correctly.
        camerasNode.eulerAngles = SCNVector3Make(degreesToRadians(-90), 0, 0)
        
        cameraRollNode = SCNNode()
        cameraRollNode!.addChildNode(camerasNode)
        
        cameraPitchNode = SCNNode()
        cameraPitchNode!.addChildNode(cameraRollNode!)
        
        cameraYawNode = SCNNode()
        cameraYawNode!.addChildNode(cameraPitchNode!)
        
        scene.rootNode.addChildNode(cameraYawNode!)
        
        leftView?.pointOfView = leftCameraNode
        rightView?.pointOfView = rightCameraNode
        
        // Ambient Light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 1, alpha: 1)
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Omni Light
        let diffuseLight = SCNLight()
        diffuseLight.type = .omni
        diffuseLight.color = UIColor(white: 1, alpha: 1)
        let diffuseLightNode = SCNNode()
        diffuseLightNode.light = diffuseLight
        diffuseLightNode.position = SCNVector3(x: -30, y: 30, z: 50)
        scene.rootNode.addChildNode(diffuseLightNode)
        
        // Create Floor
        let floor = SCNFloor()
        floor.reflectivity = 0.15
        let mat = SCNMaterial()
        let lightGreen = UIColor(red: 0, green: 0.7, blue: 0.0, alpha: 0.5)
        mat.diffuse.contents = lightGreen
        mat.specular.contents = lightGreen
        floor.materials = [mat]
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(x: 0, y: -1, z: 0)
        scene.rootNode.addChildNode(floorNode)
        
        
        // Make the camera move back and forth
        let camera_anim = CABasicAnimation(keyPath: "position.y")
        camera_anim.byValue = 12.0
        camera_anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        camera_anim.autoreverses = true
        camera_anim.repeatCount = Float.infinity
        camera_anim.duration = 2.0
        
        camerasNode.addAnimation(camera_anim, forKey: "camera_motion")
        
        // Respond to user head movement
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager?.startDeviceMotionUpdates(using: .xArbitraryZVertical)
        
        leftView?.delegate = self
        
        leftView?.isPlaying = true
        rightView?.isPlaying = true
        
        
    }
    
    
    func renderer(_ aRenderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let doCorrect = UIDevice.current.orientation == .landscapeLeft
        let rollPitchCorrect: Float = doCorrect ? -1 : 1
        let yawCorrect: Float = doCorrect ? .pi : 0
        
        if let mm = motionManager, let motion = mm.deviceMotion {
            let currentAttitude = motion.attitude
            
            cameraRollNode!.eulerAngles.x = Float(currentAttitude.roll) * rollPitchCorrect
            cameraPitchNode!.eulerAngles.z = Float(currentAttitude.pitch) * rollPitchCorrect
            cameraYawNode!.eulerAngles.y = Float(currentAttitude.yaw) - yawCorrect
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

