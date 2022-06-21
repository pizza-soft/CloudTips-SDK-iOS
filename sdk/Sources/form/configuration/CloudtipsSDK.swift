//
//  Cloudtips.swift
//  Cloudtips
//
//  Created by Ivan Rysev on 06.05.2022.
//

import Foundation
import YandexPaySDK

final public class CloudtipsSDK {

    private(set) static var yandexPayAppId: String?
    private static var initialized: Bool = false

    public static var instance: CloudtipsSDK = {
        guard initialized == true else {
            fatalError("CloudtipsSDK should be initialized using initialize(yandexPayAppId:sandboxMode:) method before use")
        }
        return CloudtipsSDK()
    }()

    public static func initialize(yandexPayAppId: String?, sandboxMode: Bool? = false) throws {
        Self.yandexPayAppId = yandexPayAppId

        let configuration = YandexPaySDKConfiguration(environment: (sandboxMode ?? false) ? .sandbox : .production)
        try YandexPaySDKApi.initialize(configuration: configuration)

        initialized = true
    }

    private init() {
        //configuration: TipsConfiguration, yandexPayAppId: String?
        //fatalError("Unable to initialize YandexPaySDKApi.")
    }

    final public func applicationWillEnterForeground() {
        if Self.yandexPayAppId != nil {
            YandexPaySDKApi.instance.applicationWillEnterForeground()
        }
    }

    final public func applicationDidBecomeActive() {
        if Self.yandexPayAppId != nil {
            YandexPaySDKApi.instance.applicationDidBecomeActive()
        }
    }

    final public func applicationDidReceiveOpen(_ url: URL, sourceApplication: String?) -> Bool {
        if Self.yandexPayAppId != nil {
            return YandexPaySDKApi.instance.applicationDidReceiveOpen(url, sourceApplication: sourceApplication)
        }
        return true
    }

    final public func applicationDidReceiveUserActivity(_ userActivity: NSUserActivity) -> Bool {
        if Self.yandexPayAppId != nil {
            return YandexPaySDKApi.instance.applicationDidReceiveUserActivity(userActivity)
        }
        return true
    }
}
