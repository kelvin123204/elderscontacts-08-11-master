//
//  Edit.swift
//  EldersContacts
//
//  Created by HUI Lam on 9/11/2018.
//  Copyright © 2018 EE4304_kelvin_kong. All rights reserved.
//

import UIKit
import Contacts
import AVFoundation
import CoreData

class Edit: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var contect: CNContact?             // segue from previous page
    @IBOutlet var body: UIView!
    @IBOutlet var head: UIView!
    var permphone = ""
    @IBOutlet var profilePic: UIImageView!
    @IBAction func AddPhoto(_ sender: Any) {
        FirstName.resignFirstResponder()
        FamiyName.resignFirstResponder()
        Phone.resignFirstResponder()
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        let string = "add photo"
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
        vibration()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        profilePic.image = image
        profilePic.layer.cornerRadius = profilePic.frame.width/2
        profilePic.clipsToBounds = true
        dismiss(animated:true, completion: nil)
        //
    }
   
    
    @IBOutlet var FirstName: UITextField!
    @IBOutlet var FamiyName: UITextField!
    @IBOutlet var Phone: UITextField!
    @IBOutlet weak var Comand: UITextField!
    
    var contacts : [Contacts] = []
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBAction func Update(_ sender: Any) {
        guard let firstName = FirstName.text else {
            print("FirstName Error")
            return
        }
        guard let familyName = FamiyName.text else {
            print("FamilyName Error")
            return
        }
        guard let phone = Int64(Phone.text!) else {
            let string = "phone must be number digit zero to nine"
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
            return
        }
        if firstName != "" && familyName != "" {
            print("success")
            let contact = contect?.mutableCopy() as! CNMutableContact
            
            contact.givenName = firstName
            contact.familyName = familyName
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: String(phone)))]
            if let imageData = profilePic.image {
                contact.imageData = imageData.jpegData(compressionQuality: 1)
            } else {
                print("profile Pic is nil")
            }
            
            let store = CNContactStore()
            let saveRequest = CNSaveRequest()
            saveRequest.update(contact)
            do{
                try store.execute(saveRequest)
            }catch{
                print("Cannot update the contact")
            }
            
            if Comand.text != "" {
                do {
                    let fetchRequest : NSFetchRequest<Contacts> = Contacts.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "phone == %@", permphone)
                    contacts = try context.fetch(fetchRequest)
                    
                    if contacts.count > 0 {
                        var isRecordFound = false
                        for contact in contacts {
                            contact.phone = String(phone)
                            contact.toCall = Comand.text
                            isRecordFound = true
                        }
                        if isRecordFound {
                            appDelegate.saveContext()
                        } else {
                            let comcontact = Contacts(context: context)
                            comcontact.toCall = Comand.text
                            comcontact.phone = Phone.text
                            appDelegate.saveContext()
                        }
                    } else {
                        let comcontact = Contacts(context: context)
                        comcontact.toCall = Comand.text
                        comcontact.phone = Phone.text
                        appDelegate.saveContext()
                    }
                } catch {
                    print("data fetch error")
                }
            } else {
                print("this record cannot be found")
            }
            self.performSegue(withIdentifier: "updatedSegue", sender: self)
        }else{
            // user change their contact's first or last name to empty
            let alert = UIAlertController.init(title: "Alert", message: "First Name or Last Name cannot be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { (self) in
                print("empty first Name Field and empty last name field in editing")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        permphone = Phone.text!
        FirstName.delegate = self
        FamiyName.delegate = self
        Phone.delegate = self
        //setup placeholder
        FirstName.text = contect?.givenName
        FamiyName.text = contect?.familyName
        Phone.text = contect?.phoneNumbers.first?.value.stringValue ?? ""
        profilePic.image = UIImage.init(data: contect?.imageData ?? Data.init())
        
        body.layer.cornerRadius = body.frame.width/2.5
        body.clipsToBounds = true
        head.layer.cornerRadius = head.frame.width/2
        head.clipsToBounds = true
        
        //setting the background image
        let backgroundImage = UIImage.init(named: "edit.jpg")
        let backgroundImageView = UIImageView.init(frame: self.view.frame)
        
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        //how saturate is the image
        backgroundImageView.alpha = 0.3
        //tablereload
        
        self.view.insertSubview(backgroundImageView, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func vibration () {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        print("vibrate")
    }
}
