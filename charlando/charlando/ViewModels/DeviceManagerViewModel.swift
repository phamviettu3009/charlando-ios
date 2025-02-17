//
//  DeviceManagerViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 15/04/2024.
//

import Foundation
import SwiftUI
import CoreData

class DeviceManagerViewModel: ViewModel {
    private let coreDataProvider = CoreDataProvider.shared
    private var context: NSManagedObjectContext
    
    private let authenticationRepository: AuthenticationRepository = AuthenticationRepositoryImpl.shared
    
    enum LoadType: LoadCase {
        case LoadingListDevice
    }
    
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var isLoadingListDevice: Bool = false
    @Published var devices: [Device] = []
    
    init() {
        context = coreDataProvider.newContext
        Task { await fetchListDevice() }
    }
    
    // MARK: - FETCH DEVICES
    
    func fetchListDevice() async {
        loader(true, LoadType.LoadingListDevice)
        do {
            let devices = try await authenticationRepository.getDevices()
            DispatchQueue.main.async {
                self.devices = devices
            }
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.LoadingListDevice)
    }
    
    // MARK: - LOGOUT
    
    func logout(deviceID: String, success: @escaping () -> Void) async {
        do {
            try await authenticationRepository.logout(deviceID: deviceID)
            let curentDeviceID = await UIDevice.current.identifierForVendor ?? UUID()
            if (curentDeviceID.uuidString.lowercased() == deviceID) {
                APIManager.shared.removeAll()
                success()
            }
            if let index = devices.firstIndex(where: { $0.deviceID == deviceID }) {
                DispatchQueue.main.async {
                    self.devices[index].login = false
                }
            }
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func logoutAll(success: @escaping () -> Void) async {
        do {
            try await authenticationRepository.logoutAll()
            APIManager.shared.removeAll()
            success()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
}

extension DeviceManagerViewModel {
    private func putMessage(_ message: String?, _ messageColor: Color = .red) {
        DispatchQueue.main.async {
            self.message = message
            self.messageColor = messageColor
        }
    }
    
    private func loader(_ value: Bool, _ caseLoader: LoadCase? = nil) {
        DispatchQueue.main.async {
            switch caseLoader! {
            case LoadType.LoadingListDevice:
                self.isLoadingListDevice = value
                break
            default:
                break
            }
        }
    }
}
