//
//  ViewController.swift
//  dewdue
//
//  Created by Devine Lu Linvega on 2014-08-06.
//  Copyright (c) 2014 XXIIVV. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController {
                            
	@IBOutlet var timeLeftLabel: UILabel!
	@IBOutlet var timeTargetLabel: UILabel!
	@IBOutlet var timeTouchView: UIView!
	@IBOutlet var gridView: UIView!
	@IBOutlet var pointNow: UIView!
	@IBOutlet var pointTarget: UIView!
	@IBOutlet var alarmLabel: UILabel!
    
    @IBOutlet weak var markerNow: UIView!
    @IBOutlet weak var markerTarget: UIView!
	
	var tileSize:CGFloat = 0.0
	var screenWidth:CGFloat = 0.0
	var screenHeight:CGFloat = 0.0
	
	var templateLineSpacing:CGFloat = 5.0
	
	var touchStart:CGFloat = 0.0
	var incrementMinutes = 0
	
	var timeNow: NSDateComponents!
	var timeThen: NSDateComponents!
	
	var timerTouch:NSTimer!
    
    var touchSound:SystemSoundID = 0
    var releaseSound:SystemSoundID?
    var barSound:SystemSoundID?
    
    var lastLineCount:Float = 0.0
	
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
        touchSound = createTouchSound()
        releaseSound = createReleaseSound()
        barSound = createBarSound()
        
		timeUpdate()
		var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("timeStep"), userInfo: nil, repeats: true)
	}
	
	func timeUpdate()
	{
		let date = NSDate()
		
		let calendar = NSCalendar.currentCalendar()
		let dateFormatter = NSDateFormatter()
		dateFormatter.timeZone = NSTimeZone()
		
		timeNow = calendar.components([.Hour, .Minute, .Second] , fromDate: date)
		
		let dateFuture = NSDate(timeIntervalSinceNow: NSTimeInterval(incrementMinutes) )
		let futureDate = dateFormatter.stringFromDate( dateFuture )
		
		timeThen = calendar.components([.Hour, .Minute, .Second] , fromDate: dateFuture)
		
		var timeThenSecondsString = "\(timeThen.second)"
		if( timeThen.second < 10 ){ timeThenSecondsString = "0\(timeThen.second)" }
		
		var timeThenMinutesString = "\(timeThen.minute)"
		if( timeThen.minute < 10 ){ timeThenMinutesString = "0\(timeThen.minute)" }
		
		timeTargetLabel.text = "\(timeThen.hour):\(timeThenMinutesString):\(timeThenSecondsString)"
		
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
        
        incrementMinutes = incrementMinutes % 86400
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
		
		NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("templateGrid"), userInfo: nil, repeats: false)
	}
	
	func templateGrid()
	{
        var i = 1
		while i < 24*4
		{
            let targetFrame:CGRect = CGRectMake(0, (templateLineSpacing * CGFloat(i)), screenWidth-(2*tileSize)+1, 1)
            let initFrame:CGRect = CGRectMake(0, (templateLineSpacing * CGFloat(i)), 0, 1)
			let lineView = UIView(frame: initFrame)
			
			if i == 0 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")!).colorWithAlphaComponent(0.5) }
			else if i % 24 == 0 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.3.png")!).colorWithAlphaComponent(0.5) }
			else if i % 4 == 2 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")!).colorWithAlphaComponent(0.5) }
			else { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")!).colorWithAlphaComponent(0.5) }
			
			self.gridView.addSubview(lineView)
            
            
            let duration = 0.5
            let delay:NSTimeInterval = (0.01 * Double(i))
            let options = UIViewAnimationOptions.CurveLinear
            
            UIView.animateWithDuration(duration, delay: delay, options: options, animations: {
                // any changes entered in this block will be animated
                lineView.frame = targetFrame
            }, completion: nil)

			i = i + 1
		}
		
	}
    
	// MARK: - Touch
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
        AudioServicesPlaySystemSound(touchSound)
        
        if(( timerTouch ) != nil){
            timerTouch.invalidate()
        }
        
		for touch: AnyObject in touches {
			let location = touch.locationInView(gridView)
			touchStart = location.y
		}
		
		timerTouch = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("timeIncrementSmall"), userInfo: nil, repeats: true)
		
		timeIncrementSmall()
		
		timeLeftLabel.textColor = UIColor.grayColor()
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
	{
        timerTouch.invalidate()
        timerTouch.invalidate()
        
		for touch: AnyObject in touches
		{
			let location = touch.locationInView(gridView)
			let incrementStep = abs(touchStart - location.y)
			
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
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        AudioServicesPlaySystemSound(releaseSound!)
        
        timerTouch.invalidate()
        timerTouch.invalidate()
		
		if incrementMinutes > 0
		{
			alarmSetup()
		}
		
		timeLeftLabel.textColor = UIColor.whiteColor()
		
		timeUpdate()
        lineUpdate()
	}
    
    // MARK: Sounds
    
    func createTouchSound() -> SystemSoundID {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "audio.touch", "wav", nil)
        AudioServicesCreateSystemSoundID(soundURL, &soundID)
        return soundID
    }
    
    func createReleaseSound() -> SystemSoundID {
        var soundID: SystemSoundID = 1
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "audio.release", "wav", nil)
        AudioServicesCreateSystemSoundID(soundURL, &soundID)
        return soundID
    }
    
    func createBarSound() -> SystemSoundID {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "audio.bar", "mp3", nil)
        AudioServicesCreateSystemSoundID(soundURL, &soundID)
        return soundID
    }
    
    // MARK: Misc
	
	func lineUpdate()
	{
		lineNowDraw()
		lineThenDraw()
		lineInbetweensDraw()
	}
	
	func lineNowDraw()
	{
		let targetSeconds = (timeNow.hour * 60 * 60) + (timeNow.minute * 60) + timeNow.second
		
		var positionY = (24-CGFloat(timeNow.hour)) * templateLineSpacing * 4
		
		if timeNow.minute >= 45 { positionY -= templateLineSpacing * 3  }
		else if timeNow.minute >= 30 { positionY -= templateLineSpacing * 2  }
		else if timeNow.minute >= 15 { positionY -= templateLineSpacing * 1  }
		
		let spaceToOccupy = screenWidth - (2 * tileSize)
		
		let percentGone = Float(targetSeconds % 900)/900
		var posWidth = CGFloat(percentGone) * spaceToOccupy
		
		var lineOrigin = CGFloat(percentGone) * spaceToOccupy
		var lineWidth = CGFloat(Int(gridView.frame.size.width-lineOrigin))
		
		let fromMinutePos = ((timeNow.minute * 60) + timeNow.second) % 900
		
		// Doesnt take the whole line
		if fromMinutePos + incrementMinutes < 900
		{
			let targetTimeThen = (timeThen.hour * 60 * 60) + (timeThen.minute * 60) + timeThen.second
			
			let targetPercentGone = Float(targetTimeThen % 900)/900
			var targetPosWidth = CGFloat(targetPercentGone) * spaceToOccupy
			targetPosWidth = targetPosWidth - lineOrigin
			
			lineWidth = targetPosWidth
			pointTarget.hidden = true
			
		}
		
		if lineWidth < 2 {
			lineWidth = 1
		}
        
        lineOrigin = CGFloat(Int(lineOrigin))

		pointNow.frame = CGRectMake(lineOrigin, positionY,lineWidth , 1)
        
        markerNow.backgroundColor = UIColor.grayColor()
        markerNow.frame = CGRectMake(tileSize * 0.75 * -1, positionY, tileSize/2, 1)
	}
	
	func lineThenDraw()
	{
		// Draw Then
		
		let targetSeconds = (timeThen.hour * 60 * 60) + (timeThen.minute * 60) + timeThen.second
		var positionY = (24-CGFloat(timeThen.hour)) * templateLineSpacing * 4
		
		if timeThen.minute > 44 { positionY -= templateLineSpacing * 3  }
		else if timeThen.minute > 29 { positionY -= templateLineSpacing * 2  }
		else if timeThen.minute > 14 { positionY -= templateLineSpacing * 1  }
		
		let spaceToOccupy = screenWidth - (2 * tileSize)
		
		let percentGone = Float(targetSeconds % 900)/900
		let posWidth = CGFloat(percentGone) * spaceToOccupy
		
		pointTarget.frame = CGRectMake(0, positionY, posWidth, 1)
		pointTarget.hidden = false
		
		if pointTarget.frame.origin.y == pointNow.frame.origin.y
		{
			pointTarget.hidden = true
		}
        
        markerTarget.backgroundColor = UIColor.grayColor()
        markerTarget.frame = CGRectMake(tileSize * 0.75 * -1, positionY, tileSize/2, 1)
	}
	
	func lineInbetweensDraw()
	{
		for view in gridView.subviews {
			if view.tag != 100 { continue }
			view.removeFromSuperview()
		}
		
		let numberOfLines = (pointNow.frame.origin.y - pointTarget.frame.origin.y)/templateLineSpacing
		
		var i = 0
		while i < Int(numberOfLines) - 1
		{
			let positionY = pointTarget.frame.origin.y + ( CGFloat(i+1) * templateLineSpacing)
			let lineView = UIView(frame: CGRectMake(0.0, positionY, screenWidth-(2*tileSize), 1))
			lineView.backgroundColor = UIColor.whiteColor()
			lineView.tag = 100
			self.gridView.addSubview(lineView)
			i = i + 1
		}
        
        if( Float(numberOfLines) != Float(lastLineCount) ){
            AudioServicesPlaySystemSound(barSound!)
        }
        
        lastLineCount = Float(numberOfLines)
		
		// If it goes over midnight
		if( numberOfLines < 0 ){
			
			// Lines above
			var limitLines = (24-CGFloat(timeNow.hour)) * templateLineSpacing * 4
            
//            if timeNow.minute > 44 { limitLines = limitLines * 3 }
//            else if timeNow.minute > 29 { limitLines = limitLines * 2  }
//            else if timeNow.minute > 14 { limitLines = limitLines * 1  }
//            else { limitLines = limitLines * 4  }
            
			var i = 0
			while i < Int(limitLines)
			{
				let positionY = ((limitLines)) - ( CGFloat(1+i) * templateLineSpacing)
				
				let lineView = UIView(frame: CGRectMake(0.0, positionY, screenWidth-(2*tileSize), 1))
				lineView.backgroundColor = UIColor.whiteColor()
				lineView.tag = 100
				if( positionY > (-1 * templateLineSpacing) + templateLineSpacing ){
					self.gridView.addSubview(lineView)
				}
				
				i += 1
			}
			
			// Lines below
			limitLines = (24 * 4 ) - ( (24-CGFloat(timeThen.hour)) * 4 )
			i = 0
			while i < Int(24*4)
			{
				let positionY = ((24*4*templateLineSpacing)) - ( CGFloat(1+i) * templateLineSpacing)
				
				let lineView = UIView(frame: CGRectMake(0.0, positionY, screenWidth-(2*tileSize), 1))
				lineView.backgroundColor = UIColor.whiteColor()
				lineView.tag = 100
				if( positionY > pointTarget.frame.origin.y ){
					self.gridView.addSubview(lineView)
				}
				
				i += 1
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
	
	// MARK: - Alarm
	
	func alarmSetup()
	{
		NSLog("! ALARM | Set: %d", incrementMinutes)
		
		UIApplication.sharedApplication().cancelAllLocalNotifications()
		
		let localNotification:UILocalNotification = UILocalNotification()
		localNotification.alertAction = "turn off the alarm"
		if( incrementMinutes % 2 == 0){
			localNotification.alertBody = "◉"
		}
		else{
			localNotification.alertBody = "◎"
		}
		let test:NSTimeInterval = NSTimeInterval(incrementMinutes)
		localNotification.fireDate = NSDate(timeIntervalSinceNow: test)
		localNotification.soundName = "alarm_tone.wav"
		UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
		
		self.alarmLabel.text = "ALARM SET"
		self.alarmLabel.alpha = 1
		
		UIView.animateWithDuration(1.0, delay: 1.5, options: .CurveEaseOut, animations: { self.alarmLabel.alpha = 0 }, completion: { finished in print("") })
	}
	
	// MARK: - Misc
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}

}

