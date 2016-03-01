//
//  Cloudant.swift
//
//  Created by Cameron Conway on 2/25/16.
//  Copyright © 2016 Cam-Built Programming Plus. All rights reserved.
//

class Cloudant:NSObject {
    static let cloudantUrl = "https://[your host id]-bluemix.cloudant.com"
    static var base64Auth:String?
    
    static var base64Authorization:String! {
        get {
            if base64Auth == nil {
                let keyString = "[your Cloudant API key]:[the associated API password]"
                let plainTextData = keyString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) as NSData!
                base64Auth = plainTextData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed) as String!
            }
            
            return base64Auth
        }
    }
    
    class func getAllDocs(dbName:String, completionHandler:([NSDictionary]?, error:NSError?) -> Void) {
        if let url = NSURL(string: "\(cloudantUrl)/\(dbName)/_all_docs?include_docs=true") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.setValue("Basic \(base64Authorization)", forHTTPHeaderField: "Authorization")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
                if error == nil {
                    let httpResponse = response as! NSHTTPURLResponse!
                    
                    if httpResponse.statusCode == 200 {
                        do {
                            if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary, let rows = json["rows"] as? [NSDictionary] {
                                completionHandler(rows, error:nil)
                            }
                        } catch {
                            let err = NSError(domain: "Cloudant", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON Serialization error: \(error)"])
                            completionHandler(nil, error:err)
                        }
                    } else {
                        let error = NSError(domain: "Cloudant", code: 1, userInfo: [NSLocalizedDescriptionKey: "HTTP Response Code \(httpResponse.statusCode), \(httpResponse.description)"])
                        completionHandler(nil, error:error)
                    }
                } else {
                    completionHandler(nil, error:error)
                }
            })
            task.resume()
        }
    }
    
    
    class func findDocs(dbName:String, condition:NSDictionary, completionHandler:([NSDictionary]?, error:NSError?) -> Void) {
        if let url = NSURL(string: "\(cloudantUrl)/\(dbName)/_find") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue("Basic \(base64Authorization)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(condition, options: [])
            } catch {
                request.HTTPBody = nil
            }
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
                if error == nil {
                    let httpResponse = response as! NSHTTPURLResponse!
                    
                    if httpResponse.statusCode == 200 {
                        do {
                            if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary, let docs = json["docs"] as? [NSDictionary] {
                                completionHandler(docs, error:nil)
                            }
                        } catch {
                            let err = NSError(domain: "Cloudant", code: 3, userInfo: [NSLocalizedDescriptionKey: "JSON Serialization error: \(error)"])
                            completionHandler(nil, error:err)
                        }
                    } else {
                        let error = NSError(domain: "Cloudant", code: 3, userInfo: [NSLocalizedDescriptionKey: "HTTP Response Code \(httpResponse.statusCode), \(httpResponse.description)"])
                        completionHandler(nil, error:error)
                    }
                } else {
                    print(error)
                    completionHandler(nil, error:error)
                }
            })
            task.resume()
        }
    }
    
    class func findDoc(dbName:String, id:String, completionHandler:(NSDictionary?, error:NSError?) -> Void) {
        if let url = NSURL(string: "\(cloudantUrl)/\(dbName)/\(id)") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.setValue("Basic \(base64Authorization)", forHTTPHeaderField: "Authorization")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
                if error == nil {
                    let httpResponse = response as! NSHTTPURLResponse!
                    
                    if httpResponse.statusCode == 200 {
                        do {
                            if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                                completionHandler(json, error:nil)
                            }
                        } catch {
                            let err = NSError(domain: "Cloudant", code: 6, userInfo: [NSLocalizedDescriptionKey: "JSON Serialization error: \(error)"])
                            completionHandler(nil, error:err)
                        }
                    } else if httpResponse.statusCode == 404 {
                        completionHandler(nil, error:nil)
                    } else {
                        let error = NSError(domain: "Cloudant", code: 6, userInfo: [NSLocalizedDescriptionKey: "HTTP Response Code \(httpResponse.statusCode), \(httpResponse.description)"])
                        completionHandler(nil, error:error)
                    }
                } else {
                    print(error)
                    completionHandler(nil, error:error)
                }
            })
            task.resume()
        }
    }
    
    class func createDoc(dbName:String, doc:NSDictionary, completionHandler:(Bool, error:NSError?) -> Void) {
        if let url = NSURL(string: "\(cloudantUrl)/\(dbName)") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue("Basic \(base64Authorization)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(doc, options: [])
            } catch {
                request.HTTPBody = nil
            }
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
                if error == nil {
                    let httpResponse = response as! NSHTTPURLResponse!
                    
                    if httpResponse.statusCode == 201 {
                        completionHandler(true, error:nil)
                    } else {
                        let error = NSError(domain: "Cloudant", code: 5, userInfo: [NSLocalizedDescriptionKey: "HTTP Response Code \(httpResponse.statusCode), \(httpResponse.description)"])
                        completionHandler(false, error: error)
                    }
                } else {
                    completionHandler(false, error: error)
                }
            })
            task.resume()
        }
    }
    
    class func deleteDoc(dbName:String, id:String, rev:String, completionHandler:(success:Bool, error:NSError?) -> Void) {
        if let url = NSURL(string: "\(cloudantUrl)/\(dbName)/\(id)?rev=\(rev)".stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!.stringByReplacingOccurrencesOfString("&", withString: "%26", options: [], range: nil)) {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "DELETE"
            request.setValue("Basic \(base64Authorization)", forHTTPHeaderField: "Authorization")
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
                if error == nil {
                    let httpResponse = response as! NSHTTPURLResponse!
                    
                    if httpResponse.statusCode == 200 {
                        completionHandler(success: true, error:nil)
                    } else {
                        let error = NSError(domain: "Cloudant", code: 7, userInfo: [NSLocalizedDescriptionKey: "HTTP Response Code \(httpResponse.statusCode), \(httpResponse.description)"])
                        completionHandler(success: false, error: error)
                    }
                } else {
                    completionHandler(success: false, error: error)
                }
            })
            task.resume()
        } else {
            completionHandler(success: false, error: nil)
        }
    }
    
    class func postBulkDocs(dbName:String, docArray:[NSDictionary], completionHandler:(success:Bool, error:NSError?) -> Void) {
        if let url = NSURL(string: "\(cloudantUrl)/\(dbName)/_bulk_docs") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue("Basic \(base64Authorization)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(["docs":docArray], options: [])
            } catch {
                request.HTTPBody = nil
            }
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
                if error == nil {
                    let httpResponse = response as! NSHTTPURLResponse!
                    
                    if httpResponse.statusCode == 201 {
                        completionHandler(success: true, error:nil)
                    } else {
                        let error = NSError(domain: "Cloudant", code: 2, userInfo: [NSLocalizedDescriptionKey: "HTTP Response Code \(httpResponse.statusCode), \(httpResponse.description)"])
                        completionHandler(success: false, error: error)
                    }
                } else {
                    completionHandler(success: false, error: error)
                }
            })
            task.resume()
        }
    }
    
    class func createIndex(dbName:String, body:NSDictionary, completionHandler:(success:Bool, error:NSError?) -> Void) {
        if let url = NSURL(string: "\(cloudantUrl)/\(dbName)/_index") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.setValue("Basic \(base64Authorization)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: [])
            } catch {
                request.HTTPBody = nil
            }
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
                if error == nil {
                    let httpResponse = response as! NSHTTPURLResponse!
                    
                    if httpResponse.statusCode == 200 {
                        completionHandler(success: true, error:nil)
                    } else {
                        let error = NSError(domain: "Cloudant", code: 4, userInfo: [NSLocalizedDescriptionKey: "HTTP Response Code \(httpResponse.statusCode), \(httpResponse.description)"])
                        completionHandler(success: false, error: error)
                    }
                } else {
                    completionHandler(success: false, error: error)
                }
            })
            task.resume()
        }
    }
}
