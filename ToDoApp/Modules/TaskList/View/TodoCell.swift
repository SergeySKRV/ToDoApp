//
//  TodoCell.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 02.04.2026.
//

import UIKit

/// Custom table view cell used to display a todo item in the task list.
final class TodoCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "TodoCell"

    private let statusImageView = UIImageView()
    private let textContainerView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let dividerView = UIView()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        descriptionLabel.attributedText = nil
        dateLabel.text = nil
        statusImageView.image = nil
    }

    // MARK: - Configuration

    func configure(with viewModel: TaskListCellViewModel) {
        if viewModel.isCompleted {
            titleLabel.attributedText = NSAttributedString(
                string: viewModel.title,
                attributes: [
                    .foregroundColor: AppColors.secondaryText,
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ]
            )

            descriptionLabel.attributedText = NSAttributedString(
                string: viewModel.description,
                attributes: [
                    .foregroundColor: AppColors.secondaryText,
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular)
                ]
            )

            statusImageView.image = UIImage(systemName: "checkmark.circle")
            statusImageView.tintColor = AppColors.accent
        } else {
            titleLabel.attributedText = NSAttributedString(
                string: viewModel.title,
                attributes: [
                    .foregroundColor: AppColors.primaryText,
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
                ]
            )

            descriptionLabel.attributedText = NSAttributedString(
                string: viewModel.description,
                attributes: [
                    .foregroundColor: AppColors.secondaryText,
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular)
                ]
            )

            statusImageView.image = UIImage(systemName: "circle")
            statusImageView.tintColor = AppColors.tertiaryText
        }

        dateLabel.text = viewModel.createdAtText
    }

    // MARK: - Private

    private func setupUI() {
        backgroundColor = AppColors.background
        contentView.backgroundColor = AppColors.background
        selectionStyle = .none

        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.contentMode = .scaleAspectFit
        statusImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)

        textContainerView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 2
        descriptionLabel.lineBreakMode = .byTruncatingTail

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = AppColors.tertiaryText
        dateLabel.numberOfLines = 1

        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = AppColors.divider

        contentView.addSubview(statusImageView)
        contentView.addSubview(textContainerView)
        contentView.addSubview(dividerView)

        textContainerView.addSubview(titleLabel)
        textContainerView.addSubview(descriptionLabel)
        textContainerView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            statusImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusImageView.widthAnchor.constraint(equalToConstant: 24),
            statusImageView.heightAnchor.constraint(equalToConstant: 24),

            textContainerView.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: 12),
            textContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),

            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),

            statusImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            dividerView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dividerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
