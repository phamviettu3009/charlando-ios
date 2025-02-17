//
//  SettingViewModel.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 14/11/2023.
//

import Foundation
import SwiftUI
import CoreData
import FirebaseMessaging
import FormValidator

class SettingViewModel: ViewModel {
    private let coreDataProvider = CoreDataProvider.shared
    private var context: NSManagedObjectContext
    
    private let userRepository: UserRepository = UserRepositoryImpl.shared
    private let resourceRepository: ResourceRepository = ResourceRepositoryImpl.shared
    private let authenticationRepository: AuthenticationRepository = AuthenticationRepositoryImpl.shared
    
    enum LoadType: LoadCase {
        case LoadingUser
        case UpdatingUser
        case Logout
    }
    
    @Published var validatorManager = FormManager(validationType: .immediate)
    @Published var message: String? = nil
    @Published var messageColor: Color = .red
    
    @Published var isLoadingUser: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isOpenSheetLanguage: Bool = false
    @Published var fullName: String? = nil
    @Published var email: String? = nil
    @Published var phone: String? = nil
    @Published var countryCode: String? = nil
    @Published var gender: String? = nil
    @Published var dob: Date? = nil
    @Published var avatarUrl: String? = nil
    @Published var avatarPhoto: PhotoItem? = nil
    @Published var coverPhotoUrl: String? = nil
    @Published var coverPhoto: PhotoItem? = nil
    @Published var isOpenSheetEditInfo: Bool = false
    @Published var isUpdatingUser: Bool = false
    @Published var isLogout: Bool = false
    @Published var publicEmail: Bool = false
    @Published var publicPhoneNumber: Bool = false
    @Published var publicGender: Bool = false
    @Published var publicDob: Bool = false
    @Published var country: Country = Country(countryName: "Afghanistan", countryCode: "+93", flagSymbol: "🇦🇫", languageCode: "fa_AF")
    
    // MARK: - VALIDATION FILED
    
    @FormField(validator: CompositeValidator(validators: [
        NonEmptyValidator(message: LocalizedStringKey("full_name_is_not_empty").stringValue()),
        CountValidator(count: 25, type: .lessThan, message: LocalizedStringKey("full_name_is_to_long").stringValue())
    ], type: .all, strategy: .all))
    var fullNameField: String = ""
    lazy var fullNameValidationContainer = _fullNameField.validation(manager: validatorManager)
    
    
    @FormField(validator: CompositeValidator(validators: [
        PatternValidator(
            pattern: try! NSRegularExpression(pattern: phonePattern, options: .caseInsensitive),
            message: LocalizedStringKey("invalid_phone_number").stringValue()
        )
    ], type: .all, strategy: .all))
    var phoneField: String = ""
    lazy var phoneValidationContainer = _phoneField.validation(manager: validatorManager)
    
    @FormField(validator: CompositeValidator(validators: [
        NonEmptyValidator(message: LocalizedStringKey("email_is_not_empty").stringValue()),
        EmailValidator(message: LocalizedStringKey("incorrect_email_format").stringValue())
    ], type: .all, strategy: .all))
    var emailField: String = ""
    lazy var emailValidationContainer = _emailField.validation(manager: validatorManager)
    
    @Published var genderField: String? = nil
    
    init() {
        context = coreDataProvider.newContext
        fetchUserFromCoreData()
        Task { await fetchUserFromAPIs() }
    }
    
    // MARK: - FETCH USER
    
    func fetchUserFromCoreData() {
        let ownerRequest = OwnerEntity.findOwner()
        if let ownerEntity: OwnerEntity = try? context.fetch(ownerRequest).first {
            let user = ownerEntity.asUser()
            DispatchQueue.main.async {
                self.fullName = user.fullName
                self.fullNameField = user.fullName
                self.avatarUrl = user.avatar
                self.emailField = user.email ?? ""
                self.phoneField = user.phone ?? ""
                self.genderField = user.gender ?? nil
                self.dob = user.dob?.asDate()
                self.coverPhotoUrl = user.coverPhoto
                self.email = user.email
                self.phone = user.phone
                self.gender = user.gender
                self.countryCode = user.countryCode
                
                if let languageCode = user.languageCode {
                    self.country = self.findCountryByLanguageCode(languageCode: languageCode)
                }
                
                if let publicEmail = user.setting?.publicEmail {
                    self.publicEmail = publicEmail
                }
                
                if let publicPhone = user.setting?.publicPhone {
                    self.publicPhoneNumber = publicPhone
                }
                
                if let publicGender = user.setting?.publicGender {
                    self.publicGender = publicGender
                }
                
                if let publicDob = user.setting?.publicDob {
                    self.publicDob = publicDob
                }
            }
        }
    }
    
