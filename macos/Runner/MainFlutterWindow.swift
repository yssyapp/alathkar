import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    // عنوان النافذة كان يظهر "athkari" (اسم مشروع Xcode التقني من القالب
    // الافتراضي) لأن سمة title في MainMenu.xib تحمل نص العنصر النائب
    // "APP_NAME" الذي لا يُستبدل تلقائياً. الاسم التقني/البرمجي للمشروع
    // (alathkar) يبقى للأغراض الداخلية فقط (اسم المجلد، Bundle ID)، أما كل
    // ما يظهر للمستخدم في الواجهة — بما فيها عنوان النافذة هنا — فبالعربي
    // "الأذكار"، تماشياً مع بقية التطبيق. نضبطه صراحةً بعد
    // super.awakeFromNib() حتى لا يُستبدل بقيمة الـ xib.
    self.title = "الأذكار"
  }
}
