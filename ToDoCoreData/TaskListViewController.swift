//
//  ViewController.swift
//  ToDoCoreData
//
//  Created by Виталий Подшибякин on 27.08.2024.
//

import UIKit
import CoreData

protocol TaskViewControllerDelegate {
    func reloadData()
}

class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    

    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
    
    private func editAlert(in taskList: [Task], at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit", message: "You can make your changes here.", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Update", style: .default) { _ in
            let editingTask = taskList[indexPath.row]
            guard let newValue = alert.textFields?.first?.text, !newValue.isEmpty else { return }
            StorageManager.shared.edit(edit: editingTask, with: newValue)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title:"Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = taskList[indexPath.row].title
        }
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        StorageManager.shared.save(taskName) { task in
            self.taskList.append(task)
            self.tableView.insertRows(
                at: [IndexPath(row: taskList.count - 1, section: 0)],
                with: .automatic
            )
        }
    }
    
    private func fetchData() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let tasks):
                self.taskList = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            StorageManager.shared.deleteContext(from: taskList, at: indexPath.row)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editAlert(in: taskList, at: indexPath)
    }
}
// MARK: - TaskViewControllerDelegate
extension TaskListViewController: TaskViewControllerDelegate {
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
}

