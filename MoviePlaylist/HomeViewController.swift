//
//  HomeViewController.swift
//  MoviePlaylist
//
//  Created by Shreyas Thiagaraj on 1/9/21.
//  Copyright © 2021 Shreyas. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var playlists: [String]! {
        didSet {
            self.playlistTable.reloadData()
        }
    }
    
    private var createButton: UIButton!
    private var playlistTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "My Playlists"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .systemBackground
        
        let createButton = UIButton(type: .custom)
        createButton.setTitle("+ New Playlist", for: .normal)
        createButton.setTitleColor(.systemBlue, for: .normal)
        createButton.setTitleColor(.systemGray, for: .highlighted)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        let playlistTable = UITableView()
        playlistTable.delegate = self
        playlistTable.dataSource = self
        playlistTable.register(UITableViewCell.self, forCellReuseIdentifier: "PlaylistCell")
        playlistTable.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(createButton)
        self.view.addSubview(playlistTable)
        
        self.createButton = createButton
        self.playlistTable = playlistTable
        
        NSLayoutConstraint.activate([
            self.createButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.createButton.heightAnchor.constraint(equalToConstant: 60),
            self.createButton.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.playlistTable.topAnchor.constraint(equalTo: self.createButton.bottomAnchor),
            self.playlistTable.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.playlistTable.widthAnchor.constraint(equalTo: self.view.widthAnchor),
        ])
        
        // Add actions
        self.createButton.addTarget(self, action: #selector(HomeViewController.handleCreateTapped), for: .touchUpInside)
        
        self.playlists = UserDefaults.standard.array(forKey: "playlists") as? [String] ?? [String]()
    }
    
    @objc private dynamic func handleCreateTapped() {
        let alert = UIAlertController(title: "New Playlist", message: "Enter a name for this playlist.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default) { _ in
            guard let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
                let error = UIAlertController(title: "Oops!", message: "You must choose a name for the playlist.", preferredStyle: .alert)
                error.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(error, animated: true)
                return
            }
            guard !self.playlists.contains(name) else {
                let error = UIAlertController(title: "Oops!", message: "A playlist with that name already exists.", preferredStyle: .alert)
                error.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(error, animated: true)
                return
            }
            self.playlists.append(name)
            UserDefaults.standard.set(self.playlists, forKey: "playlists")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath)
        cell.textLabel?.text = self.playlists[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = PlaylistViewController()
        vc.playlistName = self.playlists[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