    func fetchUserFromAPIs() async {
        
        loader(true, LoadType.LoadingUser)
        do {
            let user = try await userRepository.getUser()
            let _ = user.asOwner(context: context)
            try? context.performAndWait {
                try coreDataProvider.persist(in: context)
            }
            
            fetchUserFromCoreData()
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        loader(false, LoadType.LoadingUser)
    }
    
    // MARK: - SAVE USER
    
    func saveUser() async {
        loader(true, LoadType.UpdatingUser)
        
        var avatarResource: String? = nil
        var coverResource: String? = nil
        
        if let avatarPhoto = avatarPhoto {
            avatarResource = await uploadImage(photoItem: avatarPhoto)
        }
        
        if let coverPhoto = coverPhoto {
            coverResource = await uploadImage(photoItem: coverPhoto)
        }
        
        let payload = UserUpdateRequest(
            fullName: fullNameField,
            avatar: avatarResource,
            coverPhoto: coverResource,
            gender: genderField,
            dob: dob?.ISO8601Format(),
            phone: phoneField,
            email: emailField,
            countryCode: country.countryCode,
            languageCode: country.languageCode
        )
        
        await updateUser(payload)
        await updateSetting()
        
        await fetchUserFromAPIs()
        
        loader(false, LoadType.UpdatingUser)
    }
    
    private func updateUser(_ userUpdateRequest: UserUpdateRequest) async {
        do {
            let _ = try await userRepository.updateUser(userUpdateRequest: userUpdateRequest)
            DispatchQueue.main.async {
                self.isOpenSheetEditInfo = false
            }
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    func updateSetting() async {
        do {
            let payload = Setting(
                publicEmail: publicEmail,
                publicGender: publicGender,
                publicPhone: publicPhoneNumber,
                publicDob: publicDob
            )
            
            let _ = try await userRepository.updateSetting(settingUpdateRequest: payload)
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
    }
    
    private func uploadImage(photoItem: PhotoItem) async -> String? {
        do {
            var multipart = MultipartRequest()
            let fileName = UUID().uuidString
            let extensionFile = photoItem.extensionFile
            let fileMimeType = photoItem.mimeType
            let data = photoItem.data
            
            multipart.add(
                key: "files",
                fileName: "\(fileName).\(extensionFile)",
                fileMimeType: fileMimeType,
                fileData: data
            )
            
            let resources = try await resourceRepository.uploadAvatar(multipart: multipart)
            guard let resourceID = resources.first?.id.uuidString.lowercased() else { return nil }
            return resourceID
        } catch {
            if case let ResultError.apiError(apiError) = error {
                putMessage(apiError?.message)
            }
        }
        return nil
    }
    
    // MARK: - LOGOUT
    
    func logout(success: @escaping () -> Void) async {
        loader(true, LoadType.Logout)
        do {
            try await Messaging.messaging().deleteToken()
            let deviceID = await UIDevice.current.identifierForVendor ?? UUID()
            
            try await authenticationRepository.logout(deviceID: deviceID.uuidString.lowercased())
            APIManager.shared.removeToken()
            
            try KeyChainManager.save(
                service: SERVICE_NAME,
                account: ACCOUNT_NAME,
                data: "".data(using: .utf8)!
            )
            
            try coreDataProvider.deleteAll(entityName: "Channel", in: context)
            try coreDataProvider.deleteAll(entityName: "Message", in: context)
            try coreDataProvider.deleteAll(entityName: "Event", in: context)
            try coreDataProvider.deleteAll(entityName: "User", in: context)
            try coreDataProvider.deleteAll(entityName: "Owner", in: context)
            try coreDataProvider.deleteAll(entityName: "LinkPreview", in: context)
            try coreDataProvider.deleteAll(entityName: "UserDetail", in: context)
            ImageCache.shared.clearCache()
            SocketIOManager.shared.disconnect()
            success()
        } catch {
            APIManager.shared.removeToken()
            
            try? KeyChainManager.save(
                service: SERVICE_NAME,
                account: ACCOUNT_NAME,
                data: "".data(using: .utf8)!
            )
            
            try? coreDataProvider.deleteAll(entityName: "Channel", in: context)
            try? coreDataProvider.deleteAll(entityName: "Message", in: context)
            try? coreDataProvider.deleteAll(entityName: "Event", in: context)
            try? coreDataProvider.deleteAll(entityName: "User", in: context)
            try? coreDataProvider.deleteAll(entityName: "Owner", in: context)
            try? coreDataProvider.deleteAll(entityName: "LinkPreview", in: context)
            try? coreDataProvider.deleteAll(entityName: "UserDetail", in: context)
            ImageCache.shared.clearCache()
            
            DispatchQueue.main.async {
                self.errorMessage = "Delete keychain failure!"
            }
            
            success()
        }
        loader(false, LoadType.Logout)
    }
}

extension SettingViewModel {
    func findCountryByLanguageCode(languageCode: String = systemLanguageCode) -> Country {
        let countrySystem = countryOptions.first { country in
            country.languageCode == languageCode
        }
        
        return countrySystem ?? Country(countryName: "Afghanistan", countryCode: "+93", flagSymbol: "🇦🇫", languageCode: "fa_AF")
    }
    
    func putMessage(_ message: String?, _ messageColor: Color = .red) {
        DispatchQueue.main.async {
            self.message = message
            self.messageColor = messageColor
        }
    }
    
    func loader(_ value: Bool, _ caseLoader: LoadCase? = nil) {
        DispatchQueue.main.async {
            switch caseLoader! {
            case LoadType.LoadingUser:
                self.isLoadingUser = value
            case LoadType.UpdatingUser:
                self.isUpdatingUser = value
            case LoadType.Logout:
                self.isLogout = value
            default:
                break
            }
            
        }
    }
    
    func resetData() {
        DispatchQueue.main.async {
            self.message = nil
            self.messageColor = .red
            self.isOpenSheetLanguage = false
            self.isLoadingUser = false
            self.errorMessage = nil
            self.fullName = nil
            self.fullNameField = ""
            self.avatarUrl = nil
            self.avatarPhoto = nil
            self.isOpenSheetEditInfo = false
            self.isUpdatingUser = false
        }
    }
}

let phonePattern = "^[+]?[0-9]{1,4}?[-.\\s]?\\(?[0-9]{1,3}?\\)?[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{1,9}$|^$";
