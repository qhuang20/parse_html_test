//
//  ViewController.swift
//  parse_html_test
//
//  Created by Qichen Huang on 2018-01-25.
//  Copyright © 2018 Qichen Huang. All rights reserved.
//

import UIKit
import SwiftSoup
import Firebase
import TRON
import SwiftyJSON
import Alamofire

class ViewController: UIViewController {////////////////////////////  change it in AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        start()
    }
    
    class Elasticsearch: JSONDecodable {
        
        required init(json: JSON) throws {
            print("Parsed Json: ", json)
            
            let hits = json["hits"]
            print(hits)
        }
        
    }
    
    class JsonError: JSONDecodable {
        
        required init(json: JSON) throws {
            print("JSON ERROR")
        }
        
    }
    
    let tron = TRON(baseURL: "http://35.184.55.147//elasticsearch")
    
    private func start() {
        let request: APIRequest<Elasticsearch, JsonError> = tron.swiftyJSON.request("/posts/_search")
        request.authorizationRequirement = .none
        request.headerBuilder = HeaderBuilder(defaultHeaders: ["Accept": "application/json", "Authorization": "Basic dXNlcjpmQ212dFI0TktOd3o="])
        let userSearchInput = "NeED"
        let type = "book for Sale"
        let searchText = "*\(userSearchInput)* type:\(type)"//the space equals +
        request.parameters = ["default_operator": "AND", "q": searchText]

        request.perform(withSuccess: { (searchResult) in
            print("Successfully fetch json")
        }) { (error) in
            print("Fail to fetch json: ", error)
        }
    }

}

///test
//let courseName = "tr>td[class=dedead] + td[class=dedefault] + td:contains(\(course))"
//let courseNumber = "tr>td>a[href]"
//let daysAndTime = "tr>td[nowrap]"
//let roomAndTeacher = "tr>td[nowrap] + td[nowrap] ~ td[class=dedefault]"
//let selectorCode = courseName + ", " + courseNumber + ", " + daysAndTime + ", " + roomAndTeacher



extension StringProtocol where Index == String.Index {//see SFU
    func index<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while start < endIndex, let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges<T: StringProtocol>(of string: T, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while start < endIndex, let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound  ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}




