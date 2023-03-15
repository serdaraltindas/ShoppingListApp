//
//  detailsVC.swift
//  ShoppingListApp
//
//  Created by Serdar Altındaş on 14.03.2023.
//

import UIKit
import CoreData

class detailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var sizeText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedName = ""
    var selectedId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedName != "" {
           
            saveButton.isHidden = true
            
            //core data
            if let uuidString = selectedId?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                do{
                    let results = try context.fetch(fetchRequest)
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            if let name = result.value(forKey: "name") as? String{
                                nameText.text = name
                                
                            }
                            if let price = result.value(forKey: "price") as? Int{
                                priceText.text = String(price)
                            }
                            if let size = result.value(forKey: "size") as? String{
                                sizeText.text = size
                            }
                            if let imageData = result.value(forKey: "image") as? Data {
                                let image = UIImage(data: imageData)
                                imageView.image = image
                            }
                        }
                    }
                    
                }catch{
                    print("ERROR!")
                }
                
            }
            
        }
        else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            sizeText.text = ""
            priceText.text = ""
        }
        
        //when tap somewhere in view. How can be hide the keyboard.
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        //ekrana dokunmayı aktif hale getiriyoruz.
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchedImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
    }
    @objc func touchedImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    //fotoğraf seçmeyi bitirdikten sonra ne yapayım.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
    }
     
    @objc func hideKeyboard(){
        view.endEditing(true)
        //ekranda olan her şeyi kapatır klavye dahil.
    }
   
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        shopping.setValue(nameText.text!, forKey: "name")
        shopping.setValue(sizeText.text!, forKey: "size")
        if let price = Int(priceText.text!){
            shopping.setValue(price, forKey: "price")
        }
        shopping.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.5 )
        shopping.setValue(data, forKey: "image")
        do{
            try context.save()
            print("SUCCESS")
        }catch{
            print("ERROR!")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        //to back VC
        self.navigationController?.popViewController(animated: true)
        
        
    }
}
