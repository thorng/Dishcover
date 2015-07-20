////
////  CSVScanner.swift
////  Im-Horngry
////
////  Created by Timothy Horng on 7/20/15.
////  Copyright (c) 2015 Timothy Horng. All rights reserved.
////
//
//import Foundation
//
//class CSVScanner {
//    
//    class func arrayOfDictionaryFromFile(#columnNames:Array<String>, fromFile theFileName:String, withFunction theFunction:(Dictionary<String, String>)->()) {
//        
//        if let strBundle = NSBundle.mainBundle().pathForResource(theFileName, ofType: "csv") {
//            
//            var encodingError:NSError? = nil
//            
//            if let fileObject = NSString(contentsOfFile: strBundle, encoding: NSUTF8StringEncoding, error: &encodingError){
//                
//                var fileObjectCleaned = fileObject.stringByReplacingOccurrencesOfString("\r", withString: "\n")
//                
//                fileObjectCleaned = fileObjectCleaned.stringByReplacingOccurrencesOfString("\n\n", withString: "\n")
//                
//                let objectArray = fileObjectCleaned.componentsSeparatedByString("\n")
//                
//                for anObjectRow in objectArray {
//                    
//                    let objectColumns = anObjectRow.componentsSeparatedByString(",")
//                    
//                    var aDictionaryEntry = Dictionary<String, String>()
//                    
//                    var columnIndex = 0
//                    
//                    for anObjectColumn in objectColumns {
//                        
//                        aDictionaryEntry[columnNames[columnIndex]] = anObjectColumn.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
//                        
//                        columnIndex++
//                    }
//                    
//                    if (aDictionaryEntry.count > 1) {
//                        theFunction(aDictionaryEntry)
//                    }
//                }
//            }
//        }
//    }
//    
//    // create a dictionary from CSV file
//    var myCSVContents = Array<Dictionary<String, String>>()
//    
//    CSVScanner.runFunctionOnRowsFromFile(["country", "adjectival"], withFileName: "Countries/countries_of_the_world.csv", withFunction: {
//    
//    (aRow:Dictionary<String, String>) in
//    
//    myCSVContents.append(aRow)
//    
//    })
//    
//}