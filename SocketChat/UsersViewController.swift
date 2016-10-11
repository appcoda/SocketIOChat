//
//  UsersViewController.swift
//  SocketChat
//
//  Created by Gabriel Theodoropoulos on 1/31/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblUserList: UITableView!
    
    
    var users = [[String: AnyObject]]()
    
    var nickname: String!
    
    var configurationOK = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !configurationOK {
            configureNavigationBar()
            configureTableView()
            configurationOK = true
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if nickname == nil {
            askForNickname()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "idSegueJoinChat" {
                let chatViewController = segue.destination as! ChatViewController
                chatViewController.nickname = nickname
            }
        }
    }

    
    // MARK: IBAction Methods
    
    @IBAction func exitChat(sender: AnyObject) {
        SocketIOManager.sharedInstance.exitChatWithNickname(nickname: nickname) { () -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.nickname = nil
                self.users.removeAll()
                self.tblUserList.isHidden = true
                self.askForNickname()
            })
        }
    }

    
    
    // MARK: Custom Methods
    
    func configureNavigationBar() {
        navigationItem.title = "SocketChat"
    }
    
    
    func configureTableView() {
        tblUserList.delegate = self
        tblUserList.dataSource = self
        tblUserList.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "idCellUser")
        tblUserList.isHidden = true
        tblUserList.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    
    func askForNickname() {
        let alertController = UIAlertController(title: "SocketChat", message: "Please enter a nickname:", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addTextField(configurationHandler: nil)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.characters.count == 0 {
                self.askForNickname()
            }
            else {
                self.nickname = textfield.text
                
                SocketIOManager.sharedInstance.connectToServerWithNickname(nickname: self.nickname, completionHandler: { (userList) -> Void in
                    DispatchQueue.main.async(execute: { () -> Void in
                        if userList != nil {
                            self.users = userList!
                            self.tblUserList.reloadData()
                            self.tblUserList.isHidden = false
                        }
                    })
                })
            }
        }
        
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: UITableView Delegate and Datasource methods
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellUser", for: indexPath as IndexPath) as! UserCell
        
        cell.textLabel?.text = users[indexPath.row]["nickname"] as? String
        cell.detailTextLabel?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
        cell.detailTextLabel?.textColor = (users[indexPath.row]["isConnected"] as! Bool) ? UIColor.green : UIColor.red
        
        return cell
    }
    
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
}
