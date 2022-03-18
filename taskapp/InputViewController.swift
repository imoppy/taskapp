//
//  InputViewController.swift
//  taskapp
//
//  Created by 若原 旬 on 2022/03/10.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let realm = try! Realm()
    var task: Task!
    var categories = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
    var categoryId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        // 過去の日付を選択できないようにする
        datePicker.minimumDate = Date()
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        categoryId = task.categoryId
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        pickerView.reloadAllComponents()
        let index = categories.firstIndex(where: { $0.id == task.categoryId }) ?? 0
        self.pickerView.selectRow(index, inComponent: 0, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = titleTextField.text!
            self.task.contents = contentsTextView.text
            self.task.date = datePicker.date
            self.task.categoryId = categoryId
            self.realm.add(task, update: .modified)
        }
        
        setNotification(task: task)

        super.viewWillDisappear(animated)
    }

    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default

        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }

        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }

    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.categoryId = categories[row].id
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }

    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
}
