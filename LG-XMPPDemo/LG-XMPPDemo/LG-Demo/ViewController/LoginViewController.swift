//
//  LoginViewController.swift
//  LG-Demo
//
//  Created by jamie on 16/6/16.QQ:2726786161
//  Copyright © 2016年 LG. All rights reserved.
//  登录页

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var _userNameTextField: UITextField!
    @IBOutlet weak var _passwordTextField: UITextField!
    class func loadFromStoryBoard() -> LoginViewController?
    {
        let mainStoryBoard = UIStoryboard(name: "Storyboard", bundle: nil)
        return mainStoryBoard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        _userNameTextField.returnKeyType = UIReturnKeyType.Next
        _passwordTextField.returnKeyType = UIReturnKeyType.Done
        
        
        if let userName = NSUserDefaults.standardUserDefaults().objectForKey(kUserIdKey) as? String, let userPassword = NSUserDefaults.standardUserDefaults().objectForKey(kUserTokenKey)  as? String {
            _userNameTextField.text = userName
            _passwordTextField.text = userPassword
            self.login(nil)
        
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.loginSuccess), name: "loginSuccess", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.loginError), name: "loginError", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "loginSuccess", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "loginError", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: ------------------- 登录 -----------------------
    @IBAction func login(sender: AnyObject?) {
        if NSString.isNilOrEmpty(_userNameTextField.text){
            _userNameTextField.shake()
            _userNameTextField.becomeFirstResponder()
            return
        }
        
        if NSString.isNilOrEmpty(_passwordTextField.text){
            _passwordTextField.shake()
            _passwordTextField.becomeFirstResponder()
        }
        
       LGXMPPManager.shared.login(_userNameTextField.text!, password: _passwordTextField.text!)
    }

    func loginSuccess() {
        
        //存储userid
        NSUserDefaults.standardUserDefaults().setObject(_userNameTextField.text!, forKey: kUserIdKey)
        NSUserDefaults.standardUserDefaults().setObject(_passwordTextField.text!, forKey: kUserTokenKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let friendListVC = FriendListViewController.shared
        if self.navigationController!.viewControllers.contains(friendListVC){
            //已登录，不再重复进入
            return;
        }
        self.navigationController?.pushViewController(friendListVC, animated: true)

    }
    
    func loginError() {
        Tools.shared.showAlertViewAndDismissDefault("登录失败", message: "请确认您的用户名和密码")

        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: kUserTokenKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: ------------------- UITextFieldDelegate-----------------------
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == _userNameTextField{
            _passwordTextField.becomeFirstResponder()
        }else{
            self.login(nil)
        }
        return true
    }

}
