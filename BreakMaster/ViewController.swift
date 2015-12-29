//
//  ViewController.swift
//  BreakMaster
//
//  Created by KakimotoMasaaki on 2015/12/26.
//  Copyright © 2015年 Masaaki Kakimoto. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MEMELibDelegate {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var debugLabel: UILabel!
    var myWebView : UIWebView!
    var startTime: Int = Int(NSDate().timeIntervalSince1970)
    var diffSec: Int = 0
    var totalX = 0
    var totalY = 0
    var totalZ = 0
    var avrX = 0
    var avrY = 0
    var avrZ = 0
    let AVR_LIMIT = 3
    var playMoview = false
    override func viewDidLoad() {
        super.viewDidLoad()
        restartButton.hidden = true
        movieImage.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
        MEMELib.sharedInstance().delegate = self
        statusLabel.text = "現在の状態：ふつう"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func memeAppAuthorized(status: MEMEStatus) {
        MEMELib.sharedInstance().startScanningPeripherals()
    }
    
    func memePeripheralFound(peripheral: CBPeripheral!, withDeviceAddress address: String!) {
        MEMELib.sharedInstance().connectPeripheral(peripheral)
    }
    
    func memePeripheralConnected(peripheral: CBPeripheral!) {
        let status = MEMELib.sharedInstance().startDataReport()
        print(status)
    }
    
    func memeRealTimeModeDataReceived(data: MEMERealTimeData!) {
        print(data.description)
        let diff = Int(NSDate().timeIntervalSince1970) - startTime
        if diff <= diffSec {
            return
        }
        diffSec = diff
        totalX += Int(data.accX)
        totalY += Int(data.accY)
        totalZ += Int(data.accZ)
        avrX = totalX / diffSec
        avrY = totalY / diffSec
        avrZ = totalZ / diffSec
        debugLabel.text = "\(diffSec)sec x=\(data.accX)(\(avrX)) y=\(data.accY)(\(avrY)) z=\(data.accZ)(\(avrZ))"
        
        let diffX = abs(data.accX - avrX)
        let diffY = abs(data.accY - avrY)
        let diffZ = abs(data.accZ - avrZ)
        let diffT = Int(diffX) + Int(diffY) + Int(diffZ)
        
        if diffT > Int(AVR_LIMIT) {
            statusLabel.text = "ふらふらしとる"
        } else if diffSec >= 10 {
            statusLabel.text = "しゅうちゅうしとる"
        } else {
        }
        //最初の30秒は平均値を計測するだけ
        if diffSec <= 20 {
            return
        }
        //restartButton.hidden = false
        //movieImage.hidden = false
        
        if !playMoview {
            playMoview = true
            
            // webViewを生成.
            myWebView = UIWebView()
            myWebView.frame = self.view.bounds
            
            self.view.addSubview(myWebView)
            
            // ファイルパスを生成.
            let path: NSString = NSBundle.mainBundle().pathForResource("player", ofType:"html")!
            
            // requestを生成.
            let request:NSURLRequest = NSURLRequest(URL: NSURL.fileURLWithPath(path as String))
            
            // fullscreen表示ではなく、inline表示にする.
            myWebView.allowsInlineMediaPlayback = true
            
            // 自動的に再生を開始.
            myWebView.mediaPlaybackRequiresUserAction = false
            
            // load開始.
            myWebView.loadRequest(request)
            restartButton.hidden = false
            //workImage.hidden = true
            self.view.bringSubviewToFront(restartButton)
            self.view.sendSubviewToBack(myWebView)
        }
    }

    @IBAction func tappedRestart(sender: AnyObject) {
        restartButton.hidden = true
        movieImage.hidden = true
        //workImage.hidden = false
        startTime = Int(NSDate().timeIntervalSince1970)
        diffSec = 0
        totalX = 0
        totalY = 0
        totalZ = 0
        avrX = 0
        avrY = 0
        avrZ = 0
        playMoview = false
        myWebView.removeFromSuperview()
        myWebView = nil
        statusLabel.text = "現在の状態：ふつう"
    }
}

