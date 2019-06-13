//
//  Audio.swift
//  CohesiveU
//
//  Created by Administrator on 2016-11-04.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import Foundation

class Audio {

    var delegate: IQAudioRecorderViewControllerDelegate
    
    init(delegate_: IQAudioRecorderViewControllerDelegate) {
        delegate = delegate_
    }
    
    func presentAudioRecorder(target:UIViewController) {
    
        let controller = IQAudioRecorderViewController()
        controller.delegate = self.delegate
        controller.title = "Recorder"
        controller.maximumRecordDuration = 10.0
        controller.allowCropping = true
        target.presentBlurredAudioRecorderViewControllerAnimated(controller)
        
    }

}
