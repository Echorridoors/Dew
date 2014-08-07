//
//  ViewController.swift
//  dewdue
//
//  Created by Devine Lu Linvega on 2014-08-06.
//  Copyright (c) 2014 XXIIVV. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
                            
	@IBOutlet var timeTargetLabel: UILabel!
	@IBOutlet var timeTouchView: UIView!
	@IBOutlet var gridView: UIView!
	@IBOutlet var pointNow: UIView!
	@IBOutlet var pointTarget: UIView!
	
	var tileSize:CGFloat = 0.0
	var screenWidth:CGFloat = 0.0
	var screenHeight:CGFloat = 0.0
	
	var templateLineSpacing:CGFloat = 0.0
	
	var touchStart:CGFloat = 0.0
	var incrementMinutes = 0
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		template()
		alarmSetup()
		drawViews()
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func drawViews()
	{
//		for view in gridView.subviews {
//			view.removeFromSuperview()
//		}
		
		templateLineSpacing = 5
		
		var i = 0
		while i < 24*4
		{
			var lineView = UIView(frame: CGRectMake(0, (templateLineSpacing * CGFloat(i)), screenWidth-(2*tileSize), 1))
			
			if i % 4 == 0 { lineView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5) }
			else { lineView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.25) }
	
		
			
			self.gridView.addSubview(lineView)
			
			/*
			var labelView = UILabel(frame: CGRectMake(tileSize-40, tileSize + spacing * CGFloat(i)-4, 30, 10))
			labelView.text = "\(23-i)"
			labelView.font = UIFont(name:"helvetica",size:10)
			labelView.textColor = UIColor.whiteColor()
			labelView.textAlignment = NSTextAlignment.Right
			self.gridView.addSubview(labelView)
			*/
			
			
			i = i + 1
		}
		
		
	}
	
	override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
		
		for touch: AnyObject in touches {
			let location = touch.locationInView(self.view)
			touchStart = location.y
			NSLog("> START | %@", location.y)
		}
		
	}
	
	override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
		
		for touch: AnyObject in touches {
			
			let location = touch.locationInView(gridView)

			incrementMinutes += touchStart - location.y
			
			//
			
			let date = NSDate()
			
			let calendar = NSCalendar.currentCalendar()
			let dateFormatter = NSDateFormatter()
			dateFormatter.timeZone = NSTimeZone()
			
			let timeNow = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond , fromDate: date)
			
			let dateFuture = NSDate(timeIntervalSinceNow: NSTimeInterval(incrementMinutes) )
			let futureDate = dateFormatter.stringFromDate( dateFuture )
			let timeThen = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond , fromDate: dateFuture)
			
			//
			
			
			NSLog("%@ FUTURE:%d:%d",touchStart - location.y, timeThen.hour, timeThen.minute)
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
		screenWidth = self.view.frame.width
		screenHeight = self.view.frame.height
		timeTouchView.frame = CGRectMake(tileSize, tileSize, screenWidth-(2*tileSize), screenHeight-(2*tileSize))
		
		pointNow.frame = CGRectMake(0, 0, 10, 10)
		pointNow.backgroundColor = UIColor.redColor()
		pointTarget.frame = CGRectMake(0, 0, 10, 10)
		pointTarget.backgroundColor = UIColor.blueColor()
		
		gridView.frame = CGRectMake(tileSize, tileSize, screenWidth - (2 * tileSize), screenHeight - (2 * tileSize) )
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	
	// Old
	
	/*
	override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
		
		for touch: AnyObject in touches {
			let location = touch.locationInView(self.view)
			
			let hourPerc = touchValuePerc( Float(location.y)-Float(tileSize), maxVal: Float(self.timeTouchView.frame.height) )
			let minuPerc = touchValuePerc( Float(location.x)-Float(tileSize), maxVal: Float(self.timeTouchView.frame.width) )
			
			var hourVal = Int(hourPerc*24)
			if hourVal > 23 { hourVal = 23 }
			
			var minuVal = 60-Int(minuPerc*60)
			if minuVal > 59 { minuVal = 59 }
			
			// Mess
			
			let date = NSDate()
			
			let calendar = NSCalendar.currentCalendar()
			let dateFormatter = NSDateFormatter()
			dateFormatter.timeZone = NSTimeZone()
			
			let timeNow = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond , fromDate: date)
			
			let dateFuture = NSDate(timeIntervalSinceNow: NSTimeInterval(hourVal*60*60) )
			let futureDate = dateFormatter.stringFromDate( dateFuture )
			let timeThen = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond , fromDate: dateFuture)
			
			var difference = 0
			
			if timeNow.hour-timeThen.hour < 1
			{
				difference = (timeNow.hour-timeThen.hour) * -1
			}else
			{
				difference = 24-(timeNow.hour-timeThen.hour)
			}
			
			NSLog("NOW:%d:%d:%d TARGET:%d:%d:%d DIFF:%d",timeNow.hour,timeNow.minute, timeNow.second, timeThen.hour, timeThen.minute, timeThen.second, difference )
			
			// Print
			
			timeTargetLabel.text = "\(timeThen.hour):\(timeThen.minute)"
			
			// Position now
			
			let pos = CGFloat(difference) * -1
			let posY = pos * templateLineSpacing
			
			
			pointNow.frame = CGRectMake(0, posY+(templateLineSpacing*24), 5, 5)
			
		}
		
	}
	
	*/
	
//	- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//	{
//	UITouch *theTouch = [touches anyObject];
//	_startPoint = [theTouch locationInView:self.view];
//	CGFloat x = _startPoint.x;
//	CGFloat y = _startPoint.y;
//	_xCoord.text = [NSString stringWithFormat:@"%f", x];
//	_yCoord.text = [NSString stringWithFormat:@"%f", y];


}

