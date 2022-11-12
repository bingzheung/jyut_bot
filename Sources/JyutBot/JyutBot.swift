import Foundation
import TelegramBotSDK

@main
public struct JyutBot {
        public static func main() {
                let token = readToken(from: "TELEGRAM_JYUT_BOT_TOKEN")
                let bot = TelegramBot(token: token)

                let controller = BotController(bot: bot)

                let router = Router(bot: bot)
                router["help"] = controller.help
                router["start"] = controller.help
                router["app"] = controller.app
                router["ios"] = controller.app
                router.unmatched = controller.help

                while let update = bot.nextUpdateSync() {
                        _ = try? router.process(update: update)
                }
        }
}


struct BotController {

        let bot: TelegramBot
        init(bot: TelegramBot) {
                self.bot = bot
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

                發 「/add +要加嘅詞條」，
                可向我哋建議添加粵拼詞條。

                發 「/feedback +你嘅反饋」，
                向 粵拼bot 提出反饋同建議
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
}

