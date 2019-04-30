//
//  PostController.swift
//  Post
//
//  Created by David Sadler on 4/29/19.
//  Copyright © 2019 David Sadler. All rights reserved.
//

import Foundation

class PostController {
    
    // This URL will be used to build other URLs throughout the app
    static let baseURL = URL(string: "https://dm-post.firebaseio.com/posts/")!
    static let getterEndpoint = baseURL.appendingPathComponent("json")
    
    // MARK: - Network Request
    
    // this function will try to perform a GET request on the web API Endpoint
    // What is the completion handler doing here? It is an escaping closure meaning it can be called after this function has returned (Async)? URLSession returns data in the completion handler?
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        
        // 1. Create an unwrapped instant of the baseURL, and the getterEndpoint
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15"
        ]
        let queryItems = urlParameters.compactMap({ URLQueryItem(name: $0.key, value: $0.value) })
        var urlComponents = URLComponents(url: PostController.baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else { completion(); return }
        let getterEndpoint = url.appendingPathExtension("json")
        
        
        //2. Create an instance of URLRequest and give it to the getterEndpoint.
        var request = URLRequest(url: getterEndpoint)
        // We want the HTTP Body to be nil since we only want to get data, and not post it.
        request.httpBody = nil
        request.httpMethod = "GET"
        
        //3. Create an instance of URLSessionDataTask -- Methods makes the network call and calls the completion closure with the results: Data?, URLResponse?, and Error?
        // URLSession (is both a class and suite of classes) is used primarily for interacting wtih web API endpoints. URLSessionDataTask is the task for HTTP GET requests
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
            // 4. Handle the results that the DataTask comes back with. URLResponse if not given a parameter name since we won't be using it in this project.
            if let error = error {
                NSLog("Error retrieving data in \(#function). Error: \(error)")
                completion()
                return
            }
           
            guard let data = data else { NSLog("No data returned from data task."); completion(); return }
            // If the dataTask was successful, data will have a value and error will not -- Here we want to unwrap the data. NOTE: Post adopts Codable protocol.
            do {
                let decoder = JSONDecoder()
                // This postsDictionary constant will decode the data into a [String:Post] dictionary -- IE a dictionary with keys being the UUID that they are stored under and the values being the post objects -- Check out the JSON Data for clarification.
                // This decode function throws - hence the 'try'
                let postsDictionary = try decoder.decode([String:Post].self, from: data)
                // We call compactMap on this post dictionary to pull ot the post from each key-value pair
                let posts: [Post] = postsDictionary.compactMap({ $0.value })
                // Call higher order sorted function to sort the posts reverse chronologically
                let sortedPosts = posts.sorted(by: {$0.timestamp > $1.timestamp})
                if reset {
                    // Assign the PostController posts array to the posts we just received
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
                // Check for an error - if so print and call completion()
            } catch let error {
                NSLog("ERROR Decoding: \(error.localizedDescription)")
                completion()
            }
        })
        dataTask.resume()
    }
    
    // MARK: - Properties
    
    var posts: [Post] = []
    
    
}

