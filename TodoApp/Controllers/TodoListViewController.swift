//
//  ViewController.swift
//  TodoApp
//
//  Created by Irfaane Ousseny on 08/09/2018.
//  Copyright © 2018 Irfaane. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    var itemArray : [Item] = [Item]()
    
   // let defaults = UserDefaults.standard
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        //CRUD Version : Deleting data from the permanent storage of the phone
       // context.delete(itemArray[indexPath.row]) //-> Remove data from the permanent store
       // itemArray.remove(at: indexPath.row) //-> Remove data from the itemArray

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
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false // we have to specify this field because in the DataModel, we set the done attributes as not an optionnal
            
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
        //CRUD Version : Here we Create Data
        do {
            try context.save()
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func loadDataItems(with request : NSFetchRequest<Item> = Item.fetchRequest()) {
        //CRUD Version : Here we Read Data from the database
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context : \(error)")
        }
        tableView.reloadData()
    }
    
/*    private func staDataItemV1() {
        //Version 1 : using a Codable class

        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
            
        } catch {
            print(error)
        }
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
 */
    
}

// MARK: - Search Bar methods
extension TodoListViewController : UISearchBarDelegate {
    
    // Query the database
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadDataItems(with: request)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadDataItems()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadDataItems()
            
            //ask to the main thread to perform the going back to the original list
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}















