//
//  TaskListViewController.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import UIKit
import Speech
import AVFoundation

final class TaskListViewController: UIViewController {
    var presenter: TaskListPresenterProtocol?

    private var items: [TaskListCellViewModel] = [] {
        didSet {
            let count = items.count
            tasksCountLabel.text = L10n.tasksCount(count)
        }
    }

    private let titleLabel = UILabel()
    private let searchContainerView = UIView()
    private let searchTextField = UITextField()
    private let voiceSearchButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let bottomBarView = UIView()
    private let tasksCountLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private var bottomBarHeightConstraint: NSLayoutConstraint?

    private let overlayView = UIView()
    private let blurView = UIVisualEffectView(effect: nil)
    private let dimView = UIView()

    private let focusedCardView = UIView()
    private let focusedTitleLabel = UILabel()
    private let focusedDescriptionLabel = UILabel()
    private let focusedDateLabel = UILabel()

    private let actionsContainerView = UIStackView()

    private var selectedTodoIndex: Int?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isVoiceSearchActive = false
    private var isVoiceSearchAvailable = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestSpeechAuthorization()
        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        presenter?.viewWillAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopVoiceRecognition()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomBarHeightConstraint?.constant = 49 + view.safeAreaInsets.bottom
    }
}

private extension TaskListViewController {
    func setupUI() {
        view.backgroundColor = AppColors.background

        setupTitleLabel()
        setupSearchField()
        setupTableView()
        setupBottomBar()
        setupOverlayUI()

        view.addSubview(titleLabel)
        view.addSubview(searchContainerView)
        view.addSubview(tableView)
        view.addSubview(bottomBarView)
        view.addSubview(overlayView)

        bottomBarHeightConstraint = bottomBarView.heightAnchor.constraint(equalToConstant: 49)
        bottomBarHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            searchContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchContainerView.heightAnchor.constraint(equalToConstant: 36),

            tableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor),

            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = L10n.tasksTitle
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = AppColors.primaryText
    }

    func setupSearchField() {
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.backgroundColor = AppColors.searchBackground
        searchContainerView.layer.cornerRadius = 10
        searchContainerView.layer.masksToBounds = true

        let searchIconView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIconView.tintColor = AppColors.tertiaryText
        searchIconView.contentMode = .scaleAspectFit
        searchIconView.translatesAutoresizingMaskIntoConstraints = false

        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.delegate = self
        searchTextField.backgroundColor = .clear
        searchTextField.textColor = AppColors.primaryText
        searchTextField.tintColor = AppColors.primaryText
        searchTextField.font = .systemFont(ofSize: 17, weight: .regular)
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.returnKeyType = .search
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: L10n.searchPlaceholder,
            attributes: [
                .foregroundColor: AppColors.tertiaryText,
                .font: UIFont.systemFont(ofSize: 17, weight: .regular)
            ]
        )
        searchTextField.addTarget(self, action: #selector(searchTextDidChange(_:)), for: .editingChanged)

        voiceSearchButton.translatesAutoresizingMaskIntoConstraints = false
        voiceSearchButton.tintColor = AppColors.tertiaryText
        voiceSearchButton.addTarget(self, action: #selector(didTapVoiceSearch), for: .touchUpInside)

        searchContainerView.addSubview(searchIconView)
        searchContainerView.addSubview(searchTextField)
        searchContainerView.addSubview(voiceSearchButton)

        NSLayoutConstraint.activate([
            searchIconView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 12),
            searchIconView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIconView.widthAnchor.constraint(equalToConstant: 16),
            searchIconView.heightAnchor.constraint(equalToConstant: 16),

            voiceSearchButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -10),
            voiceSearchButton.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            voiceSearchButton.widthAnchor.constraint(equalToConstant: 24),
            voiceSearchButton.heightAnchor.constraint(equalToConstant: 24),

            searchTextField.leadingAnchor.constraint(equalTo: searchIconView.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: voiceSearchButton.leadingAnchor, constant: -8),
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor)
        ])

        updateVoiceSearchIcon()
    }

    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = AppColors.background
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
    }

    func setupBottomBar() {
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.backgroundColor = AppColors.bottomBarBackground

        tasksCountLabel.translatesAutoresizingMaskIntoConstraints = false
        tasksCountLabel.font = .systemFont(ofSize: 11, weight: .medium)
        tasksCountLabel.textColor = AppColors.primaryText
        tasksCountLabel.textAlignment = .center
        tasksCountLabel.text = L10n.tasksCount(0)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = AppColors.accent
        activityIndicator.hidesWhenStopped = true

        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.tintColor = AppColors.accent
        addButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)

        bottomBarView.addSubview(tasksCountLabel)
        bottomBarView.addSubview(activityIndicator)
        bottomBarView.addSubview(addButton)

        NSLayoutConstraint.activate([
            tasksCountLabel.centerXAnchor.constraint(equalTo: bottomBarView.centerXAnchor),
            tasksCountLabel.centerYAnchor.constraint(equalTo: bottomBarView.safeAreaLayoutGuide.topAnchor, constant: 25),

            activityIndicator.leadingAnchor.constraint(equalTo: bottomBarView.leadingAnchor, constant: 16),
            activityIndicator.centerYAnchor.constraint(equalTo: tasksCountLabel.centerYAnchor),

            addButton.trailingAnchor.constraint(equalTo: bottomBarView.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: tasksCountLabel.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 28),
            addButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func setupOverlayUI() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = .clear
        overlayView.alpha = 0
        overlayView.isHidden = true

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = true

        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)

        focusedCardView.translatesAutoresizingMaskIntoConstraints = false
        focusedCardView.backgroundColor = AppColors.focusedCardBackground
        focusedCardView.layer.cornerRadius = 16
        focusedCardView.clipsToBounds = true
        focusedCardView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)

        focusedTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        focusedTitleLabel.textColor = AppColors.primaryText
        focusedTitleLabel.numberOfLines = 2

        focusedDescriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        focusedDescriptionLabel.textColor = AppColors.secondaryText
        focusedDescriptionLabel.numberOfLines = 3

        focusedDateLabel.font = .systemFont(ofSize: 14, weight: .regular)
        focusedDateLabel.textColor = AppColors.tertiaryText

        let cardStack = UIStackView(arrangedSubviews: [focusedTitleLabel, focusedDescriptionLabel, focusedDateLabel])
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardStack.axis = .vertical
        cardStack.spacing = 8

        actionsContainerView.translatesAutoresizingMaskIntoConstraints = false
        actionsContainerView.axis = .vertical
        actionsContainerView.spacing = 1
        actionsContainerView.backgroundColor = AppColors.actionMenuBackground
        actionsContainerView.layer.cornerRadius = 16
        actionsContainerView.clipsToBounds = true

        overlayView.addSubview(blurView)
        overlayView.addSubview(dimView)
        overlayView.addSubview(focusedCardView)
        overlayView.addSubview(actionsContainerView)
        focusedCardView.addSubview(cardStack)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: overlayView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor),

            dimView.topAnchor.constraint(equalTo: overlayView.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor),

            focusedCardView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            focusedCardView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor, constant: -78),
            focusedCardView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 24),
            focusedCardView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -24),

            cardStack.topAnchor.constraint(equalTo: focusedCardView.topAnchor, constant: 16),
            cardStack.leadingAnchor.constraint(equalTo: focusedCardView.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: focusedCardView.trailingAnchor, constant: -16),
            cardStack.bottomAnchor.constraint(equalTo: focusedCardView.bottomAnchor, constant: -16),

            actionsContainerView.topAnchor.constraint(equalTo: focusedCardView.bottomAnchor, constant: 16),
            actionsContainerView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 53),
            actionsContainerView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -53)
        ])

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(hideFocusedMenu))
        dimView.addGestureRecognizer(dismissTap)

        let blurTap = UITapGestureRecognizer(target: self, action: #selector(hideFocusedMenu))
        blurView.addGestureRecognizer(blurTap)
    }

    func makeActionRow(title: String, assetImageName: String, tintColor: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear

        var config = UIButton.Configuration.plain()
        var attributes = AttributeContainer()
        attributes.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        attributes.foregroundColor = tintColor

        config.attributedTitle = AttributedString(title, attributes: attributes)
        config.image = UIImage(named: assetImageName)?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .trailing
        config.imagePadding = 12
        config.baseForegroundColor = tintColor
        config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18)

        button.configuration = config
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    func showFocusedMenu(for index: Int) {
        guard items.indices.contains(index) else { return }

        selectedTodoIndex = index
        let item = items[index]

        focusedTitleLabel.text = item.title
        focusedDescriptionLabel.text = item.description
        focusedDateLabel.text = item.createdAtText

        actionsContainerView.arrangedSubviews.forEach {
            actionsContainerView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let editButton = makeActionRow(
            title: L10n.actionEdit,
            assetImageName: "edit",
            tintColor: .black,
            action: #selector(didTapEditAction)
        )

        let shareButton = makeActionRow(
            title: L10n.actionShare,
            assetImageName: "export",
            tintColor: .black,
            action: #selector(didTapShareAction)
        )

        let deleteButton = makeActionRow(
            title: L10n.actionDelete,
            assetImageName: "trash",
            tintColor: .systemRed,
            action: #selector(didTapDeleteAction)
        )

        let buttons = [editButton, shareButton, deleteButton]

        for (index, button) in buttons.enumerated() {
            actionsContainerView.addArrangedSubview(button)

            if index < buttons.count - 1 {
                let separator = UIView()
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.backgroundColor = UIColor.black.withAlphaComponent(0.28)
                NSLayoutConstraint.activate([
                    separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
                ])
                actionsContainerView.addArrangedSubview(separator)
            }
        }

        overlayView.isHidden = false
        overlayView.alpha = 0
        focusedCardView.transform = CGAffineTransform(translationX: 0, y: 30).scaledBy(x: 0.96, y: 0.96)
        actionsContainerView.transform = CGAffineTransform(translationX: 0, y: 20)
        blurView.effect = nil

        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.overlayView.alpha = 1
            self.blurView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            self.focusedCardView.transform = .identity
            self.actionsContainerView.transform = .identity
        }
    }

    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] speechStatus in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    let enabled = (speechStatus == .authorized) && granted
                    self?.isVoiceSearchAvailable = enabled
                    self?.updateVoiceSearchIcon()
                }
            }
        }
    }

    func updateVoiceSearchIcon() {
        let imageName = isVoiceSearchActive ? "stop.fill" : "mic.fill"
        let tintColor: UIColor

        if isVoiceSearchAvailable == false {
            tintColor = AppColors.tertiaryText.withAlphaComponent(0.4)
        } else if isVoiceSearchActive {
            tintColor = .systemRed
        } else {
            tintColor = AppColors.tertiaryText
        }

        let image = UIImage(systemName: imageName)
        voiceSearchButton.setImage(image, for: .normal)
        voiceSearchButton.tintColor = tintColor
    }

    func startVoiceRecognition() {
        guard isVoiceSearchAvailable else {
            showError(L10n.voiceSearchPermissionDenied)
            return
        }

        guard let speechRecognizer, speechRecognizer.isAvailable else {
            showError(L10n.voiceSearchUnavailable)
            return
        }

        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            showError(L10n.voiceSearchAudioSessionFailed)
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if #available(iOS 13.0, *) {
            request.requiresOnDeviceRecognition = false
        }
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result = result {
                let recognizedText = result.bestTranscription.formattedString
                self.searchTextField.text = recognizedText
                self.presenter?.didSearch(text: recognizedText)
            }

            let isFinal = result?.isFinal ?? false
            if error != nil || isFinal {
                self.stopVoiceRecognition()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isVoiceSearchActive = true
            updateVoiceSearchIcon()
        } catch {
            stopVoiceRecognition()
            showError(L10n.voiceSearchStartFailed)
        }
    }

    func stopVoiceRecognition() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }

        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil
        isVoiceSearchActive = false
        updateVoiceSearchIcon()

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch { }
    }

    @objc func searchTextDidChange(_ textField: UITextField) {
        presenter?.didSearch(text: textField.text ?? "")
    }

    @objc func didTapVoiceSearch() {
        if isVoiceSearchActive {
            stopVoiceRecognition()
        } else {
            startVoiceRecognition()
        }
    }

    @objc func hideFocusedMenu() {
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseIn]) {
            self.overlayView.alpha = 0
            self.blurView.effect = nil
            self.focusedCardView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.actionsContainerView.transform = CGAffineTransform(translationX: 0, y: 12)
        } completion: { _ in
            self.overlayView.isHidden = true
            self.selectedTodoIndex = nil
        }
    }

    @objc func didTapEditAction() {
        guard let selectedTodoIndex else { return }
        hideFocusedMenu()
        presenter?.didSelectItem(at: selectedTodoIndex)
    }

    @objc func didTapShareAction() {
        guard let selectedTodoIndex else { return }
        let item = items[selectedTodoIndex]
        let text = [item.title, item.description].joined(separator: "\n")

        hideFocusedMenu()

        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
        }
        present(activityVC, animated: true)
    }

    @objc func didTapDeleteAction() {
        guard let selectedTodoIndex else { return }
        hideFocusedMenu()
        presenter?.didDeleteItem(at: selectedTodoIndex)
    }

    @objc func didTapAdd() {
        presenter?.didTapAdd()
    }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let location = gesture.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: location) else { return }

        tableView.deselectRow(at: indexPath, animated: false)
        showFocusedMenu(for: indexPath.row)
    }
}

extension TaskListViewController: TaskListViewProtocol {
    func showLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    func showTodos(_ items: [TaskListCellViewModel]) {
        self.items = items
        tableView.reloadData()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: L10n.errorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.ok, style: .default))
        present(alert, animated: true)
    }
}

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TodoCell.reuseIdentifier,
            for: indexPath
        ) as? TodoCell else {
            return UITableViewCell()
        }

        cell.configure(with: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        presenter?.didToggleStatus(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        106
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: L10n.actionDelete) { [weak self] _, _, completion in
            self?.presenter?.didDeleteItem(at: indexPath.row)
            completion(true)
        }

        let toggleTitle = items[indexPath.row].isCompleted ? L10n.actionRestore : L10n.actionDone
        let toggleAction = UIContextualAction(style: .normal, title: toggleTitle) { [weak self] _, _, completion in
            self?.presenter?.didToggleStatus(at: indexPath.row)
            completion(true)
        }
        toggleAction.backgroundColor = .systemBlue

        let config = UISwipeActionsConfiguration(actions: [deleteAction, toggleAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}

extension TaskListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        presenter?.didSearch(text: textField.text ?? "")
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        presenter?.didSearch(text: "")
        return true
    }
}
