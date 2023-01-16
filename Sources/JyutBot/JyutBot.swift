import Foundation
import Logging
import TelegramBotSDK

let logger: Logger = Logger(label: "io.ososo.jyutbot")

@main
public struct JyutBot {

        private static func placeholderLogger(_ text: String) { }

        public static func main() {
                let token = readToken(from: "TELEGRAM_JYUT_BOT_TOKEN")
                let bot = TelegramBot(token: token)
                bot.logger = placeholderLogger

                let controller = BotController(bot: bot)

                let router = Router(bot: bot)
                router["test"] = controller.test
                router["help"] = controller.help
                router["start"] = controller.help
                router["app"] = controller.app
                router["ios"] = controller.app
                router["ping", [.slashRequired]] = controller.ping
                router["caa", [.slashRequired]] = controller.ping
                router["chaa", [.slashRequired]] = controller.ping
                router["cha", [.slashRequired]] = controller.ping
                router.partialMatch = { context -> Bool in
                        return true
                }
                router.unmatched = controller.fallbackHandler

                while let update = bot.nextUpdateSync() {
                        let timeInterval = update.message?.date.distance(to: Date()) ?? 0
                        if timeInterval > 60 {
                                logger.notice("Drop outdated message.")
                        } else {
                                _ = try? router.process(update: update)
                        }
                }
        }
}


struct BotController {

        let bot: TelegramBot
        init(bot: TelegramBot) {
                self.bot = bot
        }

        func test(context: Context) -> Bool {
                context.respondPrivatelyAsync("absolutely", groupText: "absolutely")
                return true
        }

        func help(context: Context) -> Bool {
                guard let from = context.message?.from else { return false }

                let responseText: String = """
                你好， \(from.firstName)！
                我係一個粵拼bot，
                有咩可以幫到你？😃

                發「/ping +要查嘅字詞」，
                我就會回覆相應嘅粵拼。

                撳 /app 獲取
                粵拼輸入法 App Store 連結。
                """

                context.respondPrivatelyAsync(responseText, groupText: responseText)
                return true
        }

        func app(context: Context) -> Bool {

                let responseText: String = """
                前往 App Store 下載 iOS 粵拼輸入法App：
                https://apps.apple.com/hk/app/id1509367629
                """

                context.respondPrivatelyAsync(responseText, groupText: responseText)
                return true
        }

        func ping(context: Context) -> Bool {
                guard let messageText: String = context.message?.text else { return false }
                let filteredText: String = filteredCJKV(text: messageText)
                guard !filteredText.isEmpty else {
                        let tipText: String = "/ping +粵語字詞"
                        context.respondPrivatelyAsync(tipText, groupText: tipText)
                        return true
                }
                let responseText: String = {
                        let text: String = messageText.replacingOccurrences(of: "/ping", with: "", options: .anchored).trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .controlCharacters)
                        let matched = lookup(text: text)
                        if matched.romanizations.isEmpty {
                                let question: String = Array(repeating: "?", count: text.count).joined(separator: " ")
                                return text + "：\n" + question
                        } else {
                                let romanization: String = matched.romanizations.joined(separator: "\n")
                                return matched.text + "：\n" + romanization
                        }
                }()
                context.respondPrivatelyAsync(responseText, groupText: responseText)
                return true
        }

        func fallbackHandler(context: Context) -> Bool {

                // aka. (context.chatId ?? 0) > 0
                let isPrivateChat = context.message?.chat.type == .privateChat
                guard isPrivateChat else {
                        // logger.notice("Incomprehensible message from group chat.")
                        return true
                }

                let text: String = context.message?.text ?? ""
                guard !text.isEmpty else { return true }
                guard text != "?" && text != "？" else {
                        _ = help(context: context)
                        return true
                }

                let filteredText: String = filteredCJKV(text: text)
                guard !filteredText.isEmpty else {
                        // logger.notice("Incomprehensible message.")
                        context.respondPrivatelyAsync("我聽毋明 😥", groupText: "我聽毋明 😥")
                        // logger.info("Sent fallback() response back.")
                        return true
                }

                let responseText: String = {
                        let text: String = text.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .controlCharacters)
                        let matched = lookup(text: text)
                        if matched.romanizations.isEmpty {
                                let question: String = Array(repeating: "?", count: text.count).joined(separator: " ")
                                return text + "：\n" + question
                        } else {
                                let romanization: String = matched.romanizations.joined(separator: "\n")
                                return matched.text + "：\n" + romanization
                        }
                }()

                context.respondPrivatelyAsync(responseText, groupText: responseText)
                return true
        }


        // MARK: - Search Jyutpings

        private func filteredCJKV(text: String) -> String {
                return text.unicodeScalars.filter({ $0.properties.isIdeographic }).map({ String($0) }).joined()
        }
        private func ideographicBlocks(text: String) -> [(text: String, isIdeographic: Bool)] {
                var blocks: [(String, Bool)] = []
                var ideographicCache: String = ""
                var otherCache: String = ""
                var lastWasIdeographic: Bool = true
                for character in text {
                        let isIdeographic: Bool = character.unicodeScalars.first?.properties.isIdeographic ?? false
                        if isIdeographic {
                                if !lastWasIdeographic && !otherCache.isEmpty {
                                        let newElement: (String, Bool) = (otherCache, false)
                                        blocks.append(newElement)
                                        otherCache = ""
                                }
                                ideographicCache.append(character)
                                lastWasIdeographic = true
                        } else {
                                if lastWasIdeographic && !ideographicCache.isEmpty {
                                        let newElement: (String, Bool) = (ideographicCache, true)
                                        blocks.append(newElement)
                                        ideographicCache = ""
                                }
                                otherCache.append(character)
                                lastWasIdeographic = false
                        }
                }
                if !ideographicCache.isEmpty {
                        let newElement: (String, Bool) = (ideographicCache, true)
                        blocks.append(newElement)
                } else if !otherCache.isEmpty {
                        let newElement: (String, Bool) = (otherCache, false)
                        blocks.append(newElement)
                }
                return blocks
        }
        private func lookup(text: String) -> (text: String, romanizations: [String]) {
                let filtered: String = filteredCJKV(text: text)
                let search = Lookup.search(for: filtered)
                guard filtered != text else { return search }
                guard !(filtered.isEmpty) else { return search }
                let transformed = ideographicBlocks(text: text)
                var handledCount: Int = 0
                var combinedText: String = ""
                for item in transformed {
                        if item.isIdeographic {
                                let tail = search.text.dropFirst(handledCount)
                                let suffixCount = tail.count - item.text.count
                                let selected = tail.dropLast(suffixCount)
                                combinedText += selected
                                handledCount += item.text.count
                        } else {
                                combinedText += item.text
                        }
                }
                let combinedRomanizations = search.romanizations.map { romanization -> String in
                        let syllables: [String] = romanization.components(separatedBy: " ")
                        var index: Int = 0
                        var newRomanization: String = ""
                        var lastWasIdeographic: Bool = false
                        for character in text {
                                let isIdeographic: Bool = character.unicodeScalars.first?.properties.isIdeographic ?? false
                                if isIdeographic {
                                        newRomanization += (syllables[index] + " ")
                                        index += 1
                                        lastWasIdeographic = true
                                } else {
                                        if lastWasIdeographic {
                                                newRomanization = String(newRomanization.dropLast())
                                        }
                                        newRomanization.append(character)
                                        lastWasIdeographic = false
                                }
                        }
                        return newRomanization.trimmingCharacters(in: .whitespaces)
                }
                return (combinedText, combinedRomanizations)
        }
}

