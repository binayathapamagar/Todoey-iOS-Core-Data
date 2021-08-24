//
//  SwipeTableViewController.swift
//  Todoeyy
//
//  Created by Binaya on 23/08/2021.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate, UISearchBarDelegate {
    
    override func viewDidLoad() {
        tableView.rowHeight = 80.0
        tableView.backgroundColor = K.appColor
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.backgroundColor = K.appColor
        cell.textLabel?.numberOfLines = 0
        
        return cell
        
    }
    
    //MARK: - SwipeTableViewCellDelegate Methods
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        // Update Model Action
        
        let updateAction = SwipeAction(style: .default, title: "Update") { action, indexPath in
            self.updateModel(with: indexPath)
        }
        
        updateAction.image = UIImage(named: "update")
        
        // Delete Model Action
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.deleteModel(with: indexPath)
        }
        
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction, updateAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    //MARK: - UISearchBarDelegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let userSearchedText = searchBar.text!.trimmingCharacters(in: .whitespaces)
        fetchUserSearchedItems(with: userSearchedText)
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let userSearchedText = searchBar.text!.trimmingCharacters(in: .whitespaces)
        fetchUserSearchedItems(userSearchedText)
        if userSearchedText.isEmpty {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
    
    //MARK: - Instance methods
    
    func deleteModel(with indexPath: IndexPath) {
        // Override in sub-class and update model in subclass.
    }
    
    func updateModel(with indexPath: IndexPath) {
        // Override in sub-class and update model in subclass.
    }
    
    func fetchUserSearchedItems(with searchedItem: String) {
        // Override in sub-class and update model in subclass.
    }
    
    func fetchUserSearchedItems(_ textThatGotChanged: String) {
        // Override in sub-class and update model in subclass.
    }
    
    func showErrorAlert(with message: String = "TextField is empty! Please enter a valid text.") {
        
        let errorAlert = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
        let errorAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        errorAlert.addAction(errorAction)
        present(errorAlert, animated: true, completion: nil)
        
    }
    
}
