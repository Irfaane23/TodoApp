//
//  ViewController.swift
//  TodoApp
//
//  Created by Irfaane Ousseny on 08/09/2018.
//  Copyright © 2018 Irfaane. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray : [Item] = [Item]()
    
   // let defaults = UserDefaults.standard
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Persistance local data storage using UserDefaults
   /*     if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemArray = items
        }
    */
        
        loadDataItems()
        
        
    }

    //TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
  /*      if item.done == true {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
 */
        return cell
    }
    
    //TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveDataItem()
        
        //selected a cell -> cell is gray
        // with that after selecting the cell, it turns back to white
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //Add new item in the TableView
    @IBAction func addPressedButton(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        //Add a pop-up alert
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        //button that we're going to pressed after we have written our new item
        let alertAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user have pressed the button
            // -> we add at the end of the itemArray the new item we create
            
            let newItem = Item()
            newItem.title = textField.text!
            
            self.itemArray.append(newItem)
           
            // UserDefault
            //self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.saveDataItem()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            

        }
        
        alert.addAction(alertAction)
        
        //show the alert
        present(alert,animated: true, completion: nil)
    }
    
    
    //Model manipulation data
    
    private func saveDataItem() {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print(error)
        }
        
        tableView.reloadData()
    }
    
    func loadDataItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data) //[Item].self reffers to the type of the data we want to decode
            } catch {
                print(error)
            }
        }
    }
    
    
    
}

