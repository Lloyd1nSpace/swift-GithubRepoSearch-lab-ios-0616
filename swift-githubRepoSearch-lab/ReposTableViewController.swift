//
//  ReposTableViewController.swift
//  swift-githubRepoSearch-lab
//
//  Created by Haaris Muneer on 7/28/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

import UIKit

class ReposTableViewController: UITableViewController {
    
    let store = ReposDataStore.sharedInstance
    let api = GithubAPIClient.sharedInstance
    
    var repositories: [GithubRepository] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.accessibilityLabel = "tableView"
        self.tableView.accessibilityIdentifier = "tableView"
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.store.repositories.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let repoSelected: GithubRepository = self.store.repositories[indexPath.row]
        
        ReposDataStore.toggleStarStatusForRepository(repoSelected) { (starred) in
            let alert = UIAlertController.init(title: "", message: "", preferredStyle: .Alert)
            let dismissAlert = UIAlertAction(title: "Ok", style: .Cancel) { (cancel) in
            }
            alert.addAction(dismissAlert)
            
            if starred {
                alert.accessibilityLabel = "You just starred \(repoSelected.name)"
                alert.title = "starred \(repoSelected.name)"
            } else {
                alert.accessibilityLabel = "You just unstarred \(repoSelected.name)"
                alert.title = "unstarred \(repoSelected.name)"
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.presentViewController(alert, animated: true, completion: {
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                })
            })
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("repoCell", forIndexPath: indexPath)
        
        let repository:GithubRepository = self.store.repositories[indexPath.row]
        cell.textLabel?.text = repository.name
        
        return cell
    }
    
    @IBAction func searchButtonTapped(sender: AnyObject) {
        
        let searchAlert = UIAlertController(title: "Search", message: "", preferredStyle: .Alert)
        searchAlert.addTextFieldWithConfigurationHandler { (searchText) in
            searchText.placeholder = "Search for a Repository"
            searchAlert.accessibilityLabel = "Search for a repository"
            searchAlert.title = "Search for a repository"
        }
        
        let searchAction = UIAlertAction(title: "Search", style: .Default) { (search) in
            
            let textField = searchAlert.textFields![0]
            
            if let text = textField.text {
                
                self.store.searchForRepository(text, completion: {
                    self.repositories = self.store.repositories
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.tableView.reloadData()
                    })
                })
            }
        }
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .Cancel) { (cancel) in
            print("Search cancelled")
        }
        searchAlert.addAction(searchAction)
        searchAlert.addAction(dismissAction)
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(searchAlert, animated: true, completion:  {})
        }
    }
}