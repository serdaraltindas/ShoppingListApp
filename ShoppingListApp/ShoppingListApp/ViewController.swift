//
//  ViewController.swift
//  ShoppingListApp
//
//  Created by Serdar Altındaş on 14.03.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var sizeArray = [String]()
    var choosenName = ""
    var choosenId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add button
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        tableView.delegate = self
        tableView.dataSource = self
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
   @objc func getData(){
       //duplice verileri siler
       nameArray.removeAll(keepingCapacity: false)
       sizeArray.removeAll(keepingCapacity: false)
       idArray.removeAll(keepingCapacity: false)
       
       let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String {
                        nameArray.append(name)
                    }
                    if let size = result.value(forKey: "size") as? String {
                        sizeArray.append(size)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }
                }
                tableView.reloadData()
            }
        }catch{
            print("ERROR!")
        }
    }
    
    
    @objc func addButtonClicked() {
        choosenName = ""
        //when someone push the add button, what will be happen!
        performSegue(withIdentifier: "toViewController", sender: nil)
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        content.secondaryText = sizeArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController"{
            let destinationVC = segue.destination as! detailsVC
            destinationVC.selectedName = choosenName
            destinationVC.selectedId = choosenId
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choosenName = nameArray[indexPath.row]
        choosenId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
            let uuidString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row]{
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do{
                                    try context.save()
                                }catch{
                                    print("ERROR!")
                                }
                                break
                            }
                        }
                    }
                }
            }catch{
                print("ERROR!")
            }
            
        }
    }
    
}

