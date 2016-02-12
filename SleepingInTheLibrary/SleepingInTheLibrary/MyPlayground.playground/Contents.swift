//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"



let someParameters =
[
    "course" :"networking",
    "nanodegree":"ios",
    "quiz":"escaping parameters"
]

private func escapedParameters(parameters:[String:AnyObject]) -> String {
    
    
    if parameters.isEmpty {
        return ""
    }else{
        var keyValuePairs = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            //escape
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            keyValuePairs.append(key + "=" + "\(escapedValue!)")
            
        }
        return "?\(keyValuePairs.joinWithSeparator("&"))"
    }
}




print(escapedParameters(someParameters))




