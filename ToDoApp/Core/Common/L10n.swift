//
//  L10n.swift
//  ToDoApp
//
//  Created by Сергей Скориков on 04.04.2026.
//

import Foundation

/// Centralized access point for localized strings used in the app.
enum L10n {

    // MARK: - Common

    static let back = NSLocalizedString("common.back", comment: "")
    static let ok = NSLocalizedString("common.ok", comment: "")

    // MARK: - Task List

    static let tasksTitle = NSLocalizedString("tasks.title", comment: "")
    static let searchPlaceholder = NSLocalizedString("search.placeholder", comment: "")

    static func tasksCount(_ count: Int) -> String {
        let format = NSLocalizedString("tasks.count", comment: "")
        return String.localizedStringWithFormat(format, count)
    }

    // MARK: - Task Details

    static let taskCreateTitle = NSLocalizedString("task.details.createTitle", comment: "")
    static let taskEditTitle = NSLocalizedString("task.details.editTitle", comment: "")
    static let errorEnterTaskTitle = NSLocalizedString("task.details.error.enterTitle", comment: "")
    static let taskTitlePlaceholder = NSLocalizedString("task.details.placeholder.title", comment: "")
    static let taskDescriptionPlaceholder = NSLocalizedString("task.details.placeholder.description", comment: "")

    // MARK: - Task Content

    static let taskWithoutDescription = NSLocalizedString("task.withoutDescription", comment: "")
    static let taskCompleted = NSLocalizedString("task.status.completed", comment: "")
    static let taskNotCompleted = NSLocalizedString("task.status.notCompleted", comment: "")

    // MARK: - Task Actions

    static let actionEdit = NSLocalizedString("task.action.edit", comment: "")
    static let actionShare = NSLocalizedString("task.action.share", comment: "")
    static let actionDelete = NSLocalizedString("task.action.delete", comment: "")
    static let actionDone = NSLocalizedString("task.action.done", comment: "")
    static let actionRestore = NSLocalizedString("task.action.restore", comment: "")

    // MARK: - Errors

    static let errorTitle = NSLocalizedString("error.title", comment: "")
    static let errorInvalidURL = NSLocalizedString("error.invalidURL", comment: "")
    static let errorNoData = NSLocalizedString("error.noData", comment: "")
    static let errorDecodingFailed = NSLocalizedString("error.decodingFailed", comment: "")
    static let errorObjectNotFound = NSLocalizedString("error.objectNotFound", comment: "")
    static let errorPersistenceFailedFormat = NSLocalizedString("error.persistenceFailed.format", comment: "")
    static let errorNetworkFailedFormat = NSLocalizedString("error.networkFailed.format", comment: "")

    static func errorPersistence(_ message: String) -> String {
        String(format: errorPersistenceFailedFormat, message)
    }

    static func errorNetwork(_ message: String) -> String {
        String(format: errorNetworkFailedFormat, message)
    }

    // MARK: - Network

    static let networkIncorrectResponse = NSLocalizedString("network.incorrectResponse", comment: "")

    // MARK: - Voice Search

    static let voiceSearchPermissionDenied = NSLocalizedString("voiceSearch.permissionDenied", comment: "")
    static let voiceSearchUnavailable = NSLocalizedString("voiceSearch.unavailable", comment: "")
    static let voiceSearchAudioSessionFailed = NSLocalizedString("voiceSearch.audioSessionFailed", comment: "")
    static let voiceSearchStartFailed = NSLocalizedString("voiceSearch.startFailed", comment: "")
}
