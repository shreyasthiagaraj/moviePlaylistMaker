//
//  SearchViewController.swift
//  MoviePlaylist
//
//  Created by Shreyas Thiagaraj on 1/8/21.
//  Copyright © 2021 Shreyas. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var searchResults = [Movie]() {
        didSet {
            DispatchQueue.main.async {
                self.resultsTable.reloadData()
            }
        }
    }
    
    private var resultsPage = 0
    private var urlSession = URLSession(configuration: .default)
    private var totalResults = 0
    
    weak var delegate: SearchDelegate?
    
    private var resultsTable: UITableView!
    private var searchTextField: UITextField!
    private var searchButton: UIButton!
    
    override func viewDidLoad() {
        let closeButton = UIButton(type: .custom)
        closeButton.setTitle("Done", for: .normal)
        closeButton.setTitleColor(.darkGray, for: .normal)
        closeButton.addTarget(self, action: #selector(SearchViewController.handleCloseTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let searchTextField = UITextField()
        searchTextField.rightViewMode = .always
        searchTextField.placeholder = "Movie name"
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.addTarget(self, action: #selector(SearchViewController.handleTextFieldValueChanged), for: .editingChanged)

        let searchButton = UIButton(type: .custom)
        searchButton.setTitle("Search", for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
        searchButton.setTitleColor(.systemGray, for: .highlighted)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorView = UIView()
        separatorView.backgroundColor = .black
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        let resultsTable = UITableView()
        resultsTable.delegate = self
        resultsTable.dataSource = self
        resultsTable.register(UITableViewCell.self, forCellReuseIdentifier: "SearchCell")
        resultsTable.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(closeButton)
        self.view.addSubview(searchTextField)
        self.view.addSubview(separatorView)
        self.view.addSubview(searchButton)
        self.view.addSubview(resultsTable)
        
        self.searchButton = searchButton
        self.searchTextField = searchTextField
        self.resultsTable = resultsTable

        self.view.backgroundColor = .white
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 80),
            closeButton.leadingAnchor.constraint(equalTo:  self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            self.searchTextField.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            self.searchTextField.heightAnchor.constraint(equalToConstant: 80),
            self.searchTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            self.searchTextField.trailingAnchor.constraint(equalTo: self.searchButton.leadingAnchor, constant: 8),
            
            separatorView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: self.searchTextField.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),

            self.searchButton.widthAnchor.constraint(equalToConstant: 70),
            self.searchButton.centerYAnchor.constraint(equalTo: self.searchTextField.centerYAnchor),
            self.searchButton.heightAnchor.constraint(equalToConstant: 80),
            self.searchButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            
            self.resultsTable.topAnchor.constraint(equalTo: self.searchTextField.bottomAnchor),
            self.resultsTable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.resultsTable.widthAnchor.constraint(equalTo: self.view.widthAnchor),
        ])
        
        // Add actions
        self.searchButton.addTarget(self, action: #selector(SearchViewController.handleSearchTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    private func fetchMovies(_ text: String, page: Int, completion: @escaping ([Movie], Int) -> ()) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "omdbapi.com"
        urlComponents.queryItems = [
            URLQueryItem(name: "i", value: "tt3896198"),
            URLQueryItem(name: "apikey", value: "f689617d"),
            URLQueryItem(name: "s", value: text),
            URLQueryItem(name: "page", value: page.description)
        ]
        guard let url = urlComponents.url else {
            return
        }
        // Fetch movie results
        self.urlSession.dataTask(
            with: url,
            completionHandler: { data, response, error in
                guard error == nil, let data = data else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Oops!", message: "Something went wrong. Please check your internet connection and try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                guard let searchResults = try? JSONDecoder().decode(SearchResults.self, from: data) else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Movie not found", message: "Please try again!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                completion(searchResults.Search, Int(searchResults.totalResults) ?? searchResults.Search.count)
        }).resume()
    }
    
    @objc private dynamic func handleSearchTapped() {
        self.resultsPage = 1
        self.totalResults = 0
        
        guard let text = self.searchTextField.text else {
            // TODO: Show error
            return
        }
        self.fetchMovies(text, page: self.resultsPage) { results, totalResults in
            self.searchResults = results
            self.totalResults = totalResults
        }
    }
    
    @objc private dynamic func handleTextFieldValueChanged() {
        guard !searchResults.isEmpty else {
            return
        }
        self.resultsPage = 0
        self.totalResults = 0
        self.searchResults = []
    }
    
    @objc private dynamic func handleCloseTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //  MARK: - UITableViewDataSource & UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = self.searchResults[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell")!
        cell.textLabel?.text = "\(result.Title) (\(result.Year))"
        cell.textLabel?.numberOfLines = 2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = self.searchResults[indexPath.row]
        let confirmAlert = UIAlertController(title: "Confirm Selection", message: "Add \"\(movie.Title)\" to playlist?", preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            self.delegate?.didFinishPickingMovie(self, movie: movie)
        })
        self.present(confirmAlert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.searchResults.count < self.totalResults,
            scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height - 150 else {
            return
        }
        self.resultsPage += 1
        self.fetchMovies(self.searchTextField.text!, page: self.resultsPage) { results, _ in
            self.searchResults.append(contentsOf: results)
        }
    }
}
