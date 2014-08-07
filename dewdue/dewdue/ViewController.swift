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
	
	var templateLineSpacing:CGFloat = 5.0
	
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
		
		var i = 0
		while i < 24*4
		{
			var lineView = UIView(frame: CGRectMake(0, (templateLineSpacing * CGFloat(i)), screenWidth-(2*tileSize)+1, 1))
			
			if i % 4 == 0 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")) }
			else if i % 4 == 2 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.2.png")) }
			else { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.3.png")) }
			
			
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
		
		var lineView = UIView(frame: CGRectMake(0, (templateLineSpacing * CGFloat(24*4)), screenWidth-(2*tileSize)+1, 1))
		lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png"))
		self.gridView.addSubview(lineView)
		
		
		
	}
	
	override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
		
		for touch: AnyObject in touches {
			let location = touch.locationInView(gridView)
			touchStart = location.y
			NSLog("> START | %@", location.y)
		}
		
	}
	
	override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
		
		for touch: AnyObject in touches {
			
			let location = touch.locationInView(gridView)
			
			if touchStart > location.y { incrementMinutes += 30 }
			else{ incrementMinutes += -30 }
			
			if incrementMinutes < 0 {
				incrementMinutes = 0
				continue
			}
			
			// Setup
			
			let date = NSDate()
			
			let calendar = NSCalendar.currentCalendar()
			let dateFormatter = NSDateFormatter()
			dateFormatter.timeZone = NSTimeZone()
			
			let timeNow = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond , fromDate: date)
			
			let dateFuture = NSDate(timeIntervalSinceNow: NSTimeInterval(incrementMinutes) )
			let futureDate = dateFormatter.stringFromDate( dateFuture )
			let timeThen = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond , fromDate: dateFuture)
			
			timeTargetLabel.text = "\(timeThen.hour):\(timeThen.minute)"
			
			// Draw Then
			
			var targetMinutes = (timeThen.hour * 60) + timeThen.minute
			var targetHoursFloat = Float(targetMinutes)/60
			var posTest = (24-CGFloat(timeThen.hour)) * templateLineSpacing * 4
	
			if timeThen.minute > 45 { posTest -= templateLineSpacing * 3  }
			else if timeThen.minute > 30 { posTest -= templateLineSpacing * 2  }
			else if timeThen.minute > 15 { posTest -= templateLineSpacing * 1  }
			
			var posWidth = CGFloat(UInt(timeThen.minute) % 15)/15 * (screenWidth-(2 * tileSize))
			pointTarget.frame = CGRectMake(0, posTest, posWidth, 1)
			
			// Draw Now
			
			targetMinutes = (timeNow.hour * 60) + timeNow.minute
			targetHoursFloat = Float(targetMinutes)/60
			posTest = (24-CGFloat(timeNow.hour)) * templateLineSpacing * 4
			
			if timeNow.minute > 45 { posTest -= templateLineSpacing * 3  }
			else if timeNow.minute > 30 { posTest -= templateLineSpacing * 2  }
			else if timeNow.minute > 15 { posTest -= templateLineSpacing * 1  }
	
			posWidth = CGFloat(UInt(timeNow.minute) % 15)/15 * (screenWidth-(2 * tileSize))
			
			// Early
			if pointNow.frame.origin.y == pointTarget.frame.origin.y
			{
				var testSomething = ((incrementMinutes/60) % 15)
				testSomething = testSomething * ( (screenWidth-(2 * tileSize)) / 15)
				
				pointNow.frame = CGRectMake(posWidth, posTest, CGFloat(testSomething), 1)
				pointTarget.hidden = 1
			}
			else{
				pointNow.frame = CGRectMake(posWidth, posTest, gridView.frame.size.width-posWidth, 1)
				pointTarget.hidden = 0
			}
			
			// Erase Old Inbetweens
			
			for view in gridView.subviews {
				if view.tag != 100 { continue }
				view.removeFromSuperview()
			}

			// Draw Inbetweens
			
			var someTest = incrementMinutes / 60
			someTest = someTest + (timeNow.minute)
			someTest = someTest / 15
	
			var i = 0
			while i < someTest-3
			{
				var lineView = UIView(frame: CGRectMake(0.0, pointNow.frame.origin.y - ( (CGFloat(i) + 1) * templateLineSpacing), screenWidth-(2*tileSize), 1))
				
				lineView.backgroundColor = UIColor.whiteColor()
				lineView.tag = 100
				
				self.gridView.addSubview(lineView)
				
				i = i + 1
			}
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
		pointNow.backgroundColor = UIColor.whiteColor()
		pointTarget.frame = CGRectMake(0, 0, 1, 1)
		pointTarget.backgroundColor = UIColor.whiteColor()
		
		gridView.frame = CGRectMake(tileSize, tileSize, screenWidth - (2 * tileSize), screenHeight - (2 * tileSize) )
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}

}

