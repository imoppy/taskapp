//
//  InputCategoryViewController.swift
//  taskapp
//
//  Created by 若原 旬 on 2022/03/17.
//

import UIKit
import RealmSwift

class InputCategoryViewController: UIViewController {
    @IBOutlet weak var categoryNameTextField: UITextField!

    let realm = try! Realm()
    let category = Category()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }

    @IBAction func buttonPressed(_ sender: Any) {
        try! realm.write {
            self.category.name = categoryNameTextField.text!

            let allCategories = realm.objects(Category.self)
            if allCategories.count != 0 {
                self.category.id = allCategories.max(ofProperty: "id")! + 1
            }

            self.realm.add(category)
        }        
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
}
