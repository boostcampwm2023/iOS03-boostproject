//
//  UserInfoViewController.swift
//  Macro
//
//  Created by Byeon jinha on 11/21/23.
//

import Combine
import UIKit

final class UserInfoViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: UserInfoViewModel
    private let inputSubject: PassthroughSubject<UserInfoViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    lazy var homeCollectionView: PostCollectionView = PostCollectionView(frame: .zero, viewModel: viewModel)
    lazy var userInfoHeaderView: UserInfoHeaderView = UserInfoHeaderView(frame: .zero, inputSubject: inputSubject)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.appColor(.blue1)
        bind()
        inputSubject.send(.searchUserProfile(email: viewModel.searchUserEmail))
        setUpLayout()
        super.viewDidLoad()
    }
    
    // MARK: - Init
    
    init(viewModel: UserInfoViewModel, userInfo: String) {
        self.viewModel = viewModel
        viewModel.searchUserEmail = userInfo 
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Settings

private extension UserInfoViewController {
    
    private func setTranslatesAutoresizingMaskIntoConstraints() {
        userInfoHeaderView.translatesAutoresizingMaskIntoConstraints = false
        homeCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addSubviews() {
        self.view.addSubview(userInfoHeaderView)
        self.view.addSubview(homeCollectionView)
    }
    
    private func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            userInfoHeaderView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            userInfoHeaderView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            userInfoHeaderView.widthAnchor.constraint(equalToConstant: UIScreen.width - 40),
            userInfoHeaderView.heightAnchor.constraint(equalToConstant: 217),
            
            homeCollectionView.topAnchor.constraint(equalTo: userInfoHeaderView.bottomAnchor, constant: 20),
            homeCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            homeCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            homeCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    private func setUpLayout() {
        setTranslatesAutoresizingMaskIntoConstraints()
        addSubviews()
        setLayoutConstraints()
    }
    
}

// MARK: - Bind

private extension UserInfoViewController {
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: RunLoop.main).sink { [weak self] output in
            switch output {
            case let .updateFollowResult(result):
                self?.updateFollowResult(result)
            case let .updateUserProfile(result):
                self?.updateUserProfile(result)
            case let .updateUserPost(result):
                self?.updateUserPost(result)
            default: break
            }
        }.store(in: &cancellables)
        
    }
}

// MARK: - Methods

private extension UserInfoViewController {
    
    private func updateFollowResult(_ result: FollowResponse) {
        userInfoHeaderView.updateFollow(item: result)
    }
    
    private func updateUserProfile(_ result: UserProfile) {
        userInfoHeaderView.configure(item: result)
    }
    
    private func updateUserPost(_ result: [PostFindResponse]) {
        homeCollectionView.viewModel.posts = result
        homeCollectionView.reloadData()
    }
}
