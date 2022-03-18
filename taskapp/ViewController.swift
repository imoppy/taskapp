//
//  ViewController.swift
//  taskapp
//
//  Created by 若原 旬 on 2022/03/10.
//

import UIKit
import RealmSwift
import UserNotifications
import SafariServices

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var selectCategoryButton: UIBarButtonItem!

    let realm = try! Realm()
    var tasks = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    var categories = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self

        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        pickerView.reloadAllComponents()
    }

    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
     
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString

        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_  tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.tasks[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
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
    }

    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count + 1
    }
    
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "すべて" : categories[row - 1].name
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var categoryName = ""
        if row == 0 {
            categoryName = "すべて"
            self.tasks = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        } else {
            let category = categories[row - 1]
            categoryName = category.name
            self.tasks = try! Realm().objects(Task.self).filter("categoryId == %@", category.id).sorted(byKeyPath: "date", ascending: true)
        }
        tableView.reloadData()
        selectCategoryButton.title = "カテゴリ: \(categoryName)"
        pickerView.isHidden = true
    }

    @IBAction func selectCategoryButtonTapped(_ sender: Any) {
        pickerView.isHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController

        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = tasks[indexPath!.row]
        } else {
            let task = Task()

            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }

            inputViewController.task = task
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

