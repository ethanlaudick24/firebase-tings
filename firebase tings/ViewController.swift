//
//  ViewController.swift
//  firebase tings
//
//  Created by ETHAN LAUDICK on 1/4/23.
//

class Student{
    //line below creates a reference to our firebase
    var ref = Database.database().reference()
    var name: String
    var age: Int
    var key = ""
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    init(dict: [String: Any]) {
        if let n = dict["name"] as? String {
            name = n
        } else{
            name = "john"
        }
        if let a = dict["age"] as? Int {
            age = a
        } else{
            age = 0
        }
        
    }
    
    func saveToFirebase(){
        let dict = ["name": name, "age": age] as [String: Any]
        key = ref.child("students2").childByAutoId().key ?? "0"
        ref.child("students2").child(key).setValue(dict)
    }
    
    func deleteFromFirebase() {
        ref.child("students2").child(key).removeValue()
    }
    
    func editOnFirebase() {
        let dict = ["name": name, "age": age] as! [String: Any]
        ref.child("students2").child(key).updateChildValues(dict)
    }
    
    func equals(stew: Student) -> Bool{
        if(stew.name == name && stew.age == age){
            return true
        }
        return false
    }
    
}

import UIKit
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var textFeildOutlet: UITextField!
    @IBOutlet weak var ageTextFieldOutlet: UITextField!
    
    var ref: DatabaseReference!
    var names = [String]()
    var students = [Student]()
    var lastStudent = Student(name: "", age: 0)
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //need these 2 lines of code everytime you put in a table view
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        
        //ref is now a reference to the database
        ref = Database.database().reference()
        //reading from the database
        //automatically called for every child added and for every child already existing at start
        ref.child("students").observe(.childAdded) { snapshot in
            let name = snapshot.value as! String
            self.names.append(name)
            self.tableViewOutlet.reloadData()
        }
        
        ref.child("students2").observe(.childAdded) { snapshot in
            let dict = snapshot.value as! [String: Any]
            let student = Student(dict: dict)
            student.key = snapshot.key
            if !(self.lastStudent.equals(stew: student)){
                self.students.append(student)
                self.tableViewOutlet.reloadData()
            }
            //self.students.append(student)
            self.tableViewOutlet.reloadData()
        }
        
        ref.child("students2").observe(.childAdded) { snapshot in
            
            for i in 0..<self.students.count {
                if self.students[i].key == snapshot.key {
                    self.students.remove(at: i)
                    self.tableViewOutlet.reloadData()
                    break
                }
            }
            self.tableViewOutlet.reloadData()
        }
        
        ref.child("students2").observe(.childChanged) { snapshot in
            let key = snapshot.key
            let value = snapshot.value as! [String: Any]
            for i in 0..<self.students.count {
                if self.students[i].key == key {
                    self.students[i].name = value["name"] as! String
                    self.students[i].age = value["age"] as! Int
                    break
                }
            }
            self.tableViewOutlet.reloadData()
        }
        
    }

    @IBAction func saveButtonAction(_ sender: Any) {
        let name = textFeildOutlet.text!
        //names.append(name)
        ref.child("students").childByAutoId().setValue(name)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = students[indexPath.row].name
        cell.detailTextLabel?.text = String(students[indexPath.row].age)
        return cell
    }
    
    @IBAction func addStudentButton(_ sender: Any) {
        let name = textFeildOutlet.text!
        let age = Int(ageTextFieldOutlet.text!)!
        let student = Student(name: name, age: age)
        student.saveToFirebase()
        //students.append(student)
        tableViewOutlet.reloadData()
    }
    
    @IBAction func editButton(_ sender: Any) {
        students[selectedIndex].name = textFeildOutlet.text!
        students[selectedIndex].age = Int(ageTextFieldOutlet.text!)!
        students[selectedIndex].editOnFirebase()
        tableViewOutlet.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //delete func
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            students[indexPath.row].deleteFromFirebase()
            students.remove(at: indexPath.row)
            tableViewOutlet.reloadData()
        }
    }
    
}

