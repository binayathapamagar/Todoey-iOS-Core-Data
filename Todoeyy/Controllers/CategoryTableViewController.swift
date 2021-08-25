//
//  ViewController.swift
//  Todoeyy
//
//  Created by Binaya on 23/08/2021.
//

import UIKit
import CoreData

class CategoryTableViewController: SwipeTableViewController {
    
    var categories = [Category]()
    var duplicatesArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.barTintColor = K.appColor
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.leftView?.tintColor = .black
        searchBar.searchTextField.textColor = .black
        searchBar.placeholder = "Search for a Category"
        loadCategories(with: getRequestForAllCategories())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navBar = navigationController?.navigationBar {
            navBar.backgroundColor = K.appColor
            navBar.tintColor = .black
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        }
    }
    
    //MARK: - IBAction Method
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let addAlertController = UIAlertController(title: "Add a new Category", message: "", preferredStyle: .alert)
        
        addAlertController.addTextField { alertTextField in
            alertTextField.placeholder = "Add a new category"
            alertTextField.autocorrectionType = .default
            alertTextField.autocapitalizationType = .sentences
            textField = alertTextField
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { addAction in
            
            let newCategoryName = textField.text!.trimmingCharacters(in: .whitespaces)
            
            self.loadDuplicatesCheckArray(with: newCategoryName)
            
            if newCategoryName == "" {
                
                self.showErrorAlert()
                
            }else if !self.duplicatesArray.isEmpty {
                
                self.showErrorAlert(with: "Category already exists!")
                
            } else {
                
                let newCategory = Category(context: self.context)
                newCategory.name = newCategoryName
                newCategory.createdDate = Date()
                self.categories.append(newCategory)
                self.saveCategories()
                let indexPath = IndexPath(row: self.categories.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addAlertController.addAction(addAction)
        addAlertController.addAction(cancelAction)
        
        present(addAlertController, animated: true, completion: nil)
        
    }
    
    //MARK: - UITableViewControllerDataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        cell.textLabel?.textColor = .black

        tableViewLines()
        
        return cell
        
    }
    
    //MARK: - UITableViewControllerDelegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: K.segueIdentifier, sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ItemsTableViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
        }
        
    }
    
    //MARK: - Instance methods
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
        
    }
    
    func loadCategories (with request: NSFetchRequest<Category>) {
        
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories: \(error)")
        }
        tableView.reloadData()
        
    }
    
    func tableViewLines() {
        tableView.separatorStyle = categories.isEmpty ? .none : .singleLine
    }
    
    func loadDuplicatesCheckArray (with categoryName: String) {
        do {
            duplicatesArray = try context.fetch(self.getFetchReqToCheckForDuplicates(with: categoryName))
        } catch {
            print("Error loading categories: \(error)")
        }
    }
    
    func getRequest(with searchedText: String) -> NSFetchRequest<Category> {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchedText)
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        
        return request
        
    }
    
    func getRequestForAllCategories() -> NSFetchRequest<Category>  {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
    
    func getFetchReqToCheckForDuplicates (with userEnteredText: String) -> NSFetchRequest<Category> {
      
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name MATCHES[cd] %@", userEnteredText)
        return request
        
    }
    
    //MARK: - Overridden Super Class Method
    
    override func deleteModel(with indexPath: IndexPath) {
        context.delete(categories[indexPath.row])
        categories.remove(at: indexPath.row)
        do {
            try context.save()
        } catch {
            print("Error saving to the database: \(error.localizedDescription)")
        }
        tableViewLines()
    }
    
    override func fetchUserSearchedItems(with searchedItem: String) {
        if !searchedItem.isEmpty {
            loadCategories(with: getRequest(with: searchedItem))
        }else {
            loadCategories(with: getRequestForAllCategories())
        }
    }
    
    override func fetchUserSearchedItems(_ textThatGotChanged: String) {
        if !textThatGotChanged.isEmpty {
            loadCategories(with: getRequest(with: textThatGotChanged))
        }else {
            loadCategories(with: getRequestForAllCategories())
        }
    }
    
    override func updateModel(with indexPath: IndexPath) {
        
        let category = categories[indexPath.row]
        let initialName = category.name
        
        var textField = UITextField()
        
        let addAlertController = UIAlertController(title: "Update Category", message: "", preferredStyle: .alert)
        
        addAlertController.addTextField { alertTextField in
            alertTextField.placeholder = "Update \(category.name!)"
            alertTextField.text = category.name
            alertTextField.autocapitalizationType = .sentences
            alertTextField.autocorrectionType = .default
            textField = alertTextField
        }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { addAction in
            
            let newCategoryName = textField.text!.trimmingCharacters(in: .whitespaces)
            
            self.loadDuplicatesCheckArray(with: newCategoryName)
            
            if newCategoryName == "" {
               
                self.showErrorAlert()
                self.tableView.reloadData()
                
            }else if initialName == newCategoryName {
                
                self.showErrorAlert(with: "New Category name cannot be the same as the previous name.")
                self.tableView.reloadData()
                
            }else if !self.duplicatesArray.isEmpty {
                
                self.showErrorAlert(with: "Category with that name already exists!")
                self.tableView.reloadData()
                
            } else {
                
                // Update Category in db.
                category.name = newCategoryName
                self.saveCategories()
                
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
