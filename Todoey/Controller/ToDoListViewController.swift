//
//  ViewController.swift
//  Todoey
//
//  Created by Yassine Sabeq on 5/3/18.
//  Copyright © 2018 Yassine Sabeq. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

    let realm = try! Realm()
    var todoItems : Results<Item>?

    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category?  { // optional because it's gonna be nil until we set it in the category controller
        didSet { // everything between this curly braces is goig to happen as soon as selectedCategory gets set with a value
           loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) { // we put the below block of code in viewWillAppear because viewDidLoad loads before the viewController is managed by the navigationController
        self.title = selectedCategory?.name
        guard let colorHex = selectedCategory?.colour else { fatalError()} // we use guard let instead of if let when you don't have "else" case and you're sure that it won't crash
        updateNavBar(withHexCode: colorHex)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let originalColour = UIColor(hexString: "1D9BF6") else { fatalError()}
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - NavigationBar Setup Methods
    
    func updateNavBar (withHexCode colorHexCode : String) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation Controller does not exist. ")}// Only use them if the application enters an unknown state, a state it doesn't know how to handle. Don't see fatal errors as an easy way out. Remember that your application will crash and burn if it throws a fatal error.
        guard let navBarColour = UIColor(hexString: colorHexCode) else { fatalError()}
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true)]
        navBar.barTintColor = navBarColour
        searchBar.barTintColor = navBarColour
    }

    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        //once the cell dissapears off the screen it comes around the tableview and initialized at the bottom as a new tableview cell
        if let item = todoItems?[indexPath.row] {
        cell.textLabel?.text = item.title
        if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)) { // we know that selectedCategory is not null so, todoItems not null . we add ? to UIColor because hexString may be just random caracters so fi it"s null don't go forward to .darken.... (optional chainning)
            cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
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
    
    //MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                        realm.delete(item)
                }
            } catch {
                print("Error changing done status, \(error)")
            }
    }
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



