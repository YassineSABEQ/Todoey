//
//  ViewController.swift
//  Todoey
//
//  Created by Yassine Sabeq on 5/3/18.
//  Copyright © 2018 Yassine Sabeq. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    var selectedCategory : Category?  { // optional because it's gonna be nil until we set it in the category controller
        didSet { // everything between this curly braces is goig to happen as soon as selectedCategory gets set with a value
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // allows us to access the AppDelegate Object not the class (the blueprint) . in order to get the persistentContainer property
    
  //  let defaults = UserDefaults.standard // standard is a singleton inside this class UserDefaults. it points towards the same p list everytime we tap into the UserDefaults and it stays the same across all of our objects and classes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     //   print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        if let items = defaults.array(forKey: "ToDoListArray") as? [Item] { //that's an optional not ! which gonna force downcast to an array of string . that's why i put if statement
//            itemArray = items
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - TableView DataSourceMethods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) //once the cell dissapears off the screen it comes around the tableview and initialized at the bottom as a new tableview cell 
        
        
        // let cellBis = UITableViewCell(style: .default, reuseIdentifier: "TodoItemCell") once the cell dissapears off the screen it gets deallocated and destroyed. when we scroll back we are getting a brand new brand new cell
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        // Ternary Operator
        // value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem){
    
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            
            self.saveItems()

        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add New Item"
            textField = alertTextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        self.saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true) // gray does not stay peremntly on the cell but instead flashes and goes back to being de-selected (fades)
        
    }
    
    //MARK: - Model Manupulation Methods
    
    func saveItems() {
    
        do {
            try context.save()
        } catch {
           print("Error Saving item array, \(error)")
        }
        
        tableView.reloadData() // forces the tableview to call its data sources methodes again
    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) { //"with" presents an external parameter and "request" an internal one that's used inside this function and = .... is the default value of the request in case we didn't provide a value
        // also "with" is used when you call this loadItems function
      
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
//
//        request.predicate = compoundPredicate
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - SearchBar Methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
   
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() //we're asking the dispatchqueue to get the main queue and then run this method on it
            }
        }
    }
}
    


