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
	@IBOutlet var alarmLabel: UILabel!
	
	var tileSize:CGFloat = 0.0
	var screenWidth:CGFloat = 0.0
	var screenHeight:CGFloat = 0.0
	
	var templateLineSpacing:CGFloat = 5.0
	
	var touchStart:CGFloat = 0.0
	var incrementMinutes = 0
	
	var timeNow: NSDateComponents!
	var timeThen: NSDateComponents!
	
	var timerTouch:NSTimer!
	
	// MARK: - Init
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		templateStart()
		timeStart()
		lineUpdate()
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
		
		timeTargetLabel.text = "\(timeThen.hour):\(timeThen.minute):\(timeThen.second)"
		
		let hoursLeft = incrementMinutes/60/60
		let minutesLeft = (incrementMinutes/60) - (60*hoursLeft)
		let secondsLeft = (incrementMinutes) - (60*60*hoursLeft) - (60*minutesLeft)
		
		var secondsLeftString = "\(secondsLeft)"
		if( secondsLeft < 10 ){ secondsLeftString = "0\(secondsLeft)" }
		
		var MinutesLeftString = "\(minutesLeft)"
		if( minutesLeft < 10 ){ MinutesLeftString = "0\(minutesLeft)" }
		
		if(hoursLeft > 0){
			timeLeftLabel.text = "\(hoursLeft):\(MinutesLeftString):\(secondsLeftString)"
		}
		else if( minutesLeft > 0 ){
			timeLeftLabel.text = "\(MinutesLeftString):\(secondsLeftString)"
		}
		else{
			timeLeftLabel.text = "\(secondsLeftString)"
		}
		
		if( incrementMinutes < 1 ){
			timeLeftLabel.text = ""
		}
	
		if incrementMinutes > 0 { incrementMinutes -= 1 }
		
	}
	
	func timeIncrementSmall()
	{
		incrementMinutes += 5
		timeStep()
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
		
		timeLeftLabel.frame = CGRectMake(tileSize, 0, screenWidth-(2*tileSize), tileSize)
		timeTargetLabel.frame = CGRectMake(tileSize, 0, screenWidth-(2*tileSize), tileSize)
		alarmLabel.frame = CGRectMake(tileSize, 0, screenWidth-(2*tileSize), tileSize)
		
		templateGrid()
	}
	
	func templateGrid()
	{
		var i = 0
		while i < 24*4
		{
			var lineView = UIView(frame: CGRectMake(0, (templateLineSpacing * CGFloat(i)), screenWidth-(2*tileSize)+1, 1))
			
			if i == 0 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")!).colorWithAlphaComponent(0.5) }
			else if i % 24 == 0 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.3.png")!).colorWithAlphaComponent(0.5) }
			else if i % 4 == 2 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")!).colorWithAlphaComponent(0.5) }
			else { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")!).colorWithAlphaComponent(0.5) }
			
			self.gridView.addSubview(lineView)
			
			i = i + 1
		}
		
	}
	
	// MARK: - Touch
	
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		
		for touch: AnyObject in touches {
			let location = touch.locationInView(gridView)
			touchStart = location.y
			NSLog("> START | %@", location.y)
		}
		
		timerTouch = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("timeIncrementSmall"), userInfo: nil, repeats: true)
		
		timeIncrementSmall()
		
		timeLeftLabel.textColor = UIColor.grayColor()
		
	}
	
	override func touchesMoved(touches: NSSet, withEvent event: UIEvent)
	{
		timerTouch.invalidate()
		for touch: AnyObject in touches
		{
			let location = touch.locationInView(gridView)
			var incrementStep = abs(touchStart - location.y)

			NSLog("%@",incrementStep)
			
			if touchStart > location.y { incrementMinutes += Int(incrementStep) }
			else{ incrementMinutes -= Int(incrementStep) }
			
			if incrementMinutes < 0 {
				incrementMinutes = 0
			}
			
			timeUpdate()
			lineUpdate()
		}
		
		timeLeftLabel.textColor = UIColor.grayColor()
	}
	
	override func touchesEnded(touches: NSSet, withEvent event: UIEvent)
	{
		timerTouch.invalidate()
		
		if incrementMinutes > 0
		{
			alarmSetup()
		}
		
		timeLeftLabel.textColor = UIColor.whiteColor()
		
		timeUpdate()
		lineUpdate()
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
		var lineWidth = CGFloat(Int(gridView.frame.size.width-lineOrigin))
		
		if ( (incrementMinutes/60) + (Int(timeNow.minute)%15) ) < 15 {
			
			lineWidth =  ( CGFloat( incrementMinutes/60 )/15 ) * (screenWidth-(2 * tileSize))
			pointTarget.hidden = true
			
		}
		
		if incrementMinutes < 1 {
			lineWidth = 1
		}
		
		
		pointNow.frame = CGRectMake(lineOrigin, lineVerticalPosition,lineWidth , 1)
	}
	
	func lineThenDraw()
	{
		// Draw Then
		
		var targetSeconds = (timeThen.hour * 60 * 60) + (timeThen.minute * 60) + timeThen.second
		var targetHoursFloat = Float(targetSeconds)/3600
		var positionY = (24-CGFloat(timeThen.hour)) * templateLineSpacing * 4
		
		if timeThen.minute > 45 { positionY -= templateLineSpacing * 3  }
		else if timeThen.minute > 30 { positionY -= templateLineSpacing * 2  }
		else if timeThen.minute > 15 { positionY -= templateLineSpacing * 1  }
		
		let spaceToOccupy = screenWidth - (2 * tileSize)
		
		let percentGone = Float(targetSeconds % 900)/900
		
		println(percentGone)
		
		var posWidth = CGFloat(percentGone) * spaceToOccupy
		
		pointTarget.frame = CGRectMake(0, positionY, posWidth, 1)
		pointTarget.hidden = false
		
		if pointTarget.frame.origin.y == pointNow.frame.origin.y
		{
			pointTarget.hidden = true
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
		while i < Int(someTest - offset)
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
		NSLog("! ALARM | Set: %d", incrementMinutes)
		
		UIApplication.sharedApplication().cancelAllLocalNotifications()
		
		var localNotification:UILocalNotification = UILocalNotification()
		localNotification.alertAction = "turn off the alarm"
		localNotification.alertBody = "∆ Good Mourning"
		let test:NSTimeInterval = NSTimeInterval(incrementMinutes)
		localNotification.fireDate = NSDate(timeIntervalSinceNow: test)
		localNotification.soundName = "test2.wav"
		UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
	}
	
	// MARK: - Misc
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}

}

