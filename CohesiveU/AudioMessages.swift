//
//  AudioMessages.swift
//  CohesiveU
//
//  Created by Administrator on 2016-11-04.
//  Copyright © 2016 Serranos Fund. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class AudioMessage:JSQMediaItem {

    var imageView:UIImageView?
    var status:Int?
    var fileURL:NSURL?
    
    init(withFileURL:NSURL, maskOutGoing:Bool) {
        super.init(maskAsOutgoing: maskOutGoing)
        
        fileURL = withFileURL
        imageView = nil
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mediaView() -> UIView! {
        
        switch DEVICEMODEL {
            case "Simulator","iPhone":
                if let st = status {
                    if st == 1 {
                        return nil
                    }
                    
                    if st == 2 && (self.imageView == nil){
                        let size = self.mediaViewDisplaySize
                        let outgoing = self.appliesMediaViewMaskAsOutgoing
                        
                        let colorBackground = outgoing ? UIColor.defaultBlue:UIColor.jsq_messageBubbleLightGray()
                        
                        let colorContent = outgoing ? UIColor.white:UIColor.gray
                        let icon = UIImage.jsq_defaultPlay().jsq_imageMasked(with: colorContent)
                        let iconView = UIImageView(image:icon)
                        let ypos = (size().height-icon!.size.height-6)
                        let xpos = outgoing ? ypos:ypos+6
                        
                        iconView.frame = CGRect(x:xpos,y:ypos,width:icon!.size.width,height:icon!.size.height)
                        
                        let frame = outgoing ? CGRect(x:45, y:10, width:60, height:20) : CGRect(x: 51, y:10, width:60, height:20)
                        
                        let label = UILabel(frame:frame)
                        label.textAlignment = .right
                        label.textColor = colorContent
                        label.text = "Audio"
                        
                        let imageView = UIImageView(frame: CGRect(x:0, y:0, width:size().width, height: size().height))
                        imageView.backgroundColor = colorBackground
                        imageView.clipsToBounds = true
                        imageView.addSubview(iconView)
                        imageView.addSubview(label)
                        
                        JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: outgoing)
                        self.imageView = imageView
                        
                    }
                }
                break
            case "iPad":
                if let st = status {
                    if st == 1 {
                        return nil
                    }
                    
                    if st == 2 && (self.imageView == nil){
                        let size = self.mediaViewDisplaySize
                        let outgoing = self.appliesMediaViewMaskAsOutgoing
                        
                        let colorBackground = outgoing ? UIColor.defaultBlue:UIColor.jsq_messageBubbleLightGray()
                        
                        let colorContent = outgoing ? UIColor.white:UIColor.gray
                        let icon = UIImage.jsq_defaultPlay().jsq_imageMasked(with: colorContent)
                        let iconView = UIImageView(image:icon)
                        let ypos = (size().height-icon!.size.height-16)
                        let xpos = outgoing ? ypos:ypos+6
                        
                        iconView.frame = CGRect(x:xpos,y:ypos,width:icon!.size.width,height:icon!.size.height)
                        
                        let frame = outgoing ? CGRect(x:45, y:18, width:60, height:24) : CGRect(x: 51, y:18, width:60, height:24)
                        
                        let label = UILabel(frame:frame)
                        label.textAlignment = .right
                        label.textColor = colorContent
                        label.text = "Audio"
                        
                        let imageView = UIImageView(frame: CGRect(x:0, y:0, width:size().width, height: size().height))
                        imageView.backgroundColor = colorBackground
                        imageView.clipsToBounds = true
                        imageView.addSubview(iconView)
                        imageView.addSubview(label)
                        
                        JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: outgoing)
                        self.imageView = imageView
                        
                    }
                }
                break;
            default:
                break;
        }
        
        return self.imageView
    }

    
    override func mediaViewDisplaySize() -> CGSize {
        
        var size = CGSize()
        
        switch DEVICEMODEL {
        case "Simulator","iPhone":
            size = CGSize(width:120,height:40)
            break
        case "iPad":
            size = CGSize(width:120,height:60)
            break
        default:
            break
        }
        
        return size
    }
    
    /*
     
     if st == 2 && (self.imageView == nil){
     let size = self.mediaViewDisplaySize
     let outgoing = self.appliesMediaViewMaskAsOutgoing
     
     let colorBackground = outgoing ? UIColor.defaultBlue:UIColor.jsq_messageBubbleLightGray()
     
     let colorContent = outgoing ? UIColor.white:UIColor.gray
     let icon = UIImage.jsq_defaultPlay().jsq_imageMasked(with: colorContent)
     let iconView = UIImageView(image:icon)
     let ypos = (size().height-icon!.size.height-11)
     let xpos = outgoing ? ypos:ypos+6
     
     iconView.frame = CGRect(x:xpos,y:ypos,width:icon!.size.width,height:icon!.size.height)
     
     let frame = outgoing ? CGRect(x:45, y:10, width:60, height:40) : CGRect(x: 51, y:10, width:60, height:20)
     
     let label = UILabel(frame:frame)
     label.textAlignment = .right
     label.textColor = colorContent
     label.text = "Audio"
     
     let imageView = UIImageView(frame: CGRect(x:0, y:0, width:size().width, height: size().height+10))
     imageView.backgroundColor = colorBackground
     imageView.clipsToBounds = true
     imageView.addSubview(iconView)
     imageView.addSubview(label)
     
     JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: outgoing)
     self.imageView = imageView
     
     }
     }
     
     return self.imageView
     }
     
     
     override func mediaViewDisplaySize() -> CGSize {
     return CGSize(width:120,height:80)
     }
     
     */

    /*
     ORIGINAL
     override func mediaView() -> UIView! {
     if let st = status {
     if st == 1 {
     return nil
     }
     
     if st == 2 && (self.imageView == nil){
     let size = self.mediaViewDisplaySize
     let outgoing = self.appliesMediaViewMaskAsOutgoing
     
     let colorBackground = outgoing ? UIColor.defaultBlue:UIColor.jsq_messageBubbleLightGray()
     
     let colorContent = outgoing ? UIColor.white:UIColor.gray
     let icon = UIImage.jsq_defaultPlay().jsq_imageMasked(with: colorContent)
     let iconView = UIImageView(image:icon)
     let ypos = (size().height-icon!.size.height-6)
     let xpos = outgoing ? ypos:ypos+6
     
     iconView.frame = CGRect(x:xpos,y:ypos,width:icon!.size.width,height:icon!.size.height)
     
     let frame = outgoing ? CGRect(x:45, y:10, width:60, height:20) : CGRect(x: 51, y:10, width:60, height:20)
     
     let label = UILabel(frame:frame)
     label.textAlignment = .right
     label.textColor = colorContent
     label.text = "Audio"
     
     let imageView = UIImageView(frame: CGRect(x:0, y:0, width:size().width, height: size().height))
     imageView.backgroundColor = colorBackground
     imageView.clipsToBounds = true
     imageView.addSubview(iconView)
     imageView.addSubview(label)
     
     JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: outgoing)
     self.imageView = imageView
     
     }
     }
     
     return self.imageView
     }
     
     
     override func mediaViewDisplaySize() -> CGSize {
     return CGSize(width:120,height:40)
     }
     
     
     */

}
