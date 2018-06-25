/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import UIKit

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Setup
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let herbView = presenting ? toView : transitionContext.view(forKey: .from)!
        
        let initailFrame = presenting ? originFrame : herbView.frame
        let finalFrame = presenting ? herbView.frame : originFrame
        
        let xScaleFactor = presenting
            ? initailFrame.width / finalFrame.width
            : finalFrame.width / initailFrame.width

        let yScaleFactor = presenting
            ? initailFrame.height / finalFrame.height
            : finalFrame.height / initailFrame.height
        
        let scaleFactor = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        herbView.layer.cornerRadius = self.presenting ? 20.0 / xScaleFactor : 0.0
        herbView.clipsToBounds = true
        
        if presenting {
            herbView.transform = scaleFactor
            herbView.center = CGPoint(x: initailFrame.midX, y: initailFrame.midY)
        }
        
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: herbView)
        
        guard let vc = transitionContext.viewController(forKey: presenting ? .to : .from) as? HerbDetailsViewController else {
            transitionContext.completeTransition(false)
            return
        }
        
        if presenting {
            vc.containerView.alpha = 0
        }
        
        //Animate
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, animations: {
            herbView.transform = self.presenting ? .identity : scaleFactor
            herbView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            herbView.layer.cornerRadius = self.presenting ? 0 : 20.0 / xScaleFactor
            vc.containerView.alpha = self.presenting ? 1 : 0
            
            
        }) { (_) in
            if !self.presenting {
                if let vc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? ViewController {
                    vc.selectedImage?.isHidden = false
                }
            }
            
            transitionContext.completeTransition(true)
        }
        
    }
    
    
    let duration = 1.0
    var originFrame = CGRect.zero
    var presenting = false
    
}

