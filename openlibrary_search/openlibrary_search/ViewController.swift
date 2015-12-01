//
//  ViewController.swift
//  openlibrary_search
//
//  Created by Francisco Betancourt on 11/22/15.
//  Copyright © 2015 VendwatchTelematics. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate  {
    
    // 1. Una caja de texto para capturar el ISBN del libro a buscar
    @IBOutlet weak var txtSearchByISBN: UITextField!
    
    @IBOutlet weak var cmdClear: UIButton!
    
    // 4. Una vista texto (Text View) para mostrar el resultado de la petición
    @IBOutlet weak var txtResult: UITextView!
    
    @IBOutlet weak var txtTitle: UITextView!
    
    @IBOutlet weak var txtAuthors: UITextView!
    
    @IBOutlet weak var imgCover: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSearchByISBN.placeholder = "ISBN"
        txtSearchByISBN.delegate = self
        
        // 2. EL botón de "enter" del teclado del dispositivo deberá ser del tipo de búsqueda ("Search")
        txtSearchByISBN.returnKeyType = UIReturnKeyType.Search
        
        // 3. El botón de limpiar ("clear") deberá estar siempre presente
        txtSearchByISBN.clearButtonMode = UITextFieldViewMode.Always
        
        txtResult.editable = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearSearch() {
        txtSearchByISBN.text = ""
        txtResult.text = ""
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        txtResult.text = ""
        
        // Al momento de presionar buscar en el teclado, se deberá mostrar los datos crudos (sin procesar) producto de la consulta en la vista texto en concordancia con el ISBN que se ingreso en la caja de texto
        asynchronousCommunication()
        
        return true
    }
    
    func synchronousCommunication() {
        if (txtSearchByISBN.text != "") {
            
            let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + txtSearchByISBN.text!
            //978-84-376-0494-7
            
            let url = NSURL(string: urls)
            
            let datos:NSData? = NSData(contentsOfURL: url!)
            
            let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
            
            print(texto!)
            
            txtResult.text = String(data: datos!, encoding: NSUTF8StringEncoding)
            
            
        }
    }
    
    func asynchronousCommunication() {
        if (txtSearchByISBN.text != "") {
            let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
                + txtSearchByISBN.text!
                //+ "978-84-376-0494-7"
        
            let url = NSURL(string: urls)
        
            let sesion = NSURLSession.sharedSession()
        
            let bloque = { (datos: NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
                
                if(error != nil) {
                    print(error!)
                    
                    /* refresh alert code start here */
                    dispatch_async(dispatch_get_main_queue(), {
                        //Run UI Updates
                        
                        // En caso de error (problemas con Internet), se deberá mostrar una alerta indicando esta situación
                        let alert = UIAlertController(title: "Error", message: error!.description, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                            switch action.style{
                            case .Default:
                                print("default")
                                
                            case .Cancel:
                                print("cancel")
                                
                            case .Destructive:
                                print("destructive")
                            }
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                    /* refresh alert code End here */
                    
                    return
                }
                
                let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
                print(texto!)
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                    let book = json as! NSDictionary
                    let isbn = book["ISBN:" + self.txtSearchByISBN.text!] as! NSDictionary
                    let titulo = isbn["title"] as! NSString
                    let cover = isbn["cover"] as! NSDictionary
                    let imgStr = cover["medium"] as! NSString
                    let authorsArr = isbn["authors"] as! NSArray
                    var idx = 0
                    for idx in idx...authorsArr.count-1 {
                        let authors = authorsArr[idx] as! NSDictionary
                        let name = authors["name"] as! NSString
                        /* refresh TextView code start here */
                        dispatch_async(dispatch_get_main_queue(), {
                            //Run UI Updates
                            
                            if authorsArr.count>1
                            {
                                self.txtAuthors.text = "Authors: "
                            }
                            else
                            {
                                self.txtAuthors.text = "Author: "
                            }
                            
                            if (idx == authorsArr.count-1)
                            {
                                self.txtAuthors.text = self.txtAuthors.text + (name as String)
                            }
                            else
                            {
                                self.txtAuthors.text = self.txtAuthors.text + (name as String) + ", "
                            }
                            
                            self.txtTitle.text = "Título del libro: "
                            self.txtTitle.text = self.txtTitle.text + " " + (titulo as String)
                            
                            self.imgCover.image = UIImage(data: NSData(contentsOfURL: NSURL(string: imgStr as String)!)!)
                        })
                    }
                    
                   
                    
                    
                } catch _ {
                    
                }
                
                /* refresh TextView code start here */
                dispatch_async(dispatch_get_main_queue(), {
                    //Run UI Updates
                    self.txtResult.text = String(data: datos!, encoding: NSUTF8StringEncoding)
                })
                /* refresh TextView code End here */
            }
        
            let dt = sesion.dataTaskWithURL(url!, completionHandler: bloque)
            dt.resume()
        }
        else
        {
            /* refresh TextView code start here */
            dispatch_async(dispatch_get_main_queue(), {
                //Run UI Updates
                self.txtResult.text = "Error: El campo de ISBN esta vacío."
            })
            /* refresh TextView code End here */
        }
    }
}

