//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
//vai mostrar um pop up de que está carregando
import SVProgressHUD

class LogInViewController: UIViewController {

    //Textfields pre-linked with IBOutlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

   
    @IBAction func logInPressed(_ sender: AnyObject) {
        //mostra o pop up que está carregando
        SVProgressHUD.show()
        
        
        
        //TODO: Log in the user, a seguir é uma closure
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user , error) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Log in Successful!")
                //por estar dentro de uma closure, é preciso colocar a key self no começo
                //desabilita o pop up quando terminar de fazer o login 
                SVProgressHUD.dismiss()
                
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
        
    }
    


    
}  
