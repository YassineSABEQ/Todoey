//
//  ViewController.swift
//  Todoey
//
//  Created by Yassine Sabeq on 5/3/18.
//  Copyright © 2018 Yassine Sabeq. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {

    let realm = try! Realm()
    
    var todoItems : Results<Item>?
    
    var selectedCategory : Category?  { // optional because it's gonna be nil until we set it in the category controller
        didSet { // everything between this curly braces is goig to happen as soon as selectedCategory gets set with a value
           loadItems()
        }
    }
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // allows us to access the AppDelegate Object not the class (the blueprint) . in order to get the persistentContainer property
    
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
        if let item = todoItems?[indexPath.row] {
        
        cell.textLabel?.text = item.title
        
        // Ternary Operator
        // value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType = item.done ? .checkmark : .none
        
        } else {
            cell.textLabel?.text = "No items added yet"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem){
    
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in

            if let currentCategory = self.selectedCategory {
               
                do {
                try self.realm.write {
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.createdAt = Date()
                    currentCategory.items.append(newItem) // we didn't keep the save func with its realm.add because currentCategory already exists in the realm DB . we just need to add newItems to the list of items inside   the currentCategory
                    }
                    } catch {
                        print("Error saving new Items, \(error)")
                    }
            }
            self.tableView.reloadData()
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
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                    //realm.delete(item)
                }
            } catch {
                print("Error changing done status, \(error)")
            }
        }
        tableView.reloadData()

        tableView.deselectRow(at: indexPath, animated: true) // gray does not stay peremntly on the cell but instead flashes and goes back to being de-selected (fades)
        
    }
    
    //MARK: - Model Manupulation Methods
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
}

//MARK: - SearchBar Methods

extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdAt", ascending: false)
        
        tableView.reloadData()
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



