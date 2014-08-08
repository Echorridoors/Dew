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
                            
	@IBOutlet var timeLeftLabel: UILabel!
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
	
	var timeNow: NSDateComponents!
	var timeThen: NSDateComponents!
	
	// MARK: - Init
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		templateStart()
		timeStart()
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}
	
	// MARK: - Time
	
	func timeStart()
	{
		timeUpdate()
		var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("timeStep"), userInfo: nil, repeats: true)
	}
	
	func timeUpdate()
	{
		let date = NSDate()
		
		let calendar = NSCalendar.currentCalendar()
		let dateFormatter = NSDateFormatter()
		dateFormatter.timeZone = NSTimeZone()
		
		timeNow = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond , fromDate: date)
		
		let dateFuture = NSDate(timeIntervalSinceNow: NSTimeInterval(incrementMinutes) )
		let futureDate = dateFormatter.stringFromDate( dateFuture )
		
		timeThen = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond , fromDate: dateFuture)
		
		timeTargetLabel.text = "\(timeThen.hour):\(timeThen.minute)"
		timeLeftLabel.text = "\(incrementMinutes)"
		
		if incrementMinutes > 0 { incrementMinutes -= 1 }
		
	}
	
	func timeStep()
	{
		timeUpdate()
		lineUpdate()
	}
	
	// MARK: - Template
	
	func templateStart()
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
		
		timeLeftLabel.frame = CGRectMake(tileSize, screenHeight-tileSize, screenWidth-(2*tileSize), tileSize)
		timeTargetLabel.frame = CGRectMake(tileSize, screenHeight-tileSize, screenWidth-(2*tileSize), tileSize)
		
		templateGrid()
	}
	
	func templateGrid()
	{
		var i = 0
		while i < 24*4
		{
			var lineView = UIView(frame: CGRectMake(0, (templateLineSpacing * CGFloat(i)), screenWidth-(2*tileSize)+1, 1))
			
			if i % 24 == 0 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.3.png")).colorWithAlphaComponent(0.5) }
			else if i % 4 == 2 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")).colorWithAlphaComponent(0.5) }
			else { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")).colorWithAlphaComponent(0.5) }
			
			self.gridView.addSubview(lineView)
			
			i = i + 1
		}
		
		var lineView = UIView(frame: CGRectMake(0, (templateLineSpacing * CGFloat(24*4)), screenWidth-(2*tileSize)+1, 1))
		lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")).colorWithAlphaComponent(0.5)
		self.gridView.addSubview(lineView)
	}
	
	// MARK: - Touch
	
	override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
		
		for touch: AnyObject in touches {
			let location = touch.locationInView(gridView)
			touchStart = location.y
			NSLog("> START | %@", location.y)
		}
		
	}
	
	override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!)
	{
		for touch: AnyObject in touches
		{
			let location = touch.locationInView(gridView)
			var incrementStep = 30
			
			if abs(touchStart - location.y) < 100 { incrementStep = 60 }
			else if abs(touchStart - location.y) < 200 { incrementStep = 120 }
			else if abs(touchStart - location.y) < 300 { incrementStep = 240 }
			else if abs(touchStart - location.y) < 400 { incrementStep = 480 }
			else { incrementStep = 960 }
			
			if touchStart > location.y { incrementMinutes += incrementStep }
			else{ incrementMinutes += -incrementStep }
			
			if incrementMinutes < 0 {
				incrementMinutes = 0
				return
			}
			
			timeUpdate()
			lineUpdate()
		}
	}
	
	func lineUpdate()
	{
		lineNowDraw()
		lineThenDraw()
		lineInbetweensDraw()
	}
	
	func lineNowDraw()
	{
		var minutes = UInt((timeNow.minute * 60) + timeNow.second)
		var lineVerticalPosition = (24-CGFloat(timeNow.hour)) * templateLineSpacing * 4
		if timeNow.minute > 45 { lineVerticalPosition -= templateLineSpacing * 3  }
		else if timeNow.minute > 30 { lineVerticalPosition -= templateLineSpacing * 2  }
		else if timeNow.minute > 15 { lineVerticalPosition -= templateLineSpacing * 1  }
		
		var lineOrigin = CGFloat(minutes % (15*60))/(15*60) * (screenWidth-(2 * tileSize))
		var lineWidth = gridView.frame.size.width-lineOrigin
		
		if ( (incrementMinutes/60) + (Int(timeNow.minute)%15) ) < 15 {
			
			lineWidth =  ( CGFloat( incrementMinutes/60 )/15 ) * (screenWidth-(2 * tileSize))
			pointTarget.hidden = 1
			
		}
		
		
		pointNow.frame = CGRectMake(lineOrigin, lineVerticalPosition,lineWidth , 1)
	}
	
	func lineThenDraw()
	{
		// Draw Then
		
		var targetMinutes = (timeThen.hour * 60) + timeThen.minute
		var targetHoursFloat = Float(targetMinutes)/60
		var posTest = (24-CGFloat(timeThen.hour)) * templateLineSpacing * 4
		
		if timeThen.minute > 45 { posTest -= templateLineSpacing * 3  }
		else if timeThen.minute > 30 { posTest -= templateLineSpacing * 2  }
		else if timeThen.minute > 15 { posTest -= templateLineSpacing * 1  }
		
		var posWidth = CGFloat(UInt(timeThen.minute) % 15)/15 * (screenWidth-(2 * tileSize))
		pointTarget.frame = CGRectMake(0, posTest, posWidth, 1)
		
		pointTarget.hidden = 0
		
		if pointTarget.frame.origin.y == pointNow.frame.origin.y
		{
			pointTarget.hidden = 1
		}
		
	}
	
	func lineInbetweensDraw()
	{
		for view in gridView.subviews {
			if view.tag != 100 { continue }
			view.removeFromSuperview()
		}
		
		// Draw Inbetweens
		
		var someTest = incrementMinutes / 60
		someTest = someTest + (timeNow.minute)
		someTest = someTest / 15
		
		var offset = 1
		if timeNow.minute > 45 { offset = 4 }
		else if timeNow.minute > 30 { offset = 3 }
		else if timeNow.minute > 15 { offset = 2 }
		
		var i = 0
		while i < someTest-offset
		{
			let positionY = pointNow.frame.origin.y - ( (CGFloat(i) + 1) * templateLineSpacing)
			var lineView = UIView(frame: CGRectMake(0.0, positionY, screenWidth-(2*tileSize), 1))
			
			if lineView.frame.origin.y < 0 { lineView.frame = CGRectMake(0.0, positionY+(24*4*templateLineSpacing), screenWidth-(2*tileSize), 1) }
			
			lineView.backgroundColor = UIColor.whiteColor()
			lineView.tag = 100
			
			self.gridView.addSubview(lineView)
			
			i = i + 1
		}
		
	}
	
	
	func touchValuePerc(nowVal: Float,maxVal: Float) -> Float
	{
		var posValue = nowVal/maxVal
		
		if posValue > 1 { posValue = 1.0 }
		if posValue < 0 { posValue = 0.0 }
		
		return 1-posValue
	}
	
	// MARK: - Alarm
	
	func alarmSetup()
	{
		var localNotification:UILocalNotification = UILocalNotification()
		localNotification.alertAction = "Testing notifications on iOS8"
		localNotification.alertBody = "Woww it works!!"
		localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
		UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
	}
	
	// MARK: - Misc
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}

}

