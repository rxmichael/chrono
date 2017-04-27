//
//  ViewController.swift
//  chrono
//
//  Created by blackbriar on 3/23/17.
//  Copyright © 2017 Teressa Eid. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

let notificationIdentifier = "TimerUp"

class ViewController: UIViewController {

    
    // MARK: - Outlets from storyboard
    
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var secondsSlider: UISlider!
    @IBOutlet weak var startButton: UIButton!
    
    var timer = Timer()
    var player = AVAudioPlayer()
    
    var counter = 180 {
        didSet {
            secondsLabel.text = "\(self.counter)"
            secondsSlider.setValue(Float(Double(self.counter)), animated: true)
        }
    }
    var isRunning = false {
        didSet {
            if isRunning == false {
                secondsSlider.isEnabled = true
                startButton.setTitle("count me down!", for: .normal)
                startButton.setTitleColor(UIColor(hex: 0xFE7877), for: .normal)
                secondsLabel.textColor = UIColor(hex: 0x85C8FF)
                if self.player.isPlaying {
                    print("player playing")
                    self.player.stop()
                }
                timer.invalidate()
            }
            else {
                startButton.setTitle("Pause maybe? ", for: .normal)
                secondsSlider.isEnabled = false
               
            }
        }
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        self.counter = Int(sender.value)
        secondsLabel.text = "\(self.counter)"
    }
    
    
    
    
    // MARK: - Tapped Action
    
    @IBAction func activateTapped(_ sender: UIBarButtonItem) {
        if !isRunning {
            startCountDown()
            isRunning = true

        }
        else {
            isRunning = false
        }
    }
    
    func startCountDown() {
        playSound(resource: "click", type: "mp3")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
        NotificationsHelper.scheduleLocalNotificationIos10(delay: TimeInterval(self.counter), body: "Hey! Time is up! What do you want to do now? ", title: "Time's Up", soundName: nil, imageName: "coldplay", category: "timerOptions")
    }
    
    
    
    // MARK: - Help functions
    
    private func getSeconds () -> Int {
        return Int(secondsSlider.value)
    }
    
    func getDialog (finished: Bool) -> UIAlertController {
        let title = finished ? "Time's up" : "Timer started"
        let msg = finished ? "Your tea is ready!" : "Your tea countdown started"
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return alert
    }
    
    func updateTimer() {
        if self.counter <= 0 {
            print("time'sup")
            isRunning = false
            self.counter = 180
        }
        else {
            self.counter -= 1
            if self.counter == 20 {
                secondsLabel.textColor = UIColor.red
                playSound(resource: "ctuclock", type: "wav", loop: -1)
            }
        }
            //String(format: "%.1f", self.counter)
        //secondsLabel.text = String(format: "%.1f", self.counter)
    }
    
    func playSound(_ playerAudio: inout AVAudioPlayer, resource: String, type: String) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: type) else {
            return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
        }
        catch let error {
            print("Could not load player \(error.localizedDescription)")
        }
    }
    func playSound(resource: String, type: String, loop: Int = 0) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: type) else {
            return }
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            self.player.prepareToPlay()
            self.player.numberOfLoops = loop
            self.player.play()
            
        }
        catch let error {
            print("Could not load player \(error.localizedDescription)")
        }
    }
    
    
    
    // MARK: - View did Load function
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
    }

}

extension ViewController: UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
            startCountDown()
            isRunning = true
        case "Stop":
            print("Delete")
            isRunning = false
        default:
            print("Unknown action")
        }
        completionHandler()
        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == notificationIdentifier {
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}

