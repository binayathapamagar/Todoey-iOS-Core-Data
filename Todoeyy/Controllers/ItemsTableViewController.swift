//
//  ItemsTableViewController.swift
//  Todoeyy
//
//  Created by Binaya on 23/08/2021.
//

import UIKit
import CoreData
import ChameleonFramework

class ItemsTableViewController: SwipeTableViewController {
    
    var items = [Item]()
    var duplicatesArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var searchBar: UISearchBar!
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.barTintColor = K.appColor
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.leftView?.tintColor = .black
        searchBar.searchTextField.textColor = .black
        searchBar.placeholder = "Search for an Item"
        navigationItem.title = selectedCategory?.name
    }
    
    //MARK: - UITableViewControllerDataSource delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = items[indexPath.row]
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = item.title
        cell.accessoryType = item.isDone ? .checkmark : .none
        let itemNumber = CGFloat(indexPath.row)
        let itemsCount = CGFloat(items.count)
        let percentage = itemNumber / itemsCount
        cell.backgroundColor = K.appColor.darken(byPercentage: percentage)
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        return cell
        
    }
    
    //MARK: - UITableViewControllerDelegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        items[indexPath.row].isDone = !items[indexPath.row].isDone
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - IBAction Method
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alertController = UIAlertController(title: "Add a new Item", message: "", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { alertAction in
            
            let newItemTitle = textField.text!.trimmingCharacters(in: .whitespaces)

            self.loadDuplicatesCheckArray(with: newItemTitle)
            
            if newItemTitle == "" {
                
                self.showErrorAlert()
                
            }else if !self.duplicatesArray.isEmpty {
                
                self.showErrorAlert(with: "Item already exists!")
                
            }else {
                
                let newItem = Item(context: self.context)
                newItem.title = newItemTitle
                newItem.createdDate = Date()
                newItem.isDone = false
                newItem.parentCategory = self.selectedCategory
                self.items.append(newItem)
                self.saveItems()
                let indexPath = IndexPath(row: self.items.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField { alertTextField in
            alertTextField.placeholder = "Create a new Item"
            alertTextField.autocapitalizationType = .sentences
            alertTextField.autocorrectionType = .default
            textField = alertTextField
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: - Instance Methods
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving to the database: \(error.localizedDescription)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), and predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES[cd] %@", selectedCategory!.name!)
        
        if let anotherPredicate = predicate {
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, anotherPredicate])
            
        }else {
            request.predicate = categoryPredicate
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }
        
        do {
            items = try context.fetch(request)
        }catch {
            print("Error fetching data from the database: \(error.localizedDescription)")
        }
        
        tableView.reloadData()
        
    }
    
    func loadDuplicatesCheckArray (with itemTitle: String) {
        do {
            duplicatesArray = try context.fetch(self.getFetchReqToCheckForDuplicates(with: itemTitle))
        } catch {
            print("Error loading categories: \(error)")
        }
    }
    
    func getFetchReqToCheckForDuplicates (with userEnteredText: String) -> NSFetchRequest<Item> {
      
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title MATCHES[cd] %@", userEnteredText)
        return request
        
    }
    
    func getRequest (with userSearchedText: String) -> NSFetchRequest<Item> {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", userSearchedText)
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        return request
    }
    
    //MARK: - Overridden Super Class Method
    
    override func deleteModel(with indexPath: IndexPath) {
        context.delete(items[indexPath.row])
        items.remove(at: indexPath.row)
        do {
            try context.save()
        } catch {
            print("Error saving to the database: \(error.localizedDescription)")
        }
    }
    
    override func fetchUserSearchedItems(with searchedItem: String) {
        if !searchedItem.isEmpty {
            let request = getRequest(with: searchedItem)
            loadItems(with: request, and: request.predicate)
        }else {
            loadItems()
        }
    }
    
    override func fetchUserSearchedItems(_ textThatGotChanged: String) {
        if !textThatGotChanged.isEmpty {
            let request = getRequest(with: textThatGotChanged)
            loadItems(with: request, and: request.predicate)
        }else {
            loadItems()
        }
    }
    
    override func updateModel(with indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        let initialTitle = item.title
        
        var textField = UITextField()
        
        let addAlertController = UIAlertController(title: "Update Item", message: "", preferredStyle: .alert)
        
        addAlertController.addTextField { alertTextField in
            alertTextField.placeholder = "Update \(item.title!)"
            alertTextField.text = item.title
            alertTextField.autocapitalizationType = .sentences
            alertTextField.autocorrectionType = .default
            textField = alertTextField
        }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { addAction in
            
            let newItemTitle = textField.text!.trimmingCharacters(in: .whitespaces)

            self.loadDuplicatesCheckArray(with: newItemTitle)
            
            if newItemTitle == "" {
               
                self.showErrorAlert()
                self.tableView.reloadData()
                
            }else if initialTitle == textField.text! {
                
                self.showErrorAlert(with: "New Item name cannot be the same as the previous name.")
                self.tableView.reloadData()
                
            } else if !self.duplicatesArray.isEmpty {
                
                self.showErrorAlert(with: "Item with that title already exists!")
                self.tableView.reloadData()
                
            }else {
                
                // Update Item in db.
                item.title = newItemTitle
                self.saveItems()
                
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { UIAlertAction in
            self.tableView.reloadData()
        }
        
        addAlertController.addAction(updateAction)
        addAlertController.addAction(cancelAction)
        
        present(addAlertController, animated: true, completion: nil)
        
    }
    
}
