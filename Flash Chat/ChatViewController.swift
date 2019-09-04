//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework


// ChatViewController será o delegate do Table View,o ChatViewController vai lidar com tudo que acontece no table view. O ChatViewController será a responsável pelos dados que serão mostrados no table View
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    //por enquanto será um array sem nada
    var messageArray : [Message] = [Message]()
    
    
    
    
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        //TableView é a propriedade de rolar as opções na tela
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture (gesto de touch) here:
        // é preciso criar um método que ao clicar em qualquer lugar na table view, o teclado suma com a animação.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        // o próximo passo é criar o tableViewTapped
        
        

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib (nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        // comando para fazer o auto-layout
        configureTableView()
        retrieveMessages()
        
        
        //melhorar o design do app, tirando as linhas cinzas
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    //fornecer as celulas que serão mostradas no table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.messageBody.text = messageArray [indexPath.row].messageBody
        cell.senderUsername.text = messageArray [indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        // mudar as cores de cada usuário
        if cell.senderUsername.text == Auth.auth().currentUser?.email! {
            
            //mensagens que enviamos
            
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            
            
        }
        else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        
        
        
        return cell
    }
    
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    
    //TODO: Declare tableViewTapped here:
    // O código descrito anteriormente chama o tableViewTapped, que por sua vez chama o método de endEditing, que também chama o textFieldEndEditing
    @objc func tableViewTapped (){
        
        messageTextfield.endEditing(true)
    }
    
    
    
    //TODO: Declare configureTableView here:
    //Um auto-layout dos balões das mensagens
    func configureTableView () {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // a função a seguir faz uma animação quando abrir o teclado, é colocado dessa closure o tamanho que irá ocupar a table view e o tempo que levará para aparecer o teclado. 
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 308
            //Se a constraint mudar ou se algo na view mudar, redesenhe tudo
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    //somente este código não é o suficiente para sumir a janela que já apareceu.
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 50
            //Se a constraint mudar ou se algo na view mudar, redesenhe tudo
            self.view.layoutIfNeeded()
        }
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        // código que faz mandar mensagens quando o botão de send for pressionado
        messageTextfield.endEditing(true)
        //TODO: Send the message to Firebase and save it in our database
        //Temporariamente desabilitar o campo de texto e o botão de enviar, evitando assim que envie a mesma mensagem duas vezes, pois não houve tempo de remover os dados do campo de texto, isto é feito com a propriedade isEnable
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        //criar um banco de dados para as mensagens dentro do firebase
        let messagesDB = Database.database().reference().child("Messages")
        
        //criar um dicionario
        //a pessoa que está mandando a mensagem é um usuário que está logado no app
        //A única informação de identificação é o email
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody" : messageTextfield.text!]
        
        // Usar um método do firebase chamado child by auto ID
        // Cria uma chave aleatória personalizada (custom random key), então as mensagens pode ser salvas
        //Este código está salvando as mensagens dentro do banco de dados
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Message saved successfully!")
                
                //Reativar o campo de texto e o botäo de enviar
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                //resetar o campo de texto
                self.messageTextfield.text = ""
            
            }
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    //retrieve = recuperar
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        
        //usando essa referência, iremos solicitar ao firebase para ficar de olho em qualquer novo dado que será adicionado, que será guardado
        
        messageDB.observe(.childAdded, with:  { (snapshot) in
            
        //tipo de data do dicionario
        let snapshotValue = snapshot.value as! Dictionary<String,String>
            
        let text = snapshotValue["MessageBody"]!
        let sender = snapshotValue["Sender"]!
        // Não será impresso mais nada, criar novo objeto
        //print(text, sender)
        let message = Message()
        message.messageBody = text
        message.sender = sender
            
        self.messageArray.append(message)
            
        self.configureTableView()
        self.messageTableView.reloadData()
            
    })
        
        
        
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            //root view controller é a última camada , a última a ser acessada
            navigationController?.popToRootViewController(animated: true)
        }
        catch{
            print("Error, problem to sign out")
        }
        //can throw an error
    }
    


}
