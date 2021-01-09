//
//  ViewController.swift
//  MoviePlaylist
//
//  Created by Shreyas Thiagaraj on 1/8/21.
//  Copyright © 2021 Shreyas. All rights reserved.
//

import UIKit

protocol SearchDelegate: class {
    func didFinishPickingMovie(_ vc: SearchViewController, movie: Movie)
}

class PlaylistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchDelegate {
        
    var movieTable: UITableView!
    var addButton: UIButton!

    private var title: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        
        let addButton = UIButton(type: .custom)
        addButton.setTitle("+ Add Movie", for: .normal)
        addButton.setTitleColor(.systemBlue, for: .normal)
        addButton.setTitleColor(.systemGray, for: .highlighted)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        let movieTable = UITableView()
        movieTable.delegate = self
        movieTable.dataSource = self
        movieTable.register(UITableViewCell.self, forCellReuseIdentifier: "MovieCell")
        movieTable.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(addButton)
        self.view.addSubview(movieTable)
        
        self.addButton = addButton
        self.movieTable = movieTable

        NSLayoutConstraint.activate([
            self.addButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.addButton.heightAnchor.constraint(equalToConstant: 60),
            self.addButton.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.movieTable.topAnchor.constraint(equalTo: self.addButton.bottomAnchor),
            self.movieTable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.movieTable.widthAnchor.constraint(equalTo: self.view.widthAnchor),
        ])
        
        // Add actions
        self.addButton.addTarget(self, action: #selector(PlaylistViewController.handleAddTapped), for: .touchUpInside)
        
        self.loadMovies()
    }
    
    // MARK: - Actions
    
    @objc private dynamic func handleAddTapped() {
        let vc = SearchViewController()
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewCellDelegate & UITableViewCellDataSource
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = self.movies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        cell.textLabel?.text = "\(movie.Title) (\(movie.Year))"
        cell.textLabel?.numberOfLines = 2
//        let session = URLSession(configuration: .default)
//        session.downloadTask(with: movie.Poster
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: - SearchDelegate
    
    func didFinishPickingMovie(_ vc: SearchViewController, movie: Movie) {
        vc.dismiss(animated: true, completion: nil)

        // Add to beginning of playlist
        self.movies.insert(movie, at: 0)
        
        // Update cache
        let archiver = NSKeyedArchiver(requiringSecureCoding: false)
        do {
            try archiver.encodeEncodable(self.movies, forKey: NSKeyedArchiveRootObjectKey)
            UserDefaults.standard.set(archiver.encodedData, forKey: "movies")
        } catch _ {
            // Handle error
        }
    }
    
    // MARK: - Private
    
    private var movies = [Movie]() {
        didSet {
            self.movieTable.reloadData()
        }
    }

    private func loadMovies() {
        // TODO: Create a movie service to hold this data instead of unarchiving every time
        guard let data = UserDefaults.standard.data(forKey: "movies"),
            let unarchiver = try? NSKeyedUnarchiver(forReadingFrom: data),
            let decodable = unarchiver.decodeDecodable([Movie].self, forKey: NSKeyedArchiveRootObjectKey) else {
                return
        }
        self.movies = decodable
    }
}
