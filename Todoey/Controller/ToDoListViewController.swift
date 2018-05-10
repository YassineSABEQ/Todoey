//
//  ViewController.swift
//  Todoey
//
//  Created by Yassine Sabeq on 5/3/18.
//  Copyright © 2018 Yassine Sabeq. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    let defaults = UserDefaults.standard // standard is a singleton inside this class UserDefaults. it points towards the same p list everytime we tap into the UserDefaults and it stays the same across all of our objects and classes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let newItem1 = Item()
        newItem1.title = "avengers"
        self.itemArray.append(newItem1)
        
        let newItem2 = Item()
        newItem2.title = "infinity"
        self.itemArray.append(newItem2)
        
        let newItem3 = Item()
        newItem3.title = "war"
        self.itemArray.append(newItem3)
        
        if let items = defaults.array(forKey: "ToDoListArray") as? [Item] { //that's an optional not ! which gonna force downcast to an array of string . that's why i put if statement
            itemArray = items
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK - TableView DataSourceMethods
    
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
    
    
    //MARK - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem){
    
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item()
            newItem.title = textField.text!
            self.itemArray.append(newItem)
            
            self.defaults.set(self.itemArray, forKey: "ToDoListArray")
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        tableView.reloadData() // forces the tableview to call its data sources methodes again
        
        tableView.deselectRow(at: indexPath, animated: true) // gray does not stay peremntly on the cell but instead flashes and goes back to being de-selected (fades)
        
        
    }
    }
    
    

