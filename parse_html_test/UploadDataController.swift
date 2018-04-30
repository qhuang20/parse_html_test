//
//  uploadDataController.swift
//  parse_html_test
//
//  Created by Qichen Huang on 2018-03-02.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import SwiftSoup
import Firebase

class UploadDataController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.brown
        setupNavigationButtons()
    }
    
    private func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(handlePost))
    }

    

    ///upload to firebase
    let schoolName = "Simon Fraser University"//////////////////////////////////////////////////
    var schoolIsSet = false
    
    @objc func handlePost() {
        start()
    }
    
    private func updateSchoolCoursesWith(courseInfoValue: [String: Any]) {
        var courseInfoValue = courseInfoValue as [String: Any]
        courseInfoValue["postsCount"] = 0
        
        let courseId = String(describing: courseInfoValue["name"]!) + String(describing: courseInfoValue["number"]!)
        let ref = Database.database().reference().child("school_courses").child(schoolName).child(courseId)
        ref.updateChildValues(courseInfoValue) { (err, ref) in
            if let err = err {
                print("Failed to save school course to DB", err)
                return
            }
            print("Successfully saved school course to DB")
            
            if !self.schoolIsSet {
                self.updateSchoolsWith(schoolName: self.schoolName)
                self.schoolIsSet = true
            }
        }
    }
    
    private func updateSchoolsWith(schoolName: String) {
        let ref = Database.database().reference().child("schools")
        let values = [schoolName: 1]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("Failed to save school to DB", err)
                return
            }
            print("Successfully saved school to DB")
        }
    }
    
    
    
    ///fetch school_courses ////   change the school   !!!!!!!!!!
    private func start() {
        let urlString = "https://www.sfu.ca/students/calendar/2017/fall/courses.html"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            let html = String(data: data!, encoding: String.Encoding.utf8)!
            self.getAllCourses(html: html)
            
            }.resume()
    }
    
    private func getAllCourses(html: String) {
        guard let doc = try? SwiftSoup.parse(html) else { return }
        
        let courseUrl = "ul>a[href]"
        let selectorCode = courseUrl
        
        guard let elements = try? doc.select(selectorCode) else {
            print("getValueForm html:")
            return
        }
        
        for element in elements {
            let linkHref: String = try! element.attr("href");
            let s  = linkHref.endIndex(of: "courses/")
            let e = linkHref.index(of: ".html")
            let c = linkHref[s!...e!]
            
            let cc = c.replacingOccurrences(of: ".", with: "", options: .literal, range: nil)
            print(cc)
            
            fetchDataWith(course: cc)
        }
    }
    
    
    
    private func fetchDataWith(course: String) {
        let urlString = "https://www.sfu.ca/students/calendar/2017/fall/courses/\(course).html"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            let html = String(data: data!, encoding: String.Encoding.utf8)!
            self.getValueForm(html: html, course: course.uppercased())
            
            }.resume()
        
    }
    
    private func getValueForm(html: String, course: String) {
        guard let doc = try? SwiftSoup.parse(html) else { return }
        
        let courseName = "section[class]>h3>a[href]"
        let courseDetail = "section[class]>h3"
        let selectorCode = courseDetail + ", " + courseName
        
        guard let elements = try? doc.select(selectorCode) else {
            print("getValueForm html:")
            return
        }
        
        var counter = 1
        var dic:[String: String] = [:]
        for element in elements {
            
            if counter == 1 {
                print(course)
                dic["name"] = course
                
                let oldCourseNum = try! element.text()
                let courseNum = oldCourseNum.replacingOccurrences(of: "\(course) ", with: "", options: .literal, range: nil)
                let detail = courseNum.replacingOccurrences(of: "\(courseNum) - ", with: "", options: .literal, range: nil)
                dic["description"] = detail
                
            } else {
                let oldCourseNum = try! element.text()
                let courseNum = oldCourseNum.replacingOccurrences(of: "\(course) ", with: "", options: .literal, range: nil)
                print(courseNum)
                dic["number"] = courseNum
                
                let oldDes = dic["description"]
                let newDes = oldDes?.replacingOccurrences(of: "\(courseNum) - ", with: "", options: .literal, range: nil)
                dic["description"] = newDes
                print(newDes!)
            }
            
            counter = counter + 1
            if counter % 3 == 0 {
                counter = 1
                print(dic)
                
                updateSchoolCoursesWith(courseInfoValue: dic)
                
                dic = [:]
                print("\n")
            }
        }
    }
    
}










