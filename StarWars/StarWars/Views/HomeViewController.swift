//
//  ViewController.swift
//  StarWars
//
//  Created by Fredric Billow on 2021-05-02.
//

import UIKit

class HomeViewController: UIViewController {
    private let personCellIdentifier = "personCell"
    private var safeArea: UILayoutGuide!
    private let tableView = UITableView()
    private let searchTextField = UITextField()
    private var personNavigationController: UINavigationController?
    private var displayingPerson: Person?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide

        searchTextField.placeholder = "Search..."
        searchTextField.addTarget(self, action: #selector(onSearchChange), for: .editingChanged)
        view.addSubview(searchTextField)
        view.addSubview(tableView)

        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10).isActive = true
        searchTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        searchTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20).isActive = true

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: personCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self

        fetchPersons()
    }

    @objc private func onSearchChange(sender: UITextField) {
        let query = sender.text ?? ""

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            guard query == sender.text else {
                return
            }
            let url = URL(string: "\(ApiUtil.PEOPLE_SEARCH_ENDPOINT)\(sender.text ?? "")")
            if let url = url {
                DataManager.shared.persons = []
                DataManager.shared.paginationMeta = PaginationMeta(count: -1, next: url, previous: nil)
                self.tableView.reloadData()
                self.fetchPersons()
            }
        }
    }

    private func fetchPersons() {
        if let url = DataManager.shared.paginationMeta.next {
            ApiUtil.fetch(PersonsResponse.self, url: url) { result in
                if let result = result, let persons = result.results {
                    DataManager.shared.persons.append(contentsOf: persons)

                    var nextUrl: URLComponents?
                    var previousUrl: URLComponents?

                    if let resultNext = result.next {
                        nextUrl = URLComponents(string: resultNext)
                        nextUrl?.scheme = "https"
                    }

                    if let resultPrevious = result.previous {
                        previousUrl = URLComponents(string: resultPrevious)
                        previousUrl?.scheme = "https"
                    }

                    DataManager.shared.paginationMeta = PaginationMeta(count: result.count, next: nextUrl?.url ?? nil, previous: previousUrl?.url ?? nil)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    @objc private func addToFavourites(sender: UIView) {
        let isAlreadyInFavourites = DataManager.shared.favourites.contains {
            $0.name == displayingPerson?.name
        }

        guard !isAlreadyInFavourites else {
            return
        }

        if let urlStr = displayingPerson?.url, var urlComponents = URLComponents(string: urlStr) {
            urlComponents.scheme = "https"
            if let name = displayingPerson?.name, let url = urlComponents.url {
                DataManager.shared.favourites.append(FavouritePerson(name: name, url:url))
            }
        }
    }

    @objc private func dismissPersonView(sender: UIView) {
        self.personNavigationController?.dismiss(animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.persons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: personCellIdentifier, for: indexPath)
        cell.textLabel?.text = DataManager.shared.persons[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.personNavigationController = UINavigationController()

        guard let personNavigationController = self.personNavigationController else {
            return
        }

        let vc = PersonViewController()
        let barButtonFavourites = UIBarButtonItem(title: "Add to favourites", style: .plain, target: self, action: #selector(addToFavourites(sender:)))
        let barButtonClose = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(dismissPersonView))

        vc.navigationItem.leftBarButtonItem = barButtonFavourites
        vc.navigationItem.rightBarButtonItem = barButtonClose

        self.displayingPerson = DataManager.shared.persons[indexPath.item]
        vc.person = self.displayingPerson

        personNavigationController.viewControllers = [vc]
        self.present(personNavigationController, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (DataManager.shared.persons.count - 1) {
            fetchPersons()
        }
    }
}

