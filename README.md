# Cloudtips SDK for iOS 

Cloudtips SDK позволяет интегрировать прием чаевых в мобильные приложение для платформы iOS.

### Требования
Для работы Cloudtips SDK необходим iOS версии 11.0 и выше.

### Подключение
Для подключения SDK мы рекомендуем использовать Cocoa Pods. Для корректной работы понадобится Cloudpayments SDK. Добавьте в файл Podfile зависимости:

```
pod 'Cloudtips', :git => "https://github.com/cloudpayments/CloudTips-SDK-iOS", :branch => "master"
pod 'Cloudpayments', :git => "https://github.com/cloudpayments/CloudPayments-SDK-iOS", :branch => "master"
pod 'CloudpaymentsNetworking', :git => "https://github.com/cloudpayments/CloudPayments-SDK-iOS", :branch => "master"
```

### Структура проекта:

* **demo** - Пример реализации приложения с использованием SDK
* **sdk** - Исходный код SDK

### Использование

1) Создайте объект TipsConfiguration, передайте в него номер телефона в формате +7********** и имя пользователя (если пользователя с таким номером телефона нет в системе Cloudtips, то будет зарегистрирован новый пользователь с этим именем)

Если вы являетесь партнером CloudTips, передайте в конфигурацию id партнера
```
let configuration = TipsConfiguration.init(phoneNumber: "+79001234567", userName: "Walter WWhite", partner: "partner_id")

//или

let configuration = TipsConfiguration.init(phoneNumber: "+" + text, userName: "Cloudtips demo user", partner: "ctdemo", testMode: true) //Если необходимо включить режим тестирования
```

2) Для возможности оплаты с Apple Pay передайте в конфигурацию ваш Apple Pay merchant id.

```
configuration.setApplePayMerchantId("merchant.ru.cloudpayments")
```

3) Для изменения цвета navigation бара и цвета крестика задайте значения

```
configuration.navigationBackgroundColor = .white
configuration.navigationTintColor = .blue
```

4) Вызовите TipsViewController внутри вашего контроллера

```
TipsViewController.present(with: configuration, from: self)
```

### Поддержка

По возникающим вопросам техничечкого характера обращайтесь на support@cloudpayments.ru
