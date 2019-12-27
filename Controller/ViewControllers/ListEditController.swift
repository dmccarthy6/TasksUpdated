//
//  ListEditController.swift
//  Tasks
//
//  Created by Dylan  on 12/3/19.
//  Copyright © 2019 Dylan . All rights reserved.
//

import Foundation
import UIKit
import TasksFramework


class EditListViewController: UIViewController {
    
    //MARK: - Properties
    lazy var tableView: UITableView = {
        let editListTableView = UITableView()
        editListTableView.dataSource = self
        editListTableView.delegate = self
        editListTableView.registerCell(cellClass: MenuCell.self)
        editListTableView.separatorStyle = .singleLine
        editListTableView.tableFooterView = UIView()
        return editListTableView
    }()
    
    var data = [EditListMenuModel]()
    let cellID = "Cell"
    let editListCellID = "EditListCell"
    let menuCellID = "MenuCell"
    var list: List?
    var cellTextColor: UIColor = .systemBackground
    
    
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        setModelData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.handleThemeChange()
        NotificationCenter.default.post(name: .TasksThemeDidChange, object: nil)
    }
    
    func createView() {
        view.addSubview(tableView)
        
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        tableView.register(EditItemCell.self, forCellReuseIdentifier: editListCellID)
        tableView.register(MenuCell.self, forCellReuseIdentifier: menuCellID)
        
        self.navigationItem.title = "\(list?.title ?? "")"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        //Setting 'Done' button to false until the user edits the list title -- then it becomes enabled
        doneButton(isEnabled: false)
    }
   
    func setModelData() {
        data.append(EditListMenuModel(image: Images.CheckCircleFill!, label: .saveList))
    }
    
    //MARK: - Button Functions
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
//        let window = UIWindow()
//        let vc = window.visibleViewController()
        Alerts.showNormalAlert(self, title: "List Saved", message: "Your list title has been changed to \(list?.title ?? "nil")")
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    func doneButton(isEnabled: Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = isEnabled
    }
}

extension EditListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 { return data.count }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuCell: MenuCell = tableView.dequeueReusableCell(for: indexPath)
        if indexPath.section == 0 {
            let editListCell = EditItemCell(style: .default, reuseIdentifier: editListCellID)
            editListCell.configure(text: list?.title ?? "", delegate: self)
            return editListCell
        }
        if indexPath.section == 1 {
            let menuData = data[indexPath.row]
            menuCell.configure(image: Images.SaveIcon!, tintColor: Colors.tasksRed, text: menuData.label.rawValue, value: nil)
            return menuCell
        }
        return UITableViewCell()
    }
}

extension EditListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            handleDone()
        }
    }
    
    //Section Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let title = "Edit Title:"
            return title
        }
        else { return "" }
    }
}

extension EditListViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let list = list else { return false }
        let newTitle = textField.text
        CoreDataManager.shared.updateListTitle(list: list, newTitle: newTitle!)
        textField.resignFirstResponder()
        cellTextColor = .label
        tableView.reloadData()
        doneButton(isEnabled: true)
        return true
    }
    
}
