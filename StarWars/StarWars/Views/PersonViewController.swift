//
//  PersonViewController.swift
//  StarWars
//
//  Created by Fredric Billow on 2021-05-02.
//

import UIKit

class PersonViewController: UIViewController {
    private let simpleCellIdentifier = "simpleCell"
    private var safeArea: UILayoutGuide!
    private let tableView = UITableView()

    var person: Person?
    var favouritePerson: FavouritePerson?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: simpleCellIdentifier)
        tableView.dataSource = self
        fetchPerson()
    }

    private func fetchPerson() {
        guard person != nil || favouritePerson != nil else {
            self.dismiss(animated: true)
            return
        }

        if person != nil {
            return
        }

        guard let favouritePerson = favouritePerson else {
            self.dismiss(animated: true)
            return
        }

        let personIndex = DataManager.shared.persons.firstIndex { $0.name == favouritePerson.name }

        if let personIndex = personIndex {
            self.person = DataManager.shared.persons[personIndex]
            self.tableView.reloadData()
            return
        }

        guard let url = favouritePerson.url else {
            return
        }

        ApiUtil.fetch(Person.self, url: url) { result in
            self.person = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

    }
}

extension PersonViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Name"
        case 1:
            return "Height"
        case 2:
            return "Mass"
        case 3:
            return "Haircolor"
        case 4:
            return "Skin color"
        case 5:
            return "Eye color"
        case 6:
            return "Birth year"
        case 7:
            return "Gender"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: simpleCellIdentifier, for: indexPath)

        var text: String?
        switch indexPath.section {
        case 0:
            text = person?.name
        case 1:
            text = person?.height
        case 2:
            text = person?.mass
        case 3:
            text = person?.hairColor
        case 4:
            text = person?.skinColor
        case 5:
            text = person?.eyeColor
        case 6:
            text = person?.birthYear
        case 7:
            text = person?.gender
        default:
            break
        }
        cell.textLabel?.text = text
        return cell
    }
}
