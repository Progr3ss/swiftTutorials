//
//  Download.swift
//  HalfTunes
//
//  Created by martin chibwe on 1/21/16.
//  Copyright © 2016 Ken Toh. All rights reserved.
//

import Foundation


class Download: NSObject {
    
    var url: String
    var isDownloading = false
    var progress: Float = 0.0
    
    var downloadTask: NSURLSessionDownloadTask?
    var resumeData: NSData?
    
    
    init(url: String){
        self.url = url
    }
}