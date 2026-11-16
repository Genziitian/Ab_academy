import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_text_styles.dart';
import 'strings.dart';

/// The app's two languages. Saved on the device; the first launch follows
/// the phone (Hindi phones open in Hindi).
enum AppLang { en, hi }

const _prefsKey = 'ab_lang';

/// Read once in `main()` before the first frame, so the app never flashes the
/// wrong language.
Future<AppLang> loadSavedLang() async {
  try {
    final saved = (await SharedPreferences.getInstance()).getString(_prefsKey);
    if (saved == 'hi') return AppLang.hi;
    if (saved == 'en') return AppLang.en;
  } catch (_) {
    // Storage unavailable: fall through to the phone's language.
  }
  return PlatformDispatcher.instance.locale.languageCode == 'hi' ? AppLang.hi : AppLang.en;
}

/// Overridden in `main()` with the saved language.
final initialLangProvider = Provider<AppLang>((_) => AppLang.en);

final langProvider = NotifierProvider<LangNotifier, AppLang>(LangNotifier.new);

class LangNotifier extends Notifier<AppLang> {
  @override
  AppLang build() {
    final lang = ref.watch(initialLangProvider);
    applyLang(lang);
    return lang;
  }

  Future<void> set(AppLang lang) async {
    if (lang == state) return;
    applyLang(lang);
    state = lang;
    try {
      await (await SharedPreferences.getInstance()).setString(_prefsKey, lang.name);
    } catch (_) {
      // Not saved; the choice still applies for this session.
    }
  }
}

/// Points the strings and type styles at [lang].
void applyLang(AppLang lang) {
  L10n.current = S(hindi: lang == AppLang.hi);
  AppText.hindi = lang == AppLang.hi;
}

/// Rebuilds every widget under [context] so text and type styles that were
/// read before the switch pick up the new language. State is kept.
void rebuildAll(BuildContext context) {
  void mark(Element el) {
    el.markNeedsBuild();
    el.visitChildren(mark);
  }

  (context as Element).visitChildren(mark);
}
