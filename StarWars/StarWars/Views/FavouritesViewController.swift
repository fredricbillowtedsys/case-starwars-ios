//
//  FavouritesViewController.swift
//  StarWars
//
//  Created by Fredric Billow on 2021-05-02.
//

import UIKit

class FavouritesViewController: UIViewController {
    private let personCellIdentifier = "personCell"
    private var safeArea: UILayoutGuide!
    private let tableView = UITableView()
    private var personNavigationController: UINavigationController?
    private var displayingPerson: FavouritePerson?

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

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: personCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    @objc private func removeFromFavourites(sender: UIView) {
        let index = DataManager.shared.favourites.firstIndex { $0.name == displayingPerson?.name}

        if let index = index {
            DataManager.shared.favourites.remove(at: index)
        }

        self.tableView.reloadData()
    }

    @objc private func dismissPersonView(sender: UIView) {
        self.personNavigationController?.dismiss(animated: true)
    }
}

extension FavouritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.favourites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: personCellIdentifier, for: indexPath)
        cell.textLabel?.text = DataManager.shared.favourites[indexPath.item].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

}

extension FavouritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.personNavigationController = UINavigationController()

        guard let personNavigationController = self.personNavigationController else {
            return
        }

        let vc = PersonViewController()
        let barButtonFavourites = UIBarButtonItem(title: "Remove from favourites", style: .plain, target: self, action: #selector(removeFromFavourites))
        let barButtonClose = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(dismissPersonView))

        vc.navigationItem.leftBarButtonItem = barButtonFavourites
        vc.navigationItem.rightBarButtonItem = barButtonClose

        self.displayingPerson = DataManager.shared.favourites[indexPath.item]
        vc.favouritePerson = self.displayingPerson

        personNavigationController.viewControllers = [vc]
        self.present(personNavigationController, animated: true)
    }
}

