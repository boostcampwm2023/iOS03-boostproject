//
//  MyPageViewController.swift
//  Macro
//
//  Created by Byeon jinha on 11/21/23.
//

import MacroNetwork
import UIKit

final class MyPageViewController: TabViewController {
    
    // MARK: - Properties
    
    private let viewModel: MyPageViewModel
    
    // MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.fill")
        imageView.backgroundColor = .cyan
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "아몰랑"
        label.textColor = UIColor.appColor(.purple5)
        label.font = UIFont.appFont(.baeEunCallout)
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorColor = UIColor.appColor(.purple2)
        return tableView
    }()
    
    // MARK: - Init
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "sectionTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        setUpLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
        profileImageView.clipsToBounds = true
    }
    
}

// MARK: - UI Settings

extension MyPageViewController {
    
    private func setTranslatesAutoresizingMaskIntoConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addsubviews() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(tableView)
    }
    
    private func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: Metrics.imageWidth),
            profileImageView.heightAnchor.constraint(equalToConstant: Metrics.imageHeight),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Padding.imageTop),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: Metrics.nameLabelWidth),
            nameLabel.heightAnchor.constraint(equalToConstant: Metrics.nameLabelHeight),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: Padding.labelTop),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Padding.tableViewTop),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Padding.tableViewSide),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Padding.tableViewSide),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Padding.tableViewBottom)
        ])
    }
    
}

extension MyPageViewController {
    
    private func setUpLayout() {
        setTranslatesAutoresizingMaskIntoConstraints()
        addsubviews()
        setLayoutConstraints()
    }
    @objc func backButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Methods

// MARK: - TableView

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel.information.count
        case 1: return viewModel.post.count
        default: return viewModel.management.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTableViewCell", for: indexPath)
        cell.backgroundColor = UIColor.appColor(.purple1)
        cell.textLabel?.font = UIFont.appFont(.baeEunCallout)
        switch indexPath.section {
        case 0: cell.textLabel?.text = "\(viewModel.information[indexPath.row])"
        case 1: cell.textLabel?.text = "\(viewModel.post[indexPath.row])"
        default: cell.textLabel?.text = "\(viewModel.management[indexPath.row])"
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        
        headerLabel.text = viewModel.sections[section]
        headerLabel.font = UIFont.appFont(.baeEunBody)
        
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        headerView.addSubview(headerLabel)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        return headerView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .systemBackground
        return footerView
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.contentView.backgroundColor = UIColor.systemBackground
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && (indexPath.row == 0 || indexPath.row == 2) {
            let myInfoVC = MyInfoViewController(viewModel: viewModel, selectedIndex: indexPath.row)
            if #available(iOS 15.0, *) {
                myInfoVC.sheetPresentationController?.detents = [.large()]
                myInfoVC.sheetPresentationController?.prefersGrabberVisible = true
            }
            present(myInfoVC, animated: true)
        }
        else if indexPath.section == 0 && indexPath.row == 1 {
            presentImagePickerController()
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            let provider = APIProvider(session: URLSession.shared)
            let userInfoViewModel = UserInfoViewModel(postSearcher: Searcher(provider: provider), followFeature: FollowFeature(provider: provider))
            let userInfoVC = UserInfoViewController(viewModel: userInfoViewModel, userInfo: "SomeUserInfo")
            self.navigationController?.pushViewController(userInfoVC, animated: true)
        }
        else if indexPath.section == 1 && indexPath.row == 1 {
            
        }
        
    }
}

// MARK: - ImagePicker

extension MyPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func presentImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    /// 사용자가 이미지를 선택했을 때
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    /// 사용자가 이미지 선택을 취소했을 때
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - LayoutMetrics

extension MyPageViewController {
    enum Metrics {
        static let imageWidth: CGFloat = 120
        static let imageHeight: CGFloat = 120
        static let nameLabelWidth: CGFloat = 42
        static let nameLabelHeight: CGFloat = 46
    }
    
    enum Padding {
        static let imageTop: CGFloat = 40
        static let labelTop: CGFloat = 20
        static let tableViewTop: CGFloat = 10
        static let tableViewSide: CGFloat = 38
        static let tableViewBottom: CGFloat = 75
    }
}
