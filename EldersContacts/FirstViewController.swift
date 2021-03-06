//
//  FirstViewController.swift
//  EldersContacts
//
//  Created by Chun Yin Kong on 6/11/2018.
//  Copyright © 2018 EE4304_kelvin_kong. All rights reserved.
//

import UIKit
import Contacts
import AudioToolbox

class customViewCell: UITableViewCell{
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
}

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!

    
    private var contactArr: [CNContact] = []
    // var person: CNContact?
    var selectedRowNumber: Int?
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat.init(integerLiteral: 100)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contact", for: indexPath as IndexPath) as! customViewCell
        let name = contactArr[indexPath.row].givenName + " " + contactArr[indexPath.row].familyName
        let image = contactArr[indexPath.row].imageData
        
        //set font size of the name
        let size = 30 as CGFloat
        
        cell.contactName.adjustsFontSizeToFitWidth = true
        
        //set font style
        cell.contactName.font = UIFont(name: "Bradley Hand", size: size)
        
        //set name to contact
        cell.contactName.text = name
        
        //set image to contact
        cell.contactImage.image = UIImage.init(data: image ?? Data.init())// temporary solution for no image data
        cell.contactImage.layer.cornerRadius = cell.contactImage.frame.size.width/2.5
        cell.contactImage.clipsToBounds = true
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowNumber = indexPath.row
        let cell = tableView.cellForRow(at: indexPath)
        self.performSegue(withIdentifier: "contact", sender: cell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateContactList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the background image
        let backgroundImage = UIImage.init(named: "background.jpg")
        let backgroundImageView = UIImageView.init(frame: self.view.frame)
        
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        //how saturate is the image
        backgroundImageView.alpha = 0.5
        
        self.view.insertSubview(backgroundImageView, at: 0)
        //make the navigation bar become invisible
        //the bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //the shadow
        navigationController?.navigationBar.shadowImage = UIImage()
        
        //set the back bar
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "BACK", style: .done, target: nil, action: nil)
        
        
        //Set the back button image
        //navigationController?.navigationBar.backIndicatorImage = UIImage.init(named: "back1.png")
        //navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage.init(named: "back1.png")
        
        //fetchContact()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        table.reloadData()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        if parent == self.navigationController?.parent {
            print("Back tapped")
        }
    }
    
    
    private func fetchContact(){
        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: { (granted, err) in
            if let err = err{
                print("Failed to request access:", err)
                return
            }
            if granted{
                print("Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do{
                    try store.enumerateContacts(with: request, usingBlock: {
                        (contact, stopPointer) in
                        self.contactArr.append(contact)
                    })
                }catch let err {
                    print("Failed to enum... contacts", err)
                }
            }else{
                print("Access denied...")
            }
        })
    }
    
    func printAllContentArr(_ arr: [CNContact]){
        for contact in arr{
            print(contact.givenName)
            print(contact.familyName)
            print(contact.phoneNumbers.first?.value.stringValue ?? "")
        }
    }
    
    func printAllContactInfo(_ contact: CNContact){
        print(contact.givenName)
        print(contact.familyName)
        print(contact.phoneNumbers.first?.value.stringValue ?? "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier{
            if identifier == "contact"{
                let temp: personInfo = segue.destination as! personInfo
                if let number = selectedRowNumber{
                        let person = contactArr[number]
                        printAllContactInfo(person)
                        temp.content = person
                        vibration()
                        
                    }else{
                        print("cannot get the row number")
                    }
            }else{
                print("identifier failed")
            }
        }else{
            print("identifier is nil")
        }
    }
    
    
    func vibration () {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        print("vibrate")
    }
    
    func updateContactList(){
        contactArr = []
        fetchContact()
        table.reloadData()
    }
}


