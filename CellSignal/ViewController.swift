//
//  ViewController.swift
//  CellSignal
//
//  Created by Al Pascual on 1/19/18.
//  Copyright © 2018 Al Pascual. All rights reserved.
//

import UIKit
import CoreLocation
import Crashlytics

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var signalImage: UIImageView!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var lineChart: LineChartCustom!
    @IBOutlet weak var labelSignal: UILabel!
    @IBOutlet weak var QueuedLabel: UILabel!
    @IBOutlet weak var sentLabel: UILabel!
    @IBOutlet weak var sensivityLabel: UILabel!
    @IBOutlet weak var updateOfflineButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var distanceFilterSlider: UISlider!
    //@IBOutlet weak var tank: VNTankView!
    let locationManager = CLLocationManager()
    var lineValues = [CGFloat]()
    
    //let databaseManager = SqliteManager()
    let databaseManager = UnsentFeaturesManager()
    
    let reachability = Reachability()!
    var hasInternet = false
    var editor: Editor? = nil
    var timer: Timer? = nil
    var privateTimer: Timer? = nil
    var timerHeartbeat: Timer? = nil
    var sentCounter = 0
    var featureServiceError = 0
    var offlineFeaturesSender: OfflineFeaturesSender?
    
    // ------------ New feature service sync
    // Not in used at this time, we are using Editor at this time
    var bUseTrackingService = false
    var trackingService: FeatureServiceEditor? {
        didSet {
            if trackingService == nil {
                uploadTimer?.invalidate()
            } else {
                uploadTimer = Timer.scheduledTimer(withTimeInterval: uploadTimeInterval, repeats: true) { _ in
                    self.uploadIfNecessary()
                }
            }
        }
    }
    var isUploading = false
    let uploadTimeInterval: TimeInterval = 300
    var uploadTimer: Timer?
    var lastUploadTime: Date?
    // ----------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            versionLabel.text = "Version \(versionNumber)"
        }
        
        lineChart.colors = [UIColor.black, UIColor.black]
        
        databaseManager.viewController = self
        //tank.percent = 0
        
        // Start Location Manager and Motion
        LocationManager(locationManager:locationManager).setup(distanceFilter: Double(distanceFilterSlider.value))
        locationManager.delegate = self
        sensivityLabel.text = "Location Filter: \(distanceFilterSlider.value)"
        
        startReachability()
        
        setupChart()
        
        updateUnsentFeatures()
        
        timerHeartbeat = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.checkForOfflineFeatures), userInfo: nil, repeats: true)
        
        // Test the crash
        //Crashlytics.sharedInstance().crash()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var signal = SignalStrength().getSignalStrength()
        
        // Internet down, the UI could fail at reporting 0
        if hasInternet == false {
            signal = 0
        }
        
        lineValues.append(CGFloat(signal))
        lineChart.clearAll()
        lineChart.addLine(lineValues)
        labelSignal.text = "Last Signal: \(signal)"
        
        var signalObservation: SignalObservation? = nil
        if let coordinate = locations.last?.coordinate {
            gpsLabel.text = "\(coordinate.latitude) \(coordinate.longitude)"
            
            let altitude = locations.last?.altitude ?? 0
            
            // Create the observation
            signalObservation = SignalObservation(coordinates: coordinate, signalStrength: Int(signal), altitude: altitude)
        }
        
        // Clear the lines to avoid the chart to get huge
        if lineValues.count > 15 {
            lineValues.remove(at: 0)
        }
        
        if hasInternet {
            
            // Build the editor for the first time
            loadEditor()
            
            // Send observation to the feature service inmediatly
            if let signalObservation = signalObservation {
                
                sendObservation(signalObservation: signalObservation, databaseObservation: nil, completion: { success in
                    
                    self.checkForOfflineFeatures()
                })
            }
        } else {
            // No internet, adding into the database for later.
            if let signalObservation = signalObservation {
                _ = databaseManager.addObservation(newObservation: signalObservation)
            }
            updateUnsentFeatures()
        }
    }
    
    private func loadEditor() {
        if editor == nil {
            
            SettingsBundleHelper.registerSettingsBundle()
            
            var urlString = UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.FeatureService)
            var username = UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.Username)
            var password = UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.Password)
            var webMap = UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.WebMap)
            var portalUrl = UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.Portal)
            
            if urlString == nil {
                urlString = SettingsBundleHelper.featureServiceToUse
                UserDefaults.standard.set(urlString, forKey: SettingsBundleHelper.SettingsBundleKeys.FeatureService)
            }
            if username == nil {
                username = "blank"
                UserDefaults.standard.set(username, forKey: SettingsBundleHelper.SettingsBundleKeys.Username)
            }
            if password == nil {
                password = "blank"
                UserDefaults.standard.set(password, forKey: SettingsBundleHelper.SettingsBundleKeys.Password)
            }
            if webMap == nil {
                webMap = "insert-id-here"
                UserDefaults.standard.set(webMap, forKey: SettingsBundleHelper.SettingsBundleKeys.WebMap)
            }
            if portalUrl == nil {
                portalUrl = "https://arcgis.com/....."
                UserDefaults.standard.set(portalUrl, forKey: SettingsBundleHelper.SettingsBundleKeys.Portal)
            }
            
            //USE the new tracking start the new service here
            if bUseTrackingService {
                if let urlString = urlString, let username = username, let password = password {
                    trackingService = FeatureServiceEditor(tracksUrl: URL(string: urlString)!, username: username, password: password)
                }
            }
            
            if trackingService == nil {
                if let urlString = urlString, let username = username, let password = password {
                    editor = Editor(urlString: urlString, username: username, password: password)
                }
            }
        }
    }
    
    var privateTimerReschedule = 0
    @objc private func checkForOfflineFeatures() {
        
        // Update signal without GPS
        var signal = SignalStrength().getSignalStrength()
        
        // Internet down, the UI could fail at reporting 0
        if hasInternet == false {
            signal = 0
        }
        
        labelSignal.text = "Last Signal: \(signal)"
        
        // Check if there are old observations to send to the feature service
        if self.timer == nil && self.privateTimer == nil && hasInternet {
            privateTimerReschedule = 0
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.CheckForObservations), userInfo: nil, repeats: false)
        } else {
            //Check the private timer as does not become nil when there are features waiting
            if let databaseCount = databaseManager.fetchUnsentObservations()?.count {
                if databaseCount > 1 {
                    privateTimerReschedule = privateTimerReschedule + 1
                    if privateTimerReschedule > 4 {
                        privateTimerReschedule = 0
                        self.privateTimer = nil
                    }
                }
            }
        }
        
        // Check if the feature service is having issues
        if featureServiceError > 10 {
            featureServiceError = 0
            loadEditor()
            print("loading editor again")
        }
    }
    
    @objc func CheckForObservations() {
        
        defer {
            timer?.invalidate()
            timer = nil
        }
        
        let unsent = databaseManager.fetchUnsentObservations()
        if unsent == nil {
            return
        }
        if unsent?.count == 0 {
            return
        }
        
        if privateTimer == nil {
            privateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.SendOfflineObservations), userInfo: nil, repeats: false)
            showSendingImage()
        }
    }
    
    @objc func SendOfflineObservations() {
        
         // Kill the timer
        func closePrivateTimer() {
            privateTimer?.invalidate()
            privateTimer = nil
            showSendingImage()
        }
        
        func rescheduleTimer(interval: Double) {
            privateTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.SendOfflineObservations), userInfo: nil, repeats: false)
        }
        
        updateUnsentFeatures()
        
        let unsent = databaseManager.fetchUnsentObservations()
        
        if let unsent = unsent {
            //Cannot send features too fast or will create duplicate, wait until
            //we get the confirmation that is stored before sending next one
            //we are using a timer that only fires after the confirmation happens            
            if let observation = unsent.first {
                
                if let signalObservation = databaseManager.convertToSignalObservation(observation: observation) {
                
                    self.sendObservation(signalObservation: signalObservation, databaseObservation: observation, completion: { [weak self] success in
                        
                        self?.databaseManager.deleteAllSent()
                        if success {
                            self?.updateUnsentFeatures()
                        } else {
                            // Store for later
                            if let mySelf = self {
                                mySelf.featureServiceError = mySelf.featureServiceError + 1
                            }
                        }
                        
                        closePrivateTimer()
                        //rescheduleTimer(interval: 0.1)
                        return
                    })
                }
            }
            
            if unsent.count == 0 {
                closePrivateTimer()
            } else if unsent.count > 1 {
                print("Unsent feature waiting \(unsent.count)")
                
            } else {
                print("Unsent is less than interval \(unsent.count)")
            }
            
            // The private time won't be nil due the unsent only sends one at the time
            // when there are a collection waiting the timer never becomes nil
        } else {
            closePrivateTimer()
        }
    }
    
    func updateUnsentFeatures() {
        let count = "\(databaseManager.fetchUnsentObservations()?.count ?? 0)"
        //print("Unsent features count \(count)")
        
        self.QueuedLabel.text = "\(count) features unsent"
//        if let floatCount = Float(count) {
//            if floatCount > 0 {
//                
//                self.tank.percent = floatCount / 100
//            }
//        }
    }
    
    func sendObservation(signalObservation: SignalObservation, databaseObservation: Any?, completion: @escaping (_ success:Bool) -> Void) {
        
        // Otherwise send the observation to the server
        
        // Update status of the observation inside the sql database.
        // Should we avoid to change the status so many times?
        
        func updateStatusObservation(databaseObservation: Any?, status: String) {
            if let databaseObservation = databaseObservation as? Observation{
                databaseObservation.status = status
                self.databaseManager.updateObservation(databaseObservation: databaseObservation)
            } else if let databaseObservation = databaseObservation as? MemoryObservation {
                databaseObservation.status = status
                self.databaseManager.updateObservation(databaseObservation: databaseObservation)
            }
        }
        
        updateStatusObservation(databaseObservation: databaseObservation, status: "sending")
        
        if trackingService == nil {
            editor?.addObservationToFeatureService(signalObservation: signalObservation, counter: String(sentCounter), completion: { [weak self] success in
                
                //print("Enter \(String(describing: self?.sentCounter))")
                
                if success {
                    // Update the database only when is offline
                    updateStatusObservation(databaseObservation: databaseObservation, status: "sending")
                    
                    // Update the counter
                    if var sentCounter = self?.sentCounter {
                        sentCounter = sentCounter + 1
                        self?.sentLabel.text = "\(sentCounter) features stored online"
                        self?.sentCounter = sentCounter
                    }
                } else {
                    
                    if let mySelf = self {
                        
                        if let databaseObservation = databaseObservation {
                            print("failed changing observation status to new")
                            CustomNotification.show(parent: mySelf, title: "Error Feature Service Failed", description: "The request timed out reschedule")
                            updateStatusObservation(databaseObservation: databaseObservation, status: "new")
                            mySelf.updateUnsentFeatures()
                        } else {
                            // Update
                            print("failed queue observation for later")
                            CustomNotification.show(parent: mySelf, title: "Error Feature Service Failed", description: "The request timed out, adding...")
                            _ = self?.databaseManager.addObservation(newObservation: signalObservation)
                            mySelf.updateUnsentFeatures()
                        }
                        
                        mySelf.loadEditor()
                    }
                }
                
                completion(success)
            })
        } else {
            trackingService?.save(observation: signalObservation, completion: { (error) in
                if let error = error {
                    print("error with tracking service \(error)")
                } else {
                    updateStatusObservation(databaseObservation: databaseObservation, status: "sent")
                    
                    // Update the counter
                    self.sentCounter = self.sentCounter + 1
                    self.sentLabel.text = "\(self.sentCounter) features stored online"
                }
            })
        }
    }
    
    func setupChart() {
        // Remove labels
        lineChart.x.labels.visible = false
        lineChart.y.labels.visible = true
        lineChart.y.grid.count = 5
        lineChart.y.labels.values = ["0", "1", "2", "3", "4"]
        lineChart.hardMax = 4
        lineChart.hardMin = 0
        
        lineChart.labelsX = ["0", "1", "2", "3", "4"]
        
        lineValues.append(CGFloat(0))
        lineValues.append(CGFloat(0))
        lineValues.append(CGFloat(0))
        lineValues.append(CGFloat(0))
        lineValues.append(CGFloat(0))
        lineChart.addLine(lineValues)
    }
    
    @IBAction func sensivityChanged(_ sender: Any) {
        
        let sensivityControl = sender as! UISlider
        let sliderValue = round(sensivityControl.value)
        sensivityLabel.text = "Location Filter: \(sliderValue)"
        
        if locationManager.distanceFilter != Double(sliderValue) {
            locationManager.stopUpdatingLocation()
            locationManager.distanceFilter = Double(sliderValue)
            locationManager.startUpdatingLocation()
        }
    }
    
    func startReachability() {
        
        reachability.whenReachable = { [weak self] reachability in
            
            self?.hasInternet = true
            self?.signalImage.isHidden = true
            
            // Start the timer to check for offline features if needed.
            self?.checkForOfflineFeatures()
            self?.updateOfflineButton.isEnabled = true
            
            if reachability.connection == .wifi {
                // Disconnect from the WIFI notification
                if let mySelf = self {
                    CustomNotification.show(parent: mySelf, title: "WIFI detected", description: "Disconnect from the current WIFI to get accurate reading.")
                }
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
                
                // TODO Make sure the data plan actually works
                
            }
            
        }
        reachability.whenUnreachable = { [weak self] _ in
            print("Not reachable")
            self?.hasInternet = false
            self?.signalImage.isHidden = false
            self?.updateOfflineButton.isEnabled = false
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func showSendingImage() {
        
        if privateTimer == nil {
            sendImage.isHidden = true
        } else if hasInternet {
            sendImage.isHidden = false
        } else {
            sendImage.isHidden = true
        }
    }
    
    @IBAction func updateOfflinePressed(_ sender: Any) {
        
        if let count = databaseManager.fetchUnsentObservations()?.count {
        
            if count > 0 {
                privateTimer?.invalidate()
                privateTimer = nil
                
                // Stop the internet for now
                hasInternet = false
                
                guard let editor = editor else {
                    CustomNotification.show(parent: self, title: "Cannot Sync Offline", description: "Feature Service Editor is not enabled.")
                    return
                }
                
                offlineFeaturesSender = OfflineFeaturesSender(editor: editor, databaseManager: databaseManager, sentCounter: sentCounter, sentLabel: sentLabel, QueuedLabel: self.QueuedLabel)
                if let offlineFeaturesSender = offlineFeaturesSender {
                    offlineFeaturesSender.finishHandler = {
                        self.hasInternet = true
                        self.updateUnsentFeatures()
                        self.offlineFeaturesSender = nil
                    }
                    
                    offlineFeaturesSender.sendAll()
                }
            }
        }
    }
    
    @IBAction func mapPressed(_ sender: Any) {
        
        CustomNotification.show(parent: self, title: "Tracking Stopped", description: "While the map is open, the tracking of the GPS and Signal has paused.", checkForDuplicates: false)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mapViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        mapViewController.modalPresentationStyle = .overCurrentContext
        present(mapViewController, animated: true, completion: nil)
    }
}

