//
//  ViewController.swift
//  dewdue
//
//  Created by Devine Lu Linvega on 2014-08-06.
//  Copyright (c) 2014 XXIIVV. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
	@IBOutlet var timeTargetLabel: UILabel!
	@IBOutlet var timeTouchView: UIView!
	
	var tileSize:CGFloat = 0.0
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		template()
		alarmSetup()
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
		
		for touch: AnyObject in touches {
			let location = touch.locationInView(self.view)
			NSLog("> START | %@", location.x)
		}
		
	}
	
	override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
		
		for touch: AnyObject in touches {
			let location = touch.locationInView(self.view)
			
			let hourPerc = touchValuePerc( Float(location.y)-Float(tileSize), maxVal: Float(self.timeTouchView.frame.height) )
			let minuPerc = touchValuePerc( Float(location.x)-Float(tileSize), maxVal: Float(self.timeTouchView.frame.width) )
			
			var hourVal = Int(hourPerc*24)
			if hourVal > 23 { hourVal = 23 }
			
			var minuVal = 60-Int(minuPerc*60)
			if minuVal > 59 { minuVal = 59 }
			
			timeTargetLabel.text = "\(hourVal):\(minuVal)"
			
			NSLog("%@", NSDate(timeIntervalSinceNow: NSTimeInterval(hourVal*60*60) ) )
		}
		
		
	}
	
	func touchValuePerc(nowVal: Float,maxVal: Float) -> Float
	{
		var posValue = nowVal/maxVal
		
		if posValue > 1 { posValue = 1.0 }
		if posValue < 0 { posValue = 0.0 }
		
		return 1-posValue
	}
	
	func alarmSetup()
	{
		var localNotification:UILocalNotification = UILocalNotification()
		localNotification.alertAction = "Testing notifications on iOS8"
		localNotification.alertBody = "Woww it works!!"
		localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
		UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
	}
	
	func template()
	{
		tileSize = self.view.frame.width/8
		let screenWidth = self.view.frame.width
		let screenHeight = self.view.frame.height
		timeTouchView.frame = CGRectMake(tileSize, tileSize, screenWidth-(2*tileSize), screenHeight-(2*tileSize))
	}
	
	
	
//	- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//	{
//	UITouch *theTouch = [touches anyObject];
//	_startPoint = [theTouch locationInView:self.view];
//	CGFloat x = _startPoint.x;
//	CGFloat y = _startPoint.y;
//	_xCoord.text = [NSString stringWithFormat:@"%f", x];
//	_yCoord.text = [NSString stringWithFormat:@"%f", y];


}

