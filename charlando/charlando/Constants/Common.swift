//
//  Common.swift
//  flow-ios
//
//  Created by Phạm Việt Tú on 17/11/2023.
//

import Foundation

let SIZE_PER_PAGE = 10
let SIZE_PER_PAGE_MESSAGE = 20

let systemLanguageCode = Locale.current.identifier

let languages: [LanguageApp] = [
    LanguageApp(id: 1, key: "default", label: NSLocalizedString("default", comment: ""), icon: "checkmark"),
    LanguageApp(id: 2, key: "en", label: "English", icon: "checkmark"),
    LanguageApp(id: 3, key: "vi", label: "Tiếng việt", icon: "checkmark")
]

class RegisterSide {
    static let REGISTER_EMAIL = ""
    static let VERIFICATION_ACCOUNT = "UNVERIFIED"
}

class FriendStatus {
    static let FRIEND = "FRIEND"
    static let UNFRIEND = "UNFRIEND"
    static let WAIT_FOR_CONFIRMATION = "WAIT_FOR_CONFIRMATION"
    static let FRIEND_REQUEST_SENT = "FRIEND_REQUEST_SENT"
}

class ChannelType {
    static let SINGLE_TYPE = 1
    static let GROUP_TYPE = 2
}

class MessageType {
    static let MESSAGE = 1
    static let ATTACHMENTS = 2
    static let ICON_MESSAGE = 3
}

enum SideWayMessageItem {
    case LEFT, RIGHT
}

class MessageRecordStatus {
    static let DELETE = "DELETE"
}

class AttachmentType {
    static let IMAGE = 1
    static let VIDEO = 2
    static let AUDIO = 3
    static let OTHER = 4
}

class ChannelRole {
    static let OWNER = "OWNER"
    static let ADMIN = "ADMIN"
    static let MEMBER = "MEMBER"
}

