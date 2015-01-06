//
//  ViewController.swift
//  NSURLSession+NSURLCache
//
//  Created by Oliver Pfeffer on 1/5/15.
//  Copyright (c) 2015 Astrio. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cacheStatMemory: UILabel!
    @IBOutlet weak var cacheStatDisk: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config object
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.requestCachePolicy = .ReturnCacheDataElseLoad
        config.timeoutIntervalForRequest = 15
        config.URLCache = cache
        
        session = NSURLSession(configuration: config)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateCacheStats()
        fetchImages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Cache; 100mb memory, 500mb disk. Be generous.
    lazy var cache: NSURLCache = {
        let cache = NSURLCache(memoryCapacity: 100*1024*1024, diskCapacity: 500*1024*1024, diskPath: nil)
        sleep(1) // read somewhere that would help...
        
        return cache
    }()
    
    /// Underlying session object
    var session: NSURLSession!
    
    /// Request Logs; (URL, inCache)
    var logs = [ [(String, Bool)] ]()
    
    // MARK: TableView DataSource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return logs.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("logCell") as UITableViewCell
        let log = logs[indexPath.section][indexPath.row]
        
        cell.textLabel?
        cell.textLabel?.text = log.0
        cell.detailTextLabel?.text = log.1 ? "yes" : "no"
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Refresh #\(section)"
    }
    
    // MARK: - IBActions

    @IBAction func reloadButtonTapped(sender: UIButton) {
        removeImagesFromInterface()
        fetchImages()
    }
    
    @IBAction func refreshStatsButtonTapped(sender: UIButton) {
        updateCacheStats()
    }
    // MARK: - Custom Methods
    
    /// Generic Iterator with closure.
    func each<T>(array: [T], closure: (Int, T) -> Void) {
        for i in 0..<array.count {
            closure(i, array[i])
        }
    }
    
    func fetchImages() {
        var runLogs = [String, Bool]()
        
        each(containerView.subviews as [UIImageView]) { (index, imageView) in
            // set a backgroundColor for the heck of it.
            let comp = (255.0-20.0*CGFloat(index))/255.0
            let bgColor = UIColor(red: comp, green: comp, blue: comp, alpha: 1)
            imageView.backgroundColor = bgColor
            
            let request = PhotoRouter.URL(index)

            // add it to the logs
            runLogs.append((request.URL.absoluteString!, self.checkCache(request)))
            
            // lets get our beautiful kitten pictures
            self.session.dataTaskWithRequest(request) { (data, response, error) in
                println(response)

                if data != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        
        self.logs.append(runLogs)
        self.tableView.reloadData()
    }
    
    func removeImagesFromInterface() {
        each(containerView.subviews as [UIImageView]) { (index, imageView) in
            imageView.image = nil
        }
    }
    
    /// Checks for the existence of a cached response object.
    func checkCache(request: NSURLRequest) -> Bool {
        return cache.cachedResponseForRequest(request) != nil
    }
    
    func updateCacheStats() {
        cacheStatMemory.text = "Memory: \(cache.currentMemoryUsage)/\(cache.memoryCapacity) (\(cache.currentMemoryUsage/cache.memoryCapacity)%)"
        cacheStatDisk.text = "Disk:       \(cache.currentDiskUsage)/\(cache.diskCapacity) (\(Double(cache.currentDiskUsage)/Double(cache.diskCapacity)*100)%)"
    }
    
    
    struct PhotoRouter {
        // placekitten.com doesn't set expected Cache-Control headers :[
        static let baseURLString = "http://fpoimg.com/"
        
        // almost 2 by 3 :]
        private static func twoByThree(width: Int) -> (Int, Int) {
            return (width, width+width/2)
        }
        
        static func URL(index: Int) -> NSURLRequest {
            let ratio = twoByThree(200 + index)
            let url = NSURL(string: baseURLString + "\(ratio.0)x\(ratio.1)?text=Image\(index)")!
            
            return NSURLRequest(URL: url, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 15)
        }
    }

}

