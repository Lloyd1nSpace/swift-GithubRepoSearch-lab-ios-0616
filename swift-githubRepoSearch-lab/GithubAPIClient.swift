//
//  GithubAPIClient.swift
//  swift-githubRepoSearch-lab
//
//  Created by Haaris Muneer on 7/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GithubAPIClient {
    
    static let sharedInstance = GithubAPIClient()
    var publicJSON: JSON!
    
    class func getRepositoriesWithCompletion(completion: (NSArray) -> ()) {
        
        let urlString = "\(Secrets.githubAPIURL)repositories"
        let params = ["client_id" : Secrets.clientID,
                      "client_secret": Secrets.secret,]
        
        Alamofire.request(.GET, urlString, parameters: params, encoding: .URL, headers: nil).responseJSON { (response) in
            if let JSON = response.result.value {
                guard let json = JSON as? NSArray else {fatalError("Unable to get data \(response.data)")}
                completion(json)
            }
        }
    }
    
    class func checkIfRepositoryIsStarred(fullName: String, completion: (starred: Bool) -> ()) {
        
        let urlString = "\(Secrets.githubAPIURL)user/starred/\(fullName)?access_token=\(Secrets.token)"
        let headers = ["Authorization" : Secrets.token]
        
        Alamofire.request(.GET, urlString, headers: headers).responseJSON { (response) in
            if response.response?.statusCode == 204 {
                completion(starred: true)
            } else {
                completion(starred: false)
            }
        }
    }
    
    class func starRepository(fullName: String, completion: () -> ()) {
        
        let header = ["Authorization": Secrets.token]
        Alamofire.request(.PUT, "\(Secrets.githubAPIURL)user/starred/\(fullName)", headers: header).responseJSON { (response) in
            if response.response?.statusCode == 204 {
                completion()
            }
        }
    }
    
    class func unstarRepository(fullName: String, completion: () -> ()) {
        
        let urlString = "\(Secrets.githubAPIURL)user/starred/\(fullName)?access_token=\(Secrets.token)"
        let headers = ["Authorization" : Secrets.token]
        
        Alamofire.request(.DELETE, urlString, headers: headers).responseJSON { (response) in
            if response.response?.statusCode == 204 {
                completion()
            } else {
                print(response.response?.statusCode)
            }
        }
    }
    
    func searchRepositories(userText: String, completion: ([GithubRepository]) -> ()) {
        
        let urlString = "\(Secrets.githubAPIURL)search/repositories?q="
        let params = ["client_id": Secrets.clientID,
                      "client_secret": Secrets.secret,
                      ]
        let query = userText.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let url = urlString + query
        
        Alamofire.request(.GET, url, parameters: params).responseJSON { (response) in
            if let data = response.data {
                let json = JSON(data: data)
                var repositories: [GithubRepository] = []
                
                for item in json["items"] {
                    repositories.append(GithubRepository(item: item.1))
                }
                completion(repositories)
            } else {
                print("Error fetching repositories matching '\(userText)'")
            }
        }
    }
}