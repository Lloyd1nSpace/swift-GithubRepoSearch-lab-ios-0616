//
//  ReposDataStore.swift
//  swift-githubRepoSearch-lab
//
//  Created by Haaris Muneer on 7/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ReposDataStore {
    
    static let sharedInstance = ReposDataStore()
    private init() {}
    
    let api = GithubAPIClient.sharedInstance
    var repositories:[GithubRepository] = []
    
//    func getRepositoriesWithCompletion(completion: () -> ()) {
//        GithubAPIClient.getRepositoriesWithCompletion { (reposArray) in
//            self.repositories.removeAll()
//            for dictionary in reposArray {
//                guard let repoDictionary = dictionary as? NSDictionary else { fatalError("Object in reposArray is of non-dictionary type") }
//                
//                
//                let repository = GithubRepository(item: repoDictionary)
//                self.repositories.append(repository)
//            }
//            completion()
//        }
//    }
    
    class func toggleStarStatusForRepository(repository: GithubRepository,completion: (starred: Bool) -> ()) {
        
        GithubAPIClient.checkIfRepositoryIsStarred(repository.name) { (starred) in
            if starred {
                GithubAPIClient.unstarRepository(repository.name, completion: {
                    completion(starred: false)
                })
            } else {
                GithubAPIClient.starRepository(repository.name, completion: {
                    completion(starred: true)
                })
            }
        }
    }
    
    func searchForRepository(name: String, completion: () -> ()) {
    
        api.searchRepositories(name) { (repositories) in
            self.repositories = repositories
            completion()
        }
    }
}