let countryOptions: [Country] = [
    Country(countryName: "Afghanistan", countryCode: "+93", flagSymbol: "🇦🇫", languageCode: "fa_AF"),
    Country(countryName: "Albania", countryCode: "+355", flagSymbol: "🇦🇱", languageCode: "sq_AL"),
    Country(countryName: "Algeria", countryCode: "+213", flagSymbol: "🇩🇿", languageCode: "ar_DZ"),
    Country(countryName: "American Samoa", countryCode: "+1-684", flagSymbol: "🇦🇸", languageCode: "en_AS"),
    Country(countryName: "Andorra", countryCode: "+376", flagSymbol: "🇦🇩", languageCode: "ca_AD"),
    Country(countryName: "Angola", countryCode: "+244", flagSymbol: "🇦🇴", languageCode: "pt_AO"),
    Country(countryName: "Anguilla", countryCode: "+1-264", flagSymbol: "🇦🇮", languageCode: "en_AI"),
    Country(countryName: "Antarctica", countryCode: "+672", flagSymbol: "🇦🇶", languageCode: ""),
    Country(countryName: "Antigua and Barbuda", countryCode: "+1-268", flagSymbol: "🇦🇬", languageCode: "en_AG"),
    Country(countryName: "Argentina", countryCode: "+54", flagSymbol: "🇦🇷", languageCode: "es_AR"),
    Country(countryName: "Armenia", countryCode: "+374", flagSymbol: "🇦🇲", languageCode: "hy_AM"),
    Country(countryName: "Aruba", countryCode: "+297", flagSymbol: "🇦🇼", languageCode: "nl_AW"),
    Country(countryName: "Australia", countryCode: "+61", flagSymbol: "🇦🇺", languageCode: "en_AU"),
    Country(countryName: "Austria", countryCode: "+43", flagSymbol: "🇦🇹", languageCode: "de_AT"),
    Country(countryName: "Azerbaijan", countryCode: "+994", flagSymbol: "🇦🇿", languageCode: "az_AZ"),
    Country(countryName: "Bahamas", countryCode: "+1-242", flagSymbol: "🇧🇸", languageCode: "en_BS"),
    Country(countryName: "Bahrain", countryCode: "+973", flagSymbol: "🇧🇭", languageCode: "ar_BH"),
    Country(countryName: "Bangladesh", countryCode: "+880", flagSymbol: "🇧🇩", languageCode: "bn_BD"),
    Country(countryName: "Barbados", countryCode: "+1-246", flagSymbol: "🇧🇧", languageCode: "en_BB"),
    Country(countryName: "Belarus", countryCode: "+375", flagSymbol: "🇧🇾", languageCode: "be_BY"),
    Country(countryName: "Belgium", countryCode: "+32", flagSymbol: "🇧🇪", languageCode: "nl_BE"),
    Country(countryName: "Belize", countryCode: "+501", flagSymbol: "🇧🇿", languageCode: "en_BZ"),
    Country(countryName: "Benin", countryCode: "+229", flagSymbol: "🇧🇯", languageCode: "fr_BJ"),
    Country(countryName: "Bermuda", countryCode: "+1-441", flagSymbol: "🇧🇲", languageCode: "en_BM"),
    Country(countryName: "Bhutan", countryCode: "+975", flagSymbol: "🇧🇹", languageCode: "dz_BT"),
    Country(countryName: "Bolivia", countryCode: "+591", flagSymbol: "🇧🇴", languageCode: "es_BO"),
    Country(countryName: "Bosnia and Herzegovina", countryCode: "+387", flagSymbol: "🇧🇦", languageCode: "bs_BA"),
    Country(countryName: "Botswana", countryCode: "+267", flagSymbol: "🇧🇼", languageCode: "en_BW"),
    Country(countryName: "Brazil", countryCode: "+55", flagSymbol: "🇧🇷", languageCode: "pt_BR"),
    Country(countryName: "British Indian Ocean Territory", countryCode: "+246", flagSymbol: "🇮🇴", languageCode: "en_IO"),
    Country(countryName: "British Virgin Islands", countryCode: "+1-284", flagSymbol: "🇻🇬", languageCode: "en_VG"),
    Country(countryName: "Brunei", countryCode: "+673", flagSymbol: "🇧🇳", languageCode: "ms_BN"),
    Country(countryName: "Bulgaria", countryCode: "+359", flagSymbol: "🇧🇬", languageCode: "bg_BG"),
    Country(countryName: "Burkina Faso", countryCode: "+226", flagSymbol: "🇧🇫", languageCode: "fr_BF"),
    Country(countryName: "Burundi", countryCode: "+257", flagSymbol: "🇧🇮", languageCode: "fr_BI"),
    Country(countryName: "Cambodia", countryCode: "+855", flagSymbol: "🇰🇭", languageCode: "km_KH"),
    Country(countryName: "Cameroon", countryCode: "+237", flagSymbol: "🇨🇲", languageCode: "en_CM"),
    Country(countryName: "Canada", countryCode: "+1", flagSymbol: "🇨🇦", languageCode: "en_CA"),
    Country(countryName: "Cape Verde", countryCode: "+238", flagSymbol: "🇨🇻", languageCode: "pt_CV"),
    Country(countryName: "Caribbean Netherlands", countryCode: "+599", flagSymbol: "🇧🇶", languageCode: "nl_BQ"),
    Country(countryName: "Cayman Islands", countryCode: "+1-345", flagSymbol: "🇰🇾", languageCode: "en_KY"),
    Country(countryName: "Central African Republic", countryCode: "+236", flagSymbol: "🇨🇫", languageCode: "fr_CF"),
    Country(countryName: "Chad", countryCode: "+235", flagSymbol: "🇹🇩", languageCode: "fr_TD"),
    Country(countryName: "Chile", countryCode: "+56", flagSymbol: "🇨🇱", languageCode: "es_CL"),
    Country(countryName: "China", countryCode: "+86", flagSymbol: "🇨🇳", languageCode: "zh_CN"),
    Country(countryName: "Christmas Island", countryCode: "+61", flagSymbol: "🇨🇽", languageCode: "en_CX"),
    Country(countryName: "Cocos Islands", countryCode: "+61", flagSymbol: "🇨🇨", languageCode: "en_CC"),
    Country(countryName: "Colombia", countryCode: "+57", flagSymbol: "🇨🇴", languageCode: "es_CO"),
    Country(countryName: "Comoros", countryCode: "+269", flagSymbol: "🇰🇲", languageCode: "ar_KM"),
    Country(countryName: "Congo", countryCode: "+242", flagSymbol: "🇨🇬", languageCode: "fr_CG"),
    Country(countryName: "Cook Islands", countryCode: "+682", flagSymbol: "🇨🇰", languageCode: "en_CK"),
    Country(countryName: "Costa Rica", countryCode: "+506", flagSymbol: "🇨🇷", languageCode: "es_CR"),
    Country(countryName: "Croatia", countryCode: "+385", flagSymbol: "🇭🇷", languageCode: "hr_HR"),
    Country(countryName: "Cuba", countryCode: "+53", flagSymbol: "🇨🇺", languageCode: "es_CU"),
    Country(countryName: "Curaçao", countryCode: "+599", flagSymbol: "🇨🇼", languageCode: "nl_CW"),
    Country(countryName: "Cyprus", countryCode: "+357", flagSymbol: "🇨🇾", languageCode: "el_CY"),
    Country(countryName: "Czech Republic", countryCode: "+420", flagSymbol: "🇨🇿", languageCode: "cs_CZ"),
    Country(countryName: "Democratic Republic of the Congo", countryCode: "+243", flagSymbol: "🇨🇩", languageCode: "fr_CD"),
    Country(countryName: "Denmark", countryCode: "+45", flagSymbol: "🇩🇰", languageCode: "da_DK"),
    Country(countryName: "Djibouti", countryCode: "+253", flagSymbol: "🇩🇯", languageCode: "fr_DJ"),
    Country(countryName: "Dominica", countryCode: "+1-767", flagSymbol: "🇩🇲", languageCode: "en_DM"),
    Country(countryName: "Dominican Republic", countryCode: "+1-809, +1-829, +1-849", flagSymbol: "🇩🇴", languageCode: "es_DO"),
    Country(countryName: "Ecuador", countryCode: "+593", flagSymbol: "🇪🇨", languageCode: "es_EC"),
    Country(countryName: "Egypt", countryCode: "+20", flagSymbol: "🇪🇬", languageCode: "ar_EG"),
    Country(countryName: "El Salvador", countryCode: "+503", flagSymbol: "🇸🇻", languageCode: "es_SV"),
    Country(countryName: "Equatorial Guinea", countryCode: "+240", flagSymbol: "🇬🇶", languageCode: "es_GQ"),
    Country(countryName: "Eritrea", countryCode: "+291", flagSymbol: "🇪🇷", languageCode: "ti_ER"),
    Country(countryName: "Estonia", countryCode: "+372", flagSymbol: "🇪🇪", languageCode: "et_EE"),
    Country(countryName: "Eswatini", countryCode: "+268", flagSymbol: "🇸🇿", languageCode: "en_SZ"),
    Country(countryName: "Ethiopia", countryCode: "+251", flagSymbol: "🇪🇹", languageCode: "am_ET"),
    Country(countryName: "Falkland Islands", countryCode: "+500", flagSymbol: "🇫🇰", languageCode: "en_FK"),
    Country(countryName: "Faroe Islands", countryCode: "+298", flagSymbol: "🇫🇴", languageCode: "fo_FO"),
    Country(countryName: "Fiji", countryCode: "+679", flagSymbol: "🇫🇯", languageCode: "en_FJ"),
    Country(countryName: "Finland", countryCode: "+358", flagSymbol: "🇫🇮", languageCode: "fi_FI"),
    Country(countryName: "France", countryCode: "+33", flagSymbol: "🇫🇷", languageCode: "fr_FR"),
    Country(countryName: "French Guiana", countryCode: "+594", flagSymbol: "🇬🇫", languageCode: "fr_GF"),
    Country(countryName: "French Polynesia", countryCode: "+689", flagSymbol: "🇵🇫", languageCode: "fr_PF"),
    Country(countryName: "Gabon", countryCode: "+241", flagSymbol: "🇬🇦", languageCode: "fr_GA"),
    Country(countryName: "Gambia", countryCode: "+220", flagSymbol: "🇬🇲", languageCode: "en_GM"),
    Country(countryName: "Georgia", countryCode: "+995", flagSymbol: "🇬🇪", languageCode: "ka_GE"),
    Country(countryName: "Germany", countryCode: "+49", flagSymbol: "🇩🇪", languageCode: "de_DE"),
    Country(countryName: "Ghana", countryCode: "+233", flagSymbol: "🇬🇭", languageCode: "en_GH"),
    Country(countryName: "Gibraltar", countryCode: "+350", flagSymbol: "🇬🇮", languageCode: "en_GI"),
    Country(countryName: "Greece", countryCode: "+30", flagSymbol: "🇬🇷", languageCode: "el_GR"),
    Country(countryName: "Greenland", countryCode: "+299", flagSymbol: "🇬🇱", languageCode: "kl_GL"),
    Country(countryName: "Grenada", countryCode: "+1-473", flagSymbol: "🇬🇩", languageCode: "en_GD"),
    Country(countryName: "Guadeloupe", countryCode: "+590", flagSymbol: "🇬🇵", languageCode: "fr_GP"),
    Country(countryName: "Guam", countryCode: "+1-671", flagSymbol: "🇬🇺", languageCode: "en_GU"),
    Country(countryName: "Guatemala", countryCode: "+502", flagSymbol: "🇬🇹", languageCode: "es_GT"),
    Country(countryName: "Guernsey", countryCode: "+44-1481", flagSymbol: "🇬🇬", languageCode: "en_GG"),
    Country(countryName: "Guinea", countryCode: "+224", flagSymbol: "🇬🇳", languageCode: "fr_GN"),
    Country(countryName: "Guinea-Bissau", countryCode: "+245", flagSymbol: "🇬🇼", languageCode: "pt_GW"),
    Country(countryName: "Guyana", countryCode: "+592", flagSymbol: "🇬🇾", languageCode: "en_GY"),
    Country(countryName: "Haiti", countryCode: "+509", flagSymbol: "🇭🇹", languageCode: "fr_HT"),
    Country(countryName: "Honduras", countryCode: "+504", flagSymbol: "🇭🇳", languageCode: "es_HN"),
    Country(countryName: "Hong Kong", countryCode: "+852", flagSymbol: "🇭🇰", languageCode: "zh_HK"),
    Country(countryName: "Hungary", countryCode: "+36", flagSymbol: "🇭🇺", languageCode: "hu_HU"),
    Country(countryName: "Iceland", countryCode: "+354", flagSymbol: "🇮🇸", languageCode: "is_IS"),
    Country(countryName: "India", countryCode: "+91", flagSymbol: "🇮🇳", languageCode: "hi_IN"),
    Country(countryName: "Indonesia", countryCode: "+62", flagSymbol: "🇮🇩", languageCode: "id_ID"),
    Country(countryName: "Iran", countryCode: "+98", flagSymbol: "🇮🇷", languageCode: "fa_IR"),
    Country(countryName: "Iraq", countryCode: "+964", flagSymbol: "🇮🇶", languageCode: "ar_IQ"),
    Country(countryName: "Ireland", countryCode: "+353", flagSymbol: "🇮🇪", languageCode: "en_IE"),
    Country(countryName: "Isle of Man", countryCode: "+44-1624", flagSymbol: "🇮🇲", languageCode: "en_IM"),
    Country(countryName: "Israel", countryCode: "+972", flagSymbol: "🇮🇱", languageCode: "he_IL"),
    Country(countryName: "Italy", countryCode: "+39", flagSymbol: "🇮🇹", languageCode: "it_IT"),
    Country(countryName: "Jamaica", countryCode: "+1-876", flagSymbol: "🇯🇲", languageCode: "en_JM"),
    Country(countryName: "Japan", countryCode: "+81", flagSymbol: "🇯🇵", languageCode: "ja_JP"),
    Country(countryName: "Jersey", countryCode: "+44-1534", flagSymbol: "🇯🇪", languageCode: "en_JE"),
    Country(countryName: "Jordan", countryCode: "+962", flagSymbol: "🇯🇴", languageCode: "ar_JO"),
    Country(countryName: "Kazakhstan", countryCode: "+7", flagSymbol: "🇰🇿", languageCode: "ru_KZ"),
    Country(countryName: "Kenya", countryCode: "+254", flagSymbol: "🇰🇪", languageCode: "en_KE"),
    Country(countryName: "Kiribati", countryCode: "+686", flagSymbol: "🇰🇮", languageCode: "en_KI"),
    Country(countryName: "Kosovo", countryCode: "+383", flagSymbol: "🇽🇰", languageCode: "sq_XK"),
    Country(countryName: "Kuwait", countryCode: "+965", flagSymbol: "🇰🇼", languageCode: "ar_KW"),
    Country(countryName: "Kyrgyzstan", countryCode: "+996", flagSymbol: "🇰🇬", languageCode: "ky_KG"),
    Country(countryName: "Laos", countryCode: "+856", flagSymbol: "🇱🇦", languageCode: "lo_LA"),
    Country(countryName: "Latvia", countryCode: "+371", flagSymbol: "🇱🇻", languageCode: "lv_LV"),
    Country(countryName: "Lebanon", countryCode: "+961", flagSymbol: "🇱🇧", languageCode: "ar_LB"),
    Country(countryName: "Lesotho", countryCode: "+266", flagSymbol: "🇱🇸", languageCode: "en_LS"),
    Country(countryName: "Liberia", countryCode: "+231", flagSymbol: "🇱🇷", languageCode: "en_LR"),
    Country(countryName: "Libya", countryCode: "+218", flagSymbol: "🇱🇾", languageCode: "ar_LY"),
    Country(countryName: "Liechtenstein", countryCode: "+423", flagSymbol: "🇱🇮", languageCode: "de_LI"),
    Country(countryName: "Lithuania", countryCode: "+370", flagSymbol: "🇱🇹", languageCode: "lt_LT"),
    Country(countryName: "Luxembourg", countryCode: "+352", flagSymbol: "🇱🇺", languageCode: "fr_LU"),
    Country(countryName: "Macau", countryCode: "+853", flagSymbol: "🇲🇴", languageCode: "zh_MO"),
    Country(countryName: "Madagascar", countryCode: "+261", flagSymbol: "🇲🇬", languageCode: "mg_MG"),
    Country(countryName: "Malawi", countryCode: "+265", flagSymbol: "🇲🇼", languageCode: "en_MW"),
    Country(countryName: "Malaysia", countryCode: "+60", flagSymbol: "🇲🇾", languageCode: "ms_MY"),
    Country(countryName: "Maldives", countryCode: "+960", flagSymbol: "🇲🇻", languageCode: "dv_MV"),
    Country(countryName: "Mali", countryCode: "+223", flagSymbol: "🇲🇱", languageCode: "fr_ML"),
    Country(countryName: "Malta", countryCode: "+356", flagSymbol: "🇲🇹", languageCode: "mt_MT"),
    Country(countryName: "Marshall Islands", countryCode: "+692", flagSymbol: "🇲🇭", languageCode: "en_MH"),
    Country(countryName: "Martinique", countryCode: "+596", flagSymbol: "🇲🇶", languageCode: "fr_MQ"),
    Country(countryName: "Mauritania", countryCode: "+222", flagSymbol: "🇲🇷", languageCode: "ar_MR"),
    Country(countryName: "Mauritius", countryCode: "+230", flagSymbol: "🇲🇺", languageCode: "en_MU"),
    Country(countryName: "Mayotte", countryCode: "+262", flagSymbol: "🇾🇹", languageCode: "fr_YT"),
    Country(countryName: "Mexico", countryCode: "+52", flagSymbol: "🇲🇽", languageCode: "es_MX"),
    Country(countryName: "Micronesia", countryCode: "+691", flagSymbol: "🇫🇲", languageCode: "en_FM"),
    Country(countryName: "Moldova", countryCode: "+373", flagSymbol: "🇲🇩", languageCode: "ro_MD"),
    Country(countryName: "Monaco", countryCode: "+377", flagSymbol: "🇲🇨", languageCode: "fr_MC"),
    Country(countryName: "Mongolia", countryCode: "+976", flagSymbol: "🇲🇳", languageCode: "mn_MN"),
    Country(countryName: "Montenegro", countryCode: "+382", flagSymbol: "🇲🇪", languageCode: "sr_ME"),
    Country(countryName: "Montserrat", countryCode: "+1-664", flagSymbol: "🇲🇸", languageCode: "en_MS"),
    Country(countryName: "Morocco", countryCode: "+212", flagSymbol: "🇲🇦", languageCode: "ar_MA"),
    Country(countryName: "Mozambique", countryCode: "+258", flagSymbol: "🇲🇿", languageCode: "pt_MZ"),
    Country(countryName: "Myanmar", countryCode: "+95", flagSymbol: "🇲🇲", languageCode: "my_MM"),
    Country(countryName: "Namibia", countryCode: "+264", flagSymbol: "🇳🇦", languageCode: "en_NA"),
    Country(countryName: "Nauru", countryCode: "+674", flagSymbol: "🇳🇷", languageCode: "en_NR"),
    Country(countryName: "Nepal", countryCode: "+977", flagSymbol: "🇳🇵", languageCode: "ne_NP"),
    Country(countryName: "Netherlands", countryCode: "+31", flagSymbol: "🇳🇱", languageCode: "nl_NL"),
    Country(countryName: "New Caledonia", countryCode: "+687", flagSymbol: "🇳🇨", languageCode: "fr_NC"),
    Country(countryName: "New Zealand", countryCode: "+64", flagSymbol: "🇳🇿", languageCode: "en_NZ"),
    Country(countryName: "Nicaragua", countryCode: "+505", flagSymbol: "🇳🇮", languageCode: "es_NI"),
    Country(countryName: "Niger", countryCode: "+227", flagSymbol: "🇳🇪", languageCode: "fr_NE"),
    Country(countryName: "Nigeria", countryCode: "+234", flagSymbol: "🇳🇬", languageCode: "en_NG"),
    Country(countryName: "Niue", countryCode: "+683", flagSymbol: "🇳🇺", languageCode: "en_NU"),
    Country(countryName: "Norfolk Island", countryCode: "+672", flagSymbol: "🇳🇫", languageCode: "en_NF"),
    Country(countryName: "North Korea", countryCode: "+850", flagSymbol: "🇰🇵", languageCode: "ko_KP"),
    Country(countryName: "North Macedonia", countryCode: "+389", flagSymbol: "🇲🇰", languageCode: "mk_MK"),
    Country(countryName: "Northern Mariana Islands", countryCode: "+1-670", flagSymbol: "🇲🇵", languageCode: "en_MP"),
    Country(countryName: "Norway", countryCode: "+47", flagSymbol: "🇳🇴", languageCode: "no_NO"),
    Country(countryName: "Oman", countryCode: "+968", flagSymbol: "🇴🇲", languageCode: "ar_OM"),
    Country(countryName: "Pakistan", countryCode: "+92", flagSymbol: "🇵🇰", languageCode: "ur_PK"),
    Country(countryName: "Palau", countryCode: "+680", flagSymbol: "🇵🇼", languageCode: "en_PW"),
    Country(countryName: "Palestine", countryCode: "+970", flagSymbol: "🇵🇸", languageCode: "ar_PS"),
    Country(countryName: "Panama", countryCode: "+507", flagSymbol: "🇵🇦", languageCode: "es_PA"),
    Country(countryName: "Papua New Guinea", countryCode: "+675", flagSymbol: "🇵🇬", languageCode: "en_PG"),
    Country(countryName: "Paraguay", countryCode: "+595", flagSymbol: "🇵🇾", languageCode: "es_PY"),
    Country(countryName: "Peru", countryCode: "+51", flagSymbol: "🇵🇪", languageCode: "es_PE"),
    Country(countryName: "Philippines", countryCode: "+63", flagSymbol: "🇵🇭", languageCode: "en_PH"),
    Country(countryName: "Pitcairn Islands", countryCode: "+64", flagSymbol: "🇵🇳", languageCode: "en_PN"),
    Country(countryName: "Poland", countryCode: "+48", flagSymbol: "🇵🇱", languageCode: "pl_PL"),
    Country(countryName: "Portugal", countryCode: "+351", flagSymbol: "🇵🇹", languageCode: "pt_PT"),
    Country(countryName: "Puerto Rico", countryCode: "+1-787, +1-939", flagSymbol: "🇵🇷", languageCode: "es_PR"),
    Country(countryName: "Qatar", countryCode: "+974", flagSymbol: "🇶🇦", languageCode: "ar_QA"),
    Country(countryName: "Réunion", countryCode: "+262", flagSymbol: "🇷🇪", languageCode: "fr_RE"),
    Country(countryName: "Romania", countryCode: "+40", flagSymbol: "🇷🇴", languageCode: "ro_RO"),
    Country(countryName: "Russia", countryCode: "+7", flagSymbol: "🇷🇺", languageCode: "ru_RU"),
    Country(countryName: "Rwanda", countryCode: "+250", flagSymbol: "🇷🇼", languageCode: "rw_RW"),
    Country(countryName: "Saint Barthélemy", countryCode: "+590", flagSymbol: "🇧🇱", languageCode: "fr_BL"),
    Country(countryName: "Saint Helena", countryCode: "+290", flagSymbol: "🇸🇭", languageCode: "en_SH"),
    Country(countryName: "Saint Kitts and Nevis", countryCode: "+1-869", flagSymbol: "🇰🇳", languageCode: "en_KN"),
    Country(countryName: "Saint Lucia", countryCode: "+1-758", flagSymbol: "🇱🇨", languageCode: "en_LC"),
    Country(countryName: "Saint Martin", countryCode: "+590", flagSymbol: "🇲🇫", languageCode: "fr_MF"),
    Country(countryName: "Saint Pierre and Miquelon", countryCode: "+508", flagSymbol: "🇵🇲", languageCode: "fr_PM"),
    Country(countryName: "Saint Vincent and the Grenadines", countryCode: "+1-784", flagSymbol: "🇻🇨", languageCode: "en_VC"),
    Country(countryName: "Samoa", countryCode: "+685", flagSymbol: "🇼🇸", languageCode: "en_WS"),
    Country(countryName: "San Marino", countryCode: "+378", flagSymbol: "🇸🇲", languageCode: "it_SM"),
    Country(countryName: "São Tomé and Príncipe", countryCode: "+239", flagSymbol: "🇸🇹", languageCode: "pt_ST"),
    Country(countryName: "Saudi Arabia", countryCode: "+966", flagSymbol: "🇸🇦", languageCode: "ar_SA"),
    Country(countryName: "Senegal", countryCode: "+221", flagSymbol: "🇸🇳", languageCode: "fr_SN"),
    Country(countryName: "Serbia", countryCode: "+381", flagSymbol: "🇷🇸", languageCode: "sr_RS"),
    Country(countryName: "Seychelles", countryCode: "+248", flagSymbol: "🇸🇨", languageCode: "en_SC"),
    Country(countryName: "Sierra Leone", countryCode: "+232", flagSymbol: "🇸🇱", languageCode: "en_SL"),
    Country(countryName: "Singapore", countryCode: "+65", flagSymbol: "🇸🇬", languageCode: "en_SG"),
    Country(countryName: "Sint Maarten", countryCode: "+1-721", flagSymbol: "🇸🇽", languageCode: "nl_SX"),
    Country(countryName: "Slovakia", countryCode: "+421", flagSymbol: "🇸🇰", languageCode: "sk_SK"),
    Country(countryName: "Slovenia", countryCode: "+386", flagSymbol: "🇸🇮", languageCode: "sl_SI"),
    Country(countryName: "Solomon Islands", countryCode: "+677", flagSymbol: "🇸🇧", languageCode: "en_SB"),
    Country(countryName: "Somalia", countryCode: "+252", flagSymbol: "🇸🇴", languageCode: "so_SO"),
    Country(countryName: "South Africa", countryCode: "+27", flagSymbol: "🇿🇦", languageCode: "en_ZA"),
    Country(countryName: "South Korea", countryCode: "+82", flagSymbol: "🇰🇷", languageCode: "ko_KR"),
    Country(countryName: "South Sudan", countryCode: "+211", flagSymbol: "🇸🇸", languageCode: "en_SS"),
    Country(countryName: "Spain", countryCode: "+34", flagSymbol: "🇪🇸", languageCode: "es_ES"),
    Country(countryName: "Sri Lanka", countryCode: "+94", flagSymbol: "🇱🇰", languageCode: "si_LK"),
    Country(countryName: "Sudan", countryCode: "+249", flagSymbol: "🇸🇩", languageCode: "ar_SD"),
    Country(countryName: "Suriname", countryCode: "+597", flagSymbol: "🇸🇷", languageCode: "nl_SR"),
    Country(countryName: "Sweden", countryCode: "+46", flagSymbol: "🇸🇪", languageCode: "sv_SE"),
    Country(countryName: "Switzerland", countryCode: "+41", flagSymbol: "🇨🇭", languageCode: "de_CH"),
    Country(countryName: "Syria", countryCode: "+963", flagSymbol: "🇸🇾", languageCode: "ar_SY"),
    Country(countryName: "Taiwan", countryCode: "+886", flagSymbol: "🇹🇼", languageCode: "zh_TW"),
    Country(countryName: "Tajikistan", countryCode: "+992", flagSymbol: "🇹🇯", languageCode: "tg_TJ"),
    Country(countryName: "Tanzania", countryCode: "+255", flagSymbol: "🇹🇿", languageCode: "sw_TZ"),
    Country(countryName: "Thailand", countryCode: "+66", flagSymbol: "🇹🇭", languageCode: "th_TH"),
    Country(countryName: "Timor-Leste", countryCode: "+670", flagSymbol: "🇹🇱", languageCode: "pt_TL"),
    Country(countryName: "Togo", countryCode: "+228", flagSymbol: "🇹🇬", languageCode: "fr_TG"),
    Country(countryName: "Tokelau", countryCode: "+690", flagSymbol: "🇹🇰", languageCode: "en_TK"),
    Country(countryName: "Tonga", countryCode: "+676", flagSymbol: "🇹🇴", languageCode: "en_TO"),
    Country(countryName: "Trinidad and Tobago", countryCode: "+1-868", flagSymbol: "🇹🇹", languageCode: "en_TT"),
    Country(countryName: "Tunisia", countryCode: "+216", flagSymbol: "🇹🇳", languageCode: "ar_TN"),
    Country(countryName: "Turkey", countryCode: "+90", flagSymbol: "🇹🇷", languageCode: "tr_TR"),
    Country(countryName: "Turkmenistan", countryCode: "+993", flagSymbol: "🇹🇲", languageCode: "tk_TM"),
    Country(countryName: "Turks and Caicos Islands", countryCode: "+1-649", flagSymbol: "🇹🇨", languageCode: "en_TC"),
    Country(countryName: "Tuvalu", countryCode: "+688", flagSymbol: "🇹🇻", languageCode: "en_TV"),
    Country(countryName: "Uganda", countryCode: "+256", flagSymbol: "🇺🇬", languageCode: "en_UG"),
    Country(countryName: "Ukraine", countryCode: "+380", flagSymbol: "🇺🇦", languageCode: "uk_UA"),
    Country(countryName: "United Arab Emirates", countryCode: "+971", flagSymbol: "🇦🇪", languageCode: "ar_AE"),
    Country(countryName: "United Kingdom", countryCode: "+44", flagSymbol: "🇬🇧", languageCode: "en_GB"),
    Country(countryName: "United States", countryCode: "+1", flagSymbol: "🇺🇸", languageCode: "en_US"),
    Country(countryName: "Uruguay", countryCode: "+598", flagSymbol: "🇺🇾", languageCode: "es_UY"),
    Country(countryName: "Uzbekistan", countryCode: "+998", flagSymbol: "🇺🇿", languageCode: "uz_UZ"),
    Country(countryName: "Vanuatu", countryCode: "+678", flagSymbol: "🇻🇺", languageCode: "bi_VU"),
    Country(countryName: "Vatican City", countryCode: "+379", flagSymbol: "🇻🇦", languageCode: "la_VA"),
    Country(countryName: "Venezuela", countryCode: "+58", flagSymbol: "🇻🇪", languageCode: "es_VE"),
    Country(countryName: "Vietnam", countryCode: "+84", flagSymbol: "🇻🇳", languageCode: "vi_VN"),
    Country(countryName: "Wallis and Futuna", countryCode: "+681", flagSymbol: "🇼🇫", languageCode: "fr_WF"),
    Country(countryName: "Yemen", countryCode: "+967", flagSymbol: "🇾🇪", languageCode: "ar_YE"),
    Country(countryName: "Zambia", countryCode: "+260", flagSymbol: "🇿🇲", languageCode: "en_ZM"),
    Country(countryName: "Zimbabwe", countryCode: "+263", flagSymbol: "🇿🇼", languageCode: "en_ZW")
]
